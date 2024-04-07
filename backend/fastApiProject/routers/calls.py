import logging
from typing import Annotated

from fastapi import APIRouter, Depends

from ..models import entity_models
from ..models.request_models import CallRequest, CallAccept
from ..services import call_manager, user_manager
from ..services.call_manager import get_signal, accept_call
from ..shared.constants import CallUserType

router = APIRouter(prefix="/calls", )

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


@router.post("/call")
async def call_reques(_call_request: CallRequest,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_type, phone_number = _call_request.type, current_user["phone_number"]
    logger.info(f"call with call_request {_call_request} and user_id {phone_number} called")
    call_id = call_manager.create_call(phone_number, call_type)
    return {"call_id": call_id}


@router.post("/call/accept")
async def call_accept(_call_accept: CallAccept,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_accept.call_id, current_user["phone_number"]
    logger.info(f"Call accept with call_id {call_id} and user_id {phone_number}")
    signal = get_signal(call_id, CallUserType.CALLER)
    accept_call(call_id, phone_number)
    return {"offer": signal}
