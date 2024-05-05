import logging
from typing import Annotated

from fastapi import APIRouter, Depends, Path

from ..models import entity_models
from ..models.request_models import CallAccept, CallRequest, CallHangup, CallReject, CallCancel
from ..models.response_models import CallAcceptDetailsResponse, CallRequestResponse, CallAcceptResponse, \
    CallRejectResponse
from ..services import call_manager, user_manager
from ..shared.constants import CallUserType

router = APIRouter(prefix="/calls", )

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


@router.post("/call")
async def call_request(_call_request: CallRequest,
                       current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id = call_manager.create_call(_call_request, current_user)
    return CallRequestResponse(
        call_id=call_id
    )


@router.post("/call/{call_id}/search-session")
async def start_search_session(
        call_id: str,
        _call_request: CallRequest,
        current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]
):
    call_manager.start_search_session(call_id, _call_request, current_user)


@router.post("/call/accept")
async def call_accept(_call_accept: CallAccept,
                      current_user: Annotated[
                          entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_accept.call_id, current_user["phone_number"]
    logger.info(f"Call accept with call_id {call_id} and user_id {phone_number}")
    is_accepted = call_manager.accept_call(call_id, current_user)
    return CallAcceptResponse(
        is_accepted=is_accepted
    )


@router.post("/call/accept_details")
async def call_accept_details(_call_accept: CallAccept,
                              current_user: Annotated[
                                  entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_accept.call_id, current_user["phone_number"]
    logger.info(f"Call accept with call_id {call_id} and user_id {phone_number}")
    signal = call_manager.get_signal(call_id, CallUserType.CALLER)
    # TODO: remove caller name and signal here
    return CallAcceptDetailsResponse(
        call_id=call_id,
        caller_name="to be removed",
        signal=signal
    )


@router.post("/call/reject")
async def call_reject(_call_reject: CallReject,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_reject.call_id, current_user["phone_number"]
    logger.info(f"Call reject with call_id {call_id} and user_id {phone_number}")
    is_rejected = call_manager.reject_call(call_id, phone_number)
    return CallRejectResponse(
        is_rejected=is_rejected
    )


@router.post("/call/cancel")
async def search_cancel(_call_cancel: CallCancel,
                        current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    call_id, phone_number = _call_cancel.call_id, current_user["phone_number"]
    logger.info(f"Search cancel with call_id {call_id} and user_id {phone_number}")
    return call_manager.cancel_call(call_id)


# TODO: hangout does work right now
@router.post("/call/hangup")
async def call_hangup(_call_hangup: CallHangup,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    logger.info(f"Call hangup with call_id {_call_hangup.call_id} and user_id {current_user['phone_number']}")
    call_manager.hangup_call(_call_hangup)
