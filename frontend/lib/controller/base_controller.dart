import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

abstract class BaseController extends GetxController {
  late CameraController controller;
  late List<CameraDescription> cameras;
  var output = "";
  var isCameraInitialized = false.obs;
  var isImageStreamActive = true.obs;

  void changeCameraDirection();

  initCamera(CameraDescription cameraDescription);
  void onTapScreen();
}
