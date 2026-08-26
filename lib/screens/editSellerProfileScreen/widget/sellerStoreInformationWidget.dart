import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:open_file/open_file.dart';
import 'package:project/helper/generalWidgets/bottomSheetMultipleCategorySelectionWidget.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/cities.dart';
import 'package:quill_html_editor/quill_html_editor.dart';

class SellerStoreInformationWidget extends StatefulWidget {
  final String from;
  final Map<String, dynamic> personalData;
  final Map<String, String> personalDataFile;

  const SellerStoreInformationWidget({Key? key, required this.personalData, required this.personalDataFile, required this.from}) : super(key: key);

  @override
  State<SellerStoreInformationWidget> createState() => SellerStoreInformationWidgetState();
}

class SellerStoreInformationWidgetState extends State<SellerStoreInformationWidget> {
  QuillEditorController quillEditorController = QuillEditorController();
  late TextEditingController edtCategoriesName  = TextEditingController(),
      edtCategoryIds = TextEditingController(),
      edtStoreName = TextEditingController(),
      edtStoreUrl = TextEditingController(),
      edtTaxName = TextEditingController(),
      edtTaxNumber = TextEditingController(),
      edtCommission = TextEditingController(),
      edtStoreAddress = TextEditingController(),
      edtSelectCity = TextEditingController(),
      edtCitiesName = TextEditingController();

  String edtStoreDescription = "";

  String selectedLogoPath = "";

  final formKey = GlobalKey<FormState>();
  String result = '';
  bool selfPickupMode = false;
  bool doorStepMode = false;
  late TextEditingController edtPickupStoreAddress  = TextEditingController(), edtPickupLatitude  = TextEditingController(), edtPickupLongitude  = TextEditingController(), edtPickupOpeningTime  = TextEditingController(), edtPickupClosingTime = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    /* edtCategoriesName = TextEditingController();
    edtCitiesName = TextEditingController();
    edtCategoryIds = TextEditingController();
    edtStoreName = TextEditingController();
    edtStoreUrl = TextEditingController();
    edtCommission = TextEditingController();
    edtTaxName = TextEditingController();
    edtTaxNumber = TextEditingController();
    edtSelectCity = TextEditingController();
    edtStoreAddress = TextEditingController();
    edtPickupStoreAddress = TextEditingController();
    edtPickupLatitude = TextEditingController();
    edtPickupLongitude = TextEditingController();
    edtPickupOpeningTime = TextEditingController();
    edtPickupClosingTime = TextEditingController(); */

