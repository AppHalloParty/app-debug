// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_help.dart';

class LevelScreen extends StatefulWidget {
  UserModel? currentUser;

  LevelScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  @override
  void initState() {
    initializePoint();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double maxPoint = 0.0;
  double currentPoint = 0.0;
  double remainingPoint = 0.0;

  initializePoint() {
    maxPoint = QuickHelp.levelPositionValues(
            pointsInApp: widget.currentUser!.getUserPoints!) +
        0.0;
    currentPoint = widget.currentUser!.getUserPoints! + 0.0;
    remainingPoint = QuickHelp.levelPositionValues(
            pointsInApp: widget.currentUser!.getUserPoints!) -
        widget.currentUser!.getUserPoints! +
        0.0;
  }

  var pointCaptions = [];

  var levelPrivilegesText = [
    "my_level_screen.level_privilege_1".tr(),
    "my_level_screen.level_privilege_2".tr(),
  ];

  var guardianExpText = [
    "my_level_screen.users_are_rewarded".tr(),
    "my_level_screen.after_becoming_guardian".tr(),
    "my_level_screen.user_gain_highest".tr(),
  ];

  var newbieExpText = [
    "my_level_screen.first_stream".tr(),
    "my_level_screen.newly_registered".tr(),
    "my_level_screen.newly_recharge".tr(),
    "my_level_screen.first_recharge".tr(),
  ];

  var fanClubText = [
    "my_level_screen.join_fan_club".tr(),
    "my_level_screen.edit_fan_club".tr(),
    "my_level_screen.join_a_fan_club".tr(),
  ];

  var activatePremiumText = [
    "my_level_screen.activate_monthly".tr(),
    "my_level_screen.activate_3_months".tr(),
    "my_level_screen.activate_6_months".tr(),
    "my_level_screen.activate_13_months".tr(),
    "my_level_screen.premium_member_gain".tr(),
  ];

  var streamText = [
    "my_level_screen.first_stream_day".tr(),
    "my_level_screen.stream_duration".tr(),
  ];
  var shareText = [
    "my_level_screen.share_your_stream".tr(),
    "my_level_screen.record_and_share".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    pointCaptions = [
      "my_level_screen.experience_points"
          .tr(namedArgs: {"amount": "${currentPoint.toInt()}"}),
      "my_level_screen.points_until_next_level"
          .tr(namedArgs: {"amount": "${remainingPoint.toInt()}"}),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : Colors.black,
        ),
        title: TextWithTap(
          "my_level_screen.my_level".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 10, right: 10),
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                "assets/images/grade_bg.png",
                width: size.width / 2.42,
                height: size.width / 2.42,
              ),
              Positioned(
                bottom: -55,
                child: Stack(
                  alignment: AlignmentDirectional.bottomCenter,
                  children: [
                    Image.asset(
                      QuickHelp.levelImageWithBanner(
                          pointsInApp: widget.currentUser!.getUserPoints!),
                      width: size.width / 2.3,
                      height: size.width / 2.3,
                    ),
                    TextWithTap(
                      QuickHelp.levelCaption(
                          pointsInApp: widget.currentUser!.getUserPoints!),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      marginBottom: size.width / 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ContainerCorner(
            marginTop: 70,
            borderWidth: 0.5,
            borderRadius: 50,
            borderColor: kOrangeColor,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: FAProgressBar(
                currentValue: currentPoint,
                size: 5,
                maxValue: maxPoint,
                changeColorValue: 0,
                changeProgressColor: kOrangeColor,
                backgroundColor: kGrayColor.withOpacity(0.1),
                progressColor: Colors.lightBlue,
                animatedDuration: const Duration(seconds: 2),
                direction: Axis.horizontal,
                verticalDirection: VerticalDirection.up,
                displayText: '%',
                displayTextStyle: GoogleFonts.roboto(
                  color: kTransparentColor,
                  fontSize: 1,
                ),
                formatValueFixed: 0,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              pointCaptions.length,
              (index) => TextWithTap(
                pointCaptions[index],
                color: kGrayColor,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w600,
                marginTop: 10,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25, bottom: 15),
            child: Divider(
              color: kGrayColor.withOpacity(0.1),
            ),
          ),
          Row(
            children: [
              Image.asset(
                "assets/images/grade_welfare.png",
                height: 25,
                width: 25,
              ),
              TextWithTap(
                "my_level_screen.user_level_privileges".tr(),
                fontWeight: FontWeight.bold,
                marginLeft: 10,
                fontSize: size.width / 26,
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              levelPrivilegesText.length,
              (index) => TextWithTap(
                levelPrivilegesText[index],
                color: kGrayColor,
                marginBottom: 15,
                marginLeft: 30,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 15),
            child: Divider(
              color: kGrayColor.withOpacity(0.1),
            ),
          ),
          Row(
            children: [
              Image.asset(
                "assets/images/grade_up.png",
                height: 25,
                width: 25,
              ),
              TextWithTap(
                "my_level_screen.how_level_up".tr(),
                fontWeight: FontWeight.bold,
                marginLeft: 10,
                fontSize: size.width / 26,
              )
            ],
          ),
          TextWithTap(
            "my_level_screen.complete_following_actions".tr(),
            fontSize: 10,
            color: kGrayColor,
            marginLeft: 35,
            marginTop: 8,
            marginBottom: 8,
          ),
          TextWithTap(
            "my_level_screen.gift_guardianship".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              guardianExpText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        guardianExpText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextWithTap(
            "my_level_screen.newbie_exp".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              newbieExpText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        newbieExpText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextWithTap(
            "my_level_screen.other_function".tr(),
            fontSize: 10,
            color: kGrayColor,
            marginLeft: 35,
            marginTop: 8,
            marginBottom: 8,
          ),
          TextWithTap(
            "my_level_screen.fans_group".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              fanClubText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        fanClubText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextWithTap(
            "my_level_screen.activate_premium".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              activatePremiumText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        activatePremiumText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextWithTap(
            "my_level_screen.stream_".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              streamText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        streamText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextWithTap(
            "my_level_screen.watch_stream".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerCorner(
                borderRadius: 50,
                color: Colors.deepPurpleAccent,
                height: 5,
                width: 5,
                marginLeft: 30,
                marginRight: 5,
                marginTop: 3,
              ),
              SizedBox(
                width: size.width / 1.2,
                child: TextWithTap(
                  "my_level_screen.watch_stream_gain".tr(),
                  color: kGrayColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          TextWithTap(
            "my_level_screen.link_".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
            marginTop: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContainerCorner(
                borderRadius: 50,
                color: Colors.deepPurpleAccent,
                height: 5,
                width: 5,
                marginLeft: 30,
                marginRight: 5,
                marginTop: 3,
              ),
              SizedBox(
                width: size.width / 1.2,
                child: TextWithTap(
                  "my_level_screen.link_on_min".tr(),
                  color: kGrayColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          TextWithTap(
            "my_level_screen.share_".tr(),
            fontWeight: FontWeight.bold,
            fontSize: size.width / 24,
            marginLeft: 35,
            marginBottom: 15,
            marginTop: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              shareText.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      color: Colors.deepPurpleAccent,
                      height: 5,
                      width: 5,
                      marginLeft: 30,
                      marginRight: 5,
                      marginTop: 3,
                    ),
                    SizedBox(
                      width: size.width / 1.2,
                      child: TextWithTap(
                        shareText[index],
                        color: kGrayColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
