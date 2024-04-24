import logging

from .search_manager import search_manager
from ..dao import call_dao
from ..dao import matcher_dao
from ..models.entity_models import Call, CallUser, Signal
from ..models.request_models import CallHangup, CallRequest
from ..shared.constants import CallUserType

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
    # potential_callees = matcher_dao.find_potential_callees(call_request, user)
    potential_callees = ["+905444444444"]
    search_manager.init_new_search_session(call_id, potential_callees, user, call_request)
    search_manager.start_search_session(call_id)
    return call_id


def accept_call(call_id: str, user):
    is_accepted = search_manager.accept_search_session(call_id, user["phone_number"])
    if is_accepted:
        callee = CallUser(
            name=user["name"],
            phone_number=user["phone_number"],
        )
        call_dao.start_call(call_id, callee)
        search_manager.delete_session(call_id)
    return is_accepted


def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    return call_dao.get_signal(call_id, call_user_type)


def hangup_call(call_hangup: CallHangup):
    call_dao.hangup_call(call_hangup.call_id)


def reject_call(call_id: str, phone_number: str) -> None:
    search_manager.reject_search_session(call_id, phone_number)


def cancel_call(call_id):
    search_manager.cancel_session(call_id)
