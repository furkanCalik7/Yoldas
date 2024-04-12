import logging
from typing import Annotated

from fastapi import APIRouter, Depends

from ..models import entity_models
from ..models.request_models import CallAccept, CallRequest, CallHangup
from ..models.response_models import CallAcceptResponse, CallRequestResponse
from ..services import call_manager, user_manager
from ..shared.constants import CallUserType

router = APIRouter(prefix="/calls", )

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


@router.post("/call")
async def call_request(_call_request: CallRequest,
                       current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    phone_number = current_user["phone_number"]
    call_id = call_manager.create_call(phone_number, _call_request.category)
    # TODO: after the notification and make call mechnisim implemented, use this
    # user_manager.start_call(_call_request, current_user)
    return CallRequestResponse(
        call_id=call_id,
        callee_name="tsetj"
    )


@router.post("/call/accept")
async def call_accept(_call_accept: CallAccept,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_accept.call_id, current_user["phone_number"]
    logger.info(f"Call accept with call_id {call_id} and user_id {phone_number}")
    signal = call_manager.get_signal(call_id, CallUserType.CALLER)
    call_manager.accept_call(call_id, phone_number)
    return CallAcceptResponse(
        call_id=call_id,
        caller_name="test_caller_name",
        signal=signal
    )


@router.post("/call/hangup")
async def call_hangup(_call_hangup: CallHangup,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    logger.info(f"Call hangup with call_id {_call_hangup.call_id} and user_id {current_user['phone_number']}")
    call_manager.hangup_call(_call_hangup)