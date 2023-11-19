from dao import user_dao
from models.models import User


def add_user(user: User):
    user_dao.add_user(user)
