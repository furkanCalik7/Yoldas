import logging
from ..db_connection import firebase_auth
from fastapi import HTTPException
from google.cloud.firestore_v1 import FieldFilter

from ..models import request_models
from ..models.entity_models import User

db = firebase_auth.connect_db()
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def find_potential_callees(CallRequest: request_models.CallRequest, current_user):
    # check if user exists
    doc = db.collection("UserCollection").document(current_user["phone_number"]).get()
    if not doc.exists:
        logger.error(f"User with phone number {CallRequest.phone_number} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {CallRequest.phone_number} not found")

    # check which type of call is requested
    # according to the type of call, find an appropriate user
    num_of_calls = 5
    if CallRequest.isConsultancyCall:
        user_list = find_consultant_user(num_of_calls, current_user)
    elif CallRequest.isQuickCall:
        user_list = find_quick_call_user(num_of_calls, current_user)
    else:
        user_list = find_matching_ability_user(CallRequest, num_of_calls, current_user)
    return user_list


def find_consultant_user(num_of_calls: int, caller: User):
    # From UserCollection, get all users with isConsultant = True
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("isConsultant", "==", True))
        .stream()
    )
    consultant_list = list(docs)
    if not consultant_list:
        logger.error(f"No consultant found")
        ## Review note: returning here http exception seems wrong since this is a dao class - instead not found exception
        raise HTTPException(status_code=404, detail=f"No consultant found")
    # from the consultant_list, return num_of_calls number of users with the highest rating except the caller
    consultant_list = [User.model_validate(user.to_dict()) for user in consultant_list]
    consultant_list = sorted(consultant_list, key=lambda x: x.avg_rating, reverse=True)
    if caller in consultant_list:
        consultant_list.remove(caller)
    # if there are less than num_of_calls consultants, return all of them
    if len(consultant_list) < num_of_calls:
        return consultant_list

    return consultant_list[:num_of_calls]


def find_quick_call_user(num_of_calls: int, caller: User):
    # get avg_rating and return num_of_calls number of users with the highest rating except the caller
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("role", "==", "volunteer"))
        .stream()
    )
    volunteer_list = list(docs)
    if not volunteer_list:
        logger.error(f"No volunteer found")
        raise HTTPException(status_code=404, detail=f"No volunteer found")
    volunteer_list = [User.model_validate(user.to_dict()) for user in volunteer_list]
    volunteer_list = sorted(volunteer_list, key=lambda x: x.avg_rating, reverse=True)
    if caller in volunteer_list:
        volunteer_list.remove(caller)
    # if there are less than num_of_calls volunteers, return all of them
    if len(volunteer_list) < num_of_calls:
        return volunteer_list
    return volunteer_list[:num_of_calls]


def find_matching_ability_user(startCallRequest: request_models.CallRequest, num_of_calls: int, caller: User):
    # get all users with matching abilities and the highest rating except the caller
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("abilities", "array_contains", startCallRequest.category))
        .stream()
    )
    matching_ability_list = list(docs)
    if not matching_ability_list:
        logger.error(f"No user with matching abilities found")
        raise HTTPException(status_code=404, detail=f"No user with matching abilities found")
    matching_ability_list = [User.model_validate(user.to_dict()) for user in matching_ability_list]
    matching_ability_list = sorted(matching_ability_list, key=lambda x: x.avg_rating, reverse=True)
    if caller in matching_ability_list:
        matching_ability_list.remove(caller)
    # if there are less than num_of_calls users with matching abilities, return all of them
    if len(matching_ability_list) < num_of_calls:
        return matching_ability_list
    return matching_ability_list[:num_of_calls]
