import firebase_admin
from firebase_admin import credentials, firestore
import logging

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)

def connect_db():
    cred = credentials.Certificate("fastApiProject/db_connection/credentials.json")
    firebase_admin.initialize_app(cred)
    logger.info("Firebase connection established")
    return firestore.client()
