// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class HostRulesScreen extends StatefulWidget {
  UserModel? currentUser;

  HostRulesScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<HostRulesScreen> createState() => _HostRulesScreenState();
}

class _HostRulesScreenState extends State<HostRulesScreen> {
  var imagesNotCompliant = [
    "assets/images/img_blurry_avatar.png",
    "assets/images/img_spllicing_pictures.png",
    "assets/images/img_small_character.png",
    "assets/images/img_picture_with_border.png",
    "assets/images/img_pornographic.png",
    "assets/images/img_face_covering.png",
    "assets/images/img_back_view.png",
    "assets/images/img_scenery_photo.png",
  ];

  var imagesNotCompliantCaption = [
    "host_rules_screen.blurry_avatar".tr(),
    "host_rules_screen.splicing_pictures".tr(),
    "host_rules_screen.small_character".tr(),
    "host_rules_screen.picture_border".tr(),
    "host_rules_screen.pornographic_".tr(),
    "host_rules_screen.face_covering".tr(),
    "host_rules_screen.back_view".tr(),
    "host_rules_screen.scenery_photo".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "host_rules_screen.host_rules".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              ContainerCorner(
                width: size.width,
                borderWidth: 0,
                child: Image.asset(
                  "assets/images/bg_host_rules.png",
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(
                      height: 230,
                    ),
                    TextWithTap(
                      "host_rules_screen.host_rules".tr(),
                      color: Colors.white,
                      fontSize: size.width / 17,
                      fontWeight: FontWeight.w900,
                    ),
                    accountRules(),
                    coverPhotoRules(),
                    liveRules(),
                    changeOfAgencyRules(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget accountRules() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: Colors.white,
      borderWidth: 0,
      borderRadius: 10,
      marginLeft: 30,
      marginRight: 30,
      marginTop: 15,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: ContainerCorner(
                height: 35,
                marginTop: 15,
                marginBottom: 15,
                width: size.width / 2.3,
                borderRadius: 50,
                colors: [kSecondaryColor, kBlue],
                child: TextWithTap(
                  "host_rules_screen.account_rules".tr(),
                  alignment: Alignment.center,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            textRule(text: "host_rules_screen.account_rules_1".tr()),
            multiColorsTextRule(
              firstText: "host_rules_screen.account_rules_2".tr(),
              secondText: "host_rules_screen.account_rules_2_continue".tr(),
            ),
            textRule(text: "host_rules_screen.account_rules_3".tr()),
            multiColorsTextRule(
              firstText: "host_rules_screen.account_rules_4".tr(),
              secondText: "host_rules_screen.account_rules_4_continue".tr(),
            ),
            textRule(text: "host_rules_screen.account_rules_5".tr()),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget coverPhotoRules() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: Colors.white,
      borderWidth: 0,
      borderRadius: 10,
      marginLeft: 30,
      marginRight: 30,
      marginTop: 15,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: ContainerCorner(
                height: 35,
                marginTop: 15,
                marginBottom: 15,
                width: size.width / 2.3,
                borderRadius: 50,
                colors: [kSecondaryColor, kBlue],
                child: TextWithTap(
                  "host_rules_screen.cover_photo_rules".tr(),
                  alignment: Alignment.center,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextWithTap(
              "host_rules_screen.cover_photo_explain".tr(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              marginBottom: 3,
              marginTop: 7,
              color: kOrangeColor,
            ),
            textRule(text: "host_rules_screen.cover_photo_rules_1".tr()),
            textRule(text: "host_rules_screen.cover_photo_rules_2".tr()),
            textRule(text: "host_rules_screen.cover_photo_rules_3".tr()),
            textRule(text: "host_rules_screen.cover_photo_rules_4".tr()),
            ContainerCorner(
              borderRadius: 10,
              width: size.width,
              borderWidth: 0,
              height: 235,
              marginTop: 10,
              color: Colors.deepPurple,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    "host_rules_screen.cover_no_pass_audit".tr(),
                    color: Colors.white,
                    marginTop: 7,
                    marginBottom: 10,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: GridView.count(
                        crossAxisCount: 4,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(
                          imagesNotCompliant.length,
                          (index) {
                            return ContainerCorner(
                              borderRadius: 10,
                              child: Column(
                                children: [
                                  Image.asset(imagesNotCompliant[index]),
                                  ContainerCorner(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: 4,
                                    marginTop: 5,
                                    height: 18,
                                    child: TextWithTap(
                                      imagesNotCompliantCaption[index],
                                      alignment: Alignment.center,
                                      color: Colors.white,
                                      fontSize: 6.7,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget liveRules() {
    var rules = [
      "host_rules_screen.live_rules_1".tr(),
      "host_rules_screen.live_rules_2".tr(),
      "host_rules_screen.live_rules_3".tr(),
      "host_rules_screen.live_rules_4".tr(),
      "host_rules_screen.live_rules_5".tr(),
      "host_rules_screen.live_rules_6".tr(),
      "host_rules_screen.live_rules_7".tr(),
      "host_rules_screen.live_rules_8".tr(),
    ];
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: Colors.white,
      borderWidth: 0,
      borderRadius: 10,
      marginLeft: 30,
      marginRight: 30,
      marginTop: 15,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: ContainerCorner(
                height: 35,
                marginTop: 15,
                marginBottom: 15,
                width: size.width / 2.3,
                borderRadius: 50,
                colors: [kSecondaryColor, kBlue],
                child: TextWithTap(
                  "host_rules_screen.live_rules".tr(),
                  alignment: Alignment.center,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextWithTap(
              "host_rules_screen.caution_".tr(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              marginBottom: 3,
              marginTop: 7,
              color: earnCashColor,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerCorner(
                  color: earnCashColor,
                  height: 8,
                  borderRadius: 50,
                  borderWidth: 0,
                  width: 8,
                  marginTop: 3,
                ),
                Flexible(
                  child: Column(
                    children: [
                      TextWithTap(
                        "host_rules_screen.live_advice".tr(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        marginBottom: 3,
                        color: earnCashColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  rules.length, (index) => textRule(text: rules[index])),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget changeOfAgencyRules() {
    var rules = [
      "host_rules_screen.change_agency_1".tr(),
      "host_rules_screen.change_agency_2".tr(),
      "host_rules_screen.change_agency_3".tr(),
      "host_rules_screen.change_agency_4".tr(),
      "host_rules_screen.change_agency_5".tr(),
    ];
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: Colors.white,
      borderWidth: 0,
      borderRadius: 10,
      marginLeft: 30,
      marginRight: 30,
      marginTop: 15,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              child: ContainerCorner(
                height: 35,
                marginTop: 15,
                marginBottom: 15,
                width: size.width / 2.3,
                borderRadius: 50,
                colors: [kSecondaryColor, kBlue],
                child: TextWithTap(
                  "host_rules_screen.change_agency".tr(),
                  alignment: Alignment.center,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  rules.length, (index) => textRule(text: rules[index])),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget textRule({required String text}) {
    return TextWithTap(
      text,
      color: kBlue,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      marginBottom: 3,
      marginTop: 7,
    );
  }

  Widget multiColorsTextRule(
      {required String firstText, required String secondText}) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: RichText(
          textAlign: TextAlign.start,
          text: TextSpan(children: [
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: kOrangeColor,
                fontWeight: FontWeight.w500,
              ),
              text: firstText,
            ),
            WidgetSpan(
              child: SizedBox(width: 3),
            ),
            TextSpan(
              style: TextStyle(
                fontSize: 12,
                color: kBlue,
                fontWeight: FontWeight.w500,
              ),
              text: secondText,
            ),
          ])),
    );
  }
}
