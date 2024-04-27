import logging
import queue
import threading
from typing import Optional

from icecream import ic
from pydantic import BaseModel

from fastApiProject.config import CALL_TIMEOUT, NUMBER_OF_CALLS
from fastApiProject.dao import matcher_dao, call_dao
from fastApiProject.models.entity_models import User, Candidate
from fastApiProject.models.request_models import CallRequest
from fastApiProject.services import notification_manager
from fastApiProject.services.search_session_manager import SearchSession
from fastApiProject.shared.constants import SearchStatus, CallStatus

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


# TODO: scheduler - (garbage collecter) her 10 dakikada bir active_session temizleyecek - birekebiliyor


class SearchManager:
    search_sessions: list[SearchSession]

    def __init__(self):
        self.search_sessions = []

    def get_search_session_by_call_id(self, call_id: str) -> SearchSession:
        for session in self.search_sessions:
            if session.call_id == call_id:
                logger.info("search session found")
                return session

    def init_new_search_session(self, call_id: str, candidate_users_phone_numbers: list[str], caller,
                                call_request: CallRequest):
        logger.info("Search session initialized")
        search_session = SearchSession(call_id, candidate_users_phone_numbers, caller,
                                       call_request)
        self.search_sessions.append(search_session)

    def start_search_session(self, search_session: SearchSession):
        search_session.start()

    def accept_search_session(self, search_session: SearchSession, candidate_phone_number: str):
        return search_session.add_task("accept_call", candidate_phone_number)

    def reject_call(self, search_session: SearchSession, candidate_phone_number: str):
        return search_session.add_task("reject_call", candidate_phone_number)

    # This might be triggered before session is initialized.
    def cancel_session(self, search_session: SearchSession):
        search_session.add_task("start_call")

    def delete_session(self, search_session: SearchSession):
        self.search_sessions.remove(search_session)

    # def retry_search_session(self, call_id: str):
    #     if not self.is_session_valid(call_id):
    #         return
    #     search_session = self.__active_search_sessions[call_id]
    #     search_session.retry_count += 1
    #
    #     for candidate in search_session.candidates:
    #         search_session.excluded_candidates.append(candidate)
    #     excluded_candidates_phone_numbers = [candidate.phone_number for candidate in search_session.candidates]
    #
    #     new_candidates_phone_numbers = matcher_dao.find_potential_callees(
    #         search_session.call_request,
    #         search_session.caller,
    #         num_of_calls=(search_session.retry_count + 1) * NUMBER_OF_CALLS,
    #         excluded_user_list=excluded_candidates_phone_numbers
    #     )
    #     if len(new_candidates_phone_numbers) == 0:
    #         call_dao.set_call_status(call_id, CallStatus.CALLEE_NOT_FOUND)
    #     else:
    #         search_session.candidates = [Candidate(
    #             phone_number=phone_number,
    #             status=SearchStatus.INITIALIZED
    #         ) for phone_number in new_candidates_phone_numbers]
    #         if self.is_session_valid(call_id):
    #             ...
    #             # self.start_search_session(call_id)


search_manager = SearchManager()
