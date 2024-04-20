import logging
from ..db_connection import firebase_auth
from fastapi import HTTPException
from google.cloud.firestore_v1 import FieldFilter

from ..models import request_models
from ..models.entity_models import User
from ..config import AVG_RATING_WEIGHT, CALL_RATIO_WEIGHT, COMPLAINT_WEIGHT, NORMALIZATION_FACTOR

db = firebase_auth.connect_db()
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def find_potential_callees(CallRequest: request_models.CallRequest, current_user: User, num_of_calls: int = 5,
                           excluded_user_list=None):
    # check which type of call is requested, according to the type of call, find an appropriate user
    if CallRequest.isConsultancyCall:
        user_list = find_consultant_user(num_of_calls, current_user, excluded_user_list)
    elif CallRequest.isQuickCall:
        user_list = find_quick_call_user(num_of_calls, current_user, excluded_user_list)
    else:
        user_list = find_matching_ability_user(CallRequest.category, num_of_calls, current_user, excluded_user_list)
    return user_list


def find_consultant_user(num_of_calls: int, caller: User, excluded_user_list: list = None):
    # From UserCollection, get all users with isConsultant = True
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("isConsultant", "==", True))
        .where(filter=FieldFilter("is_active", "==", True))
        .stream()
    )
    consultant_list = list(docs)
    consultant_list = [User.model_validate(user.to_dict()) for user in consultant_list]

    if not consultant_list:
        logger.error(f"No consultant found")
        raise KeyError(f"No consultant found")

    # remove excluded user phone numbers (users who did not pick up at first) from the list
    if excluded_user_list:
        for user in consultant_list:
            if user.phone_number in excluded_user_list:
                consultant_list.remove(user)

    if caller in consultant_list:
        consultant_list.remove(caller)

    # Initialize the overall point of each volunteer
    user_point_dict: {str, (User, int)} = {}
    for user in consultant_list:
        user_point_dict[user.phone_number] = (user, 0)
    for phone_number, (user, score) in user_point_dict.items():
        rating_point = AVG_RATING_WEIGHT * user.avg_rating

        if user.no_of_calls_received == 0:
            call_ratio_point = CALL_RATIO_WEIGHT * user.avg_rating
        else:
            call_ratio_point = CALL_RATIO_WEIGHT * (
                    user.no_of_calls_completed / user.no_of_calls_received) * NORMALIZATION_FACTOR
        if user.no_of_calls_completed == 0:
            complaint_point = COMPLAINT_WEIGHT * user.avg_rating
        else:
            complaint_point = (COMPLAINT_WEIGHT * len(user.complaints) * (
                    NORMALIZATION_FACTOR / user.no_of_calls_completed))
        overall_point = rating_point + call_ratio_point - complaint_point

        user_point_dict[phone_number] = (user, overall_point)

    # sort the list of volunteers by overall point. user_point_dict contains phone_number as key and (User, int) as value.
    # We want the int value to sort the list
    consultant_list = sorted(user_point_dict.items(), key=lambda item: item[1][1], reverse=True)

    consultant_list = [user for user, score in consultant_list]
    # if there are less than num_of_calls consultants, return all of them
    if len(consultant_list) < num_of_calls:
        return consultant_list

    return consultant_list[:num_of_calls]

