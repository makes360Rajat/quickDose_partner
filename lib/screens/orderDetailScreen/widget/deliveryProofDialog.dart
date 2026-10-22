import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/screens/orderDetailScreen/widget/inAppCameraScreen.dart';

class DeliveryProofDialog extends StatefulWidget {
  final String orderId;
  final String deliveryBoyId;
  final String statusId;
  final String? otp;

  const DeliveryProofDialog({
    Key? key,
    required this.orderId,
    required this.deliveryBoyId,
    required this.statusId,
    this.otp,
  }) : super(key: key);

  @override
  State<DeliveryProofDialog> createState() => _DeliveryProofDialogState();
}

class _DeliveryProofDialogState extends State<DeliveryProofDialog> {
  final List<File> _selectedImages = [];
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSubmitting = false;

  bool get _isOtpRequired =>
      widget.otp != null &&
      widget.otp != "0" &&
      widget.otp.toString().trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    try {
      final LostDataResponse response = await _imagePicker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null && response.file!.path.isNotEmpty) {
        final File file = File(response.file!.path);
        if (file.existsSync() && _selectedImages.length < 3) {
          setState(() {
            _selectedImages.add(file);
          });
        }
      } else if (response.files != null && response.files!.isNotEmpty) {
        setState(() {
          for (var x in response.files!) {
            if (_selectedImages.length < 3 && x.path.isNotEmpty) {
              final File file = File(x.path);
              if (file.existsSync()) {
                _selectedImages.add(file);
              }
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error retrieving lost camera data: $e");
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (_selectedImages.length >= 3) {
      showMessage(
        context,
        getTranslatedValue(context, max3ImagesAllowedLabel),
        MessageType.warning,
      );
      return;
    }

    try {
      // In-App Camera: keeps app in foreground so Android LMKD never kills the process
      final File? capturedFile = await Navigator.push<File>(
        context,
        MaterialPageRoute(builder: (_) => const InAppCameraScreen()),
      );

      if (capturedFile != null && capturedFile.existsSync()) {
        if (mounted) {
          setState(() {
            _selectedImages.add(capturedFile);
          });
        }
      }
    } catch (e) {
      debugPrint("In-app camera error, falling back to picker: $e");
      try {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
          maxWidth: 1024,
          maxHeight: 1024,
          preferredCameraDevice: CameraDevice.rear,
        );
        if (photo != null && photo.path.isNotEmpty) {
          final File file = File(photo.path);
          if (file.existsSync() && mounted) {
            setState(() {
              _selectedImages.add(file);
            });
          }
        }
      } catch (fallbackError) {
        if (mounted) {
          showMessage(context, "Could not open camera: ${fallbackError.toString()}", MessageType.error);
        }
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_selectedImages.length >= 3) {
      showMessage(
        context,
        getTranslatedValue(context, max3ImagesAllowedLabel),
        MessageType.warning,
      );
      return;
    }
    try {
      final List<XFile> photos = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photos.isNotEmpty) {
        int availableSlots = 3 - _selectedImages.length;
        List<File> newFiles = [];
        for (var x in photos.take(availableSlots)) {
          if (x.path.isNotEmpty) {
            final f = File(x.path);
            if (f.existsSync()) newFiles.add(f);
          }
        }
        if (photos.length > availableSlots) {
          showMessage(
            context,
            getTranslatedValue(context, max3ImagesAllowedLabel),
            MessageType.warning,
          );
        }
        if (newFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(newFiles);
          });
        }
      }
    } catch (e) {
      try {
        final XFile? singlePhoto = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (singlePhoto != null && singlePhoto.path.isNotEmpty) {
          final f = File(singlePhoto.path);
          if (f.existsSync()) {
            setState(() {
              _selectedImages.add(f);
            });
            return;
          }
        }
      } catch (_) {}

      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
          allowMultiple: true,
        );
        if (result != null && result.paths.isNotEmpty) {
          int availableSlots = 3 - _selectedImages.length;
          List<File> newFiles = [];
          for (String? path in result.paths) {
            if (path != null && path.isNotEmpty) {
              final f = File(path);
              if (f.existsSync()) {
                newFiles.add(f);
              }
            }
          }
          if (newFiles.length > availableSlots) {
            showMessage(
              context,
              getTranslatedValue(context, max3ImagesAllowedLabel),
              MessageType.warning,
            );
            newFiles = newFiles.sublist(0, availableSlots);
          }
          if (newFiles.isNotEmpty) {
            setState(() {
              _selectedImages.addAll(newFiles);
            });
          }
        }
      } catch (_) {
        showMessage(context, e.toString(), MessageType.error);
      }
    }
  }

  void _showImageSourcePicker() {
    if (_selectedImages.length >= 3) {
      showMessage(
        context,
        getTranslatedValue(context, max3ImagesAllowedLabel),
        MessageType.warning,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsRes.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextLabel(
                  jsonKey: selectImageSourceLabel,
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt_rounded,
                      title: getTranslatedValue(context, captureImageLabel),
                      color: ColorsRes.appColor,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _captureFromCamera();
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library_rounded,
                      title: getTranslatedValue(context, chooseFromGalleryLabel),
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _pickFromGallery();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: ColorsRes.mainTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (_selectedImages.isEmpty) {
      showMessage(
        context,
        getTranslatedValue(context, atLeastOneImageRequiredLabel),
        MessageType.warning,
      );
      return;
    }

    if (_isOtpRequired) {
      if (_otpController.text.trim().length != 6) {
        showMessage(
          context,
          getTranslatedValue(context, enter6DigitOtpLabel),
          MessageType.warning,
        );
        return;
      }
      if (_otpController.text.trim() != widget.otp.toString().trim()) {
        showMessage(
          context,
          getTranslatedValue(context, invalidOtpLabel),
          MessageType.warning,
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    Map<String, String> params = {
      ApiAndParams.orderId: widget.orderId,
      ApiAndParams.statusId: widget.statusId,
      ApiAndParams.deliveryBoyId: widget.deliveryBoyId,
    };

    Map<String, File> filesMap = {};
    for (int i = 0; i < _selectedImages.length; i++) {
      filesMap["delivery_images[$i]"] = _selectedImages[i];
    }

    try {
      OrderUpdateStatusProvider ordersProvider;
      try {
        ordersProvider = context.read<OrderUpdateStatusProvider>();
      } catch (_) {
        ordersProvider = OrderUpdateStatusProvider();
      }
      var result = await ordersProvider.updateOrdersStatus(
        params: params,
        filesMap: filesMap,
        context: context,
      );

      if (mounted) {
        if (result == true) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        showMessage(context, e.toString(), MessageType.error);
      }
    }
  }

  void _showPreview(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext previewContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  child: Image.file(
                    imageFile,
                    cacheWidth: 1024,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 48)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.pop(previewContext),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canSubmit = _selectedImages.isNotEmpty &&
        (!_isOtpRequired || _otpController.text.trim().length == 6);

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsRes.appColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: ColorsRes.appColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextLabel(
                          jsonKey: proofOfDeliveryLabel,
                          style: TextStyle(
                            color: ColorsRes.mainTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        CustomTextLabel(
                          jsonKey: deliveredItemsProofLabel,
                          style: TextStyle(
                            color: ColorsRes.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // OTP Section (if required)
              if (_isOtpRequired) ...[
                CustomTextLabel(
                  jsonKey: customerWillShareOtpLabel,
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  focusNode: Platform.isIOS ? _focusNode : null,
                  style: TextStyle(
                    color: ColorsRes.mainTextColor,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: getTranslatedValue(context, enter6DigitOtpLabel),
                    hintStyle: TextStyle(
                      color: ColorsRes.grey,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorsRes.grey.withValues(alpha: 0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: ColorsRes.appColor, width: 1.5),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Images Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextLabel(
                    text: "${getTranslatedValue(context, addProofOfDeliveryPhotoLabel)} *",
                    style: TextStyle(
                      color: ColorsRes.mainTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "${_selectedImages.length}/3",
                    style: TextStyle(
                      color: _selectedImages.isEmpty ? ColorsRes.appColorRed : ColorsRes.appColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CustomTextLabel(
                jsonKey: atLeastOneImageRequiredLabel,
                style: TextStyle(
                  color: ColorsRes.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              // Image Selector Options when empty
              if (_selectedImages.isEmpty)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _captureFromCamera,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: ColorsRes.appColor.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ColorsRes.appColor,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ColorsRes.appColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: ColorsRes.appColor,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                getTranslatedValue(context, captureImageLabel),
                                style: TextStyle(
                                  color: ColorsRes.mainTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickFromGallery,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library_rounded,
                                  color: Colors.blueAccent,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                getTranslatedValue(context, chooseFromGalleryLabel),
                                style: TextStyle(
                                  color: ColorsRes.mainTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              // Image Thumbnails & Add More Button
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...List.generate(_selectedImages.length, (index) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () => _showPreview(_selectedImages[index]),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: ColorsRes.appColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 80,
                                  height: 80,
                                  cacheWidth: 200,
                                  cacheHeight: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        color: ColorsRes.grey.withValues(alpha: 0.2),
                                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 24),
                                      ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedImages.length < 3)
                      GestureDetector(
                        onTap: _showImageSourcePicker,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: ColorsRes.appColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorsRes.appColor,
                              width: 1.2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: ColorsRes.appColor,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "+ Add",
                                style: TextStyle(
                                  color: ColorsRes.appColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: ColorsRes.grey.withValues(alpha: 0.4)),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        getTranslatedValue(context, cancelLabel),
                        style: TextStyle(
                          color: ColorsRes.mainTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsRes.appColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        disabledBackgroundColor: ColorsRes.grey.withValues(alpha: 0.3),
                      ),
                      onPressed: canSubmit && !_isSubmitting ? _submit : null,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              getTranslatedValue(context, submitLabel),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
