import logging
from datetime import datetime
import time
from icecream import ic

from ..db_connection import firebase_auth
from ..models.entity_models import Call, CallUser, Signal
from ..shared.constants import CallUserType, CallStatus

db = firebase_auth.connect_db()
logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)


def register_call(call: Call) -> str:
    call_col_ref = db.collection("CallCollection").add(call.model_dump())
    logger.info(f"call {call_col_ref[1].id} registered.")
    return call_col_ref[1].id


def get_call_status(call_id: str) -> CallStatus:
    call_col_ref = db.collection("CallCollection").document(call_id)
    doc = call_col_ref.get()
    if doc.exists:
        call_dict = doc.to_dict()
        return CallStatus[call_dict["status"]]
    else:
        print(f"call {call_id} does not exist.")


def start_call(call_id: str, callee: CallUser):
    call_col_ref = db.collection("CallCollection").document(call_id)
    doc = call_col_ref.get()
    if doc.exists:
        call_dict = doc.to_dict()
        call_dict['callee'] = callee.model_dump()
        call_dict['start_time'] = datetime.now()
        call_dict['status'] = CallStatus.IN_CALL.name
        call_col_ref.set(call_dict)
    else:
        print(f"call {call_id} does not exist.")


def set_call_status(call_id: str, status: CallStatus):
    call_col_ref = db.collection("CallCollection").document(call_id)
    doc = call_col_ref.get()
    if doc.exists:
        call_dict = doc.to_dict()
        call_dict['status'] = status.name
        call_col_ref.set(call_dict)
    else:
        print(f"call {call_id} does not exist.")

MAX_RETRIES = 5
DELAY_BETWEEN_RETRIES = 1  # in seconds

def get_signal(call_id: str, call_user_type: CallUserType) -> Signal:
    retries = 0
    while retries < MAX_RETRIES:
        ic("retry for get signal: ", retries)
        call_col_ref = db.collection("CallCollection").document(call_id)
        doc = call_col_ref.get()
        if doc.exists:
            call_dict = doc.to_dict()
            print("call_dict ", call_dict)
            if call_user_type.value in call_dict and call_dict[call_user_type.value]["signal"] is not None:
                return Signal.model_validate(call_dict[call_user_type.value]["signal"])
            else:
                print(f"Signal property not found for call {call_id} and user type {call_user_type.value}")
        else:
            print(f"Call {call_id} does not exist.")
        retries += 1
        time.sleep(DELAY_BETWEEN_RETRIES)
    raise Exception(f"Failed to fetch signal for call {call_id} after {MAX_RETRIES} attempts.")

def hangup_call(call_id: str):
    call_col_ref = db.collection("CallCollection").document(call_id)
    doc = call_col_ref.get()
    if doc.exists:
        call_dict = doc.to_dict()
        call_dict['end_time'] = datetime.now()
        call_dict['duration'] = (call_dict["end_time"].replace(tzinfo=None) - call_dict["start_time"].replace(
            tzinfo=None)).seconds
        call_dict['status'] = CallStatus.FINISHED.name
        call_col_ref.set(call_dict)
    else:
        print(f"call {call_id} does not exist.")
