// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/Config.dart';
import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class ContactUsScreen extends StatefulWidget {
  UserModel? currentUser;

  ContactUsScreen({this.currentUser, super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final Uri facebookURL = Uri.parse(Setup.facebookPage);
  final Uri facebookProfileURL = Uri.parse(Setup.facebookProfile);
  final Uri youtubeURL = Uri.parse(Setup.youtube);
  final Uri instagramURL = Uri.parse(Setup.instagram);

  var socialMediaLogos = [
    "assets/svg/fa_facebook_logo.svg",
    "assets/svg/fa_instagram_logo.svg",
    "assets/svg/fa_youtube_logo.svg",
  ];
  var socialMediaURL = [];

  Future<void> launchURL(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

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
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    socialMediaURL = [
      facebookProfileURL,
      instagramURL,
      youtubeURL,
    ];

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: BackButton(
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
            title: TextWithTap(
              "contact_us_screen.contact_us".tr(),
              fontWeight: FontWeight.bold,
            ),
          ),
          body: ListView(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
            ),
            children: [
              title(title: "contact_us_screen.contact_us".tr()),
              TextWithTap(
                "contact_us_screen.official_fb_page".tr(),
                marginBottom: 20,
              ),
              TextWithTap(
                "https://www.facebook.com/${Config.appName}/",
                marginBottom: 20,
                color: kPrimaryColor,
                onTap: () => launchURL(facebookURL),
              ),
              horizontalLine(),
              title(title: "contact_us_screen.global_social".tr()),
              Row(
                children: List.generate(socialMediaURL.length, (index) {
                  return IconButton(
                    onPressed: () => launchURL(socialMediaURL[index]),
                    icon: SvgPicture.asset(
                      socialMediaLogos[index],
                      height: size.width / 15,
                      width: size.width / 15,
                    ),
                  );
                }),
              ),
              horizontalLine(),
              title(title: "contact_us_screen.union_collaboration".tr()),
              email(),
              horizontalLine(),
              title(title: "contact_us_screen.marketing_inqueries".tr()),
              email(),
              horizontalLine(),
              title(title: "contact_us_screen.suggestion_".tr()),
              email(),
              horizontalLine(),
              TextWithTap(
                "contact_us_screen.for_more_details".tr(),
                marginBottom: 20,
                color: kGrayColor,
              ),
            ],
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

  Widget title({required String title}) {
    Size size = MediaQuery.of(context).size;
    return TextWithTap(
      title,
      fontSize: size.width / 18,
      fontWeight: FontWeight.w600,
      marginBottom: 20,
    );
  }

  Widget email() {
    return Row(
      children: [
        TextWithTap(
          "contact_us_screen.e_mail".tr(),
          marginBottom: 20,
        ),
        TextWithTap(
          Setup.gmail,
          marginBottom: 20,
          marginLeft: 10,
          color: kPrimaryColor,
          onTap: () {
            QuickHelp.copyText(
              textToCopy: Setup.gmail,
            );
            showTemporaryAlert();
          },
        ),
      ],
    );
  }

  Widget horizontalLine() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      height: 0.3,
      width: size.width,
      color: kGrayColor,
      marginTop: 10,
      marginBottom: 20,
    );
  }
}
