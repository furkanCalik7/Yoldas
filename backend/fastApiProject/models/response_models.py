from typing import Optional

from pydantic import BaseModel

from fastApiProject.models.entity_models import Signal


class CallRequestResponse(BaseModel):
    call_id: str


class CallAcceptDetailsResponse(BaseModel):
    caller_name: Optional[str]
    call_id: Optional[str]
    signal: Optional[Signal]


class CallAcceptResponse(BaseModel):
    is_accepted: bool

class CallRejectResponse(BaseModel):
    is_rejected: bool