def find_quick_call_user(num_of_calls: int, caller: User, excluded_user_list=None):
    # get avg_rating and return num_of_calls number of users with the highest rating except the caller
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("role", "==", "volunteer"))
        .where(filter=FieldFilter("is_active", "==", True))
        .stream()
    )
    volunteer_list = list(docs)

    volunteer_list = [User.model_validate(user.to_dict()) for user in volunteer_list]

    if not volunteer_list:
        logger.error(f"No volunteer found")
        raise KeyError(f"No volunteer found")

    if caller in volunteer_list:
        volunteer_list.remove(caller)

    # remove excluded user phone numbers (users who did not pick up at first) from the list
    if excluded_user_list:
        for user in volunteer_list:
            if user.phone_number in excluded_user_list:
                volunteer_list.remove(user)

    # Initialize the overall point of each volunteer
    user_point_dict: {str, (User, int)} = {}
    for user in volunteer_list:
        user_point_dict[user.phone_number] = (user, 0)
    for phone_number, (user, score) in user_point_dict.items():
        rating_point = AVG_RATING_WEIGHT * user.avg_rating

        if user.no_of_calls_received == 0:
            call_ratio_point = CALL_RATIO_WEIGHT * user.avg_rating
        else:
            call_ratio_point = CALL_RATIO_WEIGHT * (
                    user.no_of_calls_completed / user.no_of_calls_received) * NORMALIZATION_FACTOR
        if user.no_of_calls_completed == 0:
            complaint_point = COMPLAINT_WEIGHT * user.avg_rating
        else:
            complaint_point = (COMPLAINT_WEIGHT * len(user.complaints) * (
                    NORMALIZATION_FACTOR / user.no_of_calls_completed))
        overall_point = rating_point + call_ratio_point - complaint_point

        user_point_dict[phone_number] = (user, overall_point)

    # sort the list of volunteers by overall point. user_point_dict contains phone_number as key and (User, int) as value.
    # We want the int value to sort the list
    volunteer_list = sorted(user_point_dict.items(), key=lambda item: item[1][1], reverse=True)
    volunteer_list = [user for user, score in volunteer_list]
    # if there are less than num_of_calls consultants, return all of them
    if len(volunteer_list) < num_of_calls:
        return volunteer_list

    return volunteer_list[:num_of_calls]


def find_matching_ability_user(category: str, num_of_calls: int, caller: User, excluded_user_list=None):
    # get all users with matching abilities and the highest rating except the caller
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("abilities", "array_contains", category))
        .where(filter=FieldFilter("is_active", "==", True))
        .stream()
    )
    matching_ability_list = list(docs)
    matching_ability_list = [User.model_validate(user.to_dict()) for user in matching_ability_list]

    if not matching_ability_list:
        logger.error(f"No user with matching abilities found")
        raise KeyError(f"No user with matching abilities found")

    if caller in matching_ability_list:
        matching_ability_list.remove(caller)
    # remove excluded user phone numbers (users who did not pick up at first) from the list
    if excluded_user_list:
        for user in matching_ability_list:
            if user.phone_number in excluded_user_list:
                matching_ability_list.remove(user)

    # Initialize the overall point of each volunteer
    user_point_dict: {str, (User, int)} = {}
    for user in matching_ability_list:
        user_point_dict[user.phone_number] = (user, 0)
    for phone_number, (user, score) in user_point_dict.items():
        rating_point = AVG_RATING_WEIGHT * user.avg_rating

        if user.no_of_calls_received == 0:
            call_ratio_point = CALL_RATIO_WEIGHT * user.avg_rating
        else:
            call_ratio_point = CALL_RATIO_WEIGHT * (
                    user.no_of_calls_completed / user.no_of_calls_received) * NORMALIZATION_FACTOR
        if user.no_of_calls_completed == 0:
            complaint_point = COMPLAINT_WEIGHT * user.avg_rating
        else:
            complaint_point = (COMPLAINT_WEIGHT * len(user.complaints) * (
                    NORMALIZATION_FACTOR / user.no_of_calls_completed))
        overall_point = rating_point + call_ratio_point - complaint_point
        user_point_dict[phone_number] = (user, overall_point)

    # sort the list of volunteers by overall point. user_point_dict contains phone_number as key and (User, int) as value.
    # We want the int value to sort the list
    matching_ability_list = sorted(user_point_dict.items(), key=lambda item: item[1][1], reverse=True)

    matching_ability_list = [user for user, score in matching_ability_list]
    # if there are less than num_of_calls consultants, return all of them
    if len(matching_ability_list) < num_of_calls:
        return matching_ability_list

    return matching_ability_list[:num_of_calls]
