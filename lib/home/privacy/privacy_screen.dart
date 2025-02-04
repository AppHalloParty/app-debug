// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/app/Config.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class PrivacyScreen extends StatefulWidget {
  UserModel? currentUser;

  PrivacyScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  PermissionStatus? locationStatus;

  PermissionStatus? cameraStatus;
  PermissionStatus? microStatus;
  PermissionStatus? storageStatus;

  var titles = [
    "privacy_screen.allow_camera_title"
        .tr(namedArgs: {"app_name": Config.appName}),
    "privacy_screen.allow_gallery_title"
        .tr(namedArgs: {"app_name": Config.appName}),
    "privacy_screen.allow_micro_title"
        .tr(namedArgs: {"app_name": Config.appName}),
    "privacy_screen.allow_location_title"
        .tr(namedArgs: {"app_name": Config.appName}),
  ];

  var subTitles = [
    "privacy_screen.allow_camera_explain".tr(),
    "privacy_screen.allow_gallery_explain".tr(),
    "privacy_screen.allow_micro_explain".tr(),
    "privacy_screen.allow_location_explain".tr(),
  ];

  var permissionsStatus = [true, true, true, true];

  verifyPermissionStatus() async {
    locationStatus = await Permission.location.status;
    cameraStatus = await Permission.camera.status;
    microStatus = await Permission.microphone.status;
    storageStatus = await Permission.storage.status;

    setState(() {
      permissionsStatus = [
        cameraStatus!.isGranted,
        storageStatus!.isGranted,
        microStatus!.isGranted,
        locationStatus!.isGranted,
      ];
    });
  }


  @override
  void initState() {
    super.initState();
    verifyPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "privacy_screen.privacy_".tr(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          Column(
            children: List.generate(titles.length, (index) {
              return option(
                title: titles[index],
                subTitle: subTitles[index],
                activated: permissionsStatus[index],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget option({
    required String title,
    required String subTitle,
    required bool activated,
  }) {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      borderWidth: 0,
      marginTop: 2,
      color: QuickHelp.getColorStandard(inverse: true),
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerCorner(
              width: size.width / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    title,
                    fontSize: 15,
                    marginBottom: 10,
                  ),
                  TextWithTap(
                    subTitle,
                    color: kGreyColor1,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextWithTap(
                  activated ? "on_".tr() : "privacy_screen.go_settings".tr(),
                  fontSize: 11,
                  marginRight: 2,
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: kGrayColor,
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
