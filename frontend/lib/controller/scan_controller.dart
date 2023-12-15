import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ScanController extends GetxController {

  void onInit() {
    super.onInit();
    initCamera();
    initTflite();
    flutterTts = FlutterTts();
    flutterTts.setLanguage("en-US");
  }


  @override
  void onClose() {
    print("OnCLose function called");
    disposed.value = true;
    cameraController.dispose();
    flutterTts.stop();
  }

  @override
  void dispose() {
    print("Dispose function called");
    super.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  late FlutterTts flutterTts;
  var isCameraInitialized = false.obs;
  var disposed = false.obs;

  late CameraImage cameraImage;
  var cameraCount = 0;

  var x = 0.0;
  var y = 0.0;
  var w = 0.0;
  var h = 0.0;
  var label = "";

  initCamera() async {

    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((_) {
        cameraController.startImageStream((image) {
          cameraCount++;
          if (cameraCount % 10 == 0) {
            cameraCount = 0;
            objectDetection(image);
          }
          if(!disposed.value) {
            update();
          }
          else {
            return;
          }
        });
      });
      isCameraInitialized.value = true;
      update();
    }
    else {
      print("Permission denied");
    }
  }

  initTflite() async {
    var res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false
    );
    log("result: $res");
  }

  objectDetection(CameraImage image) async {
    if(disposed.value) {
      return;
    }
    var detector = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) {return plane.bytes;}).toList(),// required
        model: "SSDMobileNet",
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,   // defaults to 127.5
        imageStd: 127.5,    // defaults to 127.5
        rotation: 90,       // defaults to 90, Android only
        threshold: 0.1,     // defaults to 0.1
        asynch: true
    );

    if(detector != null) {
      log("Detected object: ${detector.first}");
      label = detector.first['detectedClass'].toString();
      var confidence = detector.first['confidenceInClass'];
      if (confidence > 0.6) {
        x = detector.first['rect']['x'];
        y = detector.first['rect']['y'];
        w = detector.first['rect']['w'];
        h = detector.first['rect']['h'];
        await flutterTts.speak(label);
        await flutterTts.awaitSpeakCompletion(true);

      }


    }
  }
}



