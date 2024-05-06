import logging

from icecream import ic

from .search_manager import search_manager
from ..dao import call_dao
from ..dao import matcher_dao
from ..models.entity_models import Call, CallUser, Signal
from ..models.request_models import CallHangup, CallRequest
from ..shared.constants import CallUserType, CallStatus

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def create_call(call_request: CallRequest, user) -> str:
    call = Call(
        caller=CallUser(
            name=user["name"],
            phone_number=user["phone_number"],
        ),
        isQuickCall=call_request.isQuickCall,
        category=call_request.category,
        isConsultancyCall=call_request.isConsultancyCall,
    )
    call_id = call_dao.register_call(call)
    search_manager.init_new_search_session(call_id, user, call_request)
    return call_id


def start_search_session(call_id, call_request: CallRequest, user) -> str:
    # potential_callees = matcher_dao.find_potential_callees(call_request, user)
    potential_callees = ["+905555555555", "+905333333333"]
    search_session = search_manager.get_search_session_by_call_id(call_id)
    search_session.set_candidates(potential_callees)
    search_manager.start_search_session(search_session)


def accept_call(call_id: str, user):
    search_session = search_manager.get_search_session_by_call_id(call_id)
    if search_session is not None:
        search_manager.accept_search_session(search_session, user["phone_number"])
        callee = CallUser(
            name=user["name"],
            phone_number=user["phone_number"],
        )
        call_dao.start_call(call_id, callee)
        search_manager.delete_session(search_session)
        return True
    else:
        return False


def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    return call_dao.get_signal(call_id, call_user_type)


def hangup_call(call_hangup: CallHangup):
    call_dao.hangup_call(call_hangup.call_id)


def reject_call(call_id: str, phone_number: str):
    search_session = search_manager.get_search_session_by_call_id(call_id)

    if search_session is not None:
        search_manager.reject_call(search_session, phone_number)
        return True
    return False


def cancel_call(call_id):
    search_session = search_manager.get_search_session_by_call_id(call_id)
    return search_manager.cancel_session(search_session)
