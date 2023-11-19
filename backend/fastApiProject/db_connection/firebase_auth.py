import firebase_admin
from firebase_admin import credentials, firestore


def connect_db():
    cred = credentials.Certificate("db_connection/credentials.json")
    firebase_admin.initialize_app(cred)
    return firestore.client()



