from enum import Enum
from typing import Optional, List, Annotated
from uuid import UUID, uuid4

from pydantic import BaseModel, EmailStr
from pydantic import StringConstraints
from typing_extensions import Annotated


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


class Ability(str, Enum):
    cooking = "cooking"
    sports = "sports"


class NotificationSettings(BaseModel):
    callNotifications: bool
    messageNotifications: bool

    # control valid emails using pydantic
    # https://pydantic-docs.helpmanual.io/usage/types/#constrained-types


class User(BaseModel):
    # id: Optional[UUID] = uuid4()
    name: str
    role: Role
    abilities: Optional[list[Ability]] = []
    phone_number: Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^\+[1-9]\d{1,14}$")]
    email: EmailStr
    isConsultant: Optional[bool] = False
    password: str
    avg_rating: Optional[float] = 0
    rating_count: Optional[int] = 0
    notification_settings: Optional[NotificationSettings] = NotificationSettings(callNotifications=False,
                                                                                 messageNotifications=False)


class Call(BaseModel):
    pass
