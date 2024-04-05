import 'package:flutter/material.dart';
import 'package:frontend/custom_widgets/buttons/custom_icon_button.dart';
import 'package:frontend/custom_widgets/colors.dart';
import 'package:frontend/pages/evaluation_page.dart';

class TransparentVideoCallBar extends StatefulWidget {
  const TransparentVideoCallBar({Key? key}) : super(key: key);

  @override
  _TransparentVideoCallBarState createState() =>
      _TransparentVideoCallBarState();
}

class _TransparentVideoCallBarState extends State<TransparentVideoCallBar> {
  Color currentMicButtonColor = videoCallButtonDefaultColor;
  bool isMicOn = true;
  IconData currentMicIcon = Icons.mic;

  Color currentVideoButtonColor = videoCallButtonDefaultColor;
  bool isVideoOn = true;
  IconData currentVideoIcon = Icons.videocam;

  bool isSpeakerOn = true;
  IconData currentSpeakerIcon = Icons.volume_up;

  bool isCameraFront = true;
  IconData currentFlipCameraIcon = Icons.flip_camera_ios_outlined;

  @override
  void initState() {
    super.initState();
  }

  void navigateToEvaluationPage() {
    // end call
    print("Call ended");

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const EvaluationPage(
                  callId:
                      "2w0KxysanozQK3mwfI7g", // this will be provided after call ends.
                )),
        (route) => false);
  }

  void toggleSpeaker() {
    setState(() {
      if (isSpeakerOn) {
        currentSpeakerIcon = Icons.volume_off;
      } else {
        currentSpeakerIcon = Icons.volume_up;
      }
      isSpeakerOn = !isSpeakerOn;
    });
  }

  void toggleVideo() {
    setState(() {
      if (isVideoOn) {
        currentVideoButtonColor = redIconButtonColor;
        currentVideoIcon = Icons.videocam_off;
      } else {
        currentVideoButtonColor = videoCallButtonDefaultColor;
        currentVideoIcon = Icons.videocam;
      }
      isVideoOn = !isVideoOn;
    });
  }

  void toggleMic() {
    setState(() {
      if (isMicOn) {
        currentMicButtonColor = redIconButtonColor;
        currentMicIcon = Icons.mic_off;
      } else {
        currentMicButtonColor = videoCallButtonDefaultColor;
        currentMicIcon = Icons.mic;
      }
      isMicOn = !isMicOn;
    });
  }

  void flipCamera() {
    setState(() {
      if (isCameraFront) {
        currentFlipCameraIcon = Icons.flip_camera_ios_outlined;
      } else {
        currentFlipCameraIcon = Icons.flip_camera_ios;
      }
      isCameraFront = !isCameraFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomIconButton(
                onPressed: toggleVideo,
                icon: currentVideoIcon,
                backgroundColor: currentVideoButtonColor,
                tooltip: 'Kamera Aç/Kapat',
              ),
              CustomIconButton(
                onPressed: toggleMic,
                icon: currentMicIcon,
                backgroundColor: currentMicButtonColor,
                tooltip: 'Mikrofon Aç/Kapat',
              ),
              CustomIconButton(
                onPressed: navigateToEvaluationPage,
                icon: Icons.call_end,
                backgroundColor: Colors.red,
                iconSize: 50.0,
                tooltip: 'Çağrıyı Sonlandır',
              ),
              CustomIconButton(
                onPressed: flipCamera,
                icon: currentFlipCameraIcon,
                tooltip: 'Kamera Çevir',
              ),
              CustomIconButton(
                onPressed: toggleSpeaker,
                icon: currentSpeakerIcon,
                tooltip: 'Hoparlör Aç/Kapat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
