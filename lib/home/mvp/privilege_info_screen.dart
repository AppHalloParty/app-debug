// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../app/Config.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';

class PrivilegeInfoScreen extends StatefulWidget {
  UserModel? currentUser;
  int? initialIndex;

  PrivilegeInfoScreen({
    this.initialIndex,
    this.currentUser,
    super.key,
  });

  @override
  State<PrivilegeInfoScreen> createState() => _PrivilegeInfoScreenState();
}

class _PrivilegeInfoScreenState extends State<PrivilegeInfoScreen> {
  var imagesExplains = [
    "assets/images/01_primeiro.png",
    "assets/images/02_segundo.png",
    "assets/images/03_terceiro.png",
    "assets/images/04_quatre.png",
    "assets/images/05_cinco.png",
    "assets/images/06_six.png",
    "assets/images/07_sept.png",
    "assets/images/08_oito.png",
    "assets/images/09_nove.png",
    "assets/images/10_dez.png",
    "assets/images/11_onze.png",
  ];

  var premiumTitle = [
    "wallet_screen.exclusive_social".tr(),
    "wallet_screen.level_up".tr(),
    "wallet_screen.family_privilege".tr(),
    "wallet_screen.enhances_presence".tr(),
    "wallet_screen.exclusive_vehicle".tr(),
    "wallet_screen.premium_badge".tr(),
    "wallet_screen.true_love".tr(),
    "wallet_screen.mini_background".tr(),
    "wallet_screen.status_symbol".tr(),
    "wallet_screen.exclusive_background".tr(),
    "wallet_screen.wealth_privileges".tr(),
  ];

  var textExplains = [
    "privilege_info_screen.more_record".tr(),
    "privilege_info_screen.gained_increase".tr(),
    "privilege_info_screen.more_progress".tr(),
    "privilege_info_screen.exclusive_comment".tr(),
    "privilege_info_screen.awesome_entrance".tr(),
    "privilege_info_screen.exclusive_frame".tr(),
    "privilege_info_screen.join_more_group".tr(),
    "privilege_info_screen.stream_bio".tr(),
    "privilege_info_screen.mvp_badge".tr(),
    "privilege_info_screen.party_room_wallpaper".tr(),
    "privilege_info_screen.claim_daily_diamonds".tr(),
  ];

  int pageViewIndex = 0;
  PageController? _controller;

  int diamondsToClaim = 10000;

  @override
  void initState() {
    super.initState();
    pageViewIndex = widget.initialIndex ?? 0;
    _controller = PageController(initialPage: pageViewIndex);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kTransparentColor,
        leading: BackButton(
          color: Colors.white,
        ),
        title: TextWithTap(
          "privilege_info_screen.privilege_info".tr(),
          color: Colors.white,
        ),
      ),
      body: ContainerCorner(
        borderWidth: 0,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                ContainerCorner(
                  imageDecoration: "assets/images/bg_privi_info_header.png",
                  height: 530,
                  width: size.width,
                  borderWidth: 0,
                  fit: BoxFit.fill,
                ),
                ContainerCorner(
                  borderWidth: 0,
                  marginTop: size.width / 4,
                  height: size.width / 1.0,
                  child: PageView.builder(
                    itemCount: imagesExplains.length,
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        pageViewIndex = index;
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            imagesExplains[pageViewIndex],
                            height: size.width / 1.5,
                            width: size.width / 1.5,
                          ),
                          TextWithTap(
                            premiumTitle[pageViewIndex],
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: size.width / 20,
                            marginTop: 20,
                            marginBottom: 7,
                          ),
                          TextWithTap(
                            textExplains[pageViewIndex],
                            color: Colors.white,
                          )
                        ],
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imagesExplains.asMap().entries.map((entry) {
                      return ContainerCorner(
                        width: 5.0,
                        height: 5.0,
                        marginRight: 5,
                        borderRadius: 50,
                        borderWidth: 0,
                        onTap: () => _controller!.jumpTo(
                          entry.key + 0.0,
                        ),
                        color: pageViewIndex == entry.key
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            TextWithTap(
              "wallet_screen.notice_".tr(),
              color: kGrayColor,
              fontSize: 12,
              marginLeft: 15,
              marginBottom: 15,
              marginTop: 35,
            ),
            TextWithTap(
              "wallet_screen.notice_1".tr(namedArgs: {
                "app_name": Config.appName,
                "platform": platformName(),
              }),
              color: kGrayColor,
              fontSize: 12,
              marginLeft: 15,
              marginBottom: 25,
              marginRight: 15,
            ),
            TextWithTap(
              "wallet_screen.notice_2".tr(),
              color: kGrayColor,
              fontSize: 12,
              marginLeft: 15,
              marginBottom: 25,
              marginRight: 15,
            ),
            TextWithTap(
              "wallet_screen.notice_3"
                  .tr(namedArgs: {"amount": "$diamondsToClaim"}),
              color: kGrayColor,
              fontSize: 12,
              marginLeft: 15,
              marginBottom: 25,
              marginRight: 15,
            ),
            SizedBox(
              height: 200,
            ),
          ],
        ),
      ),
    );
  }

  String platformName() {
    if (QuickHelp.isAndroidPlatform()) {
      return "wallet_screen.google_pay".tr();
    } else if (QuickHelp.isIOSPlatform()) {
      return "wallet_screen.apple_pay".tr();
    } else {
      return "";
    }
  }
}
