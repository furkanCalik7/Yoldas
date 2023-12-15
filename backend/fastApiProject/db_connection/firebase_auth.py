import firebase_admin
from firebase_admin import credentials, firestore
import logging

firestore_db_client = None
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def connect_db():
    global firestore_db_client
    if firestore_db_client:
        return firestore_db_client
    cred = credentials.Certificate("fastApiProject/db_connection/credentials.json")
    firebase_admin.initialize_app(cred)
    firestore_db_client = firestore.client()
    logger.info("Firebase connection established")
    return firestore_db_client
