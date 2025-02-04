// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class FaceAuthenticationScreen extends StatefulWidget {
  UserModel? currentUser;
  FaceAuthenticationScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<FaceAuthenticationScreen> createState() => _FaceAuthenticationScreenState();
}

class _FaceAuthenticationScreenState extends State<FaceAuthenticationScreen> {

  String advice = "";

  var rulesText = [
    "face_authentication_screen.avoid_cover".tr(),
    "face_authentication_screen.keep_light".tr(),
    "face_authentication_screen.minor_prohibited".tr(),
  ];

  var rulesImages = [
    "assets/images/ic_avoid_cover.png",
    "assets/images/ic_enough_light.png",
    "assets/images/ic_minor_prohibited.png",
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size  = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
        elevation: 1.5,
        centerTitle: true,
        title: TextWithTap(
          "face_authentication_screen.auth_".tr(),
          fontWeight: FontWeight.w900,
        ),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 50,),
          Image.asset(
              "assets/images/avatar_img.png",
            height: size.width / 2.4,
            width: size.width / 2.4,
          ),
          TextWithTap(
            "face_authentication_screen.please_upload_photo".tr(),
            color: kGrayColor,
            alignment: Alignment.center,
            marginTop: 15,
          ),
          TextWithTap(
            advice,
            color: Colors.red,
            alignment: Alignment.center,
            marginTop: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: const Divider(),
          ),
          ContainerCorner(
            radiusBottomRight: 10,
            radiusBottomLeft: 10,
            marginRight: 15,
            marginLeft: 15,
            width: size.width,
            borderWidth: 0,
            marginTop: 30,
            marginBottom: 30,
            height: 100,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                rulesText.length,
                    (index) {
                  return ContainerCorner(
                    child: Column(
                      children: [
                        Image.asset(
                            rulesImages[index],
                          height: 45,
                          width: 45,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: AutoSizeText(
                            rulesText[index],
                            maxFontSize: 14.0,
                            minFontSize: 11.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : kContentDarkShadow,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          ContainerCorner(
            width: size.width,
            marginBottom: 20,
            marginTop: 50,
            borderColor: kPrimaryColor,
            height: 55,
            marginLeft: 20,
            marginRight: 20,
            borderRadius: 50,
            onTap: () {},
            child: Center(
              child: TextWithTap(
                "face_authentication_screen.upload_a_photo".tr(),
                color: kPrimaryColor,
              ),
            ),
          ),
          ContainerCorner(
            width: size.width,
            marginBottom: 20,
            marginTop: 5,
            color: kPrimaryColor,
            height: 55,
            marginLeft: 20,
            marginRight: 20,
            borderRadius: 50,
            onTap: () {
              setState(() {
                advice = "face_authentication_screen.please_upload_photo".tr();
              });
            },
            child: Center(
              child: TextWithTap(
                "face_authentication_screen.start_certificate".tr(),
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        ],
      ),
    );
  }
}
