from typing import Annotated
from fastapi import APIRouter,Depends
from fastapi.security import OAuth2PasswordRequestForm

from ..models import entity_models, request_models

from ..services import user_manager

router = APIRouter(prefix="/users", )
from firebase_admin import auth


@router.get("/users/me/", response_model=entity_models.User)
async def read_users_me(
    current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]
):
    return current_user

@router.get("/users/role")
async def get_user_role(current_user_role: Annotated[entity_models.User, Depends(user_manager.get_current_user_role)]):
    return current_user_role

@router.get("/get_user_by_phone_number/{phone_number}")
async def get_user_by_phone_number(phone_number: str):
    return user_manager.get_user_by_phone_number(phone_number)


@router.get("/get_user_by_matching_abilities/{abilities}")
async def get_user_by_matching_abilities(abilities: str):
    return user_manager.get_user_by_matching_abilities(abilities)


@router.get("/get_user_by_feedback_avereage/{low}/{high}")
async def get_user_by_rating_average(low: int, high: int):
    return user_manager.get_user_by_rating_average(low, high)


@router.post("/send_feedback")
async def send_feedback(feedbackRequest: request_models.FeedbackRequest):
    return user_manager.send_feedback(feedbackRequest)


@router.post("/register")
async def register_user(user: entity_models.User):
    # If there is a missing or wrong input, it returns appropriate response.
    return user_manager.register_user(user)


@router.put("/update/{user_id}")
async def update_user(update_user_request: entity_models.User, user_id: str):
    return user_manager.update_user_request(user_id, update_user_request)


@router.post("/login")
async def login_for_access_token(
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    return user_manager.login_for_access_token(form_data)

