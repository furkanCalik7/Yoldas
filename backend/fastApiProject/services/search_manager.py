import logging
import threading
from typing import Optional

from icecream import ic
from pydantic import BaseModel

from fastApiProject.config import CALL_TIMEOUT, NUMBER_OF_CALLS
from fastApiProject.dao import matcher_dao
from fastApiProject.models.entity_models import User
from fastApiProject.models.request_models import CallRequest
from fastApiProject.services import notification_manager
from fastApiProject.shared.constants import SearchStatus

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


class Candidate(BaseModel):
    phone_number: str
    status: SearchStatus


class SearchSession(BaseModel):
    caller: User
    candidates: list[Candidate]
    retry_count: Optional[int] = 0
    call_request: CallRequest
    excluded_candidates: list[Candidate] = []

    def get_candidate(self, phone_number) -> Candidate:
        for candidate in self.candidates:
            if candidate.phone_number == phone_number:
                return candidate


def handle_call_timeout(call_id: str, candidate: Candidate):
    candidate.status = SearchStatus.NO_RESPONSE
    logging.info(f"call_timeout for {call_id} and: {candidate}")
    if search_manager.check_search_session_failed(call_id):
        search_manager.retry_search_session(call_id)


class SearchManager:
    def __init__(self):
        self.__active_search_sessions: {str, SearchSession} = {}

    def get_active_search_session(self, call_id: str) -> SearchSession:
        return self.__active_search_sessions[call_id]

    def init_new_search_session(self, call_id: str, candidate_users: list[User], caller,
                                call_request: CallRequest):
        search_session = SearchSession(
            caller=caller,
            call_request=call_request,
            candidates=[Candidate(
                phone_number=candidate_user.phone_number,
                status=SearchStatus.INITIALIZED
            ) for candidate_user in candidate_users]
        )
        ic()
        ic(f"selected candidates: {search_session.candidates}")
        self.__active_search_sessions[call_id] = search_session

    def start_search_session(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        ic(f"search session: {search_session}")
        for candidate in search_session.candidates:
            notification_manager.call_user_phone(candidate.phone_number, call_id)
            candidate.status = SearchStatus.PROCESSING
            threading.Timer(CALL_TIMEOUT, handle_call_timeout, [call_id, candidate]).start()

    def check_search_session_is_already_accepted(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        is_accepted = False

        for candidate in search_session.candidates:
            if candidate == SearchStatus.ACCEPTED:
                is_accepted = True
        return is_accepted

    def accept_search_session(self, call_id: str, candidate_phone_number: str):
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        is_accepted = self.check_search_session_is_already_accepted(call_id)
        if is_accepted:
            candidate.status = SearchStatus.ACCEPTED
        return is_accepted

    def reject_search_session(self, call_id: str, candidate_phone_number: str):
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.REJECTED

    def delete_search_session(self, call_id: str):
        self.__active_search_sessions.pop(call_id)

    def check_search_session_failed(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        should_try_again = False
        for candidate in search_session.candidates:
            if not (candidate.status == SearchStatus.PROCESSING or candidate.status == SearchStatus.ACCEPTED):
                should_try_again = True
        return should_try_again

    def retry_search_session(self, call_id: str):
        if not self.check_search_session_failed(call_id):
            return
        search_session = self.__active_search_sessions[call_id]
        search_session.retry_count += 1
        search_session.excluded_candidates.append(search_session.candidates)
        excluded_candidates_phone_numbers = [candidate.phone_number for candidate in search_session.candidates]
        new_candidate_users = matcher_dao.find_potential_callees(
            search_session.call_request,
            search_session.caller,
            num_of_calls=(search_session.retry_count + 1) * NUMBER_OF_CALLS,
            excluded_user_list=excluded_candidates_phone_numbers
        )

        search_session.candidates = [Candidate(
            phone_number=candidate_users.phone_number,
            status=SearchStatus.INITIALIZED
        ) for candidate_users in new_candidate_users]
        self.start_search_session(call_id)


search_manager = SearchManager()
