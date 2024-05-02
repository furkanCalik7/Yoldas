import logging

from fastApiProject.models.request_models import CallRequest
from fastApiProject.services.search_session_manager import SearchSession

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


# TODO: scheduler - (garbage collecter) her 10 dakikada bir active_session temizleyecek - birekebiliyor


class SearchManager:
    search_sessions: {str, SearchSession}

    def __init__(self):
        self.search_sessions = {}

    def get_search_session_by_call_id(self, call_id: str) -> SearchSession:
        return self.search_sessions[call_id]

    def init_new_search_session(self, call_id: str, caller,
                                call_request: CallRequest):
        search_session = SearchSession(call_id, caller,
                                       call_request)
        self.search_sessions[call_id] = search_session
        return search_session

    def start_search_session(self, search_session: SearchSession):
        search_session.start()

    def accept_search_session(self, search_session: SearchSession, candidate_phone_number: str):
        return search_session.add_task("accept_call", candidate_phone_number)

    def reject_call(self, search_session: SearchSession, candidate_phone_number: str):
        return search_session.add_task("reject_call", candidate_phone_number)

    # This might be triggered before session is initialized.
    def cancel_session(self, search_session: SearchSession):
        search_session.add_task("cancel")

    def delete_session(self, search_session: SearchSession):
        self.search_sessions.pop(search_session.call_id)

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
