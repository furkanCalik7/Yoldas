import firebase_admin.messaging
from firebase_admin import messaging
from ..dao.user_dao import get_fcm_tokens, delete_fcm_token


def call_user_phone(phone_number: str, call_id):
    fcm_tokens = get_fcm_tokens(phone_number)
    sorted_fcm_tokens = sorted(fcm_tokens, key=lambda x: x['createdAt'], reverse=False)
    for fcm_token in sorted_fcm_tokens:
        body = {
            "call_id": call_id
        }
        __try_send_notification_to_token__(phone_number, fcm_token["token"], body)


def __try_send_notification_to_token__(phone_number, token, data):
    try:
        message = messaging.Message(
            data=data,
            token=token,
        )
        return messaging.send(message)
    except Exception as e:
        if type(e) is firebase_admin.messaging.UnregisteredError:
            delete_fcm_token(phone_number, token)
