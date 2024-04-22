import 'package:camera/camera.dart';
import 'package:get/get.dart';

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
