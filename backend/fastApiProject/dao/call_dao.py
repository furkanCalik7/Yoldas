import logging

from ..db_connection import firebase_auth
from ..models.entity_models import Call, CallUser, Signal
from ..shared.constants import CallUserType

db = firebase_auth.connect_db()
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)

def register_call(call: Call):
    call_col_ref = db.collection("CallCollection").add(call.model_dump())
    logger.info(f"New call request: {call_col_ref}")
    return {"call": call_col_ref}

def register_callee(call_id: str, callee: CallUser):
    call_col_ref = db.collection("CallCollection").document(call_id)
    doc = call_col_ref.get()
    if doc.exists:
        call_dict = doc.to_dict()
        call_dict['callee'] = callee
    else:
        print(f"call {call_id} does not exist.")
def update_signaling(call_id: str, call_user_type: CallUserType, signaling: dict) -> None:
    pass

def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    pass

def get_phone_number_from_call(call_id: str, call_user_type:CallUserType) -> str:
    pass
