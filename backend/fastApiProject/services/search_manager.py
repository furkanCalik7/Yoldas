import threading
from typing import Optional

from pydantic import BaseModel

from fastApiProject.models.entity_models import User
from fastApiProject.services import notification_manager
from fastApiProject.shared.constants import SearchStatus

CALL_TIMEOUT = 10  # seconds


class Candidate(BaseModel):
    phone_number: str
    status: SearchStatus


class SearchSession(BaseModel):
    call_id: str
    candidates: list[Candidate]
    retry_count: Optional[int] = 0

    def get_candidate(self, phone_number) -> Candidate:
        for candidate in self.candidates:
            if candidate.phone_number == phone_number:
                return candidate


def handle_call_timeout(call_id: str, candidate: Candidate):
    candidate.status = SearchStatus.NO_RESPONSE
    search_manager.checkRetry(call_id)


class SearchManager:
    def __init__(self):
        self.__active_search_sessions: {str, SearchSession} = {}

    def get_active_search_session(self, call_id: str) -> SearchSession:
        return self.__active_search_sessions[call_id]

    def init_new_search_session(self, call_id: str, candidate_phone_numbers: list[User]):
        search_session = SearchSession(
            call_id=call_id,
            candidates=[Candidate(
                phone_number=candidate_phone_number.phone_number,
                status=SearchStatus.INITIALIZED
            ) for candidate_phone_number in candidate_phone_numbers]
        )
        self.__active_search_sessions[call_id] = search_session

    def start_search_session(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        for candidate in search_session.candidates:
            notification_manager.send_notification_to_user(candidate.phone_number, search_session.call_id)
            candidate.status = SearchStatus.PROCESSING
            threading.Timer(CALL_TIMEOUT, handle_call_timeout, [search_session.call_id, candidate]).start()

    def accept_search_session(self, call_id: str, candidate_phone_number: str):
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.ACCEPTTED

    def reject_search_session(self, call_id: str, candidate_phone_number: str):
        search_session = self.__active_search_sessions[call_id]
        candidate = search_session.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.REJECTED

    def delete_search_session(self, call_id: str):
        # delete call id key in dictionary
        self.__active_search_sessions.pop(call_id)

    def checkRetry(self, call_id: str):
        search_session = self.__active_search_sessions[call_id]
        should_try_again = False
        for candidate in search_session.candidates:
            if not (candidate.status == SearchStatus.PROCESSING or candidate.status == SearchStatus.ACCEPTTED):
                should_try_again = True
        if not should_try_again:
            return
        ## TODO: Find new candidates excluded tried ones


search_manager = SearchManager()
