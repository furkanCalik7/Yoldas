from typing import Annotated

from pydantic import BaseModel, StringConstraints


class LoginRequest(BaseModel):
    phone_number: Annotated[str, StringConstraints(strip_whitespace=True, pattern=r"^(\+90)?[0-9]{10}$")]