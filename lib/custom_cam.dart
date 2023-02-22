library custom_cam;

import 'package:camera/camera.dart';
import 'package:custom_cam/src/custom_icons_icons.dart';
import 'package:custom_cam/src/camera_alert.dart';
import 'package:custom_cam/src/custom_theme.dart';
import '/src/multimedia_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/camera_preview.dart' as camera_preview;

export 'src/multimedia_item.dart' show MultimediaItem;

class CustomCamera extends StatefulWidget {

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final bool isRecordingEnabled;

  const CustomCamera({Key? key, required this.primaryColor, required this.secondaryColor, required this.backgroundColor, this.isRecordingEnabled = false}) : super(key: key);

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> with WidgetsBindingObserver {

  List<CameraDescription> cameras = <CameraDescription>[];

  CameraController? controller;

  late bool _isVideoMode = false;
  late bool _isVideoRecording = false;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  Future<void> initCamera() async {
    exitCallback() => { Navigator.of(context).pop() };

    // initialize cameras.
    try {
      cameras = await availableCameras();
    }
    on CameraException catch (e) {
      CameraAlert exitAlert = CameraAlert(title: 'Ocurrió un error', description: 'No fue posible inicializar la cámara', positiveInput: 'Aceptar', negativeInput: '', positiveCallback: exitCallback);
      showDialog(context: context, builder: (_) { return exitAlert; });
      debugPrint("$e occurred while initializing the camera");
    }


    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(cameras[0], ResolutionPreset.high);

    controller = cameraController;

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value),
      ]);
    } on CameraException catch (e) {
      String errorDescription;
      switch (e.code) {
        case 'CameraAccessDenied':
          errorDescription = 'Los permisos de cámara son necesarios para usar esta funcionalidad';
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          errorDescription = 'Por favor conceda los permisos de cámara desde la configuración de la aplicación';
          break;
        case 'CameraAccessRestricted':
          // iOS only
          errorDescription = 'El acceso a la cámara se encuentra restringido';
          break;
        case 'AudioAccessDenied':
          errorDescription = 'Los permisos de grabación de audio son necesarios para usar esta funcionalidad';
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          errorDescription = 'Por favor conceda los permisos de grabación de audio desde la configuración de la aplicación';
          break;
        case 'AudioAccessRestricted':
          // iOS only
          errorDescription = 'El acceso a la grabación de audio se encuentra restringido';
          break;
        default:
          errorDescription = 'No fue posible inicializar la cámara';
          break;
      }
      CameraAlert exitAlert = CameraAlert(title: 'Ocurrió un error', description: errorDescription, positiveInput: 'Aceptar', negativeInput: '', positiveCallback: exitCallback);
      if (mounted) showDialog(context: context, builder: (_) { return exitAlert; });
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    CustomTheme.primaryColor = widget.primaryColor;
    CustomTheme.secondaryColor = widget.secondaryColor;
    CustomTheme.backgroundColor = widget.backgroundColor;
    // initialize the rear camera
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller?.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {return;}
    if (cameraController.value.isTakingPicture) {return;}
    try {
      lockDeviceOrientation();
      await cameraController.setFlashMode(FlashMode.off);
      XFile picture = await cameraController.takePicture();
      goToPreview(picture.path, false);
    }
    on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return;
    }
  }

  void lockDeviceOrientation() {
    List<DeviceOrientation> deviceOrientation = MediaQuery.of(context).orientation == Orientation.portrait ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown] : [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
    SystemChrome.setPreferredOrientations(deviceOrientation);
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {return;}
    if (cameraController.value.isRecordingVideo) {return;}
    try {
      lockDeviceOrientation();
      await cameraController.startVideoRecording();
    }
    on CameraException catch (e) {
      debugPrint('Error occurred while starting to record video: $e');
      return;
    }
  }

  Future<void> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (!cameraController!.value.isInitialized) {return;}
    if (!cameraController.value.isRecordingVideo) {return;}
    try {
      XFile video = await cameraController.stopVideoRecording();
      goToPreview(video.path, true);
    }
    on CameraException catch (e) {
      debugPrint('Error occurred while stopping video record: $e');
      return;
    }
  }

  void goToPreview(String url, bool isVideo) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => camera_preview.CameraPreview(multimediaItem: MultimediaItem(url, isVideo))));
    if (result is MultimediaItem) {
      if (mounted) Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child:
            Stack(
                children: [
                  _cameraPreviewWidget(),
                  OrientationBuilder(builder: (context, orientation) {
                    return Align(
                      alignment: orientation == Orientation.portrait ?  Alignment.topRight : Alignment.topLeft,
                      child: IconButton(onPressed: () {
                        exitCallback() => { Navigator.of(context).pop() };
                        CameraAlert exitAlert = CameraAlert(title: 'Salir de fotografías', description: 'Al salir perderá la información ingresada y no podrá recuperarla. ¿Desea continuar?', positiveInput: 'Salir', negativeInput: 'Volver', positiveCallback: exitCallback);
                        showDialog(context: context, builder: (_) { return exitAlert; });
                      }, icon: Icon(CustomIcons.close, size: 25, color: CustomTheme.secondaryColor)),
                    );
                  }),
                  OrientationBuilder(
                      builder: (context, orientation) {
                        return Align(
                            alignment: orientation == Orientation.portrait ? Alignment.bottomCenter : Alignment.centerRight,
                            child: Container(
                              height: orientation == Orientation.portrait ? 189 : null,
                              width: orientation == Orientation.portrait ? null : 189,
                              decoration: BoxDecoration(color: CustomTheme.backgroundColor.withOpacity(0.8)),
                              child:
                              Flex(direction: orientation == Orientation.portrait ? Axis.horizontal : Axis.vertical,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: TextButton(
                                          style: CustomTheme.circularButtonStyle,
                                          onPressed: () {
                                            setState(() => _isVideoMode = !_isVideoMode);
                                          },
                                          child: Icon(
                                              !_isVideoMode
                                                  ? Icons.videocam
                                                  : Icons.camera_alt,
                                              color: Colors.white,
                                              size: 30),
                                        )),
                                    Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            if (!_isVideoMode) {
                                              takePicture();
                                            }
                                            else {
                                              if (_isVideoRecording) {
                                                stopVideoRecording();
                                              }
                                              else {
                                                startVideoRecording();
                                              }

                                              setState(() => _isVideoRecording = !_isVideoRecording);
                                            }
                                          },
                                          style: CustomTheme.circularButtonStyle,
                                          child: Icon(
                                              !_isVideoMode
                                                  ? Icons.camera
                                                  : !_isVideoRecording ? Icons.fiber_manual_record : Icons.stop,
                                              color: Colors.white,
                                              size: 50),
                                        )),
                                    const Spacer(),
                                  ]),
                            )
                        );
                      }
                  )
                ])
        )
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: CameraPreview(
          controller!,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate
                );
              }),
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (controller == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);

    await controller!.setZoomLevel(_currentScale);
  }
}

