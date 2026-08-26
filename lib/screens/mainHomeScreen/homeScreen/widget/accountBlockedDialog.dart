import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class AccountBlockedDialog extends StatelessWidget {
  final String? remark;
  const AccountBlockedDialog({Key? key, this.remark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent closing with back button
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        surfaceTintColor: ColorsRes.appColorTransparent,
        title: CustomTextLabel(
          jsonKey: accountBlockedTitleLabel,
          style: TextStyle(
            color: ColorsRes.mainTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(mainAxisSize: .min,
          children: [
            CustomTextLabel(
              jsonKey: accountRestrictionReasonLabel,
              softWrap: true,
              style: TextStyle(
                color: ColorsRes.mainTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w700
              ),
              textAlign: TextAlign.center,
            ),
            CustomTextLabel(
              text: remark,
              softWrap: true,
              style: TextStyle(color: ColorsRes.subTitleTextColor, fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            getSizedBox(height: 10),
            Divider(height: 1, color: ColorsRes.mainTextColor.withValues(alpha: 0.2), thickness: 1),
            getSizedBox(height: 10),
            CustomTextLabel(
              jsonKey: accountBlockedMessageLabel,
              softWrap: true,
              style: TextStyle(
                color: ColorsRes.subTitleTextColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: gradientBtnWidget(
              context,
              10,
              title: getTranslatedValue(context, okLabel),
              callback: () {
                // Logout user without confirmation
                Constant.session.logoutUser(context, confirmationRequired: false);
              },
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Static method to show the dialog
  static void show(BuildContext context, String? remark) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) => AccountBlockedDialog(remark: remark),
    );
  }
}
