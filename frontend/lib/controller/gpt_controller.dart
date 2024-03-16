import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simplytranslate/simplytranslate.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class GPTController extends GetxController {
  late CameraController controller;
  late List<CameraDescription> cameras;
  late CameraImage cameraImage;
  var isCameraInitialized = false.obs;
  var isImageStreamActive = true.obs;
  late FlutterTts flutterTts;
  final gt = SimplyTranslator(EngineType.google);
  var output = "";
  final dio = Dio();

  Future<String> fetchResponse(File imageFile) async {
    String openaiApiKey = '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';
    String openaiApiUrl = 'https://api.openai.com/v1/chat/completions';

    String base64Image = base64Encode(imageFile.readAsBytesSync());

    var requestBody = jsonEncode({
      'model': 'gpt-4-vision-preview',
      'messages': [
        {
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Bu resimde ne var?'},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'max_tokens': 200
    });

    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $openaiApiKey"
    };

    try {
      final response = await http.post(
        Uri.parse(openaiApiUrl),
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        return response.body;
        // Handle response here
      } else {
        print(response.body);
        print('Request failed with status: ${response.statusCode}');
        return 'request failed';
      }
    } catch (e) {
      print('Request failed with error: $e');
      return '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    initCamera();
    flutterTts = FlutterTts();
  }

  @override
  void onClose() {
    controller.dispose();
    flutterTts.stop();
  }

  void onDispose() {
    controller.dispose();
    flutterTts.stop();
  }

  Future<void> resizeImage(File imageFile, int desiredWidth, int desiredHeight) async {
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    img.Image resizedImage = img.copyResize(image!, width: desiredWidth, height: desiredHeight);
    File resizedFile = File(imageFile.path);
    resizedFile.writeAsBytesSync(img.encodeJpg(resizedImage));
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.max);
      await controller.initialize();
      isCameraInitialized.value = true;
      update();
    }
  }

  predictImage() async {
    XFile file = await controller.takePicture();
    controller.pausePreview();
    File imageFile = File(file.path);
    print("File path: ${imageFile.path}");
    print("File size: ${imageFile.lengthSync()}");

    resizeImage(imageFile, 520, 520);
    print("Resized file size: ${imageFile.lengthSync()}");

    var response = await fetchResponse(imageFile);
    Map<String, dynamic> decodedJson = jsonDecode(response);

    String generatedText = decodedJson['choices'][0]['message']['content'];
    print("Generated Text: $generatedText");
    output = generatedText;
    update();
    flutterTts.speak(generatedText);


  }

  void onTapScreen() {
    isImageStreamActive.value = !isImageStreamActive.value;
    update();

    // If the image stream is reactivated, set the flag to perform text recognition
    if (isImageStreamActive.value) {
      controller.resumePreview();
      flutterTts.stop();
      output = "";
      update();
    }
    else {
      predictImage();
    }
  }
}
