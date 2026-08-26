import 'package:dotted_border/dotted_border.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/helper/utils/keyboardOverlay.dart';
import 'package:project/provider/passwordShowHideProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

class SellerPersonalInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, dynamic> personalData;
  final Map<String, String> personalDataFile;

  const SellerPersonalInformationWidget({Key? key, required this.personalData, required this.personalDataFile, required this.from}) : super(key: key);

  @override
  State<SellerPersonalInformationWidget> createState() => SellerPersonalInformationWidgetState();
}

class SellerPersonalInformationWidgetState extends State<SellerPersonalInformationWidget> {
  TextEditingController edtUsername = TextEditingController();
  TextEditingController edtEmail = TextEditingController();
  TextEditingController edtMobile = TextEditingController();
  TextEditingController edtPanNumber = TextEditingController();
  TextEditingController edtPassword = TextEditingController();
  TextEditingController edtConfirmPassword = TextEditingController();

  String selectedAddressProofPath = "";
  String selectedNationalIdPath = "";

  final formKey = GlobalKey<FormState>();

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      bool hasFocus = focusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    _initializeControllers();
  }

  void _initializeControllers() {
    edtUsername.text = widget.personalData[ApiAndParams.name] ?? "";
    edtEmail.text = widget.personalData[ApiAndParams.email] ?? "";
    edtMobile.text = widget.personalData[ApiAndParams.mobile] ?? "";
    edtPanNumber.text = widget.personalData[ApiAndParams.pan_number] ?? "";

    // Always restore file paths from personalDataFile
    if (widget.personalDataFile[ApiAndParams.address_proof].toString() == "null") {
      widget.personalDataFile[ApiAndParams.address_proof] = "";
    }
    if (widget.personalDataFile[ApiAndParams.national_id_card].toString() == "null") {
      widget.personalDataFile[ApiAndParams.national_id_card] = "";
    }
    selectedNationalIdPath = widget.personalDataFile[ApiAndParams.national_id_card].toString();
    selectedAddressProofPath = widget.personalDataFile[ApiAndParams.address_proof].toString();

    edtPassword.text = widget.personalData[ApiAndParams.password] ?? "";
    edtConfirmPassword.text = widget.personalData[ApiAndParams.confirm_password] ?? "";
  }

  @override
  void didUpdateWidget(SellerPersonalInformationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reinitialize if the personalData reference actually changed (e.g., from API refresh)
    // Don't reinitialize on validation failures as it resets user input
    if (oldWidget.personalData != widget.personalData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _initializeControllers();
          });
        }
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: ColorsRes.appColorTransparent,
      elevation: 0,
      child: Padding(
        padding: EdgeInsetsDirectional.all(15),
        child: /* Form(
          key: formKey,
          child: */ Column(
            crossAxisAlignment: .start,
            children: [
              CustomTextLabel(
                jsonKey: personalInformationLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ColorsRes.mainTextColor,
                ),
              ),
              getSizedBox(height: 10),
              Divider(height: 1, color: ColorsRes.grey.withValues(alpha: 0.5), thickness: 1),
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtUsername,
                validationFunction: (value)=>emptyValidation(value,  getTranslatedValue(context, enterUserNameLabel)),
                label: getTranslatedValue(context, userNameLabel),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtEmail,
                validationFunction: (value)=> emailValidation(value!,  getTranslatedValue(context, enterEmailLabel)),
                label: getTranslatedValue(context, emailLabel),
                isEditable: widget.from == "registration",
                readOnly: widget.from.isEmpty,
                inputType: TextInputType.emailAddress,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtMobile,
                validationFunction: (value)=> phoneValidation(value!,  getTranslatedValue(context, enterValidMobileLabel)),
                label: getTranslatedValue(context, mobileLabel),
                inputType: TextInputType.phone,
                focusNode: Platform.isIOS ? focusNode : null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CustomNumberTextInputFormatter()],
              ),
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isEmpty)
                CustomTextLabel(
                  jsonKey: keepBlankIfDontWantToChangePasswordLabel,
                  softWrap: true,
                  style: TextStyle(
                    color: ColorsRes.appColorRed,
                    fontSize: 12,
                  ),
                ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 5,
                ),
              ChangeNotifierProvider<PasswordShowHideProvider>(
                create: (context) => PasswordShowHideProvider(),
                child: Consumer<PasswordShowHideProvider>(
                  builder: (context, passwordShowHideProvider, child) {
                    return editBoxWidget(
                      context: context,
                      edtController: edtPassword,
                      validationFunction: (val) => widget.from == "registration" ? passwordValidation(val, getTranslatedValue(context, enterPasswordLabel)) : optionalFieldValidation(val!, getTranslatedValue(context, enterPasswordLabel)),
                      label: getTranslatedValue(context, passwordLabel),
                      inputType: TextInputType.text,
                      tailIcon: GestureDetector(
                        onTap: () {
                          passwordShowHideProvider.showHidePassword();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            child: defaultImg(
                              image: passwordShowHideProvider.hidePassword == true ? AppAssets.hidePasswordIcon : AppAssets.showPasswordIcon,
                              iconColor: ColorsRes.appColor,
                            ),
                            height: 10,
                            width: 10,
                          ),
                        ),
                      ),
                      ishidetext: passwordShowHideProvider.hidePassword == true,
                      maxlines: 1,
                    );
                  },
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              if (widget.from.isEmpty)
                CustomTextLabel(
                  jsonKey: keepBlankIfDontWantToChangePasswordLabel,
                  softWrap: true,
                  style: TextStyle(
                    color: ColorsRes.appColorRed,
                    fontSize: 12,
                  ),
                ),
              if (widget.from.isEmpty)
                getSizedBox(
                  height: 5,
                ),
              ChangeNotifierProvider<PasswordShowHideProvider>(
                create: (context) => PasswordShowHideProvider(),
                child: Consumer<PasswordShowHideProvider>(
                  builder: (context, passwordShowHideProvider, child) {
                    // print("data:${widget.from == "registration"}--${widget.from == "registration" ? "Helllo" : "World"}");
                    return editBoxWidget(
                        context: context,
                        edtController: edtConfirmPassword,
                        validationFunction: (val) => widget.from == "registration" ? validateConfirmPassword(val, edtPassword.text) : optionalFieldValidation(val!, getTranslatedValue(context, enterPasswordLabel)),
                        label: getTranslatedValue(context, confirmPasswordLabel),
                        inputType: TextInputType.text,
                        tailIcon: GestureDetector(
                          onTap: () {
                            passwordShowHideProvider.showHidePassword();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              child: defaultImg(
                                image: passwordShowHideProvider.hidePassword == true ? AppAssets.hidePasswordIcon : AppAssets.showPasswordIcon,
                                iconColor: ColorsRes.appColor,
                              ),
                              height: 10,
                              width: 10,
                            ),
                          ),
                        ),
                        ishidetext: passwordShowHideProvider.hidePassword == true,
                        maxlines: 1);
                  },
                ),
              ),
              //National Id Proof
              CustomTextLabel(
                jsonKey: nationalIdentificationCardLabel,
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedNationalIdPath.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      height: 105,
                      width: 105,
                      child: Center(
                        child: imgWidget(selectedNationalIdPath),
                      ),
                    ),
                  if (selectedNationalIdPath.isNotEmpty) getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        /* FilePicker.platform
                            .pickFiles(
                          allowMultiple: false,
                          allowCompression: true,
                          type: FileType.custom,
                          allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
                          lockParentWindow: true,
                        )
                            .then((value) {
                          if (value != null) {
                            selectedNationalIdPath = value.paths.first.toString();
                            setState(() {});
                          }
                        }); */
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                        );

                        if (result != null && result.files.single.path != null) {
                          File pickedFile = File(result.files.single.path!);
                          debugPrint("Selected file path: ${pickedFile.path}");

                          // Check if file exists
                          if (!await pickedFile.exists()) {
                            debugPrint("File does not exist: ${pickedFile.path}");
                            return;
                          }

                          // Move file to a persistent location
                          File? savedFile = await saveFileToLocalStorage(pickedFile);

                          // Set state if valid
                          setState(() {
                            selectedNationalIdPath = savedFile!.path.toString();
                          });

                          debugPrint("File ready for upload: ${savedFile!.path}");
                        } else {
                          debugPrint("No file selected");
                        }
                      },
                      child: DottedBorder(
                        /* dashPattern: [5],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        color: ColorsRes.subTitleTextColor,
                        radius: Radius.circular(10),
                        borderType: BorderType.RRect, */
                        options: RoundedRectDottedBorderOptions(
                          dashPattern: [5],
                          strokeWidth: 2,
                          radius: Radius.circular(10),
                          color: ColorsRes.subTitleTextColor,
                          // padding: EdgeInsets.all(16),
                        ),
                        child: Container(
                          height: 100,
                          color: ColorsRes.appColorTransparent,
                          padding: EdgeInsetsDirectional.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                defaultImg(
                                  image: AppAssets.uploadIcon,
                                  iconColor: ColorsRes.subTitleTextColor,
                                  height: 40,
                                  width: 40,
                                ),
                                CustomTextLabel(
                                  jsonKey: uploadNidFileHereLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorsRes.subTitleTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              //National Id Proof
              CustomTextLabel(
                jsonKey: addressProofLabel,
                style: TextStyle(
                  color: ColorsRes.mainTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedAddressProofPath.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: ColorsRes.subTitleTextColor,
                          ),
                          color: Theme.of(context).cardColor),
                      height: 105,
                      width: 105,
                      child: Center(
                        child: imgWidget(selectedAddressProofPath),
                      ),
                    ),
                  if (selectedAddressProofPath.isNotEmpty) getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        /* FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                allowCompression: true,
                                type: FileType.custom,
                                allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
                                lockParentWindow: true)
                            .then((value) {
                          if (value != null) {
                            selectedAddressProofPath = value.paths.first.toString();
                            setState(() {});
                          }
                        }); */
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['jpg', 'jpeg', 'png'],
                        );

                        if (result != null && result.files.single.path != null) {
                          File pickedFile = File(result.files.single.path!);
                          debugPrint("Selected file path: ${pickedFile.path}");

                          // Check if file exists
                          if (!await pickedFile.exists()) {
                            debugPrint("File does not exist: ${pickedFile.path}");
                            return;
                          }

                          // Move file to a persistent location
                          File? savedFile = await saveFileToLocalStorage(pickedFile);

                          // Set state if valid
                          setState(() {
                            selectedAddressProofPath = savedFile!.path.toString();
                          });

                          debugPrint("File ready for upload: ${savedFile!.path}");
                        } else {
                          debugPrint("No file selected");
                        }
                      },
                      child: DottedBorder(
                        /* dashPattern: [5],
                        strokeWidth: 2,
                        strokeCap: StrokeCap.round,
                        color: ColorsRes.subTitleTextColor,
                        radius: Radius.circular(10),
                        borderType: BorderType.RRect, */
                        options: RoundedRectDottedBorderOptions(
                          dashPattern: [5],
                          strokeWidth: 2,
                          radius: Radius.circular(10),
                          color: ColorsRes.subTitleTextColor,
                          // padding: EdgeInsets.all(16),
                        ),
                        child: Container(
                          height: 100,
                          color: ColorsRes.appColorTransparent,
                          padding: EdgeInsetsDirectional.all(10),
                          child: Center(
                            child: Column(
                              children: [
                                defaultImg(
                                  image: AppAssets.uploadIcon,
                                  iconColor: ColorsRes.subTitleTextColor,
                                  height: 40,
                                  width: 40,
                                ),
                                CustomTextLabel(
                                  jsonKey: uploadAddressProofFileHereLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ColorsRes.subTitleTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              getSizedBox(height: 10),
              editBoxWidget(
                context: context,
                edtController: edtPanNumber,
                validationFunction: (value)=> emptyValidation(value!,  getTranslatedValue(context, enterPersonalIdentityNumberLabel)),
                label: getTranslatedValue(context, personalIdentityNumberLabel),
                inputType: TextInputType.text,
              ),
              if (widget.from.isNotEmpty)
                getSizedBox(
                  height: 10,
                ),
            ],
          )/* ,
        ), */
      ),
    );
  }

  imgWidget(String fileName) {
    return GestureDetector(
      onTap: () {
        try {
          OpenFile.open(fileName);
        } catch (e) {
          showMessage(context, e.toString(), MessageType.error);
        }
      },
      child: fileName.split(".").last == "pdf"
          ? Center(
              child: defaultImg(
                image: AppAssets.pdfIcon,
                height: 50,
                width: 50,
              ),
            )
          : ClipRRect(
              borderRadius: Constant.borderRadius10,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: (fileName.contains("https://") || fileName.contains("http://"))
                  ? setNetworkImg(
                      image: fileName,
                      width: 90,
                      height: 90,
                      boxFit: BoxFit.fill,
                    )
                  : Image.file(
                      File(fileName),
                      fit: BoxFit.cover,
                    ),
            ),
    );
  }
}
