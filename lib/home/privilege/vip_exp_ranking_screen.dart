// ignore_for_file: must_be_immutable
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/home/privilege/rank_info_screen.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class VipExpRankinScreen extends StatefulWidget {
  UserModel? currentUser;

  VipExpRankinScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<VipExpRankinScreen> createState() => _VipExpRankinScreenState();
}

class _VipExpRankinScreenState extends State<VipExpRankinScreen> {

  int numRanking = 42;
  int numExp = 0;

  DateTime eventDate = DateTime(2024, 12, 25, 10, 30);
  String countDay = '';
  String countHour = '';
  String countMin = '';
  String countSec = '';

  List<String> topOneImages = [
    "assets/images/ic_vip_exp_triangle.png",
    "assets/images/ic_vip_diamond_crown.png",
    "assets/images/ic_vip_first_vehicle.png"
  ];

  List<String> topSecondImages  = [
    "assets/images/ic_vip_background.png",
    "assets/images/ic_vip_diamond_crown.png",
    "assets/images/ic_vip_second_vehicle.png"
  ];

  List<String> topText = [
    "vip_exp_screen.mini_background".tr(),
    "vip_exp_screen.profile_frame".tr(),
    "vip_exp_screen.vehicle_".tr()
  ];

  @override
  void initState() {

    startCountdown();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // bool isDarkMode = QuickHelp.isDarkMode(context);

    return Scaffold(
      backgroundColor: kColorsBlueGrey400,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: ()=>QuickHelp.goBackToPreviousPage(context),
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: TextWithTap(
          "vip_exp_screen.vip_exp_ranking".tr(),
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          Stack(
            children: [
              ContainerCorner(
                height: size.height / 3.78,
                width: size.width,
                radiusBottomRight: 40,
                radiusBottomLeft: 40,
                colors: [kColorsBlackGrey200, kColorsBlackGrey100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: ContainerCorner(
                          color: kColorsBlueGrey101,
                          radiusBottomLeft: 10,
                          onTap: () => QuickHelp.goToNavigatorScreen(
                            context,
                            RankInfoScreen()
                          ),
                          child: TextWithTap(
                            'vip_exp_screen.rank_info'.tr(),
                            color: kRoseVip100,
                            fontWeight: FontWeight.bold,
                            marginLeft: 10,
                            marginRight: 10,
                            marginBottom: 4,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 49,
                        right: 50,
                        child: Image.asset(
                          "assets/images/ic_vip_exp_cup.png",
                          height: 90,
                          width: 72,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            'vip_exp_screen.vip_exp_ranking'.tr(),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            marginTop: 40,
                          ),
                          TextWithTap(
                            'vip_exp_screen.rewards_for_you'.tr(),
                            color: kRoseVip100,
                            fontSize: 14,
                          ),
                          Row(
                            children: [
                              TextWithTap(
                                'vip_exp_screen.count_down'.tr(),
                                color: kSecondaryGrayColor,
                                marginTop: 10,
                                marginRight: 5,
                                fontSize: 13,
                              ),
                              ContainerCorner(
                                color: kColorsBlueGrey700,
                                marginTop: 10,
                                child: TextWithTap(
                                  countDay,
                                  color: Colors.white,
                                  marginLeft: 1,
                                  marginTop: 2,
                                  marginRight: 1,
                                  marginBottom: 2,
                                  fontSize: 13,
                                ),
                              ),
                              TextWithTap(
                                ':',
                                color: Colors.white,
                                marginLeft: 1,
                                marginTop: 10,
                                marginRight: 1,
                                fontSize: 13,
                              ),
                              ContainerCorner(
                                color: kColorsBlueGrey700,
                                marginTop: 10,
                                child: TextWithTap(
                                  countHour,
                                  color: Colors.white,
                                  marginLeft: 1,
                                  marginTop: 2,
                                  marginRight: 1,
                                  marginBottom: 2,
                                  fontSize: 13,
                                ),
                              ),
                              TextWithTap(
                                ':',
                                color: Colors.white,
                                marginLeft: 1,
                                marginTop: 10,
                                marginRight: 1,
                                fontSize: 13,
                              ),
                              ContainerCorner(
                                color: kColorsBlueGrey700,
                                marginTop: 10,
                                child: TextWithTap(
                                  countMin,
                                  color: Colors.white,
                                  marginLeft: 1,
                                  marginTop: 2,
                                  marginRight: 1,
                                  marginBottom: 2,
                                  fontSize: 13,
                                ),
                              ),
                              TextWithTap(
                                ':',
                                color: Colors.white,
                                marginLeft: 1,
                                marginTop: 10,
                                marginRight: 1,
                                fontSize: 13,
                              ),
                              ContainerCorner(
                                color: kColorsBlueGrey700,
                                marginTop: 10,
                                child: TextWithTap(
                                  countSec,
                                  color: Colors.white,
                                  marginLeft: 1,
                                  marginTop: 2,
                                  marginRight: 1,
                                  marginBottom: 2,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      ContainerCorner(
                        width: size.width,
                        borderRadius: 15,
                        color: Colors.white,
                        marginLeft: 20,
                        marginRight: 20,
                        marginTop: 149,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/images/ic_vip_crown.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10, top: 23.5, right: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ContainerCorner(
                                            height: 1,
                                            width: 80,
                                            color: kRoseVip100,
                                            borderRadius: 20,
                                          ),
                                          ContainerCorner(
                                            color: kRoseVip100,
                                            borderRadius: 10,
                                            marginLeft: 15,
                                            marginRight: 15,
                                            padding: EdgeInsets.only(
                                              left: 20, top: 5, right: 20, bottom: 5
                                            ),
                                            child: TextWithTap(
                                              "vip_exp_screen.top_1".tr(),
                                              color: kColorsDeepOrange800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          ContainerCorner(
                                            height: 1,
                                            width: 80,
                                            color: kRoseVip100,
                                            borderRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 8, top: 30, right: 8
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: List.generate(
                                          topText.length,
                                          (index) => ContainerCorner(
                                            color: kRoseVip100.withOpacity(0.20),
                                            borderRadius: 10,
                                            height: 140,
                                            width: 95,
                                            child: topContent(
                                              image: topOneImages[index],
                                              text: topText[index]
                                            )
                                          )
                                        )
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ContainerCorner(
                        width: size.width,
                        borderRadius: 15,
                        color: Colors.white,
                        marginLeft: 20,
                        marginRight: 20,
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    "assets/images/ic_vip_crown.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 10, top: 23.5, right: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ContainerCorner(
                                            height: 1,
                                            width: 70,
                                            color: kRoseVip100,
                                            borderRadius: 20,
                                          ),
                                          ContainerCorner(
                                            color: kRoseVip100,
                                            borderRadius: 10,
                                            marginLeft: 15,
                                            marginRight: 15,
                                            padding: EdgeInsets.only(
                                                left: 20, top: 5, right: 20, bottom: 5
                                            ),
                                            child: TextWithTap(
                                              "vip_exp_screen.top_2".tr(),
                                              color: kColorsDeepOrange800,
                                              fontSize: 14,
                                            ),
                                          ),
                                          ContainerCorner(
                                            height: 1,
                                            width: 70,
                                            color: kRoseVip100,
                                            borderRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8, top: 30, right: 8
                                      ),
                                      child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: List.generate(
                                              topText.length,
                                                  (index) => ContainerCorner(
                                                  color: kGreyColor0,
                                                  borderRadius: 10,
                                                  height: 140,
                                                  width: 95,
                                                  child: topContent(
                                                      image: topSecondImages[index],
                                                      text: topText[index]
                                                  )
                                              )
                                          )
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: getBottomNavBar()
    );
  }

  Widget topContent ({String? text, String? image}) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: ContainerCorner(
            color: kRoseVip100,
            radiusTopLeft: 10,
            radiusBottomRight: 10,
            child: TextWithTap(
              'vip_exp_screen.day_'.tr(),
              color: Colors.black,
              fontSize: 10,
              marginLeft: 5,
              marginRight: 5,
              marginBottom: 2,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 8, top: 30, right: 8
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                image!,
                height: 55,
                width: 50,
              ),
              SizedBox(
                width: 70,
                child: TextWithTap(
                  text!,
                  fontSize: 12,
                  textAlign: TextAlign.center,
                  marginTop: 15,
                  color: Colors.black,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget getBottomNavBar () {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      height: size.height * 0.138,
      width: size.width,
      colors: [kRoseVipClair, kRoseVip],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      padding: EdgeInsets.only(
        left: 10,
        top: 15,
        right: 10,
        bottom: 2
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActions.avatarWidget(widget.currentUser!, width: 40, height: 40),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextWithTap(
                        "vip_exp_screen.current_ranking".tr(),
                        color: kColorsDeepOrange800,
                        fontSize: 15,
                        maxLines: 2,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextWithTap(
                        widget.currentUser!.getFullName!,
                        color: kColorsBlueGrey600,
                        fontSize: 15,
                        maxLines: 2,
                        marginTop: 4,
                      ),
                    )
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWithTap(
                    "vip_exp_screen.this_month's".tr(),
                    color: kColorsBlueGrey700,
                    marginRight: 5,
                    fontSize: 15,
                  ),
                  TextWithTap(
                    "vip_exp_screen.exp_".tr(namedArgs: {"num_exp": "${numExp}"}),
                    color: kColorsBlueGrey700,
                    marginRight: 5,
                    fontSize: 15,
                  ),
                ],
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextWithTap(
                "vip_exp_screen.exp_required".tr(namedArgs: {"num_ranking":"${numRanking}"}),
                color: kColorsBlueGrey700,
                fontSize: 15,
                marginTop: 8,
                marginRight: 5,
              ),
            ),
          )
        ],
      ),
    );
  }

  void startCountdown() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      DateTime now = DateTime.now();
      Duration difference = eventDate.difference(now);

      if (difference.isNegative) {
        setState(() {
          countDay = '';
        });
        timer.cancel();
        return;
      }

      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;
      int seconds = difference.inSeconds % 60;

      setState(() {
        countDay = '${days}d';
        countHour = '${hours}h';
        countMin = '${minutes}m';
        countSec = '${seconds}s';
      });
    });
  }

}
