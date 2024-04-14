import firebase_admin.messaging
from firebase_admin import messaging
from ..dao.user_dao import get_fcm_tokens, delete_fcm_token


def send_notification_to_user(phone_number: str, title, body):
    fcm_tokens = get_fcm_tokens(phone_number)
    sorted_fcm_tokens = sorted(fcm_tokens, key=lambda x: x['createdAt'], reverse=False)
    for fcm_token in sorted_fcm_tokens:
        print(fcm_token)
        response = __try_send_notification_to_token(phone_number, fcm_token["token"], title, body)
        print(response)
    print(fcm_tokens)


def __try_send_notification_to_token(phone_number, token, title, body):
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            token=token
        )
        return messaging.send(message)
    except Exception as e:
        if type(e) is firebase_admin.messaging.UnregisteredError:
            delete_fcm_token(phone_number, token)
