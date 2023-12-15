import time
from typing import Dict

import socketio
import json

from ..services.socket_manager import SocketManager
from ..Constants.client_socket_events import ClientSocketEvents
from ..dao.call_dao import register_call
from ..models.entity_models import Call, CallUser

sio = socketio.AsyncServer(
    async_mode='asgi',
    cors_allowed_origins=[]
)

socket_app = socketio.ASGIApp(
    socketio_server=sio,
    socketio_path='/sockets'
)

socket_manager = SocketManager(sio)
offer: Dict = {}

completely_temp_ice_candidate_for_caller = []
completely_temp_ice_candidate_for_callee = []


@sio.event
async def connect(socket_id, environ, auth=None):
    user_id = [header_value for (header_key, header_value) in environ['asgi.scope']['headers'] if
               header_key == b'x-user-id']
    print(user_id)
    assert len(user_id) == 1
    user_id = user_id[0]
    await socket_manager.connect(user_id, socket_id)
    call = Call(
        caller=CallUser(
            phone_number=user_id,
            ice_candidates=[],
            sdp={}
        ),

        callee=CallUser(
            phone_number=user_id,
            ice_candidates=[],
            sdp={}
        ),
        start_time=time.time(),
        end_time=time.time(),
    )
    await register_call(call)


@sio.event
def connect_error(data):
    print("The connection failed!")


@sio.event
async def disconnect(socket_id):
    socket_manager.disconnect(socket_id)
    print('disconnect ', socket_id)


# catch 'join' event
@sio.event
async def join(sid, message):
    print("join ", sid)
    print(message)
    # await sio.emit('join', message, room=sid)


@sio.event
async def signaling(sid, message):
    print("signaling:", sid)
    global offer
    print(socket_manager.get_client_id_from_socket_id(sid))
    print(type(socket_manager.get_client_id_from_socket_id(sid)))
    print("sended offer:", offer)
    await socket_manager.send_message_to_user("offer", socket_manager.get_client_id_from_socket_id(sid), offer)
    # TODO: fix later
    for ice_candidate in completely_temp_ice_candidate_for_caller:
        print("ice_candidate: ", ice_candidate)
        await socket_manager.send_message_to_user("ice_candidate", socket_manager.get_client_id_from_socket_id(sid),
                                                  ice_candidate)


@sio.event
async def offer(sid, message):
    print("offer: ", message)
    global offer
    offer = message


@sio.event
async def answer(sid, message):
    print("answer: ", sid)
    print(message)
    await socket_manager.send_message_to_user("answer", b'0', message)
    print("completely_temp_ice_candidate_for_callee: ", completely_temp_ice_candidate_for_callee)
    # for ice_candidate in completely_temp_ice_candidate_for_callee:
    #     print("ice_candidate: ", ice_candidate)
    #     await socket_manager.send_message_to_user("ice_candidate", b'0', ice_candidate)


@sio.event
async def ice_candidate(sid, message):
    print("send_icecandidate: ", sid)
    client_id = socket_manager.get_client_id_from_socket_id(sid)
    if client_id == b"0":
        print("caller")
        completely_temp_ice_candidate_for_caller.append(message)
    else:
        print("callee")
        completely_temp_ice_candidate_for_callee.append(message)


@sio.event
async def callee_ice_candidate(sid, message):
    print("callee_ice_candidate: ", sid)
    await socket_manager.send_message_to_user("ice_candidate", b'0', message)

# TODO: add event handlers for the rest of the events
# TODO: handle authentication
# TODO: at least work webrtc more than one client and observe the situation
