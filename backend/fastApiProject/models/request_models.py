from typing import Annotated, Optional

from pydantic import BaseModel, StringConstraints, AfterValidator

from fastApiProject.models import entity_models
from fastApiProject.models.entity_models import Gender, Role, Ability, NotificationSettings


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
    first_name: Optional[str]
    last_name: Optional[str]
    gender: Optional[Gender]
    role: Optional[Role]
    abilities: Optional[list[Ability]]
    phone_number: Optional[Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^(\+90)?[0-9]{10}$")]]
    isConsultant: Optional[bool]
    password: Optional[str]
    avg_rating: Optional[float]
    rating_count: Optional[int]
    notification_settings: Optional[NotificationSettings]
