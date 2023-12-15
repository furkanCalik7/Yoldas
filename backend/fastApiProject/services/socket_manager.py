import socketio


class SocketManager:
    def __init__(self, socket_app: socketio.AsyncServer):
        self.active_client_connection: dict[str, str] = {}
        self.socket_app = socket_app

    async def connect(self, client_id: str, socket_id: str):
        self.active_client_connection[socket_id] = client_id

    def disconnect(self, socket_id: str):
        self.active_client_connection.pop(socket_id)

    def get_client_id_from_socket_id(self, socket_id: str):
        return self.active_client_connection[socket_id]

    async def send_message_to_user(self, event: str, client_id: str, message: str):
        await self.send_message_to_users(event, [client_id], message)

    async def send_message_to_users(self, event: str, clients: [str], message: str):
        for socket_id in self.active_client_connection:
            if self.active_client_connection[socket_id] in clients:
                await self.socket_app.emit(event, message, room=socket_id)
