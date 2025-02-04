// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/Config.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class InviteAgentScreen extends StatefulWidget {
  UserModel? currentUser;

  InviteAgentScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<InviteAgentScreen> createState() => _InviteAgentScreenState();
}

class _InviteAgentScreenState extends State<InviteAgentScreen> {
  String linkToShare = "";

  var socialMediaIcons = [
    "assets/images/icon_share_facebook150.png",
    "assets/images/icon_share_messager_big.png",
    "assets/images/icon_share_whatsapp_72.png",
    "assets/images/icon_share_line_72.png",
    "assets/images/icon_share_more.png",
  ];

  var socialMediaTitle = [
    "facebook".tr(),
    "messenger_".tr(),
    "whatsapp_".tr(),
    "line_".tr(),
    "more_".tr(),
  ];

  bool showTempAlert = false;

  showTemporaryAlert() {
    setState(() {
      showTempAlert = true;
    });
    hideTemporaryAlert();
  }

  hideTemporaryAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showTempAlert = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    createLink();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: BackButton(
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
            centerTitle: true,
            title: TextWithTap(
              "invite_agent_screen.invite_agent".tr(),
              fontWeight: FontWeight.w900,
            ),
          ),
          body: ContainerCorner(
            height: size.height,
            width: size.width,
            borderWidth: 0,
            imageDecoration: "assets/images/bg_invite_agent.png",
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ContainerCorner(
                  borderRadius: 10,
                  borderWidth: 0,
                  color: isDark ? kContentColorDarkTheme : Colors.white,
                  marginRight: 20,
                  marginLeft: 20,
                  width: size.width,
                  marginBottom: 20,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      children: [
                        TextWithTap(
                          "invite_agent_screen.copy_link".tr(),
                          alignment: Alignment.centerLeft,
                          marginTop: 20,
                          fontSize: 18,
                        ),
                        ContainerCorner(
                          color: kPrimaryColor.withOpacity(0.2),
                          borderRadius: 10,
                          borderColor: kPrimaryColor,
                          width: size.width,
                          marginTop: 20,
                          marginBottom: 20,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 20, bottom: 20),
                            child: AutoSizeText(
                              linkToShare,
                              style: GoogleFonts.nunito(
                                fontSize: 28,
                                color: kPrimaryColor,
                              ),
                              minFontSize: 15,
                              stepGranularity: 5,
                              maxLines: 10,
                            ),
                          ),
                        ),
                        ContainerCorner(
                          height: 60,
                          borderRadius: 50,
                          marginRight: 20,
                          marginLeft: 20,
                          marginBottom: 20,
                          color: kPrimaryColor,
                          onTap: () {
                            QuickHelp.copyText(textToCopy: linkToShare);
                            showTemporaryAlert();
                          },
                          child: TextWithTap(
                            "copy_".tr(),
                            color: Colors.white,
                            alignment: Alignment.center,
                            fontSize: 18,
                          ),
                        ),
                        TextWithTap(
                          "invite_agent_screen.share_link_explain".tr(),
                          color: kGrayColor,
                          fontSize: 14,
                          marginLeft: 10,
                          marginRight: 10,
                          textAlign: TextAlign.center,
                          marginBottom: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Divider(
                            height: 2,
                          ),
                        ),
                        TextWithTap(
                          "invite_agent_screen.share_link".tr(),
                          alignment: Alignment.centerLeft,
                          marginTop: 20,
                          fontSize: 18,
                          marginBottom: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                              socialMediaIcons.length,
                              (index) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        socialMediaIcons[index],
                                        height: 45,
                                        width: 45,
                                      ),
                                      TextWithTap(
                                        socialMediaTitle[index],
                                        color: kGrayColor,
                                        marginTop: 10,
                                      )
                                    ],
                                  )),
                        ),
                        ContainerCorner(
                          height: 60,
                          borderRadius: 50,
                          marginBottom: 20,
                          marginTop: 20,
                          color: kPrimaryColor,
                          onTap: () => shareLink(),
                          child: TextWithTap(
                            "invite_agent_screen.click_to_share".tr(),
                            color: Colors.white,
                            alignment: Alignment.center,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: showTempAlert,
          child: ContainerCorner(
            color: Colors.black.withOpacity(0.5),
            height: 50,
            marginRight: 50,
            marginLeft: 50,
            borderRadius: 50,
            width: size.width / 2,
            shadowColor: kGrayColor,
            shadowColorOpacity: 0.3,
            child: TextWithTap(
              "copied_".tr(),
              color: Colors.white,
              marginBottom: 5,
              marginTop: 5,
              marginLeft: 20,
              marginRight: 20,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  shareLink() async {
    Share.share("settings_screen.share_app_url"
        .tr(namedArgs: {"app_name": Config.appName, "url": linkToShare}));
  }

  createLink() async {
    QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "settings_screen.app_could_not_gen_uri".tr(),
        user: widget.currentUser);
  }
}
