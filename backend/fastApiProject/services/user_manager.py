from ..dao import user_dao
from ..models import models


def add_user(user: models.User):
    user_dao.add_user(user)


def get_user(user_id):
    return user_dao.get_user(user_id)