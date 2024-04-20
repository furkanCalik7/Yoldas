import "package:camera/camera.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:frontend/controller/base_controller.dart";
import "package:frontend/custom_widgets/appbars/appbar_custom.dart";
import "package:frontend/custom_widgets/colors.dart";
import "package:get/get.dart";
import "package:vibration/vibration.dart";

class AIModelView extends StatefulWidget {
  const AIModelView({
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

  String instruction =
      "Yapay zeka modelini aktif etmek için uzun basın, kamerayı değiştirmek için çift tıklayın";

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
      appBar: AppbarCustom(
        title: title,
      ),
      body: GestureDetector(
        onLongPress: () {
          // Vibrates the device
          Vibration.vibrate(duration: 100);
          controller.onTapScreen();
          setState(() {
            if (controller.isImageStreamActive.value) {
              instruction = "Yapay zeka modelini aktif etmek için uzun basın";
            } else {
              instruction = "Tekrar başlatmak için uzun basın";
            }
          });
        },
        onDoubleTap: () {
          controller.changeCameraDirection();
        },
        child: GetBuilder<BaseController>(
          init: controller,
          builder: (controller) {
            return controller.isCameraInitialized.value
                ? Stack(
                    children: [
                      Center(
                        child: Container(
                          color: secondaryColor,
                        ),
                      ),
                      CameraPreview(controller.controller),
                      Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: secondaryColor.withOpacity(0.5),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            instruction,
                            style: const TextStyle(
                              color: textColorLight,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (controller.output != "")
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: secondaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              maxLines: 15,
                              textAlign: TextAlign.center,
                              controller.output,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColorLight,
                              ),
                            ),
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
