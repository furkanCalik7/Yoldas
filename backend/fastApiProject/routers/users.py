from fastapi import APIRouter

from ..models import models

from ..services import user_manager

router = APIRouter(prefix="/users",)


@router.get("/get_user/{user_id}")
async def get_user(user_id):
    return user_manager.get_user(user_id)


@router.post("/register")
async def add_user(user: models.User):
    # If there is a missing or wrong input, it returns appropriate response.
    return user_manager.add_user(user)


@router.get("/login")
async def login(loginRequest: models.LoginRequest):
    # If there is a missing or wrong input, it returns appropriate response.
    pass


