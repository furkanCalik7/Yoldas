from enum import Enum

CALL_ATTEMPT_COUNT = 10
CALL_ATTEMPT_INTERVAL = 1 # seconds

class ClientSocketEvents(Enum):
    SEND_ICECANDIDATE = "send_icecandidate"
    SEND_OFFER = "send_offer"
    SEND_ANSWER = "answer"
    SIGNALING = "signaling"
    HANG_UP = "hang_up"


class CallStatus(Enum):
    WAITING = "waiting"
    IN_CALL = "in_call"
    FINISHED = "finished"


class OfferType(Enum):
    OFFER = "offer"
    ANSWER = "answer"


class CallUserType(Enum):
    CALLER = "caller"
    CALLEE = "callee"
