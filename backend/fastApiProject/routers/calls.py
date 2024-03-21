import logging

from fastapi import APIRouter
from ..models.request_models import CallRequest, CallAccept
from ..services import call_manager
from ..services.call_manager import get_signal, accept_call
from ..shared.constants import CallUserType

router = APIRouter(prefix="/calls", )

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


# TODO: add security later
@router.post("/call")
async def call_reques(_call_request: CallRequest):
    call_type, phone_number = _call_request.type, _call_request.phone_number
    logger.info(f"call with call_request {_call_request} and user_id {phone_number} called")
    call_id = call_manager.create_call(phone_number, call_type)
    return {"call_id": call_id}


# TODO: change to bearer token
@router.post("/call/accept")
async def call_accept(_call_accept: CallAccept):
    call_id, phone_number = _call_accept.call_id, _call_accept.phone_number
    logger.info(f"Call accept with call_id {call_id} and user_id {phone_number}")
    signal = get_signal(call_id, CallUserType.CALLER)
    accept_call(call_id, phone_number)
    return {"offer": signal}
