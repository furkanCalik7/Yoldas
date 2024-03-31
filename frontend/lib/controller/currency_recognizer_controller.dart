import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:frontend/controller/base_controller.dart';
import 'package:frontend/controller/text_recognizer_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:vibration/vibration.dart';

import '../util/dictionary.dart';



class CurrencyRecognizerController extends GetxController implements BaseController {

  late List<CameraDescription> cameras;
  late CameraImage cameraImage;
  var cameraCount = 0;
  late CameraController controller;
  late FlutterTts flutterTts;

  var isCameraInitialized = false.obs;
  var isImageStreamActive = true.obs;
  var shouldRunTextRecognition = false;
  var output = "";

  initTflite() async {
    var res = await Tflite.loadModel(
        model: "assets/best_float16.tflite",
        labels: "assets/tl_labels.txt",


    );
    log("result: $res");
  }

  objectDetection(CameraImage image) async {
    print(image.planes.map((plane) {return plane.bytes;}).toList());
    var detector = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {return plane.bytes;}).toList(),// required
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 0,   // defaults to 127.5
        imageStd: 255,    // defaults to 127.5
        threshold: 0.1,     // defaults to 0.1
        asynch: true,
      numResults: 1,
      // defaults to true

    );

    if (detector != null) {
      log("Detected object: ${detector.first}");

      String detectedObject = detector.first['label'].toString();
      var confidence = detector.first['confidence'];
      if (confidence
          > 0.5) {
        print(detectedObject);
        output = detectedObject;
        update();
      }
      else {
        output = "para bulunamadı";
        update();
      }
      flutterTts.awaitSpeakCompletion(true);
      flutterTTs.speak(output);
    }
  }

  @override
  void onInit() async {
    super.onInit();
    initTflite();
    cameras = await availableCameras();
    initCamera(cameras[0]);
    flutterTts = FlutterTts();
  }


  @override
  void onClose() async {
    print("OnCLose function called");
    controller.dispose();
    flutterTts.stop();
    Tflite.close();
  }

  @override
  void dispose() {
    print("Dispose function called");
    super.dispose();
  }

  void changeCameraDirection() {
    CameraDescription cameraDescription;
    if (controller.description.lensDirection == CameraLensDirection.back) {
      cameraDescription = cameras[1];
    } else {
      cameraDescription = cameras[0];
    }
    initCamera(cameraDescription);
  }

  initCamera(CameraDescription cameraDescription) async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      controller = CameraController(cameraDescription, ResolutionPreset.max);
      await controller.initialize().then((_) {
        controller.startImageStream((image) {
          if (isImageStreamActive.value && !disposed.value) {
            // Continue image stream
            update();
          } else {
            // Pause image stream
            // Perform text recognition once when tapped
            if (shouldRunTextRecognition) {
              objectDetection(image);
              shouldRunTextRecognition = false;
            }

          }
          update();
        });
      });
      isCameraInitialized.value = true;
      update();
    } else {
      print("Permission denied");
    }
  }

  // Called when the screen is tapped
  void onTapScreen() {
    isImageStreamActive.value = !isImageStreamActive.value;

    // If the image stream is reactivated, set the flag to perform text recognition
    if (isImageStreamActive.value) {
      controller.resumePreview();
      flutterTTs.stop();
      flutterTts.speak("Kamera Aktif");
    }
    else {
      controller.pausePreview();
      shouldRunTextRecognition = true;
    }
  }

}




