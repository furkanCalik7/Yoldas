from enum import Enum

CALL_ATTEMPT_COUNT = 10
CALL_ATTEMPT_INTERVAL = 1  # seconds


class CallStatus(Enum):
    WAITING = "waiting"
    IN_CALL = "in_call"
    FINISHED = "finished"


class CallUserType(Enum):
    CALLER = "caller"
    CALLEE = "callee"
