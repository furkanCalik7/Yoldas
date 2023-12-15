from ..db_connection import firebase_auth
from ..models.entity_models import Call

db = firebase_auth.connect_db()


def register_call(call: Call):
    call_col_ref = db.collection("CallCollection").add(call.model_dump())
    return {"call": call_col_ref}
