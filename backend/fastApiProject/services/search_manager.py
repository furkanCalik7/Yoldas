import logging
import threading
from typing import Optional

from icecream import ic
from pydantic import BaseModel

from fastApiProject.config import CALL_TIMEOUT, NUMBER_OF_CALLS
from fastApiProject.dao import matcher_dao, call_dao
from fastApiProject.models.entity_models import User
from fastApiProject.models.request_models import CallRequest
from fastApiProject.services import notification_manager
from fastApiProject.shared.constants import SearchStatus, CallStatus

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


# TODO: scheduler - (garbage collecter) her 10 dakikada bir active_session temizleyecek - birekebiliyor

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
    if not (candidate.status == SearchStatus.ACCEPTED or candidate.status == SearchStatus.REJECTED):
        candidate.status = SearchStatus.NO_RESPONSE
    logging.info(f"call_timeout for {call_id} and: {candidate}")
    if search_manager.is_session_valid(call_id) and search_manager.is_search_session_failed(call_id):
        ic(f"refreshed: {search_manager.is_search_session_failed(call_id)}")
        search_manager.retry_search_session(call_id)


class SearchManager:
    def __init__(self):
        self.__active_search_sessions: {str, SearchSession} = {}

    def get_active_search_session(self, call_id: str) -> SearchSession:
        return self.__active_search_sessions[call_id]

    def init_new_search_session(self, call_id: str, candidate_users_phone_numbers: list[str], caller,
                                call_request: CallRequest):
        search_session = SearchSession(
            caller=caller,
            call_request=call_request,
            candidates=[Candidate(
                phone_number=candidate_user_phone_number,
                status=SearchStatus.INITIALIZED
            ) for candidate_user_phone_number in candidate_users_phone_numbers]
        )
        self.__active_search_sessions[call_id] = search_session

    def start_search_session(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        ic(f"New search session with candidates: {search_session.candidates}")
        for candidate in search_session.candidates:
            notification_manager.call_user_phone(candidate.phone_number, call_id)
            candidate.status = SearchStatus.PROCESSING
            threading.Timer(CALL_TIMEOUT, handle_call_timeout, [call_id, candidate]).start()

    def is_search_session_is_already_accepted(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        is_accepted = False

        for candidate in search_session.candidates:
            if candidate == SearchStatus.ACCEPTED:
                is_accepted = True
        return is_accepted

    def accept_search_session(self, call_id: str, candidate_phone_number: str):
        if not self.is_session_valid(call_id):
            return False
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        is_accepted = self.is_search_session_is_already_accepted(call_id)
        if not is_accepted:
            candidate.status = SearchStatus.ACCEPTED
        return not is_accepted

    def reject_search_session(self, call_id: str, candidate_phone_number: str):
        if not self.is_session_valid(call_id):
            return
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.REJECTED

    def is_session_valid(self, call_id: str):
        return call_id in self.__active_search_sessions

    # This might be triggered before session is initialized.
    def cancel_session(self, call_id: str):
        call_dao.set_call_status(call_id, CallStatus.CANCELLED)
        self.delete_session(call_id)
        ic(self.__active_search_sessions)

    def delete_session(self, call_id: str):
        self.__active_search_sessions.pop(call_id)

    def is_search_session_failed(self, call_id: str):
        if not self.is_session_valid(call_id):
            return
        search_session = self.__active_search_sessions[call_id]
        is_failed = True
        for candidate in search_session.candidates:
            if candidate.status == SearchStatus.PROCESSING or candidate.status == SearchStatus.ACCEPTED:
                is_failed = False
        return is_failed

    def retry_search_session(self, call_id: str):
        if not self.is_session_valid(call_id):
            return
        search_session = self.__active_search_sessions[call_id]
        search_session.retry_count += 1

        for candidate in search_session.candidates:
            search_session.excluded_candidates.append(candidate)
        excluded_candidates_phone_numbers = [candidate.phone_number for candidate in search_session.candidates]

        new_candidates_phone_numbers = matcher_dao.find_potential_callees(
            search_session.call_request,
            search_session.caller,
            num_of_calls=(search_session.retry_count + 1) * NUMBER_OF_CALLS,
            excluded_user_list=excluded_candidates_phone_numbers
        )
        if len(new_candidates_phone_numbers) == 0:
            call_dao.set_call_status(call_id, CallStatus.CALLEE_NOT_FOUND)
        else:
            search_session.candidates = [Candidate(
                phone_number=phone_number,
                status=SearchStatus.INITIALIZED
            ) for phone_number in new_candidates_phone_numbers]
            if self.is_session_valid(call_id):
                ...
                # self.start_search_session(call_id)


search_manager = SearchManager()
