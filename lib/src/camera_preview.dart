import 'dart:io';

import 'package:custom_cam/src/custom_icons_icons.dart';
import 'package:custom_cam/src/multimedia_item.dart';
import 'package:custom_cam/src/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'camera_alert.dart';

class CameraPreview extends StatefulWidget {

  final MultimediaItem multimediaItem;

  const CameraPreview({Key? key, required this.multimediaItem}) : super(key: key);

  @override
  State<CameraPreview> createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    if (widget.multimediaItem.isVideo) {
      startVideoPlayer();
    }
  }

  Future startVideoPlayer() async {
    _videoController = VideoPlayerController.file(File(widget.multimediaItem.path));
    await _videoController!.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized,
      // even before the play button has been pressed.
      setState(() {});
    });
    await _videoController!.setLooping(true);
    await _videoController!.play();
  }

  Future saveToDocuments() async {
    int currentUnix = DateTime.now().millisecondsSinceEpoch;

    final directory = await getApplicationDocumentsDirectory();
    String fileFormat = widget.multimediaItem.path.split('.').last;

    await File(widget.multimediaItem.path).copy('${directory.path}/$currentUnix.$fileFormat',);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Ensure disposing of the VideoPlayerController to free up resources.
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              !widget.multimediaItem.isVideo ? Image.file(File(widget.multimediaItem.path))
                  : SizedBox(
                width: double.infinity, height: double.infinity,
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: GestureDetector(
                    child: VideoPlayer(_videoController!),
                    onTap: () {
                      // Wrap the play or pause in a call to `setState`. This ensures the
                      // correct icon is shown.
                      setState(() {
                        // If the video is playing, pause it.
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          // If the video is paused, play it.
                          _videoController!.play();
                        }
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(onPressed: () {
                  exitCallback() => { Navigator.of(context).pop() };
                  CameraAlert exitAlert = CameraAlert(title: 'Salir de fotografías', description: 'Al salir perderá la información ingresada y no podrá recuperarla. ¿Desea continuar?', positiveInput: 'Salir', negativeInput: 'Volver', positiveCallback: exitCallback);
                  showDialog(context: context, builder: (_) { return exitAlert; });
                }, icon: Icon(CustomIcons.close, size: 23.w), color: CustomTheme.secondaryColor),
              ),
              OrientationBuilder(
                  builder: (context, orientation) {
                    return Align(
                        alignment: orientation == Orientation.portrait ? Alignment.bottomCenter : Alignment.centerRight,
                        child: Container(
                          height: orientation == Orientation.portrait ? 189.h : double.infinity,
                          width: orientation == Orientation.portrait ? double.infinity : 189.w,
                          decoration: BoxDecoration(color: CustomTheme.backgroundColor.withOpacity(0.8)),
                          child:
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250.w,
                                  child: TextButton(
                                      onPressed: () {
                                        saveToDocuments();
                                        Navigator.of(context).pop(widget.multimediaItem);
                                      },
                                      style: CustomTheme.textButtonStyle,
                                      child: const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Text('Guardar'),
                                      )
                                  ),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    style: TextButton.styleFrom(
                                        foregroundColor: CustomTheme.primaryColor
                                    ),
                                    child: Text('Volver a tomar', style: TextStyle(fontFamily: 'IBMPlexSans', fontSize: 14.sp, fontWeight: FontWeight.w700))
                                ),
                              ]),
                        )
                    );
                  }
              )
            ],
          ),
        )
    );
  }
}
