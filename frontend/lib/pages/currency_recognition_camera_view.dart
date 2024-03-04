import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/controller/object_detection_controller.dart";
import "package:frontend/controller/currency_recognizer_controller.dart";
import "package:get/get.dart";

class CurrencyRecognitionCameraView extends StatefulWidget {
  const CurrencyRecognitionCameraView({super.key});

  static const String routeName = "/currency_recognition_camera_view";

  @override
  State<CurrencyRecognitionCameraView> createState() => _CurrencyRecognitionCameraViewState();
}

class _CurrencyRecognitionCameraViewState extends State<CurrencyRecognitionCameraView> {
  final CurrencyRecognizerController controller = Get.put(CurrencyRecognizerController());

  @override
  void dispose() {
    Get.delete<ObjectDetectionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Obje Tanıma"),
        ) ,
        body: GestureDetector(
          onTap: () {
            // Toggle image stream
            controller.onTapScreen();
          },
          child: GetBuilder<CurrencyRecognizerController>(
            init: controller,
            builder: (controller) {
              return controller.isCameraInitialized.value
                  ? Stack(children:
              [
                CameraPreview(controller.controller),
                Positioned(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green,
                          width: 4,
                        ),
                      ),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              color: Colors.white,
                              child: Text(controller.label,
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),

                            ),
                          ]
                      )
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
