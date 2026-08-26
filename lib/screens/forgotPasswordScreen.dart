import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';


// ignore: must_be_immutable
class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({
    Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final TextEditingController editEmailTextEditingController =
      TextEditingController();
  bool isDark = Constant.session.getBoolData(SessionManager.isDarkTheme);
  bool showPasswordWidget = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 0,
            child: Image.asset(
              Constant.getAssetsPath(0, "bg.jpg"),
              fit: BoxFit.fill,
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            top: 0,
            child: Image.asset(
              Constant.getAssetsPath(0, "bg_overlay.png"),
              fit: BoxFit.fill,
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: loginWidgets(),
          ),
          PositionedDirectional(
            top: 20,
            start: 0,
            child: backButtonText(),
          ),
        ],
      ),
    );
  }

  Widget backButtonText() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: ColorsRes.appColorTransparent,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: SizedBox(
            child: defaultImg(
              boxFit: BoxFit.contain,
              image: AppAssets.arrowBackIcon,
              iconColor: ColorsRes.mainTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget proceedBtn() {
    return (isLoading)
        ? Container(
            height: 55,
            alignment: AlignmentDirectional.center,
            child: CircularProgressIndicator(),
          )
        : gradientBtnWidget(
            context,
            10,
            otherWidgets: CustomTextLabel(
              jsonKey: verifyEmailLabel,
              softWrap: true,
              style: Theme.of(context).textTheme.titleMedium!.merge(
                    TextStyle(
                      color: ColorsRes.appColorWhite,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ),
            callback: () async {
              if (await fieldValidation() == true) {
                isLoading = true;
                setState(() {});
                try {
                  var value = await forgotPasswordApi(
                    context: context,
                    params: {
                      ApiAndParams.email: editEmailTextEditingController.text.trim(),
                      ApiAndParams.type: Constant.session.isSeller() ? "3" : "4",
                    },
                  );
                  isLoading = false;
                  setState(() {});
                  showMessage(
                    context,
                    getTranslatedValue(
                      context,
                      value[ApiAndParams.message].toString(),
                    ),
                    (value[ApiAndParams.status].toString() == "1")
                        ? MessageType.success
                        : MessageType.warning,
                  );

                  if (value[ApiAndParams.status].toString() == "1") {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  isLoading = false;
                  setState(() {});
                  showMessage(
                    context,
                    e.toString(),
                    MessageType.error,
                  );
                }
              }
            },
          );
  }

  Widget loginWidgets() {
    return Container(
      padding: EdgeInsetsDirectional.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextLabel(
            jsonKey: forgotPasswordTitleLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: 30,
              color: ColorsRes.appColor,
            ),
          ),
          getSizedBox(height: 20),
          /* Visibility(
            visible: true,
            child: Text(getTranslatedValue(context, systemUpgradeMessageLabel),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 12,
                color: ColorsRes.appColorRed,
              ),
            ),
          ),
          getSizedBox(height: 20), */
          emailPasswordWidget(),
          getSizedBox(height: 20),
          proceedBtn(),
          getSizedBox(height: 20),
        ],
      ),
    );
  }

  emailPasswordWidget() {
    return Column(
      children: [
        editBoxWidget(
          context: context,
          edtController: editEmailTextEditingController,
          validationFunction: (value)=> emailValidation(value!, getTranslatedValue(context, enterEmailLabel)),
          label: getTranslatedValue(
            context,
            emailLabel,
          ),
          hint: getTranslatedValue(
            context,
            enterValidEmailLabel,
          ),
          inputType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Future<bool> checkInternetConnection() async {
    bool check = false;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult[0] == ConnectivityResult.mobile ||
        connectivityResult[0] == ConnectivityResult.wifi ||
        connectivityResult[0] == ConnectivityResult.ethernet) {
      check = true;
    }
    return check;
  }

  Future<bool> fieldValidation() async {
    bool checkInternet = await checkInternetConnection();
    if (!checkInternet) {
      showMessage(
        context,
        getTranslatedValue(
          context,
          checkInternetLabel,
        ),
        MessageType.warning,
      );
      return false;
    }

    String email = editEmailTextEditingController.text.trim();
    if (email.isEmpty) {
      showMessage(
        context,
        "${getTranslatedValue(context, enterValidLabel)} ${getTranslatedValue(context, emailLabel)}",
        MessageType.warning,
      );
      return false;
    }

    String? emailErr = emailValidation(email, getTranslatedValue(context, enterEmailLabel));
    if (emailErr != null) {
      showMessage(
        context,
        getTranslatedValue(context, enterValidEmailLabel),
        MessageType.warning,
      );
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
