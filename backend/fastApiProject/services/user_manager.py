from ..dao import user_dao
from ..models import models


def add_user(user: models.User):
    user_dao.add_user(user)
