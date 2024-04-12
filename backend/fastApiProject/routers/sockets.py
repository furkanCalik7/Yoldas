import logging

import socketio
#
# from fastApiProject.dao.call_dao import *
# from fastApiProject.services.call_manager import register_ice_candidates, \
#     register_ice_candidates_completed, emit_answer_to_caller, exchange_ice_candidates
from fastApiProject.services.socket_manager import SocketManager

logger = logging.getLogger(__name__)
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s', level=logging.INFO)
#
# TODO: when internet connection becomes down and reconnects again, refresh connection

sio = socketio.AsyncServer(
    async_mode='asgi',
    cors_allowed_origins=[]
)

socket_app = socketio.ASGIApp(
    socketio_server=sio,
    socketio_path='/sockets'
)

socket_manager = SocketManager(sio)


@sio.event
async def connect(socket_id, environ):
    headers = environ['asgi.scope']['headers']
    user_id = [header_value for (header_key, header_value) in headers if
               header_key == b'x-user-id']
    assert len(user_id) == 1
    user_id = user_id[0].decode('utf-8')
    logger.info(f"Phone number {user_id} with socket_id {socket_id} connected.")
    await socket_manager.connect(user_id, socket_id)


@sio.event
async def disconnect(socket_id):
    user_id = socket_manager.get_client_id_from_socket_id(socket_id)
    socket_manager.disconnect(socket_id)
    logger.info(f"Phone number {user_id} with socket_id {socket_id} disconnected.")

#
# @sio.event
# async def answer_signal(sid, message):
#     message = json.loads(message)
#     call_id, signal = message["call_id"], message["signal"]
#     await emit_answer_to_caller(socket_manager, call_id, signal)
#
#
# @sio.event
# async def caller_ice_candidate(sid, message):
#     message = json.loads(message)
#     call_id = message["call_id"]
#     logger.info("(Caller) Ice candidate arrived for call_id {}: {}".format(call_id, message["ice_candidate"]))
#     register_ice_candidates(call_id, CallUserType.CALLER, message["ice_candidate"])
#
#
# @sio.event
# async def callee_ice_candidate(sid, message):
#     message = json.loads(message)
#     call_id = message["call_id"]
#     logger.info("(Callee) Ice candidate arrived for call_id {}: {}".format(call_id, message["ice_candidate"]))
#     register_ice_candidates(call_id, CallUserType.CALLEE, message["ice_candidate"])
#
#
# @sio.event
# async def caller_ice_candidates_completed(sid, message):
#     message = json.loads(message)
#     call_id = message["call_id"]
#     logger.info("Caller ice candidates completed for call id: {}".format(call_id))
#     register_ice_candidates_completed(call_id, CallUserType.CALLER)
#
#
# @sio.event
# async def callee_ice_candidates_completed(sid, message):
#     message = json.loads(message)
#     call_id = message["call_id"]
#     register_ice_candidates_completed(call_id, CallUserType.CALLEE)
#     logger.info("Callee ice candidates completed for call id: {}".format(call_id))
#     await exchange_ice_candidates(socket_manager, call_id)

# TODO: handle authentication
# TODO: at least work webrtc more than one client and observe the situation
