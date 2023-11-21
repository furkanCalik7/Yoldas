from ..dao import user_dao
from ..models import entity_models, request_models


def add_user(user: entity_models.User):
    user_dao.add_user(user)


def get_user(user_id):
    return user_dao.get_user(user_id)