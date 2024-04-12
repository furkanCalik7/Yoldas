import logging

from ..dao import call_dao
from ..models.entity_models import Call, CallUser, Signal
from ..models.request_models import CallHangup
from ..shared.constants import CallUserType

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def create_call(phone_number: str, call_type: str) -> str:
    call = Call(
        caller=CallUser(
            phone_number=phone_number,
        ),
        call_category=call_type,
    )
    return call_dao.register_call(call)


def accept_call(call_id: str, callee_phone_number: str):
    callee = CallUser(
        phone_number=callee_phone_number
    )
    call_dao.start_call(call_id, callee)


def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    return call_dao.get_signal(call_id, call_user_type)


def hangup_call(call_hangup: CallHangup):
    call_dao.hangup_call(call_hangup.call_id)