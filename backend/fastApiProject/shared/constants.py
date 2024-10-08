from enum import Enum


class CallStatus(Enum):
    INITIALIZED = "INITIALIZED"
    SEARCHING_FOR_CALLEE = "SEARCHING_FOR_CALLEE"
    IN_CALL = "IN_CALL"
    FINISHED = "FINISHED"
    CALLEE_NOT_FOUND = "CALLEE_NOT_FOUND"
    CANCELLED = "CANCELLED"


class CallUserType(Enum):
    CALLER = "caller"
    CALLEE = "callee"


class SearchStatus(Enum):
    INITIALIZED = "INITIALIZED"
    PROCESSING = "PROCESSING"
    ACCEPTED = "ACCEPTED"
    REJECTED = "REJECTED"
    NO_RESPONSE = "NO_RESPONSE"


