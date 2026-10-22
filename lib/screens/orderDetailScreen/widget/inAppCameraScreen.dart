import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project/helper/utils/generalImports.dart';

class InAppCameraScreen extends StatefulWidget {
  const InAppCameraScreen({Key? key}) : super(key: key);

  @override
  State<InAppCameraScreen> createState() => _InAppCameraScreenState();
}

class _InAppCameraScreenState extends State<InAppCameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.auto;
  XFile? _capturedPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          showMessage(
            context,
            "Camera permission is required to capture proof of delivery photo",
            MessageType.warning,
          );
          Navigator.pop(context, null);
        }
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          showMessage(context, "No camera found on this device", MessageType.error);
          Navigator.pop(context, null);
        }
        return;
      }

      // Default to rear camera
      int rearIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _selectedCameraIndex = rearIndex >= 0 ? rearIndex : 0;
      await _initCameraController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        showMessage(context, "Could not initialize camera: $e", MessageType.error);
        Navigator.pop(context, null);
      }
    }
  }

  Future<void> _initCameraController(CameraDescription camera) async {
    final previousController = _controller;
    if (previousController != null) {
      await previousController.dispose();
    }

    final CameraController controller = CameraController(
      camera,
      ResolutionPreset.medium, // Optimal balance of crisp photo and low memory
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Camera controller init error: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        showMessage(context, "Camera error: $e", MessageType.error);
      }
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() {
      _isInitializing = true;
    });
    await _initCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.off;
        break;
      case FlashMode.off:
      default:
        nextMode = FlashMode.auto;
        break;
    }
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (e) {
      debugPrint("Flash error: $e");
    }
  }

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile photo = await controller.takePicture();
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _capturedPhoto = photo;
        });
      }
    } catch (e) {
      debugPrint("Take picture error: $e");
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        showMessage(context, "Capture failed: $e", MessageType.error);
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedPhoto != null) {
      final File file = File(_capturedPhoto!.path);
      Navigator.pop(context, file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Preview / Camera Viewfinder
            if (_capturedPhoto != null)
              Positioned.fill(
                child: Image.file(
                  File(_capturedPhoto!.path),
                  fit: BoxFit.contain,
                ),
              )
            else if (!_isInitializing &&
                _controller != null &&
                _controller!.value.isInitialized)
              Positioned.fill(
                child: Center(
                  child: CameraPreview(_controller!),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Top Control Bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ),
                  if (_capturedPhoto == null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: Icon(
                              _flashMode == FlashMode.auto
                                  ? Icons.flash_auto
                                  : _flashMode == FlashMode.always
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                              color: _flashMode == FlashMode.off
                                  ? Colors.grey
                                  : Colors.amber,
                            ),
                            onPressed: _toggleFlash,
                          ),
                        ),
                        if (_cameras.length > 1) ...[
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              icon: const Icon(
                                Icons.flip_camera_android_rounded,
                                color: Colors.white,
                              ),
                              onPressed: _toggleCamera,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Hint Text when camera is live
            if (_capturedPhoto == null && !_isInitializing)
              Positioned(
                top: 70,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Capture Proof of Delivery Photo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

            // Bottom Control Bar
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _capturedPhoto != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Retake button
                        GestureDetector(
                          onTap: _retakePhoto,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.replay_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Retake",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Confirm/Use button
                        GestureDetector(
                          onTap: _confirmPhoto,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: BoxDecoration(
                                  color: ColorsRes.appColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ColorsRes.appColor.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Use Photo",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isCapturing
                                  ? Colors.grey
                                  : ColorsRes.appColor,
                              shape: BoxShape.circle,
                            ),
                            child: _isCapturing
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
