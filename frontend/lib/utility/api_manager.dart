import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/config.dart';

class ApiManager {
  static const String baseURL = API_URL;

  static Future<http.Response> get(
    String path,
    Map<String, String>? headers,
  ) async {
    String url = baseURL + path;

    return await http.get(
      Uri.parse(url),
      headers: headers,
    );
  }

  // default content type is application/json
  static Future<http.Response> post({
    required String path,
    String? bearerToken,
    Map<String, dynamic>? body,
    String? contentType = 'application/json; charset=UTF-8',
  }) async {
    // url
    String url = baseURL + path;

    // headers
    Map<String, String> headers = {
      'Content-Type': contentType!,
    };
    if (bearerToken != null) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    // body
    body = body ?? {}; // if body is null, set it to an empty map
    String jsonBody = jsonEncode(body);

    try {
      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: (contentType == 'application/json; charset=UTF-8')
            ? jsonBody
            : body,
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        return http.Response('Failed to post data', 500);
      }
    } on Exception catch (e) {
      print('Exception: $e');
      return http.Response('Failed to post data', 500);
    }
  }

  static Future<http.Response> put({
    required String path,
    String? bearerToken,
    Map<String, dynamic>? body,
    String? contentType = 'application/json; charset=UTF-8',
  }) async {
    // url
    String url = baseURL + path;

    // headers
    Map<String, String> headers = {
      'Content-Type': contentType!,
    };
    if (bearerToken != null) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    // body
    body = body ?? {}; // if body is null, set it to an empty map
    String jsonBody = jsonEncode(body);

    try {
      http.Response response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: (contentType == 'application/json; charset=UTF-8')
            ? jsonBody
            : body,
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        return http.Response('Failed to put data', response.statusCode);
      }
    } on Exception catch (e) {
      print('Exception: $e');
      return http.Response('Failed to put data', 500);
    }
  }
}
