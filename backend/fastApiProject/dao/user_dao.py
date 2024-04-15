from fastapi import HTTPException
from google.cloud.firestore_v1 import FieldFilter
import time
from . import call_dao, matcher_dao
from ..models.entity_models import User, Call, CallUser
from ..models.request_models import UpdateUserRequest
from ..db_connection import firebase_auth
import logging
from ..models import request_models

db = firebase_auth.connect_db()
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def register_user(user: User):
    # check if user exists
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("phone_number", "==", user.phone_number))
        .stream()
    )
    docs_list = list(docs)
    if docs_list:
        logger.error(f"User with phone number {user.phone_number} already exists")
        raise HTTPException(status_code=400, detail=f"User with phone number {user.phone_number} already exists")

    # set document id as phone number
    user_col_ref = db.collection("UserCollection").document(user.phone_number)
    user_col_ref.set(user.model_dump())
    logger.info(f"User with phone number {user.phone_number} successfully registered")
    # TODO: add token to response
    return {"user": user.model_dump()}


def delete_user(user_id):
    doc_ref = db.collection("UserCollection").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"User with id {user_id} not found")
        raise HTTPException(status_code=404, detail=f"User with id {user_id} not found")
    doc_ref.delete()
    logger.info(f"User with id {user_id} successfully deleted")
    return {"message": "User with phone number" + user_id + " successfully deleted"}


def send_feedback(feedbackRequest, current_user: User):
    logger.info(f"send_feedback with feedbackRequest {feedbackRequest} called in DAO")
    doc = db.collection("CallCollection").document(feedbackRequest.callID).get()
    if not doc.exists:
        logger.error(f"Call with {feedbackRequest.callID} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {feedbackRequest.callID} not found")

    phone_number_of_feedback_sender = current_user["phone_number"]
    print(f"CALL is {doc.to_dict}")
    call = Call.model_validate(doc.to_dict())
    if call.caller.phone_number == phone_number_of_feedback_sender:
        phone_number_of_update_user = call.callee.phone_number
    else:
        phone_number_of_update_user = call.caller.phone_number
    # increase rating count by 1
    # update average rating
    doc_ref = db.collection("UserCollection").document(phone_number_of_update_user)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"User with phone number {phone_number_of_update_user} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {phone_number_of_update_user} not found")

    user = User.model_validate(doc.to_dict())
    user.avg_rating = ((user.avg_rating * user.rating_count + feedbackRequest.rating)
                       / (user.rating_count + 1))
    user.rating_count += 1
    doc_ref.set(user.model_dump())
    logger.info(f"User with phone_number {phone_number_of_update_user} successfully updated")
    return user.model_dump()


def get_user_by_user_id(user_id):
    doc_ref = db.collection("UserCollection").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"User with id {user_id} not found")
        raise HTTPException(status_code=404, detail=f"User with id {user_id} not found")
    logger.info(f"User with id {user_id} successfully retrieved")
    return dict(doc.to_dict())


def token_verify(uid):
    doc_ref = db.collection("UserCollection").document(uid)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"Token for user with id {uid} not found")
        raise HTTPException(status_code=404, detail=f"User with id {uid} not found")
    logger.info(f"Token for user with id {uid} successfully retrieved")
    return doc.to_dict()


def get_user_by_phone_number(phone_number):
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("phone_number", "==", phone_number))
        .stream()
    )

    docs_list = list(docs)
    if not docs_list:
        logger.error(f"User with phone number {phone_number} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {phone_number} not found")

    for doc in docs_list:
        logger.info(f"User with phone number {phone_number} successfully retrieved")
        return doc.to_dict()


def get_user_by_matching_ability(ability):
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("abilities", 'array_contains', ability))
        .stream()
    )
    docs_list = list(docs)
    if not docs_list:
        logger.error(f"User with abilities {ability} not found")
        raise HTTPException(status_code=404, detail=f"User with abilities {ability} not found")

    user_list = {}
    for doc in docs_list:
        user_list[doc.id] = doc.to_dict()
    logger.error(f"Users with abilities {ability} successfully retrieved")
    return user_list


def get_user_by_rating_average(low, high):
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("avg_rating", "<=", high))
        .where(filter=FieldFilter("avg_rating", ">=", low))
        .stream()
    )

    docs_list = list(docs)
    if not docs_list:
        logger.error(f"User in range {low, high} not found")
        raise HTTPException(status_code=404, detail=f"User in range {low, high} not found")

    user_list = {}
    for doc in docs_list:
        user_list[doc.id] = doc.to_dict()
    logger.info(f"Users in range {low, high} successfully retrieved")
    return user_list


