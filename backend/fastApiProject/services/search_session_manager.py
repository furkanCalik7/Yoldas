import logging
import queue
import threading
from typing import Optional

from icecream import ic

from fastApiProject.config import CALL_TIMEOUT
from fastApiProject.dao import call_dao
from fastApiProject.models.entity_models import User, Candidate
from fastApiProject.models.request_models import CallRequest
from fastApiProject.services import notification_manager
from fastApiProject.shared.constants import SearchStatus, CallStatus

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


# TODO: scheduler - (garbage collecter) her 10 dakikada bir active_session temizleyecek - birekebiliyor
class SearchSession:
    caller: User
    candidates: list[Candidate]
    retry_count: Optional[int] = 0
    call_request: CallRequest
    excluded_candidates: list[Candidate] = []
    status: CallStatus
    call_id: str
    task_queue: queue.Queue

    def get_candidate(self, phone_number) -> Candidate:
        for candidate in self.candidates:
            if candidate.phone_number == phone_number:
                return candidate

    def __init__(self, call_id: str, candidate_users_phone_numbers: list[str], caller,
                 call_request: CallRequest):
        self.caller = caller
        self.call_request = call_request
        self.candidates = [Candidate(
            phone_number=candidate_user_phone_number,
            status=SearchStatus.INITIALIZED
        ) for candidate_user_phone_number in candidate_users_phone_numbers]
        self.call_id = call_id
        self.task_queue = queue.Queue(maxsize=100)
        self.status = CallStatus.INITIALIZED
        # Start worker thread
        self.worker_thread = threading.Thread(target=self.perform_tasks)

    def start(self):
        if self.status != CallStatus.INITIALIZED:
            logger.error(f"session with call_id {self.call_id} is not initialized, can't be started")
            return
        ic(f"New search session with candidates: {self.candidates}")
        for candidate in self.candidates:
            notification_manager.call_user_phone(candidate.phone_number, self.call_id)
            candidate.status = SearchStatus.PROCESSING
            threading.Timer(CALL_TIMEOUT, self.handle_call_timeout, [candidate]).start()
        self.status = CallStatus.SEARCHING_FOR_CALLEE
        self.worker_thread.start()

    def accept_call(self, candidate_phone_number: str):
        if self.status != CallStatus.SEARCHING_FOR_CALLEE:
            logger.error(f"session with call_id {self.call_id} is not in searching state can't be accepted")
            return

        candidate = self.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.ACCEPTED
        self.status = CallStatus.IN_CALL
        return True

    def reject_call(self, candidate_phone_number: str):
        if self.status != CallStatus.SEARCHING_FOR_CALLEE:
            logger.error(f"session with call_id {self.call_id} is not started, can't be accepted")
            return
        candidate = self.get_candidate(candidate_phone_number)
        candidate.status = SearchStatus.REJECTED

    def cancel(self):
        call_dao.set_call_status(self.call_id, CallStatus.CANCELLED)
        self.status = CallStatus.CANCELLED

    # TODO rewrite this method after implementing retry mechanism
    def is_failed(self):
        if self.status != CallStatus.IN_CALL or self.status != CallStatus.SEARCHING_FOR_CALLEE:
            return True

        is_failed = True
        for candidate in self.candidates:
            if candidate.status == SearchStatus.PROCESSING or candidate.status == SearchStatus.ACCEPTED:
                is_failed = False
        return is_failed

    def perform_tasks(self):
        while True:
            task = self.task_queue.get()
            if task is None:
                break

            task_type, *args = task
            logger.info(f'Worker is processing task: {task_type}')
            if task_type == 'accept_call':
                self.accept_call(*args)
            elif task_type == 'reject_call':
                self.reject_call(*args)
            elif task_type == 'cancel':
                self.cancel()
            elif task_type == 'start_call':
                self.start()
            else:
                logger.error(f"Unknown task: {task}")

    def add_task(self, task_type, *args):
        self.task_queue.put((task_type, *args))

    def handle_call_timeout(self, candidate: Candidate):
        if not (candidate.status == SearchStatus.ACCEPTED or candidate.status == SearchStatus.REJECTED):
            candidate.status = SearchStatus.NO_RESPONSE
        logging.info(f"call_timeout for {self.call_id} and: {candidate}")
        # TODO  rewrite retry logic
        # if search_manager.is_session_valid(call_id) and search_manager.is_search_session_failed(call_id):
        #     ic(f"refreshed: {search_manager.is_search_session_failed(call_id)}")
        #     search_manager.retry_search_session(call_id)
