import logging
from time import sleep

from ..dao import call_dao
from ..models.entity_models import Call, CallUser, Signal
from ..models.request_models import CallHangup, CallRequest
from ..services import notification_manager
from ..shared.constants import CallUserType, CallStatus
from ..dao import matcher_dao

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def create_call(call_request: CallRequest, user) -> str:
    call = Call(
        caller=CallUser(
            phone_number=user["phone_number"],
        ),
        isQuickCall=call_request.isQuickCall,
        category=call_request.category,
        isConsultancyCall=call_request.isConsultancyCall,
    )
    call_id = call_dao.register_call(call)
    start_search_for_potential_callees(call_id, call_request, user)
    return call_id


def accept_call(call_id: str, callee_phone_number: str):
    callee = CallUser(
        phone_number=callee_phone_number,
    )
    call_dao.start_call(call_id, callee)


def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    return call_dao.get_signal(call_id, call_user_type)


def hangup_call(call_hangup: CallHangup):
    call_dao.hangup_call(call_hangup.call_id)


# Write a active call user management system for ringing the users
def start_search_for_potential_callees(call_id, call_request: CallRequest, user):
    potential_callees = matcher_dao.find_potential_callees(call_request, user)
    # TODO: To be removed
    potential_callees = ["+905425539143"]
    for potential_callee in potential_callees:
        call_status = call_dao.get_call_status(call_id)
        if call_status == CallStatus.IN_CALL:
            break
        make_call(call_id, potential_callee)
        # Sleep for a while
        sleep(2)


def make_call(call_id, user):
    notification_manager.send_notification_to_user(user, call_id)
