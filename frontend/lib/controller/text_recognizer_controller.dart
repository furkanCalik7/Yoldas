import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';

var disposed = false.obs;
final FlutterTts flutterTTs = FlutterTts();


final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImage? _inputImageFromCameraImage(CameraImage image, CameraController controller, CameraDescription camera) {
  // get image rotation
  // it is used in android to convert the InputImage from Dart to Java
  // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  final sensorOrientation = camera.sensorOrientation;
  InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    var rotationCompensation =
    _orientations[controller!.value.deviceOrientation];
    if (rotationCompensation == null) return null;
    if (camera.lensDirection == CameraLensDirection.front) {
      // front-facing
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // back-facing
      rotationCompensation =
          (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;
  // get image format
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  // validate format depending on platform
  // only supported formats:
  // * nv21 for Android
  // * bgra8888 for iOS
  if (format == null ||
      (Platform.isAndroid && format != InputImageFormat.nv21) ||
      (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

  // since format is constraint to nv21 or bgra8888, both only have one plane
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;

  // compose InputImage using bytes
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation, // used only in Android
      format: format, // used only in iOS
      bytesPerRow: plane.bytesPerRow, // used only in iOS
    ),
  );
}

class MLKitTextRecognizer {
  late TextRecognizer recognizer;

  MLKitTextRecognizer() {
    recognizer = TextRecognizer();
    flutterTTs.setSpeechRate(0.7);
    flutterTTs.setLanguage("tr-TR");
    flutterTTs.setPitch(1);
    flutterTTs.setVoice({"name": "tr-tr-x-ama-local", "locale": "tr-TR"});
  }

  void dispose() {
    recognizer.close();
  }

  Future<String> spellcheck(String exampleText) async {
    var endpoint = "https://api.bing.microsoft.com/v7.0/spellcheck";
    var url = Uri.parse("$endpoint?mkt=en-US&mode=proof&text=${Uri.encodeComponent(exampleText)}");

    String apiKey = "0213527169d74afaacd7d4e196319321";

    var data = {'text': exampleText};

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Ocp-Apim-Subscription-Key': apiKey,
        },
        body: data,
        encoding: Encoding.getByName('utf-8'),
      );

      if (response.statusCode == 200) {
        // Handle the successful response
        var responseData = json.decode(response.body);
        print(responseData);
        return responseData["flaggedTokens"][0]["suggestions"][0]["suggestion"];
      } else {
        // Handle errors
        print("Error: ${response.statusCode}");
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      // Handle exceptions
      print("Exception: $e");
      return "Exception: $e";
    }
  }

  Future<String> processImage(InputImage image) async {
    final recognized = await recognizer.processImage(image);
    log(recognized.text);

    // remove the new line character from the recognized text
    var text = recognized.text.replaceAll("\n", " ");
    var out = await spellcheck(text);
    print(out);
    flutterTTs.speak(text);
    return recognized.text;
  }
}

class TextRecognizerController extends GetxController {

  MLKitTextRecognizer textRecognizer = MLKitTextRecognizer();

  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void onClose() {
    print("OnCLose function called");
    disposed.value = true;
    controller.dispose();
    textRecognizer.dispose();
    flutterTTs.stop();
  }

  @override
  void dispose() {
    print("Dispose function called");
    super.dispose();
  }

  late List<CameraDescription> cameras;
  late CameraImage cameraImage;
  var cameraCount = 0;
  late CameraController controller;

  var isCameraInitialized = false.obs;
  var isImageStreamActive = true.obs;
  var shouldRunTextRecognition = false;

  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      controller = CameraController(
        cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();

      controller.startImageStream((image) {
        if (isImageStreamActive.value && !disposed.value) {
          // Continue image stream
          update();
        } else {
          // Pause image stream
          // Perform text recognition once when tapped
          if (shouldRunTextRecognition) {
            InputImage? img =
            _inputImageFromCameraImage(image, controller, cameras[0]);
            textRecognizer.processImage(img!);
            shouldRunTextRecognition = false;
          }

        }
        update();
      });

      isCameraInitialized.value = true;
      update();
    }
  }

  // Called when the screen is tapped
  void onTapScreen() {
    isImageStreamActive.value = !isImageStreamActive.value;

    // If the image stream is reactivated, set the flag to perform text recognition
    if (isImageStreamActive.value) {
      controller.resumePreview();
      flutterTTs.stop();
    }
    else {
      controller.pausePreview();
      shouldRunTextRecognition = true;
    }
  }

}




