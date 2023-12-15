from enum import Enum


class ClientSocketEvents(Enum):
    SEND_ICECANDIDATE = "send_icecandidate"
    SEND_OFFER = "send_offer"
    SEND_ANSWER = "answer"
    SIGNALING = "signaling"
    HANG_UP = "hang_up"

