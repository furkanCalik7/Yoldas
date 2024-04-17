from enum import Enum


class CallStatus(Enum):
    INITIALIZED = "INITILIAZED"
    SEARCHING_FOR_CALLEE = "SEARCHING_FOR_CALLEE"
    IN_CALL = "IN_CALL"
    FINISHED = "FINISHED"
    CALLEE_NOT_FOUND = "CALLEE_NOT_FOUND"


class CallUserType(Enum):
    CALLER = "caller"
    CALLEE = "callee"
