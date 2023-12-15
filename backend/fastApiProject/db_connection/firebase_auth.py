import firebase_admin
from firebase_admin import credentials, firestore

firestore_db_client = None


def connect_db():
    global firestore_db_client
    if firestore_db_client:
        return firestore_db_client
    cred = credentials.Certificate("fastApiProject/db_connection/credentials.json")
    firebase_admin.initialize_app(cred)
    firestore_db_client = firestore.client()
    return firestore_db_client