def update_user_request(user_id, update_user_request: UpdateUserRequest):
    doc_ref = db.collection("UserCollection").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"User with id {user_id} not found")
        raise HTTPException(status_code=404, detail=f"User with id {user_id} not found")

    user = UpdateUserRequest.model_validate(doc.to_dict())

    # Define a dictionary containing attributes to update
    attributes_to_update = {
        'name': update_user_request.name,
        'phone_number': update_user_request.phone_number,
        'password': update_user_request.password,
        'isConsultant': update_user_request.isConsultant,
        'role': update_user_request.role,
        'notification_settings': update_user_request.notification_settings,
        'abilities': update_user_request.abilities
    }

    # Iterate over the dictionary and update user attributes if the value is not None
    for attribute, value in attributes_to_update.items():
        if value is not None:
            setattr(user, attribute, value)
    doc_ref.update(user.model_dump())
    logger.info(f"User with id {user_id} successfully updated")
    return user.model_dump()


def start_consultancy_call(callRequest, current_user):
    # check if user exists
    doc = db.collection("UserCollection").document(callRequest.phone_number).get()
    if not doc.exists:
        logger.error(f"User with phone number {callRequest.phone_number} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {callRequest.phone_number} not found")

    callee = User.model_validate(doc.to_dict())
    call = Call(
        caller=CallUser(phone_number=current_user.phone_number),
        callee=CallUser(phone_number=callee.phone_number),
        start_time=time.time(),
        isQuickCall=callRequest.isQuickCall,
        category=callRequest.category,
        isConsultancyCall=callRequest.isConsultancyCall
    )
    call_dao.create_call(call)
    return call.model_dump()


def start_call(CallRequest: request_models.CallRequest, current_user):
    # check if user exists
    doc = db.collection("UserCollection").document(current_user["phone_number"]).get()
    if not doc.exists:
        logger.error(f"User with phone number {CallRequest.phone_number} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {CallRequest.phone_number} not found")

    # check which type of call is requested
    # according to the type of call, find an appropriate user
    num_of_calls = 5
    if CallRequest.isConsultancyCall:
        user_list = matcher_dao.find_consultant_user(num_of_calls, current_user)
    elif CallRequest.isQuickCall:
        user_list = matcher_dao.find_quick_call_user(num_of_calls, current_user)
    else:
        user_list = matcher_dao.find_matching_ability_user(CallRequest, num_of_calls, current_user)

    # logger.info(
    # f"{len(user_list)} users found for the caller with phone number {current_user["phone_number"]}")
    return user_list  # TODO call the function that will start the actual call


def get_all_abilities():
    doc_ref = db.collection("AbilityCollection").document("2hcB6d7Yxys0oIPTEGqT")
    doc = doc_ref.get()
    return doc.to_dict()


def send_complaint(complaintRequest, current_user):
    doc = db.collection("CallCollection").document(complaintRequest.callID).get()
    if not doc.exists:
        logger.error(f"Call with {complaintRequest.callID} not found")
        raise HTTPException(status_code=404, detail=f"Call with {complaintRequest.callID} not found")

    #TODO: validate here once call object is finalized.
    call = doc.to_dict()

    if call["caller"]["phone_number"] == current_user["phone_number"]:
        phone_number_of_complaint_receiver = call["callee"]["phone_number"]
    else:
        logger.error(f"User with phone number {current_user['phone_number']} is not the caller of the call")
        raise HTTPException(status_code=400, detail=f"User with phone number {current_user['phone_number']} is not the caller of the call")

    # Get the user object which the complaint is about
    doc_ref = db.collection("UserCollection").document(phone_number_of_complaint_receiver)
    doc = doc_ref.get()
    if not doc.exists:
        logger.error(f"User with phone number {phone_number_of_complaint_receiver} not found")
        raise HTTPException(status_code=404, detail=f"User with phone number {phone_number_of_complaint_receiver} not found")

    user = User.model_validate(doc.to_dict())
    # append the complaint to the list.
    user.complaints.append(complaintRequest.complaint)
    doc_ref.set(user.model_dump())
    return user.model_dump()

def get_fcm_tokens(phone_number: str):
    fcm_tokens = db.collection("UserCollection").document(phone_number).collection("fcm_tokens")
    return [token_ref.to_dict() for token_ref in fcm_tokens.get()]


def delete_fcm_token(phone_number: str, token):
    fcm_token = db.collection("UserCollection").document(phone_number).collection("fcm_tokens").document(token)
    fcm_token.delete()