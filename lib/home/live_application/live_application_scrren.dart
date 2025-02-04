// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../face_authentication/face_authentication_screen.dart';
import '../host_rules/host_rules_screen.dart';
import '../level/level_screen.dart';
import '../upload_live_photo/upload_live_photo_screen.dart';

class LiveApplicationScreen extends StatefulWidget {
  UserModel? currentUser;

  LiveApplicationScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<LiveApplicationScreen> createState() => _LiveApplicationScreenState();
}

class _LiveApplicationScreenState extends State<LiveApplicationScreen> {
  var optionTitle = [
    "live_application_screen.face_authentication".tr(),
    "live_application_screen.live_phone".tr(),
  ];

  var optionExplain = [
    "live_application_screen.complete_authentication".tr(),
    "live_application_screen.upload_live_cover".tr(),
  ];

  var done = [];
  var screensToGo = [];

  @override
  Widget build(BuildContext context) {
    screensToGo = [
      FaceAuthenticationScreen(
        currentUser: widget.currentUser,
      ),
      UploadLivePhoto(
        currentUser: widget.currentUser,
      ),
    ];

    done = [
      widget.currentUser!.getIsFaceAuthenticated,
      widget.currentUser!.getLiveCover != null,
    ];

    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    bool isMale = widget.currentUser!.getGender == UserModel.keyGenderMale;
    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "live_application_screen.live_application".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ContainerCorner(
            width: size.width,
            marginLeft: 15,
            marginRight: 15,
            marginTop: 10,
            onTap: () {
              QuickHelp.goToNavigatorScreen(
                context,
                HostRulesScreen(
                  currentUser: widget.currentUser,
                ),
              );
            },
            child: Image.asset("assets/images/img_host_rules.png"),
          ),
          TextWithTap(
            "live_application_screen.live_application_condition".tr(),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            marginLeft: 15,
            marginTop: 20,
            marginBottom: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              optionTitle.length,
              (index) => option(
                title: optionTitle[index],
                explain: optionExplain[index],
                done: done[index],
                screen: screensToGo[index],
              ),
            ),
          ),
          Visibility(
            visible: isMale,
            child: option(
              title: "live_application_screen.wealth_level".tr(
                  namedArgs: {"level_number": "${Setup.wealthRequiredLevel}"}),
              explain: "live_application_screen.wealth_level_explain".tr(
                  namedArgs: {"level_number": "${Setup.wealthRequiredLevel}"}),
              done: QuickHelp.wealthLevelNumber(
                      creditSent: widget.currentUser!.getCreditsSent!) >=
                  Setup.wealthRequiredLevel,
              screen: LevelScreen(
                currentUser: widget.currentUser,
              ),
            ),
          ),
          ContainerCorner(
            height: 45,
            color: kPrimaryColor,
            borderRadius: 50,
            borderWidth: 0,
            width: size.width,
            marginTop: 30,
            marginRight: 30,
            marginLeft: 30,
            child: TextWithTap(
              "live_application_screen.live_now".tr(),
              alignment: Alignment.center,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget option({
    required String title,
    required String explain,
    required bool done,
    required Widget screen,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      marginTop: 2,
      height: 100,
      color: isDark ? kContentDarkShadow : Colors.white,
      onTap: () async {
        UserModel? user =
            await QuickHelp.goToNavigatorScreenForResult(context, screen);
        if (user != null) {
          setState(() {
            widget.currentUser = user;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWithTap(
                  title,
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(
                  width: size.width / 1.8,
                  child: TextWithTap(
                    explain,
                    color: kGrayColor,
                    marginTop: 10,
                  ),
                ),
              ],
            ),
            if (!done)
              ContainerCorner(
                borderRadius: 50,
                height: 23,
                width: 23,
                borderWidth: 2,
                borderColor: kPrimaryColor,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: kPrimaryColor,
                    size: 13,
                  ),
                ),
              ),
            if (done)
              Icon(
                Icons.check_circle,
                color: kGreenLight,
              ),
          ],
        ),
      ),
    );
  }
}
