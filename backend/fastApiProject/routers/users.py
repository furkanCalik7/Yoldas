from typing import Annotated
from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm

from ..models import entity_models, request_models

from ..services import user_manager
import logging

router = APIRouter(prefix="/users", )

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


@router.post("/register")
async def register_user(user: entity_models.User):
    logger.info(f"register_user with user {user} called")
    # If there is a missing or wrong input, it returns appropriate response.
    return user_manager.register_user(user)


@router.post("/login")
async def login_for_access_token(
        form_data: Annotated[OAuth2PasswordRequestForm, Depends()]
):
    return user_manager.login_for_access_token(form_data)


@router.put("/update/{user_id}")
async def update_user(update_user_request: request_models.UpdateUserRequest,
                      current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    return user_manager.update_user_request(current_user["phone_number"], update_user_request)


@router.delete("/delete/{user_id}")
async def delete_user(user_id: str):
    logger.info(f"delete_user with user_id {user_id} called")
    return user_manager.delete_user(user_id)


@router.post("/feedback")
async def send_feedback(feedbackRequest: request_models.FeedbackRequest,
                        current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    return user_manager.send_feedback(feedbackRequest, current_user)


@router.post("/complaint")
async def send_complaint(complaintRequest: request_models.ComplaintRequest,
                         current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    return user_manager.send_complaint(complaintRequest, current_user)


@router.get("/get_all_abilities")
async def get_all_abilities():
    logger.info(f"get_all_abilities called")
    return user_manager.get_all_abilities()


@router.get("/role")
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


@router.get("/completed_call_count")
async def get_completed_calls(current_user: Annotated[entity_models.User, Depends(user_manager.get_current_active_user)]):
    logger.info(f"get_call_count called")
    return user_manager.get_completed_calls(current_user["phone_number"])
