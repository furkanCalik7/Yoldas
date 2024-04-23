from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import UUID, uuid4

from pydantic import BaseModel, EmailStr
from pydantic import StringConstraints
from typing_extensions import Annotated

from fastApiProject.shared.constants import CallStatus


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    phone_number: str | None = None


class Gender(str, Enum):
    male = "male"
    female = "female"


class Role(str, Enum):
    volunteer = "volunteer"
    blind = "blind"

class NotificationSettings(BaseModel):
    callNotifications: bool
    messageNotifications: bool

    # control valid emails using pydantic
    # https://pydantic-docs.helpmanual.io/usage/types/#constrained-types


class User(BaseModel):
    name: str
    role: Role
    abilities: Optional[list[str]] = []
    phone_number: Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^\+[1-9]\d{1,14}$")]
    isConsultant: Optional[bool] = False
    password: str
    avg_rating: Optional[float] = 4
    rating_count: Optional[int] = 1
    notification_settings: Optional[NotificationSettings] = NotificationSettings(callNotifications=False, messageNotifications=False)
    complaints: Optional[list[str]] = []
    no_of_calls_received: Optional[int] = 0
    no_of_calls_completed: Optional[int] = 0
    is_active: Optional[bool] = True


class Signal(BaseModel):
    sdp: str
    type: str


class CallUser(BaseModel):
    # name: str
    phone_number: str
    signal: Optional[Signal] = None


class Call(BaseModel):
    caller: CallUser
    callee: Optional[CallUser] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    duration: Optional[int] = 0
    category: Optional[str] = "fast"
    status: Optional[CallStatus] = CallStatus.INITIALIZED.value
    isQuickCall: Optional[bool] = False
    isConsultancyCall: Optional[bool] = False
