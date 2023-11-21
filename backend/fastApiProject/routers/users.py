from fastapi import APIRouter

from ..models import models

from ..services import user_manager

router = APIRouter(prefix="/users",)


@router.get("/get_users")
async def get_users():
    return [{"username": "Rick"}, {"username": "Morty"}]


@router.post("/add_user")
async def add_user(user: models.User):
    # If there is a missing or wrong input, it returns appropriate response.
    return user_manager.add_user(user)
