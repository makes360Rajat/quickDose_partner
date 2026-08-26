import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

profileMenuWidget({required var profileMenus}) {
  return Consumer<LanguageProvider>(
    builder: (context, provider, child) {
      return ListView.separated(
          padding: EdgeInsetsDirectional.only(end: 10, start: 10),
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Divider(
              height: 0,
              color: ColorsRes.grey,
            );
          },
          itemCount: profileMenus.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                profileMenus[index]['clickFunction'](context);
              },
              contentPadding: EdgeInsets.zero,
              leading: Container(
                decoration: DesignConfig.boxDecoration(
                profileMenus[index]['alert'] ? ColorsRes.appColorRed.withValues(alpha: 0.1) : ColorsRes.appColor.withValues(alpha: 0.1), 5),
                padding: EdgeInsets.all(5),
                child: defaultImg(image: profileMenus[index]['icon'], iconColor: profileMenus[index]['alert'] ? ColorsRes.appColorRed : ColorsRes.appColor, height: 20, width: 20),
              ),
              title: Text(
                getTranslatedValue(context, profileMenus[index]['label']),
                style: Theme.of(context).textTheme.bodyMedium!.merge(
                      TextStyle(
                        letterSpacing: 0.5,
                        color: profileMenus[index]['alert']?ColorsRes.appColorRed:ColorsRes.mainTextColor,
                      ),
                    ),
              ),
              trailing: Icon(
                Icons.navigate_next,
                color: profileMenus[index]['alert'] ? ColorsRes.appColorRed : ColorsRes.subTitleTextColor,
              ),
            );
          });
    },
  );
}
