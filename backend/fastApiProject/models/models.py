from enum import Enum
from typing import Optional, List
from uuid import UUID, uuid4

from pydantic import BaseModel


class Gender(str, Enum):
    male = "male"
    female = "female"


class Role(str, Enum):
    volunteer = "volunteer"
    blind = "blind"

class Ability(str, Enum):
    cooking = "cooking"
    sports = "sports"


class User(BaseModel):
    # id: Optional[UUID] = uuid4()
    first_name: str
    last_name: str
    gender: Gender
    roles: Role
    abilities: Optional[list[Ability]]
    phone_number: str  # TODO pydantic phone validator
    isConsultant: Optional[bool]


class Call(BaseModel):
    pass
