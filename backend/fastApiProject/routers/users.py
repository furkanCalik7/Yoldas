from fastapi import APIRouter

from models.models import User
from services import user_manager

router = APIRouter(prefix="/users",)


@router.get("/get_users")
async def get_users():
    return [{"username": "Rick"}, {"username": "Morty"}]


@router.post("/add_user")
async def add_user(user: User):
    return user_manager.add_user(user)