    _initializeControllers();
    _addListeners();
  }

  void _addListeners() {
    // Add listeners to save data back to personalData when fields change
    edtStoreName.addListener(() => widget.personalData[ApiAndParams.storeName] = edtStoreName.text);
    edtStoreUrl.addListener(() => widget.personalData[ApiAndParams.store_url] = edtStoreUrl.text);
    edtTaxName.addListener(() => widget.personalData[ApiAndParams.tax_name] = edtTaxName.text);
    edtTaxNumber.addListener(() => widget.personalData[ApiAndParams.tax_number] = edtTaxNumber.text);
    edtCategoriesName.addListener(() => widget.personalData[ApiAndParams.categoriesName] = edtCategoriesName.text);
    edtCategoryIds.addListener(() {
      widget.personalData[ApiAndParams.categories] = edtCategoryIds.text;
      widget.personalData[ApiAndParams.categories_ids] = edtCategoryIds.text;
    });
    edtPickupStoreAddress.addListener(() => widget.personalData[ApiAndParams.pickupStoreAddress] = edtPickupStoreAddress.text);
    edtPickupLatitude.addListener(() => widget.personalData[ApiAndParams.pickupLatitude] = edtPickupLatitude.text);
    edtPickupLongitude.addListener(() => widget.personalData[ApiAndParams.pickupLongitude] = edtPickupLongitude.text);
    edtPickupOpeningTime.addListener(() => widget.personalData[ApiAndParams.openingTime] = edtPickupOpeningTime.text);
    edtPickupClosingTime.addListener(() => widget.personalData[ApiAndParams.closingTime] = edtPickupClosingTime.text);
  }

  void _initializeControllers() {
    edtCategoriesName.text = widget.personalData[ApiAndParams.categoriesName] == null
        ? Constant.session.getData(SessionManager.categoriesName)
        : widget.personalData[ApiAndParams.categoriesName];
    edtCitiesName.text = (widget.personalData[ApiAndParams.cities] as List<Cities>?)?.map((e) => e.name).join(', ') ?? '';
    edtCategoryIds.text = widget.personalData[ApiAndParams.categories] == null
        ? Constant.session.getData(SessionManager.categories)
        : widget.personalData[ApiAndParams.categories];
    edtStoreName.text = widget.personalData[ApiAndParams.storeName] == null
        ? Constant.session.getData(SessionManager.store_name)
        : widget.personalData[ApiAndParams.storeName];
    edtStoreUrl.text = widget.personalData[ApiAndParams.store_url] == null ? "-" : widget.personalData[ApiAndParams.store_url]??"";

    // Always restore file path from personalDataFile
    selectedLogoPath = widget.personalDataFile[ApiAndParams.store_logo] == null
        ? Constant.session.getData(SessionManager.logo_url)
        : widget.personalDataFile[ApiAndParams.store_logo].toString();

    edtStoreDescription = (widget.personalData[ApiAndParams.store_description] == null
        ? Constant.session.getData(SessionManager.store_description)
        : widget.personalData[ApiAndParams.store_description])!;

    edtCommission.text = Constant.sellerCommission;

    edtTaxName.text = widget.personalData[ApiAndParams.tax_name] == null
        ? Constant.session.getData(SessionManager.tax_name)
        : widget.personalData[ApiAndParams.tax_name];
    edtTaxNumber.text = widget.personalData[ApiAndParams.tax_number] == null
        ? Constant.session.getData(SessionManager.tax_number)
        : widget.personalData[ApiAndParams.tax_number];

    edtSelectCity.text = widget.personalData[ApiAndParams.state] == null
        ? Constant.session.getData(SessionManager.city_id)
        : widget.personalData[ApiAndParams.city_id];

    //selfpickup
    selfPickupMode = (widget.personalData[ApiAndParams.selfPickupMode]?.toString() == "1");

    edtPickupStoreAddress.text = widget.personalData[ApiAndParams.pickupStoreAddress] ?? "";
    edtPickupLatitude.text = widget.personalData[ApiAndParams.pickupLatitude]?.toString() ?? "";
    edtPickupLongitude.text = widget.personalData[ApiAndParams.pickupLongitude]?.toString() ?? "";
    edtPickupOpeningTime.text = widget.personalData[ApiAndParams.openingTime] ?? "";
    edtPickupClosingTime.text = widget.personalData[ApiAndParams.closingTime] ?? "";

    //doorstep
    doorStepMode = (widget.personalData[ApiAndParams.doorStepMode]?.toString() == "1");

    // Ensure at least one delivery mode is enabled when Constant.selfPickupMode == "1"
    if (Constant.selfPickupMode == "1" && !selfPickupMode && !doorStepMode) {
      // Default to doorStepMode if both are false
      doorStepMode = true;
    }
  }

  @override
  void didUpdateWidget(SellerStoreInformationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always refresh data when widget rebuilds (when navigating between steps)
    // The Map reference stays the same, but we need to reload from the map
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _initializeControllers();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      surfaceTintColor: ColorsRes.appColorTransparent,
      shape: DesignConfig.setRoundedBorder(7),
      elevation: 0,
      child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Constant.paddingOrMargin10,
            vertical: Constant.paddingOrMargin10,
          ),
          child: /*  Form(
          key: formKey,
          child: */
              Column(
            crossAxisAlignment: .start,
            children: [
              CustomTextLabel(
                jsonKey: storeInformationLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  color: ColorsRes.mainTextColor,
                ),
              ),
              getSizedBox(height: 10),
              Divider(height: 1, color: ColorsRes.grey.withValues(alpha: 0.5), thickness: 1),
              getSizedBox(height: 10),
              Consumer(
                builder: (context, value, child) {
                  return editBoxWidget(
                    context: context,
                    edtController: edtCategoriesName,
                    validationFunction: (value) => emptyValidation(value!, getTranslatedValue(context, enterCategoryIdsLabel)),
                    label: getTranslatedValue(context, categoryIdsLabel),
                    inputType: TextInputType.none,
                    nonFocusable: true,
                    tailIcon: GestureDetector(
                      onTap: () {
                        context.read<CategoryListProvider>().getCategoryApiProviderForRegistration(context: context).then((_) {
                          // After categories are loaded, show the bottom sheet;
                        showModalBottomSheet<Map<String, String>>(
                          backgroundColor: Theme.of(context).cardColor,
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                          builder: (BuildContext context) {
                            return Container(
                              padding: EdgeInsetsDirectional.only(
                                  start: Constant.paddingOrMargin15,
                                  end: Constant.paddingOrMargin15,
                                  top: Constant.paddingOrMargin15,
                                  bottom: Constant.paddingOrMargin15),
                              child: BottomSheetMultipleCategorySelectionWidget(),
                            );
                          },
                        ).then((value) {
                          if (value != null) {
                            edtCategoriesName.text = value["names"]!;
                            edtCategoryIds.text = value["ids"]!;
                            // Save to personalData for persistence
                            widget.personalData[ApiAndParams.categoriesName] = value["names"]!;
                            widget.personalData[ApiAndParams.categories] = value["ids"]!;
                            widget.personalData[ApiAndParams.categories_ids] = value["ids"]!;
                          }
                          setState(() {});
                        });
                        });
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.all(10),
                        child: defaultImg(
                          image: AppAssets.selectCategoriesIcon,
                          iconColor: ColorsRes.appColor,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtStoreName,
                validationFunction: (value) => emptyValidation(value!, getTranslatedValue(context, enterStoreNameLabel)),
                label: getTranslatedValue(context, storeNameLabel),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtStoreUrl,
                validationFunction: (value) => optionalFieldValidation("", ""),
                label: getTranslatedValue(context, storeUrlLabel),
                inputType: TextInputType.text,
              ),
              // getSizedBox(
              //   height: 10,
              // ),
              // editBoxWidget(
              //   context: context,
              //   edtController: edtCommission,
              //   validationFunction: percentageValidation,
              //   label: getTranslatedValue(context, commissionLabel),
              //   inputType: TextInputType.number,
              //   isEditable: false,
              // ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtTaxName,
                validationFunction: (value) => emptyValidation(value!, getTranslatedValue(context, enterTaxNameLabel)),
                label: getTranslatedValue(context, taxNameLabel),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              editBoxWidget(
                context: context,
                edtController: edtTaxNumber,
                validationFunction: (value) => emptyValidation(value!, getTranslatedValue(context, enterTaxNumberLabel)),
                label: getTranslatedValue(context, taxNumberLabel),
                inputType: TextInputType.text,
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  if (selectedLogoPath.isNotEmpty)
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
                        child: imgWidget(selectedLogoPath),
                      ),
                    ),
                  if (selectedLogoPath.isNotEmpty) getSizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // Single file path
                        /* FilePicker.platform
                            .pickFiles(
                                allowMultiple: false,
                                type: FileType.custom,
                                allowedExtensions: ["jpg", "jpeg", "png"],
                                lockParentWindow: true)
                            .then((value) {
                          if (value != null) {
                            cropImage(value.paths.first.toString());
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
                            cropImage(savedFile!.path.toString());
                            // selectedPath = savedFile!.path.toString();
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
                                  jsonKey: uploadLogoFileHereLabel,
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
              Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.sizeOf(context).width,
                  minHeight: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: ColorsRes.subTitleTextColor,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.all(10),
                      child: QuillHtmlEditor(
                        text: edtStoreDescription.isEmpty ? getTranslatedValue(context, descriptionGoesHereLabel) : edtStoreDescription,
                        hintText: getTranslatedValue(context, descriptionGoesHereLabel),
                        isEnabled: false,
                        ensureVisible: false,
                        minHeight: 10,
                        autoFocus: false,
                        textStyle: TextStyle(color: ColorsRes.mainTextColor),
                        hintTextStyle: TextStyle(color: ColorsRes.subTitleTextColor),
                        hintTextAlign: TextAlign.start,
                        padding: const EdgeInsets.only(left: 10, bottom: 2, top: 2),
                        hintTextPadding: const EdgeInsets.only(left: 20),
                        backgroundColor: Theme.of(context).cardColor,
                        inputAction: InputAction.newline,
                        loadingBuilder: (context) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: ColorsRes.appColor,
                            ),
                          );
                        },
                        controller: quillEditorController,
                      ),
                    ),
                    PositionedDirectional(
                      top: 0,
                      end: 0,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, htmlEditorScreen, arguments: edtStoreDescription).then(
                            (value) {
                              if (value != null) {
                                edtStoreDescription = value.toString();
                                widget.personalData[ApiAndParams.store_description] = edtStoreDescription;
                                quillEditorController.setText(edtStoreDescription);
                                setState(() {});
                              }
                            },
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: ColorsRes.appColor,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // if (widget.from.isNotEmpty)
              getSizedBox(
                height: 10,
              ),
              // if (widget.from.isNotEmpty)
              editBoxWidget(
                context: context,
                edtController: edtCitiesName,
                validationFunction: (value) => emptyValidation(value!, getTranslatedValue(context, enterSelectCityLabel)),
                label: getTranslatedValue(context, selectCityLabel),
                inputType: TextInputType.none,
                tailIcon: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, cityListScreen, arguments: false).then(
                      (value) {
                        /* if (value is Cities) {
                            widget.personalData.addAll({
                              ApiAndParams.address:
                                  value.formattedAddress.toString(),
                              ApiAndParams.city_id: value.id.toString(),
                            });
                            edtSelectCity.text =
                                value.formattedAddress.toString();
                          } */
                        if (value is List<Cities>) {
                          widget.personalData.addAll({
                            ApiAndParams.city_id: value.map((e) => e.id).join(','),
                            ApiAndParams.address: value.map((e) => e.formattedAddress).join(', '),
                            ApiAndParams.cities: value, // Store the actual List<Cities> object for persistence
                          });

                          edtSelectCity.text = value.map((e) => e.formattedAddress).join(', ');
                          edtCitiesName.text = value.map((e) => e.name).join(', ');
                          setState(() {});
                        }
                      },
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                    color: ColorsRes.appColor,
                  ),
                ),
              ),

              (Constant.selfPickupMode == "1") //(Constant.doorStepMode == "1")
                  ? SwitchListTile(
                      //dense: true,
                      title: CustomTextLabel(jsonKey: doorStepModeLabel),
                      inactiveTrackColor: ColorsRes.appColor,
                      activeTrackColor: ColorsRes.appColor,
                      value: doorStepMode, contentPadding: EdgeInsetsDirectional.zero,
                      onChanged: (value) {
                        // Prevent both from being false when Constant.selfPickupMode == "1"
                        if (!value && !selfPickupMode) {
                          // Don't allow turning off if selfPickupMode is also off
                          showMessage(context, getTranslatedValue(context, atLeastOneDeliveryModeRequiredLabel), MessageType.warning);
                          return;
                        }
                        setState(() {
                          doorStepMode = value;
                          widget.personalData[ApiAndParams.doorStepMode] = value ? "1" : "0";
                        });
                      },
                    )
                  : const SizedBox.shrink(),
              (Constant.selfPickupMode == "1")
                  ? Column(mainAxisSize: .min, children: [
                      SwitchListTile(
                        //dense: true,
                        title: CustomTextLabel(jsonKey: storePickupModeLabel),
                        inactiveTrackColor: ColorsRes.appColor,
                        activeTrackColor: ColorsRes.appColor,
                        value: selfPickupMode, contentPadding: EdgeInsetsDirectional.zero,
                        onChanged: (value) {
                          // Prevent both from being false when Constant.selfPickupMode == "1"
                          if (!value && !doorStepMode) {
                            // Don't allow turning off if doorStepMode is also off
                            showMessage(context, getTranslatedValue(context, atLeastOneDeliveryModeRequiredLabel), MessageType.warning);
                            return;
                          }
                          setState(() {
                            selfPickupMode = value;
                            widget.personalData[ApiAndParams.selfPickupMode] = value ? "1" : "0";
                          });
                        },
                      ),
                      if (selfPickupMode) ...[
                        getSizedBox(height: 10),
                        editBoxWidget(
                          context: context,
                          // isEditable: false,
                          readOnly: true,
                          maxlines: 1,
                          edtController: edtPickupStoreAddress,
                          validationFunction: (value) => (Constant.selfPickupMode == "1" && selfPickupMode)
                              ? emptyValidation(value!, getTranslatedValue(context, enterPickupStoreAddressLabel))
                              : optionalFieldValidation(value!, ""),
                          label: getTranslatedValue(context, pickupStoreAddressLabel),
                          inputType: TextInputType.text,
                          tailIcon: InkWell(
                            onTap: () async {
                              try {
                                debugPrint("Map icon tapped - navigating to map screen");
                                // Navigate to map screen
                                final result = await Navigator.pushNamed(
                                  context,
                                  mapScreen,
                                  arguments: {
                                    'latitude': edtPickupLatitude.text.isNotEmpty ? double.tryParse(edtPickupLatitude.text) : null,
                                    'longitude': edtPickupLongitude.text.isNotEmpty ? double.tryParse(edtPickupLongitude.text) : null,
                                    'address': edtPickupStoreAddress.text,
                                  },
                                );

                                debugPrint("Returned from map screen with result: $result");

                                if (result != null && result is Map<String, dynamic>) {
                                  setState(() {
                                    edtPickupStoreAddress.text = result['address'] ?? '';
                                    edtPickupLatitude.text = result['latitude']?.toString() ?? '';
                                    edtPickupLongitude.text = result['longitude']?.toString() ?? '';
                                  });
                                  debugPrint("Updated fields with: ${result['address']}, ${result['latitude']}, ${result['longitude']}");
                                }
                              } catch (e) {
                                debugPrint("Error navigating to map screen: $e");
                                showMessage(context, "Error opening map: $e", MessageType.error);
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.my_location,
                                color: ColorsRes.appColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        getSizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: edtPickupOpeningTime.text.contains(":")
                                        ? TimeOfDay(
                                            hour: int.tryParse(edtPickupOpeningTime.text.split(":")[0]) ?? TimeOfDay.now().hour,
                                            minute: int.tryParse(edtPickupOpeningTime.text.split(":")[1]) ?? TimeOfDay.now().minute,
                                          )
                                        : TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    edtPickupOpeningTime.text = pickedTime.format(context);
                                    setState(() {});
                                  }
                                },
                                child: AbsorbPointer(
                                  child: editBoxWidget(
                                    context: context,
                                    edtController: edtPickupOpeningTime,
                                    validationFunction: (value) => (Constant.selfPickupMode == "1" && selfPickupMode)
                                        ? emptyValidation(value!, getTranslatedValue(context, enterOpeningTimeLabel))
                                        : optionalFieldValidation(value!, ""),
                                    label: getTranslatedValue(context, openingTimeLabel),
                                    inputType: TextInputType.none,
                                  ),
                                ),
                              ),
                            ),
                            getSizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: edtPickupClosingTime.text.contains(":")
                                        ? TimeOfDay(
                                            hour: int.tryParse(edtPickupClosingTime.text.split(":")[0]) ?? TimeOfDay.now().hour,
                                            minute: int.tryParse(edtPickupClosingTime.text.split(":")[1]) ?? TimeOfDay.now().minute,
                                          )
                                        : TimeOfDay.now(),
                                  );
                                  if (pickedTime != null) {
                                    final openingParts = edtPickupOpeningTime.text.split(":");
                                    int openingMinutes = openingParts.length == 2
                                        ? (int.tryParse(openingParts[0]) ?? 0) * 60 + (int.tryParse(openingParts[1]) ?? 0)
                                        : 0;
                                    int closingMinutes = pickedTime.hour * 60 + pickedTime.minute;

                                    if (closingMinutes <= openingMinutes) {
                                      // Show error/
                                      /* ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(getTranslatedValue(context, "Closing time cannot be earlier than opening time")),
                                          duration: Duration(seconds: 2),
                                        ),
                                      ); */
                                      showMessage(context, getTranslatedValue(context, closingTimeValidationLabel), MessageType.warning);
                                    } else {
                                      edtPickupClosingTime.text = pickedTime.format(context);
                                      setState(() {});
                                    }
                                  }
                                },
                                child: AbsorbPointer(
                                  child: editBoxWidget(
                                    context: context,
                                    edtController: edtPickupClosingTime,
                                    validationFunction: (value) => (Constant.selfPickupMode == "1" && selfPickupMode)
                                        ? emptyValidation(value!, getTranslatedValue(context, enterClosingTimeLabel))
                                        : optionalFieldValidation(value!, ""),
                                    label: getTranslatedValue(context, closingTimeLabel),
                                    inputType: TextInputType.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ])
                  : const SizedBox.shrink(),
            ],
          ) /* ,
        ), */
          ),
    );
  }

  Future<void> cropImage(String filePath) async {
    await ImageCropper()
        .cropImage(
      sourcePath: filePath,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      maxHeight: 1024,
      maxWidth: 1024,
    )
        .then((croppedFile) {
      if (croppedFile != null) {
        setState(() {
          selectedLogoPath = croppedFile.path;
          // Save to personalDataFile for persistence when navigating between steps
          widget.personalDataFile[ApiAndParams.store_logo] = croppedFile.path;
        });
      }
    });
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
