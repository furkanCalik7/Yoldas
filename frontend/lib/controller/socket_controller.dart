import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/config.dart';

class SocketController {
  static SocketController? _instance; // Singleton instance variable
  IO.Socket? _socket;

  // Private constructor
  SocketController._();

  // Getter for the instance
  static SocketController get instance {
    _instance ??= SocketController._(); // Create instance if it doesn't exist
    return _instance!;
  }

  // Connect to the socket
  Future<IO.Socket> connect() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    var phoneNumber = await storage.read(key: "phone_number") ?? "N/A";
    if (phoneNumber == "N/A") {
      return Future.error(Exception("Phone number (client id) is not found in secure storage."));
    }
    return IO.io(
        API_URL,
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setPath('/sockets')
            .setReconnectionAttempts(5)
            .setReconnectionDelay(3)
            .setExtraHeaders({'x-user-id': phoneNumber})
            .build()); 
  }

  Future<IO.Socket> getConnection() async {
    _socket ??= await connect();
    return _socket!;
  }
}
