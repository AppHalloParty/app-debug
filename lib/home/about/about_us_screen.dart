// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:trace/app/config.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../web/web_url_screen.dart';

class AboutUsScreen extends StatefulWidget {
  UserModel? currentUser;

  AboutUsScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String appVersion = "...";
  final _checker = AppVersionChecker();

  void checkVersion() async {
    _checker.checkUpdate().then((value) {
      setState(() {
        appVersion = value.currentVersion;
      });
    });
  }

  var titles = [
    "about_us_screen.privacy_policy".tr(),
    "about_us_screen.terms_service".tr(),
    "about_us_screen.live_agreement".tr(),
    "about_us_screen.user_agreement".tr(),
  ];

  var urlsForPageView = [
    Config.privacyPolicyUrl,
    Config.termsOfUseUrl,
    Config.liveAgreementUrl,
    Config.userAgreementUrl,
  ];

  var titleForPageView = [
    "about_us_screen.web_view_privacy_title".tr(),
    "about_us_screen.web_view_terms_title".tr(),
    "about_us_screen.web_view_live_title".tr(),
    "about_us_screen.web_view_user_title".tr(),
  ];

  @override
  void initState() {
    super.initState();
    checkVersion();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          "about_us_screen.about_us"
              .tr(namedArgs: {"app_name": Config.appName}),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 30,
          ),
          Image.asset(
            "assets/images/ic_logo.png",
            height: size.width / 3,
            width: size.width / 3,
          ),
          TextWithTap(
            "${Config.appName} $appVersion".toUpperCase(),
            color: kGrayColor,
            fontSize: 16,
            marginTop: 10,
            marginBottom: 20,
            alignment: Alignment.center,
          ),
          Column(
            children: List.generate(
              titles.length,
              (index) {
                return option(
                  title: titles[index],
                  url: urlsForPageView[index],
                  webViewTitle: titleForPageView[index],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget option(
      {required String title,
      required String url,
      required String webViewTitle}) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: isDark ? kContentColorLightTheme : Colors.white,
      onTap: () {
        QuickHelp.goToNavigatorScreen(
          context,
          WebViewScreen(
            pageType: 'etc',
            receivedTitle: webViewTitle,
            receivedURL: url,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWithTap(
            title.capitalize,
            marginLeft: 10,
            marginTop: 10,
            marginBottom: 10,
            fontSize: size.width / 21,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
            child: Icon(
              Icons.arrow_forward_ios,
              color: kGrayColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
