from fastapi import HTTPException

from pydantic import ValidationError

from ..dao import user_dao
from ..models import entity_models, request_models


def add_user(user: entity_models.User):
    user_dao.add_user(user)


def send_feedback(feedbackRequest: request_models.FeedbackRequest):
    return user_dao.send_feedback(feedbackRequest)


def get_user_by_user_id(user_id):
    return user_dao.get_user_by_user_id(user_id)


def get_user_by_phone_number(phone_number):
    return user_dao.get_user_by_phone_number(phone_number)


def get_user_by_matching_abilities(abilities):
    return user_dao.get_user_by_matching_ability(abilities)


def get_user_by_rating_average(low, high):
    return user_dao.get_user_by_rating_average(low, high)


def update_user_request(user_id,update_user_request):
    return user_dao.update_user_request(user_id, update_user_request)