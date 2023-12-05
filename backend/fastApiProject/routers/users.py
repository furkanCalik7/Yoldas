from typing import List, Annotated

from fastapi import APIRouter, Query

from ..models import entity_models, request_models
from ..models.entity_models import Ability

from ..services import user_manager

router = APIRouter(prefix="/users", )
from firebase_admin import auth


@router.get("/get_user_by_user_id/{user_id}")
async def get_user_by_user_id(user_id: str):
    user = auth.get_user("i2cnUX3HPnhrTnh3zWDWdG3kUqi2")
    return (200, user)
    #return user_manager.get_user_by_user_id(user_id)


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
    return user_manager.add_user(user)


@router.put("/update/{user_id}")
async def update_user(update_user_request: entity_models.User, user_id: str):
    return user_manager.update_user_request(user_id, update_user_request)


@router.get("/login")
async def login(loginRequest: request_models.LoginRequest):
    # If there is a missing or wrong input, it returns appropriate response.
    pass
