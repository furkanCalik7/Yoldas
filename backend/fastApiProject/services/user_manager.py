from datetime import timedelta, datetime, timezone
from datetime import datetime, timedelta
from typing import Annotated

from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext
from ..dao import user_dao, matcher_dao
from ..models import entity_models, request_models
from ..models.entity_models import TokenData
import logging

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/users/login", auto_error=False)
# read secret_key from secret_key.txt
SecretKeyFile = open("fastApiProject/db_connection/secret_key.txt", "r")
SECRET_KEY = SecretKeyFile.read()
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password):
    return pwd_context.hash(password)


def register_user(user: entity_models.User):
    logger.info(f"register_user with user {user} called")
    if user.role == "volunteer" and user.isConsultant:
        logger.error(f"Volunteer cannot be a consultant")
        raise HTTPException(status_code=400, detail=f"Volunteer cannot be a consultant")
    user.password = get_password_hash(user.password)
    return user_dao.register_user(user)


def delete_user(user_id):
    return user_dao.delete_user(user_id)


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    logger.info(f"create_access_token with data {data} called")
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def token_verify(uid):
    logger.info(f"token_verify with uid {uid} called")
    return user_dao.token_verify(uid)


def login(loginRequest: request_models.LoginRequest):
    logger.info(f"login with loginRequest {loginRequest} called")
    user = user_dao.get_user_by_phone_number(loginRequest.phone_number)
    if not user:
        logger.error(f"User with phone number {loginRequest.phone_number} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {loginRequest.phone_number} not found")

    if not verify_password(loginRequest.password, user["password"]):
        logger.info(f"Wrong password for user with phone number {loginRequest.phone_number}")
        raise HTTPException(status_code=400, detail=f"Wrong password")

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"phone_number": loginRequest.phone_number}, expires_delta=access_token_expires
    )
    logger.info(f"User with phone number {loginRequest.phone_number} logged in successfully")
    return {"access_token": access_token, "token_type": "bearer", "user": user}


def get_current_user(token: Annotated[str, Depends(oauth2_scheme)]):
    logger.info(f"get_current_user with token {token}")
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        phone_number: str = payload.get("phone_number")

        if phone_number is None:
            logger.error(f"Invalid token for user with phone number {phone_number}")
            raise credentials_exception
        token_data = TokenData(phone_number=phone_number)
    except JWTError:
        logger.error(f"Invalid token for user with phone number {phone_number}")
        raise credentials_exception
    except AttributeError:
        logger.error(f"Authantication failed")
        raise HTTPException(401, detail="Authantication failed")

    user = user_dao.get_user_by_phone_number(token_data.phone_number)
    if user is None:
        logger.error(f"User with phone number {phone_number} not found")
        raise credentials_exception
    logger.info(f"User with phone number {phone_number} authenticated successfully")
    return user


async def get_current_user_role(current_user: Annotated[entity_models.User, Depends(get_current_user)]):
    logger.info(f"get_current_user_role for user with phoneNumber {current_user['phone_number']} called")
    return current_user["role"]


async def get_current_active_user(
        current_user: Annotated[entity_models.User, Depends(get_current_user)]
):
    logger.info(f"get_current_active_user for user with phoneNumber {current_user['phone_number']} called")
    return current_user


def authenticate_user(phone_number: str, password: str):
    logger.info(f"authenticate_user with phone_number {phone_number} and password {password} called")
    user = user_dao.get_user_by_phone_number(phone_number)
    if not user:
        logger.error(f"User with phone number {phone_number} not found")
        return False
    if not verify_password(password, user["password"]):
        logger.error(f"Wrong password for user with phone number {phone_number}")
        return False
    return user


def login_for_access_token(form_data: Annotated[OAuth2PasswordRequestForm, Depends()]):
    logger.info(f"login_for_access_token with form_data {form_data.username} called")
    user = authenticate_user(form_data.username, form_data.password)
    if not user:
        logger.error(f"Incorrect username or password")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"phone_number": user["phone_number"]}, expires_delta=access_token_expires
    )
    logger.info(f"User with phone number {user['phone_number']} logged in successfully")
    return {"access_token": access_token, "token_type": "bearer", "user": user}


async def read_users_me(current_user: Annotated[entity_models.User, Depends(get_current_active_user)]):
    return current_user


def send_feedback(feedbackRequest, current_user):
    logger.info(f"send_feedback with feedbackRequest {feedbackRequest} called")
    return user_dao.send_feedback(feedbackRequest, current_user)


def get_user_by_user_id(user_id):
    logger.info(f"get_user_by_user_id with user_id {user_id} called")
    return user_dao.get_user_by_user_id(user_id)


def get_user_by_phone_number(phone_number):
    logger.info(f"get_user_by_phone_number with phone_number {phone_number} called")
    return user_dao.get_user_by_phone_number(phone_number)


def get_user_by_matching_abilities(abilities):
    logger.info(f"get_user_by_matching_abilities with abilities {abilities} called")
    return user_dao.get_user_by_matching_ability(abilities)


def get_user_by_rating_average(low, high):
    logger.info(f"get_user_by_rating_average with rating in range {low} and {high} called")
    return user_dao.get_user_by_rating_average(low, high)


def update_user_request(user_id, update_user_req_obj):
    logger.info(f"update_user_request with user_id {user_id} called")
    if update_user_req_obj.password:
        update_user_req_obj.password = get_password_hash(password=update_user_req_obj.password)
    return user_dao.update_user_request(user_id, update_user_req_obj)


# Start Call endpoint
def start_call(startCallRequest: request_models.CallRequest, current_user):
    logger.info(f"start_call with startCallRequest {startCallRequest} called")
    return matcher_dao.find_potential_callees(startCallRequest, current_user)


# Get All Abilities endpoint
def get_all_abilities():
    logger.info(f"get all abilities called in manager")
    return user_dao.get_all_abilities()


# Send Complaint endpoint
def send_complaint(complaintRequest, current_user):
    logger.info(f"send_complaint with complaintRequest {complaintRequest} called")
    return user_dao.send_complaint(complaintRequest, current_user)
