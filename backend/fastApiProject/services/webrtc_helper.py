# TODO: for temporary use, a random client id is got
from ..services.socket_manager import SocketManager


def find_match(socket_manager: SocketManager, client_id: str):
    for client_id in socket_manager.active_client_connection:
        if client_id != client_id:
            return client_id
