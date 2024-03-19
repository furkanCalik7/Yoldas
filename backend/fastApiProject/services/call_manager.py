import json
import logging

from .socket_manager import SocketManager
from ..dao import call_dao
from ..dao.call_dao import register_callee, get_phone_number_from_call
from ..models.entity_models import Call, CallUser, Signal
from ..shared.constants import CallUserType

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def create_call(phone_number: str, call_type: str) -> dict:
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
    register_callee(call_id, callee)


def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    return call_dao.get_signal(call_id, call_user_type)

#
# async def emit_answer_to_caller(socket_manager: SocketManager, call_id: str, answer_signal: Signal) -> None:
#     caller_phone_number = get_phone_number_from_call(call_id, CallUserType.CALLER)
#     await socket_manager.send_message_to_user("answer_to_caller", caller_phone_number,
#                                               json.dumps({"signal": answer_signal}))
#
#
# def register_signal(call_id: str, call_user_type: CallUserType, signal_data: str):
#     signal = Signal.model_validate(signal_data)
#     update_signaling(call_id, call_user_type, signal)
#
#
# def register_ice_candidates_completed(call_id: str, call_user_type: CallUserType):
#     update_ice_candidates_completed(call_id, call_user_type)
#
#
# def register_ice_candidates(call_id: str, call_user_type: CallUserType, ice_candidate_data: str):
#     ice_candidate = IceCandidate.model_validate(ice_candidate_data)
#     update_ice_candidates(call_id, call_user_type, ice_candidate)