from typing import Optional

from pydantic import BaseModel

from fastApiProject.models.entity_models import Signal


class CallRequestResponse(BaseModel):
    callee_name: str
    call_id: str


class CallAcceptResponse(BaseModel):
    is_accepted: bool
    caller_name: Optional[str]
    call_id: Optional[str]
    signal: Optional[Signal]
