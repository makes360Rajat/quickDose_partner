import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/helper/utils/generalImports.dart';

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
  bool _isSubmitting = false;

  bool get _isOtpRequired =>
      widget.otp != null &&
      widget.otp != "0" &&
      widget.otp.toString().trim().isNotEmpty;

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) {
      showMessage(
        context,
        getTranslatedValue(context, max3ImagesAllowedLabel),
        MessageType.warning,
      );
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: true,
      );
      if (result != null && result.paths.isNotEmpty) {
        List<File> newFiles = [];
        for (String? path in result.paths) {
          if (path != null && path.isNotEmpty) {
            newFiles.add(File(path));
          }
        }
        int availableSlots = 3 - _selectedImages.length;
        if (newFiles.length > availableSlots) {
          showMessage(
            context,
            getTranslatedValue(context, max3ImagesAllowedLabel),
            MessageType.warning,
          );
          newFiles = newFiles.sublist(0, availableSlots);
        }
        setState(() {
          _selectedImages.addAll(newFiles);
        });
      }
    } catch (e) {
      showMessage(context, e.toString(), MessageType.error);
    }
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
      final ordersProvider = context.read<OrderUpdateStatusProvider>();
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
                      color: ColorsRes.appColor.withOpacity(0.12),
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
                      borderSide: BorderSide(color: ColorsRes.grey.withOpacity(0.4)),
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

              // Images Section
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
                      color: _selectedImages.isEmpty ? ColorsRes.red : ColorsRes.appColor,
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

              // Image Thumbnails & Add Button
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ...List.generate(_selectedImages.length, (index) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorsRes.appColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.file(
                              _selectedImages[index],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
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
                      onTap: _pickImages,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: ColorsRes.appColor.withOpacity(0.06),
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
                              size: 26,
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
                        side: BorderSide(color: ColorsRes.grey.withOpacity(0.4)),
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
                        disabledBackgroundColor: ColorsRes.grey.withOpacity(0.3),
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
