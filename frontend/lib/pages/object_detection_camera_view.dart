import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/controller/scan_controller.dart";
import "package:get/get.dart";

class ObjectDetectionCameraView extends StatefulWidget {
  const ObjectDetectionCameraView({super.key});

  static const String routeName = "/object_detection_camera_view";

  @override
  State<ObjectDetectionCameraView> createState() => _ObjectDetectionCameraViewState();
}

class _ObjectDetectionCameraViewState extends State<ObjectDetectionCameraView> {
  final ScanController controller = Get.put(ScanController());

  @override
  void dispose() {
    Get.delete<ScanController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Obje Tanıma"),
        ) ,
        body: GetBuilder<ScanController>(
          init: controller,
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Stack(children:
            [
              CameraPreview(controller.cameraController),
              Positioned(
                top: (controller.y) * 700,
                right: (controller.x) * 500,
                child: Container(
                    width: controller.w * 100 * context.width / 100,
                    height: controller.h * 100 * context.height / 100,
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
                                fontSize: 20,
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
        )
    );
  }
}
