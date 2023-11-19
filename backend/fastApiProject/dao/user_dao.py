from db_connection import firebase_auth
from models.models import User
import firebase_admin
from firebase_admin import credentials, firestore


def add_user(user: User):
    cred = credentials.Certificate("db_connection/credentials.json")
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    # db = await firebase_auth.connect_db()
    doc_ref = db.collection("UserCollection").document()
    doc_ref.set(dict(user))
