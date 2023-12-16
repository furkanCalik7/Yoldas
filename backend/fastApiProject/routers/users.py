from typing import Annotated
from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm

from ..models import entity_models, request_models

from ..services import user_manager
import logging

router = APIRouter(prefix="/users", )
from firebase_admin import auth

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


@router.get("/users/me/", response_model=entity_models.User)
async def read_users_me(
        current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]
):
    return current_user


@router.get("/users/role")
async def get_user_role(current_user_role: Annotated[entity_models.User, Depends(user_manager.get_current_user_role)]):
    logger.info(f"get_user_role for user with phoneNumber {entity_models.User.uid} called")
    return current_user_role


@router.get("/get_user_by_phone_number/{phone_number}")
async def get_user_by_phone_number(phone_number: str):
    logger.info(f"get_user_by_phone_number for User with phoneNumber {phone_number} called")
    return user_manager.get_user_by_phone_number(phone_number)


@router.get("/get_user_by_matching_abilities/{abilities}")
async def get_user_by_matching_abilities(abilities: str):
    logger.info(f"get_user_by_matching_abilities for {abilities} called")
    return user_manager.get_user_by_matching_abilities(abilities)


@router.get("/get_user_by_feedback_average/{low}/{high}")
async def get_user_by_rating_average(low: int, high: int):
    logger.info(f"get_user_by_feedback_average for rating in range {low} and {high} called")
    return user_manager.get_user_by_rating_average(low, high)


@router.post("/send_feedback/")
async def send_feedback(feedbackRequest: request_models.FeedbackRequest, current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    logger.info(f"send_feedback with feedbackRequest {feedbackRequest} called")
    return user_manager.send_feedback(feedbackRequest, current_user)


@router.post("/register")
async def register_user(user: entity_models.User):
    logger.info(f"register_user with user {user} called")
    # If there is a missing or wrong input, it returns appropriate response.
    return user_manager.register_user(user)


@router.put("/update/{user_id}")
async def update_user(update_user_request: entity_models.User, user_id: str):
    logger.info(f"update_user with user_id {user_id} called")
    return user_manager.update_user_request(user_id, update_user_request)


@router.post("/login")
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    logger.info(f"login_for_access_token with form_data {form_data.username} called")
    return user_manager.login_for_access_token(form_data)
