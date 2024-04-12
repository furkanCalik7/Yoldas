from pydantic import BaseModel

from fastApiProject.models.entity_models import Signal


class CallRequestResponse(BaseModel):
    callee_name: str
    call_id: str


class CallAcceptResponse(BaseModel):
    caller_name: str
    call_id: str
    signal: Signal
