from ..models.models import User
from ..db_connection import firebase_auth

db = firebase_auth.connect_db()


def add_user(user: User):
    doc_ref = db.collection("UserCollection").document()
    doc_ref.set(dict(user))