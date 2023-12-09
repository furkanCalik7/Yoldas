from datetime import timedelta, datetime, timezone
from datetime import datetime, timedelta
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from ..dao import user_dao
from ..models import entity_models, request_models
from ..models.entity_models import TokenData

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/login", auto_error=False)
#read secret_key from secret_key.txt
SecretKeyFile = open("fastApiProject/db_connection/secret_key.txt", "r")
SECRET_KEY = SecretKeyFile.read()
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


def register_user(user: entity_models.User):
    user.password = get_password_hash(user.password)
    return user_dao.register_user(user)


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def token_verify(uid):
    return user_dao.token_verify(uid)


def login(loginRequest: request_models.LoginRequest):
    user = user_dao.get_user_by_phone_number(loginRequest.phone_number)
    if not user:
        raise HTTPException(status_code=404, detail=f"User with phone number {loginRequest.phone_number} not found")
    if not verify_password(loginRequest.password, user["password"]):
        raise HTTPException(status_code=400, detail=f"Wrong password")

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"phone_number": loginRequest.phone_number}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer", "user": user}





def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone_number: str = payload.get("phone_number")

        if phone_number is None:
            raise credentials_exception
        token_data = TokenData(phone_number=phone_number)
    except JWTError:
        raise credentials_exception

    user = user_dao.get_user_by_phone_number(token_data.phone_number)
    if user is None:
        raise credentials_exception
    return user


async def get_current_user_role(current_user: Annotated[entity_models.User, Depends(get_current_user)]):
    return current_user["role"]


async def get_current_active_user(
    current_user: Annotated[entity_models.User, Depends(get_current_user)]
):
    return current_user


def authenticate_user(phone_number: str, password: str):
    user = user_dao.get_user_by_phone_number(phone_number)
    if not user:
        return False
    if not verify_password(password, user["password"]):
        return False
    return user


def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):

    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"phone_number": user["phone_number"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer", "user": user}


async def read_users_me(current_user: Annotated[entity_models.User, Depends(get_current_active_user)]):
    return current_user


def send_feedback(feedbackRequest: Annotated[request_models.FeedbackRequest, Depends(get_current_active_user)]):
    return user_dao.send_feedback(feedbackRequest)


def get_user_by_user_id(user_id):
    return user_dao.get_user_by_user_id(user_id)


def get_user_by_phone_number(phone_number):
    return user_dao.get_user_by_phone_number(phone_number)


def get_user_by_matching_abilities(abilities):
    return user_dao.get_user_by_matching_ability(abilities)


def get_user_by_rating_average(low, high):
    return user_dao.get_user_by_rating_average(low, high)


def update_user_request(user_id, update_user_request):
    return user_dao.update_user_request(user_id, update_user_request)
