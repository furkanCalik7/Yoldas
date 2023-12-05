from typing import List
from urllib.error import HTTPError

from fastapi import HTTPException
from google.cloud.firestore_v1 import FieldFilter

from ..models import request_models
from ..models.entity_models import User
from ..db_connection import firebase_auth

db = firebase_auth.connect_db()


def add_user(user: User):
    doc_ref = db.collection("UserCollection").document()
    doc_ref.set(user.model_dump())


def send_feedback(feedbackRequest):
    doc_ref = db.collection("UserCollection").document(feedbackRequest.user_id)
    doc = doc_ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail=f"User with id {feedbackRequest.user_id} not found")

        # increase rating count by 1
        # update average rating
    user = User.model_validate(doc.to_dict())
    user.avg_rating = ((user.avg_rating * user.rating_count + feedbackRequest.rating)
                       / (user.rating_count + 1))
    user.rating_count += 1
    doc_ref.set(user.model_dump())
    return user.model_dump()


def get_user_by_user_id(user_id):
    doc_ref = db.collection("UserCollection").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail=f"User with id {user_id} not found")
    return dict(doc.to_dict())


def get_user_by_phone_number(phone_number):
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("phone_number", "==", phone_number))
        .stream()
    )

    docs_list = list(docs)
    if not docs_list:
        raise HTTPException(status_code=404, detail=f"User with phone number {phone_number} not found")

    user_list = {}
    for doc in docs_list:
        user_list[doc.id] = doc.to_dict()
    return user_list


def get_user_by_matching_ability(ability):
    docs = (
        db.collection("UserCollection")
        .where(filter=FieldFilter("abilities", 'array_contains', ability))
        .stream()
    )
    docs_list = list(docs)
    if not docs_list:
        raise HTTPException(status_code=404, detail=f"User with abilities {ability} not found")

    user_list = {}
    for doc in docs_list:
        user_list[doc.id] = doc.to_dict()
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
        raise HTTPException(status_code=404, detail=f"User in range {low, high} not found")

    user_list = {}
    for doc in docs_list:
        user_list[doc.id] = doc.to_dict()
    return user_list


def update_user_request(user_id, update_user_request1):
    doc_ref = db.collection("UserCollection").document(user_id)
    doc = doc_ref.get()
    if not doc.exists:
        raise HTTPException(status_code=404, detail=f"User with id {user_id} not found")

    user = User.model_validate(doc.to_dict())

    if update_user_request1.first_name is not None:
        user.first_name = update_user_request1.first_name
    if update_user_request1.last_name is not None:
        user.last_name = update_user_request1.last_name
    if update_user_request1.phone_number is not None:
        user.phone_number = update_user_request1.phone_number
    if update_user_request1.password is not None:
        user.password = update_user_request1.password
    if update_user_request1.isConsultant is not None:
        user.isConsultant = update_user_request1.isConsultant
    if update_user_request1.role is not None:
        user.role = update_user_request1.role
    if update_user_request1.notification_settings is not None:
        user.notification_settings = update_user_request1.notification_settings
    doc_ref.set(user.model_dump())
    return user.model_dump()