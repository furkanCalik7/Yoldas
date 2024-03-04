import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simplytranslate/simplytranslate.dart';

class ImageCaptionController extends GetxController {

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late CameraImage cameraImage;
  var isCameraInitialized = false.obs;
  var isPaused = false.obs;
  late FlutterTts flutterTts;
  final gt = SimplyTranslator(EngineType.google);
  var output = "";

  Future<String> query(File imageFile) async {
    var apiUrl = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large";
    var headers = {"Authorization": "Bearer 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"};

    var bytes = await imageFile.readAsBytes();

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: bytes,
    );
  
    return response.body;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    initCamera();
    flutterTts = FlutterTts();
  }

  @override
  void onClose() {
    cameraController.dispose();
    flutterTts.stop();
  }

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await cameraController.initialize();
      isCameraInitialized.value = true;
      update();
    }

  }

  predictImage() async {
    XFile file = await cameraController.takePicture();
    cameraController.pausePreview();
    isPaused.value = true;
    update();

    File imageFile = File(file.path);
    var response = await query(imageFile);
    update();
    List<dynamic> decodedJson = jsonDecode(response);

    String generatedText = decodedJson[0]["generated_text"];
    print("Generated Text: $generatedText");
    String translatedText = await gt.trSimply(generatedText, "en", "tr");
    output = translatedText;
    update();
    flutterTts.speak(translatedText);
  }

}





