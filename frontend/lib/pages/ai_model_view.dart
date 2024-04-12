import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/controller/base_controller.dart";
import "package:get/get.dart";
import "package:vibration/vibration.dart";

class AIModelView extends StatefulWidget {
  const AIModelView(
      {
        required this.controller,
        required this.title,
        super.key,
      });

  static const String routeName = "/image_caption_camera_view";
  final BaseController controller;
  final String title;

  @override
  State<AIModelView> createState() => _AIModelViewState();
}

class _AIModelViewState extends State<AIModelView> {

  // Get type of controller from the constructor

  String instruction = "Yapay zeka modelini aktif etmek için uzun basın";

  @override
  void dispose() {
    Get.delete<BaseController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BaseController controller = Get.put(widget.controller);
    String title = widget.title;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: GestureDetector(
        onLongPress: ()  {
          // Vibrates the device
          Vibration.vibrate(duration: 100);
          controller.onTapScreen();
          setState(() {
            if(controller.isImageStreamActive.value) {
              instruction = "Yapay zeka modelini aktif etmek için uzun basın";
            } else {
              instruction = "Tekrar başlatmak için uzun basın";
            }
          });
        },
        child: GetBuilder<BaseController>(
          init: controller,
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                       Align(
                        alignment: Alignment.topCenter,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              instruction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CameraPreview(controller.controller),
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 16,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              instruction,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          color: Colors.white,
                          child: Text(
                            controller.output,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      // add a button to change the direction of the camera
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: FloatingActionButton(
                            backgroundColor: Colors.blue[200],
                            child: const Icon(Icons.flip_camera_ios, size: 50,),
                            onPressed: () {
                              controller.changeCameraDirection();
                            },
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
