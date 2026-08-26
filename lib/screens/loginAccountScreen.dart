import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class LoginAccountScreen extends StatefulWidget {
  LoginAccountScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginAccountScreen> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  // TODO REMOVE DEMO EMAIL FROM HERE
  late TextEditingController edtEmail = TextEditingController(
      text: Constant.session.isSeller()
          ? ""
          : "");

  // TODO REMOVE DEMO PASSWORD FROM HERE
  late TextEditingController edtPassword =
      TextEditingController(text: "");
  bool isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      try {
        // await LocalAwesomeNotification().init(context);

        await FirebaseMessaging.instance.getToken().then((token) {
          Constant.session.setData(SessionManager.keyFCMToken, token!, false);
        });
        /* FirebaseMessaging.onBackgroundMessage(
            LocalAwesomeNotification.onBackgroundMessageHandler); */
      } catch (ignore) {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        context: context,
        title: /* CustomTextLabel(
          jsonKey: loginLabel,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ) */const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.paddingOrMargin15,
                vertical: Constant.paddingOrMargin15,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60),
                    // Logo
                    SizedBox(
                      height: MediaQuery.sizeOf(context).width * 0.35,
                      child: defaultImg(image: AppAssets.logoIcon),
                    ),
                    SizedBox(height: 30),
                    Card(
                      color: Theme.of(context).cardColor,
                      surfaceTintColor: ColorsRes.appColorTransparent,
                      shape: DesignConfig.setRoundedBorder(10),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Constant.paddingOrMargin15,
                            vertical: Constant.paddingOrMargin15),
                        child: Column(
                          children: [
                            // Email field
                            TextField(
                              controller: edtEmail,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(color: ColorsRes.mainTextColor),
                              decoration: InputDecoration(fillColor: Theme.of(context).scaffoldBackgroundColor, filled: true,
                                hintText: getTranslatedValue(context, emailLabel),
                                hintStyle: TextStyle(color: ColorsRes.grey),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: defaultImg(
                                    image: AppAssets.mailIcon,
                                    iconColor: ColorsRes.grey,
                                    width: 22,
                                    height: 22,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 16),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                    color: ColorsRes.appColor,
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                    color: ColorsRes.subTitleTextColor.withValues(alpha: 0.5),
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                    color: ColorsRes.appColorRed,
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                    color: ColorsRes.subTitleTextColor,
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  borderSide: BorderSide(
                                    color: ColorsRes.subTitleTextColor.withValues(alpha: 0.5),
                                    width: 1,
                                    style: BorderStyle.solid,
                                    strokeAlign: BorderSide.strokeAlignCenter,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            // Password field
                            Consumer<UserProfileProvider>(
                              builder: (context, userProfileProvider, _) {
                                return TextField(
                                  controller: edtPassword,
                                  obscureText: userProfileProvider.hidePassword,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(color: ColorsRes.mainTextColor),
                                  decoration: InputDecoration(
                                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                                    filled: true,
                                    hintText:
                                        getTranslatedValue(context, passwordLabel),
                                    hintStyle: TextStyle(color: ColorsRes.grey),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: defaultImg(
                                        image: AppAssets.passwordIcon,
                                        iconColor: ColorsRes.grey,
                                        width: 22,
                                        height: 22,
                                      ),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        userProfileProvider.showHidePassword();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: defaultImg(
                                          image: userProfileProvider.hidePassword ==
                                                  true
                                              ? AppAssets.hidePasswordIcon
                                              : AppAssets.showPasswordIcon,
                                          iconColor: ColorsRes.grey,
                                          width: 20,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 16),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(
                                        color: ColorsRes.appColor,
                                        width: 1,
                                        style: BorderStyle.solid,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(
                                        color: ColorsRes.subTitleTextColor.withValues(alpha: 0.5),
                                        width: 1,
                                        style: BorderStyle.solid,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(
                                        color: ColorsRes.appColorRed,
                                        width: 1,
                                        style: BorderStyle.solid,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(
                                        color: ColorsRes.subTitleTextColor,
                                        width: 1,
                                        style: BorderStyle.solid,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                                      borderSide: BorderSide(
                                        color: ColorsRes.subTitleTextColor.withValues(alpha: 0.5),
                                        width: 1,
                                        style: BorderStyle.solid,
                                        strokeAlign: BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            // Forgot Password
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(forgotPasswordScreen);
                                },
                                child: CustomTextLabel(
                                  jsonKey: forgotPasswordLabel,
                                  style: TextStyle(
                                    color: ColorsRes.appColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 25),
                            // Login button
                            Consumer<UserProfileProvider>(
                              builder: (context, userProfileProvider, _) {
                                return gradientBtnWidget(
                                  context,
                                  10,
                                  otherWidgets:
                                      userProfileProvider.loginState ==
                                              LoginState.loading
                                          ? Center(
                                              child: CircularProgressIndicator(
                                                  color: ColorsRes.appColorWhite),
                                            )
                                          : CustomTextLabel(
                                              jsonKey: loginLabel,
                                              softWrap: true,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium!
                                                  .merge(
                                                    TextStyle(
                                                      color: ColorsRes.appColorWhite,
                                                      letterSpacing: 0.5,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                            ),
                                  callback: () {
                                    if (edtPassword.text.toString().isEmpty) {
                                      showMessage(
                                          context,
                                          "${getTranslatedValue(context, enterValidLabel)} ${getTranslatedValue(context, passwordLabel)}",
                                          MessageType.error);
                                    } else if (edtEmail.text.toString().isEmpty ||
                                        validateEmail(
                                              edtEmail.text.toString(),
                                            ) !=
                                            null) {
                                      showMessage(
                                          context,
                                          "${getTranslatedValue(context, enterValidLabel)} ${getTranslatedValue(context, emailLabel)}",
                                          MessageType.error);
                                    } else {
                                      Map<String, String> params = {};
                                      Constant.session.setData(
                                          SessionManager.password,
                                          edtPassword.text.toString(),
                                          false);
                                      params[ApiAndParams.email] =
                                          edtEmail.text.toString();
                                      params[ApiAndParams.password] =
                                          edtPassword.text.toString();
                                      params[ApiAndParams.type] =
                                          Constant.session.isSeller() ? "3" : "4";
                                      params[ApiAndParams.fcmToken] = Constant.session
                                          .getData(SessionManager.keyFCMToken);
                                      params[ApiAndParams.platform] =
                                          Platform.isAndroid ? "android" : "ios";
                                      params[ApiAndParams.languageId] =
                                          Constant.session.getData(
                                              SessionManager
                                                  .keySelectedAdminLangIdForFcm);

                                      userProfileProvider
                                          .loginApiProvider(params, context)
                                          .then(
                                        (value) async {
                                          UserLogin userLogin =
                                              UserLogin.fromJson(value!);
                                          if (value.isNotEmpty) {
                                            Constant.session.setData(
                                                SessionManager.email,
                                                userLogin.data?.user?.email
                                                        .toString() ??
                                                    "",
                                                false);
                                            if (Constant.session
                                                .getData(SessionManager.appThemeName)
                                                .isEmpty) {
                                              Constant.session.setData(
                                                  SessionManager.appThemeName,
                                                  Constant.themeList[0],
                                                  true);
                                            }
                                            Constant.session
                                                .setUserData(
                                                    data: Constant.session.isSeller()
                                                        ? userLogin
                                                            .data?.user?.seller
                                                            ?.toJson()
                                                        : userLogin
                                                            .data?.user?.deliveryBoy
                                                            ?.toJson())
                                                .then(
                                              (value) {
                                                Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                  mainHomeScreen,
                                                  (Route<dynamic> route) => false,
                                                );
                                              },
                                            );
                                          }
                                        },
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 15),
                            // Create Seller Account (outlined button)
                            Consumer<UserProfileProvider>(
                              builder: (context, userProfileProvider, _) {
                                return GestureDetector(
                                  onTap: () {
                                    if (Constant.session.isSeller()) {
                                      Navigator.pushNamed(
                                          context, editSellerProfileScreen,
                                          arguments: "registration");
                                    } else {
                                      Navigator.pushNamed(
                                          context, editDeliveryBoyProfileScreen,
                                          arguments: "registration");
                                    }
                                  },
                                  child: Container(
                                    height: 45,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ColorsRes.appColorTransparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: ColorsRes.appColor, width: 1.5),
                                    ),
                                    child: CustomTextLabel(
                                      jsonKey: Constant.session.isSeller()?createSellerAccountLabel:createDeliveryBoyAccountLabel,
                                      softWrap: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .merge(
                                            TextStyle(
                                              color: ColorsRes.appColor,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          // Terms & Privacy at bottom
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: Constant.paddingOrMargin15, vertical: 16),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.titleSmall!.merge(
                      TextStyle(
                        fontWeight: FontWeight.w400,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
                text:
                    "${getTranslatedValue(context, agreementMessage1Label)}\t",
                children: <TextSpan>[
                  TextSpan(
                      text:
                          getTranslatedValue(context, termsOfServiceLabel),
                      style: TextStyle(color: ColorsRes.appColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, webViewScreen,
                              arguments: getTranslatedValue(
                                  context, termsOfServiceLabel));
                        }),
                  TextSpan(
                      text:
                          "\t${getTranslatedValue(context, andLabel)}\t",
                      style:
                          TextStyle(color: ColorsRes.mainTextColor)),
                  TextSpan(
                    text:
                        getTranslatedValue(context, privacyPolicyLabel),
                    style: TextStyle(color: ColorsRes.appColor),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushNamed(context, webViewScreen,
                            arguments: getTranslatedValue(
                                context, privacyPolicyLabel));
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
