// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class HostCenterScreen extends StatefulWidget {
  UserModel? currentUser;

  HostCenterScreen({this.currentUser, super.key});

  @override
  State<HostCenterScreen> createState() => _HostCenterScreenState();
}

class _HostCenterScreenState extends State<HostCenterScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "host_center_screen.host_center".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ContainerCorner(
        imageDecoration: "assets/images/host_center_bg.png",
        borderWidth: 0,
        height: size.height,
        width: size.width,
        child: ListView(
          padding: EdgeInsets.only(left: 15, right: 15, top: 20),
          children: [
            Row(
              children: [
                QuickActions.avatarWidget(widget.currentUser!,
                    height: 50, width: 50),
                TextWithTap(
                  widget.currentUser!.getFullName!,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width / 18,
                  marginLeft: 10,
                ),
              ],
            ),
            ContainerCorner(
              width: size.width,
              borderRadius: 10,
              color: Colors.white,
              marginTop: 25,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithTap(
                          "host_center_screen.monthly_live_data".tr(),
                          fontWeight: FontWeight.bold,
                          color: kContentColorLightTheme,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                              "more_".tr().toLowerCase(),
                              fontSize: 12,
                              color: kGrayColor,
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
                    SizedBox(height: 25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                                QuickHelp.convertNumberToK(0),
                              color: kContentColorLightTheme.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            TextWithTap(
                                "host_center_screen.u_coin_income".tr(),
                              color: kGrayColor,
                              fontSize: 12,
                              marginTop: 10,
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                              QuickHelp.getTimeByDate(
                                date: widget.currentUser!.updatedAt!,
                              ),
                              color: kContentColorLightTheme.withOpacity(0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            TextWithTap(
                                "host_center_screen.live_duration_this_moth".tr(),
                              color: kGrayColor,
                              fontSize: 12,
                              marginTop: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ContainerCorner(
              height: 100,
              width: size.width,
              borderRadius: 10,
              color: Colors.white,
              marginTop: 35,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithTap(
                          "host_center_screen.starlight_challenge".tr(),
                          fontWeight: FontWeight.bold,
                          color: kContentColorLightTheme,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                              "host_center_screen.view_more".tr().toLowerCase(),
                              fontSize: 12,
                              color: kGrayColor,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kGrayColor,
                              size: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithTap(
                          "host_center_screen.host_tasks".tr(),
                          fontWeight: FontWeight.bold,
                          color: kContentColorLightTheme,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                              "host_center_screen.view_more".tr().toLowerCase(),
                              fontSize: 12,
                              color: kGrayColor,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kGrayColor,
                              size: 10,
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ContainerCorner(
              height: 100,
              width: size.width,
              borderRadius: 10,
              color: Colors.white,
              marginTop: 20,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextWithTap(
                      "host_center_screen.features_".tr(),
                      fontWeight: FontWeight.bold,
                      color: kContentColorLightTheme,
                      alignment: Alignment.centerLeft,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget featuresOptions({
    required String caption,
    required String iconURL,
    Widget? screenTogo,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      onTap: () async {
        if (screenTogo != null) {
          UserModel? user =
          await QuickHelp.goToNavigatorScreenForResult(context, screenTogo);
          if (user != null) {
            setState(() {
              widget.currentUser = user;
            });
          }
        }
      },
      child: Column(
        children: [
          isDark
              ? Image.asset(
            iconURL,
            width: size.width / 14,
            height: size.width / 14,
            //color: kTra,
          )
              : Image.asset(
            iconURL,
            width: size.width / 14,
            height: size.width / 14,
          ),
          TextWithTap(
            caption,
            marginTop: 10,
            fontSize: size.width / 38,
          ),
        ],
      ),
    );
  }
}
