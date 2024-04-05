from typing import Annotated, Optional

from pydantic import BaseModel, StringConstraints, AfterValidator

from fastApiProject.models import entity_models
from fastApiProject.models.entity_models import Gender, Role, NotificationSettings


class LoginRequest(BaseModel):
    password: str
    phone_number: Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^(\+90)?[0-9]{10}$")]


class FeedbackRequest(BaseModel):
    def check_rating(v: int) -> int:
        assert 5 >= v >= 0, f'{v} is not a proper rating'
        return v

    rating: Annotated[int, AfterValidator(check_rating)]
    callID: str


class UpdateUserRequest(BaseModel):
    name: Optional[str] = None
    gender: Optional[Gender] = None
    role: Optional[Role] = None
    abilities: Optional[list[str]] = []
    phone_number: Optional[Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^(\+90)?[0-9]{10}$")]] = None
    isConsultant: Optional[bool] = None
    password: Optional[str] = None
    avg_rating: Optional[float] = None
    rating_count: Optional[int] = None
    notification_settings: Optional[NotificationSettings] = None


class StartCallRequest(BaseModel):
    isQuickCall: bool
    category: Optional[str] = None
    isConsultancyCall: Optional[bool] = False
