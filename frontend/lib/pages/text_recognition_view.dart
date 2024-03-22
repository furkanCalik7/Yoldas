import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/controller/text_recognizer_controller.dart";
import "package:get/get.dart";

class TextRecognitionCameraView extends StatefulWidget {
  const TextRecognitionCameraView({super.key});

  static const String routeName = "/text_recognition_camera_view";

  @override
  State<TextRecognitionCameraView> createState() => _TextRecognitionCameraViewState();
}

class _TextRecognitionCameraViewState extends State<TextRecognitionCameraView> {
  final TextRecognizerController controller = Get.put(TextRecognizerController());

  @override
  void dispose() {
    Get.delete<TextRecognizerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Metin Tanıma"),
        ) ,
        body: GestureDetector(
          onTap: () {
            // Toggle image stream
            controller.onTapScreen();
          },
          child: GetBuilder<TextRecognizerController>(
            init: controller,
            builder: (controller) {
              return controller.isCameraInitialized.value
                  ? Stack(children:
              [
                CameraPreview(controller.controller),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green,
                        width: 4,
                      ),
                    ),
                ),
              ]
              )
                  : const Center(child: Text("Loading View..."),);
            },
          ),
        )
    );
  }
}
