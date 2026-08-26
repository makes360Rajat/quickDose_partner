import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/homeMainScreenProvider.dart';

class BottomSheetLanguageListContainer extends StatefulWidget {
  BottomSheetLanguageListContainer({
    Key? key,
  }) : super(key: key);

  @override
  State<BottomSheetLanguageListContainer> createState() =>
      _BottomSheetLanguageListContainerState();
}

class _BottomSheetLanguageListContainerState
    extends State<BottomSheetLanguageListContainer> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      context.read<LanguageProvider>().getAvailableLanguageList(
          params: {ApiAndParams.system_type: "2"}, context: context);

      context.read<LanguageProvider>().setSelectedLanguage(
          Constant.session.getData(SessionManager.keySelectedLanguageId));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return Column(
          children: [
            getSizedBox(
              height: 20,
            ),
            Center(
              child: CustomTextLabel(
                jsonKey: changeLanguageLabel,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.merge(
                      TextStyle(
                        letterSpacing: 0.5,
                        color: ColorsRes.mainTextColor,
                      ),
                    ),
              ),
            ),
            getSizedBox(
              height: 10,
            ),
            if (languageProvider.languageState == LanguageState.loaded ||
                languageProvider.languageState == LanguageState.updating)
              RadioGroup<String>(
                groupValue: languageProvider.selectedLanguage,
                onChanged: (value) {
                  print(" value $value");
                  if (value != null) languageProvider.setSelectedLanguage(value);
                },
                child: ListView(
                  shrinkWrap: true,
                  children: List.generate(
                    languageProvider.languageList?.data?.length ?? 0,
                    (index) {
                      final itemId = languageProvider
                          .languageList!.data![index].id
                          .toString();
                      return GestureDetector(
                        onTap: () {
                          languageProvider.setSelectedLanguage(itemId);
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: Constant.paddingOrMargin10),
                                child: CustomTextLabel(
                                  text: languageProvider
                                          .languageList!.data![index].name ??
                                      "",
                                ),
                              ),
                            ),
                            Radio<String>(
                              activeColor: ColorsRes.appColor,
                              value: itemId,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            getSizedBox(
              height: 10,
            ),
            if (languageProvider.languageState == LanguageState.loading)
              Column(
                children: List.generate(
                  8,
                  (index) {
                    return CustomShimmer(
                      height: 26,
                      width: double.maxFinite,
                      margin: EdgeInsetsDirectional.all(
                        10,
                      ),
                    );
                  },
                ),
              ),
            if (languageProvider.languageState == LanguageState.loaded ||
                languageProvider.languageState == LanguageState.updating)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.paddingOrMargin10,
                ),
                child: gradientBtnWidget(
                  context,
                  10,
                  callback: () {
                    Map<String, String> params = {};
                    params[ApiAndParams.system_type] = "2";
                    params[ApiAndParams.id] =
                        languageProvider.selectedLanguage.toString();
                    languageProvider
                        .getLanguageDataProvider(
                      params: params,
                      context: context,
                    )
                        .then((value) {
                      if (!mounted) return;
                      if (value == true) {
                        final String fcmToken =
                            Constant.session.getData(SessionManager.keyFCMToken);
                        final String adminLangIdForFcm = Constant.session
                            .getData(SessionManager.keySelectedAdminLangIdForFcm);
                        if (fcmToken.isNotEmpty && adminLangIdForFcm.isNotEmpty) {
                          updateFcmTokenApi(params: {
                            ApiAndParams.fcmToken: fcmToken,
                            ApiAndParams.languageId: adminLangIdForFcm,
                          }).catchError((e) {
                            debugPrint("Error updating FCM token language: $e");
                            return <String, dynamic>{};
                          });
                        }
                        // Use the provider's own selectBottomMenu directly so
                        // the lambda doesn't capture this (soon-to-be-disposed)
                        // bottom-sheet context.
                        final homeProvider =
                            context.read<HomeMainScreenProvider>();
                        homeProvider.refreshAllPages(
                          homeProvider.selectBottomMenu,
                        );
                        Navigator.pop(context);
                      }
                    });
                  },
                  otherWidgets: (languageProvider.languageState ==
                          LanguageState.updating)
                      ? CircularProgressIndicator(
                          color: ColorsRes.appColorWhite)
                      : CustomTextLabel(
                          jsonKey: changeLabel,
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleMedium!.merge(
                                TextStyle(
                                  color: ColorsRes.appColorWhite,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                        ),
                ),
              ),
            if (languageProvider.languageState == LanguageState.loading)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  top: Constant.paddingOrMargin10,
                  start: Constant.paddingOrMargin10,
                  end: Constant.paddingOrMargin10,
                ),
                child: CustomShimmer(
                  height: 55,
                  width: double.maxFinite,
                ),
              ),
            getSizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }
}
