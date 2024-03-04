import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/controller/image_caption_controller.dart";
import "package:frontend/controller/object_detection_controller.dart";
import "package:frontend/controller/text_recognizer_controller.dart";
import "package:get/get.dart";
import "dart:io";

class ImageCaptionView extends StatefulWidget {
  const ImageCaptionView({super.key});

  static const String routeName = "/image_caption_camera_view";

  @override
  State<ImageCaptionView> createState() => _ImageCaptionViewState();
}

class _ImageCaptionViewState extends State<ImageCaptionView> {
  final ImageCaptionController controller = Get.put(ImageCaptionController());

  @override
  void dispose() {
    Get.delete<ImageCaptionController>();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resim Tanıma"),
      ),
      body: GestureDetector(
        onTap: () async {
          if (controller.isPaused.value) {
            controller.cameraController.resumePreview();
            controller.isPaused.value = false;
          } else {
            await controller.predictImage();
          }
        },
        child: GetBuilder<ImageCaptionController>(
          init: controller,
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      CameraPreview(controller.cameraController),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          controller.output,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
                : const Center(
              child: Text("Loading View..."),
            );
          },
        ),
      ),
    );
  }

}
