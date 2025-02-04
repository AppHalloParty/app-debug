// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:math' as math;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/app/cloud_params.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/home/message/message_screen.dart';
import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/ReportModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/rounded_gradient_button.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/widgets/need_resume.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trace/app/config.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trace/widgets/snackbar_pro/snack_bar_pro.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/CoinsTransactionsModel.dart';
import '../models/GiftReceivedModel.dart';
import '../models/LiveStreamingModel.dart';
import '../models/PostsModel.dart';
import '../utils/datoo_exeption.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart'
    show consolidateHttpClientResponseBytes, kIsWeb;

import '../widgets/snackbar_pro/top_snack_bar.dart';
import 'countries_iso.dart';
import 'languages_iso.dart';

typedef EmailSendingCallback = void Function(bool sent, ParseError? error);

class QuickHelp {
  ParseConfig config = ParseConfig();

  static const String pageTypeTerms = "/terms";
  static const String pageTypePrivacy = "/privacy";
  static const String pageTypeOpenSource = "/opensource";
  static const String pageTypeHelpCenter = "/help";
  static const String pageTypeSafety = "/safety";
  static const String pageTypeCommunity = "/community";
  static const String pageTypeWhatsapp = "/whatsapp";
  static const String pageTypeInstructions = "/instructions";
  static const String pageTypeSupport = "/support";
  static const String pageTypeCashOut = "/cashOut";

  static String dateFormatDmy = "dd/MM/yyyy";
  static String dateFormatFacebook = "MM/dd/yyyy";
  static String dateFormatForFeed = "dd MMM, yyyy - HH:mm";

  static String dateFormatTimeOnly = "HH:mm";
  static String dateFormatListMessageFull = "dd MM, HH:mm";
  static String dateFormatDateOnly = "dd/MM/yy";
  static String dateFormatDayAndDateOnly = "EE., dd MMM";

  static String emailTypeWelcome = "welcome_email";
  static String emailTypeVerificationCode = "verification_code_email";

  static double earthMeanRadiusKm = 6371.0;
  static double earthMeanRadiusMile = 3958.8;

  // Online/offline track
  static int timeToSoon = 300 * 1000;
  static int timeToOffline = 2 * 60 * 1000;

  static final String admobBannerAdTest = isAndroidPlatform()
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-3940256099942544/2934735716";

  static final String admobNativeAdTest = isAndroidPlatform()
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-3940256099942544/3986624511";

  static final String admobOpenAppAdTest = isAndroidPlatform()
      ? "ca-app-pub-3940256099942544/3419835294"
      : "ca-app-pub-3940256099942544/5662855259";

  static copyText({required String textToCopy}) {
    Clipboard.setData(ClipboardData(text: textToCopy));
  }

  static Color stringToColor(String colorString) {
    //String valueString = colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    String valueString = "0xFF$colorString"; // kind of hacky..
    int value = int.parse(valueString);
    Color reverseColor = Color(value);
    return reverseColor;
  }

  static bool isAvailable(DateTime expireDate) {
    DateTime now = DateTime.now();

    if (expireDate.isAfter(now)) {
      return true;
    } else {
      return false;
    }
  }

  static getImageToShare(PostsModel post) {
    if(post.getImagesList!.isNotEmpty) {
      return post.getImagesList![0].url;
    }else if(post.getVideoThumbnail != null) {
      return post.getVideoThumbnail!.url!;
    }else{
      return null;
    }
  }

  static bool has24HoursPassed(DateTime inputDate) {
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(inputDate);
    return difference.inHours >= 24;
  }

  static String timeUntil24Hours(DateTime inputDate) {
    DateTime currentDate = DateTime.now();

    DateTime targetDate = inputDate.add(Duration(hours: 24));
    Duration difference = targetDate.difference(currentDate);

    if (difference.isNegative) {
      return "0h: 0min: 0sec";
    }

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    return "${hours}h: ${minutes}min: ${seconds}sec";
  }

  static String getTitleToShare(PostsModel post) {
    if(post.getText!.isNotEmpty) {
      return post.getText!;
    }else{
      return "feed.post_posted_title".tr();
    }
  }

  static Color getColorStandard({bool? inverse}) {
    if (isDarkModeNoContext()) {
      if (inverse != null && inverse) {
        return kContentColorLightTheme;
      } else {
        return kContentColorDarkTheme;
      }
    } else {
      if (inverse != null && inverse) {
        return kContentColorDarkTheme;
      } else {
        return kContentColorLightTheme;
      }
    }
  }

  static bool isMvpUser(UserModel? user){
    if(user != null) {
      DateTime now = DateTime.now();
      DateTime? to;

      if(user.getMVPMember != null){
        if(user.getMVPMember != null) {
          to = user.getMVPMember!;
        }else{
          to = now;
        }
        if(to.isAfter(now)){
          return true;
        }
      }
    }

    return false;
  }

  static Widget usersMoreInfo(
      BuildContext context, UserModel user, {MainAxisAlignment? mainAxisAlignment}){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      children: [
        const SizedBox(width: 6,),
        Container(
          height: 21,
          child: QuickActions.getGender(
            currentUser:
            user,
            context: context,
          ),
        ),
        Visibility(
          visible: user.getCredits! > 0,
          child: Row(
            children: [
              const SizedBox(width: 5,),
              Image.asset(
                QuickHelp.levelVipBanner(currentCredit: user.getCredits!.toDouble()),
                scale: 2.2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: Image.asset(
              QuickHelp.levelImage(
                pointsInApp: user.getUserPoints!,
              ),
              width: 37,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Visibility(
          visible: QuickHelp.isMvpUser(user),
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Image.asset(
              "assets/images/vip_member.png",
              width: 36,
            ),
          ),
        ),
      ],
    );
  }

  static String levelVipFrame({required double currentCredit}){
    if(currentCredit > 0 && currentCredit <= 9999){
      return "assets/images/ic_vip_frame_1.png";
    } else if(currentCredit >= 10000 && currentCredit <= 49999){
      return "assets/images/ic_vip_frame_2.png";
    } else if(currentCredit >= 50000 && currentCredit <= 99999){
      return "assets/images/ic_vip_frame_3.png";
    } else if(currentCredit >= 100000 && currentCredit <= 199999){
      return "assets/images/ic_vip_frame_4.png";
    } else if(currentCredit >= 200000 && currentCredit <= 499999){
      return "assets/images/ic_vip_frame_5.png";
    } else if(currentCredit >= 500000 && currentCredit <= 999999){
      return "assets/images/ic_vip_frame_6.png";
    } else if(currentCredit >= 1000000 && currentCredit <= 1999999){
      return "assets/images/ic_vip_frame_7.png";
    } else if(currentCredit >= 2000000 && currentCredit <= 4999999){
      return "assets/images/ic_vip_frame_8.png";
    } else if(currentCredit >= 5000000 && currentCredit <= 9999999){
      return "assets/images/ic_vip_frame_9.png";
    } else if(currentCredit >= 10000000){
      return "assets/images/ic_vip_frame_10.png";
    } else {
      return "";
    }
  }

  static String levelVipBanner({required double currentCredit}){
    if(currentCredit > 0 && currentCredit <= 9999){
      return "assets/images/ic_vip_1.png";
    } else if(currentCredit >= 10000 && currentCredit <= 49999){
      return "assets/images/ic_vip_2.png";
    } else if(currentCredit >= 50000 && currentCredit <= 99999){
      return "assets/images/ic_vip_3.png";
    } else if(currentCredit >= 100000 && currentCredit <= 199999){
      return "assets/images/ic_vip_4.png";
    } else if(currentCredit >= 200000 && currentCredit <= 499999){
      return "assets/images/ic_vip_5.png";
    } else if(currentCredit >= 500000 && currentCredit <= 999999){
      return "assets/images/ic_vip_6.png";
    } else if(currentCredit >= 1000000 && currentCredit <= 1999999){
      return "assets/images/ic_vip_7.png";
    } else if(currentCredit >= 2000000 && currentCredit <= 4999999){
      return "assets/images/ic_vip_8.png";
    } else if(currentCredit >= 5000000 && currentCredit <= 9999999){
      return "assets/images/ic_vip_9.png";
    } else if(currentCredit >= 10000000){
      return "assets/images/ic_vip_10.png";
    } else {
      return "";
    }
  }

  static String? levelVipCover({required double currentCredit, required UserModel user}){
    if(currentCredit > 0 && currentCredit <= 9999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_1.png";
    } else if(currentCredit >= 10000 && currentCredit <= 49999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_2.png";
    } else if(currentCredit >= 50000 && currentCredit <= 99999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_3.png";
    } else if(currentCredit >= 100000 && currentCredit <= 199999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_4.png";
    } else if(currentCredit >= 200000 && currentCredit <= 499999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_5.png";
    } else if(currentCredit >= 500000 && currentCredit <= 999999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_6.png";
    } else if(currentCredit >= 1000000 && currentCredit <= 1999999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_7.png";
    } else if(currentCredit >= 2000000 && currentCredit <= 4999999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_8.png";
    } else if(currentCredit >= 5000000 && currentCredit <= 9999999 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_9.png";
    } else if(currentCredit >= 10000000 && !user.getProfileCoverFrame!){
      return "assets/images/bg_vip_cover_10.png";
    } else {
      return null;
    }
  }

  static String levelUser(int index, {required double currentCredit}){
    if(currentCredit == 0 && index == 0){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 0 && index == 0){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit > 0 && currentCredit <= 9999 && index == 1){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 9999 && index == 1){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 10000 && currentCredit <= 49999 && index == 2){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 49999 && index == 2){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 50000 && currentCredit <= 99999 && index == 3){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 99999 && index == 3){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 100000 && currentCredit <= 199999 && index == 4){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 199999 && index == 4){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 200000 && currentCredit <= 499999 && index == 5){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 499999 && index == 5){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 500000 && currentCredit <= 999999 && index == 6){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 999999 && index == 6){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 1000000 && currentCredit <= 1999999 && index == 7){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 1999999 && index == 7){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 2000000 && currentCredit <= 4999999 && index == 8){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 4999999 && index == 8){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 5000000 && currentCredit <= 9999999 && index == 9){
      return "guardian_and_vip_screen.current_level".tr();
    }else if(currentCredit > 9999999 && index == 9){
      return "guardian_and_vip_screen.past_level".tr();
    } else if(currentCredit >= 10000000 && index == 10){
      return "guardian_and_vip_screen.current_level".tr();
    } else {
      return "guardian_and_vip_screen.not_gained".tr();
    }
  }

  static int levelUserPage(double currentCredit){
    if(currentCredit > 0 && currentCredit <= 9999){
      return 1;
    } else if(currentCredit >= 10000 && currentCredit <= 49999){
      return 2;
    } else if(currentCredit >= 50000 && currentCredit <= 99999){
      return 3;
    } else if(currentCredit >= 100000 && currentCredit <= 199999){
      return 4;
    } else if(currentCredit >= 200000 && currentCredit <= 499999){
      return 5;
    } else if(currentCredit >= 500000 && currentCredit <= 999999){
      return 6;
    } else if(currentCredit >= 1000000 && currentCredit <= 1999999){
      return 7;
    } else if(currentCredit >= 2000000 && currentCredit <= 4999999){
      return 8;
    } else if(currentCredit >= 5000000 && currentCredit <= 9999999){
      return 9;
    } else if(currentCredit >= 10000000){
      return 10;
    } else {
      return 0;
    }
  }

  static String fanClubIcon({required int day}) {
    if(day == 0) {
      return "assets/images/tab_fst_0.png";
    }else if(day == 1) {
      return "assets/images/tab_fst_1.png";
    }else if(day == 2) {
      return "assets/images/tab_fst_2.png";
    }else if(day == 3) {
      return "assets/images/tab_fst_3.png";
    }else if(day == 4) {
      return "assets/images/tab_fst_4.png";
    }else if(day == 5) {
      return "assets/images/tab_fst_5.png";
    }else if(day == 6) {
      return "assets/images/tab_fst_6.png";
    }else if(day == 7) {
      return "assets/images/tab_fst_7.png";
    }else if(day == 8) {
      return "assets/images/tab_fst_8.png";
    }else if(day == 9) {
      return "assets/images/tab_fst_9.png";
    }else if(day == 10) {
      return "assets/images/tab_fst_10.png";
    }else if(day == 11) {
      return "assets/images/tab_fst_11.png";
    }else if(day == 12) {
      return "assets/images/tab_fst_12.png";
    }else if(day == 13) {
      return "assets/images/tab_fst_13.png";
    }else if(day == 14) {
      return "assets/images/tab_fst_14.png";
    }else if(day == 15) {
      return "assets/images/tab_fst_15.png";
    }else if(day == 16) {
      return "assets/images/tab_fst_16.png";
    }else if(day == 17) {
      return "assets/images/tab_fst_17.png";
    }else if(day == 18) {
      return "assets/images/tab_fst_18.png";
    }else if(day == 19) {
      return "assets/images/tab_fst_19.png";
    }else if(day == 20) {
      return "assets/images/tab_fst_20.png";
    }else if(day == 21) {
      return "assets/images/tab_fst_21.png";
    }else if(day == 22) {
      return "assets/images/tab_fst_22.png";
    }else if(day == 23) {
      return "assets/images/tab_fst_23.png";
    }else if(day == 24) {
      return "assets/images/tab_fst_24.png";
    }else if(day == 25) {
      return "assets/images/tab_fst_25.png";
    }else if(day == 26) {
      return "assets/images/tab_fst_26.png";
    }else if(day == 27) {
      return "assets/images/tab_fst_27.png";
    }else if(day == 28) {
      return "assets/images/tab_fst_28.png";
    }else if(day == 29) {
      return "assets/images/tab_fst_29.png";
    }else if(day == 30) {
      return "assets/images/tab_fst_30.png";
    }else if(day == 31) {
      return "assets/images/tab_fst_31.png";
    }else if(day == 32) {
      return "assets/images/tab_fst_32.png";
    }else if(day == 33) {
      return "assets/images/tab_fst_33.png";
    }else if(day == 34) {
      return "assets/images/tab_fst_34.png";
    }else if(day == 35) {
      return "assets/images/tab_fst_35.png";
    }else if(day == 36) {
      return "assets/images/tab_fst_36.png";
    }else if(day == 37) {
      return "assets/images/tab_fst_37.png";
    }else if(day == 38) {
      return "assets/images/tab_fst_38.png";
    }else if(day == 39) {
      return "assets/images/tab_fst_39.png";
    }else if(day == 40) {
      return "assets/images/tab_fst_40.png";
    }else if(day == 41) {
      return "assets/images/tab_fst_41.png";
    }else if(day == 42) {
      return "assets/images/tab_fst_42.png";
    }else if(day == 43) {
      return "assets/images/tab_fst_43.png";
    }else if(day == 44) {
      return "assets/images/tab_fst_44.png";
    }else if(day == 45) {
      return "assets/images/tab_fst_45.png";
    }else if(day == 46) {
      return "assets/images/tab_fst_46.png";
    }else if(day == 47) {
      return "assets/images/tab_fst_47.png";
    }else if(day == 48) {
      return "assets/images/tab_fst_48.png";
    }else if(day == 49) {
      return "assets/images/tab_fst_49.png";
    }else if(day == 50) {
      return "assets/images/tab_fst_50.png";
    }else if(day == 51) {
      return "assets/images/tab_fst_51.png";
    }else if(day == 52) {
      return "assets/images/tab_fst_52.png";
    }else if(day == 53) {
      return "assets/images/tab_fst_53.png";
    }else if(day == 54) {
      return "assets/images/tab_fst_54.png";
    }else if(day == 55) {
      return "assets/images/tab_fst_55.png";
    }else if(day == 56) {
      return "assets/images/tab_fst_56.png";
    }else if(day == 57) {
      return "assets/images/tab_fst_57.png";
    }else if(day == 58) {
      return "assets/images/tab_fst_58.png";
    }else if(day == 59) {
      return "assets/images/tab_fst_59.png";
    }else if(day == 60) {
      return "assets/images/tab_fst_60.png";
    }else if(day == 61) {
      return "assets/images/tab_fst_61.png";
    }else if(day == 62) {
      return "assets/images/tab_fst_62.png";
    }else if(day == 63) {
      return "assets/images/tab_fst_63.png";
    }else if(day == 64) {
      return "assets/images/tab_fst_64.png";
    }else if(day == 65) {
      return "assets/images/tab_fst_65.png";
    }else if(day == 66) {
      return "assets/images/tab_fst_66.png";
    }else if(day == 67) {
      return "assets/images/tab_fst_67.png";
    }else if(day == 68) {
      return "assets/images/tab_fst_68.png";
    }else if(day == 69) {
      return "assets/images/tab_fst_69.png";
    }else if(day == 70) {
      return "assets/images/tab_fst_70.png";
    }else if(day == 71) {
      return "assets/images/tab_fst_71.png";
    }else if(day == 72) {
      return "assets/images/tab_fst_72.png";
    }else if(day == 73) {
      return "assets/images/tab_fst_73.png";
    }else if(day == 74) {
      return "assets/images/tab_fst_74.png";
    }else if(day == 75) {
      return "assets/images/tab_fst_75.png";
    }else if(day == 76) {
      return "assets/images/tab_fst_76.png";
    }else if(day == 77) {
      return "assets/images/tab_fst_77.png";
    }else if(day == 78) {
      return "assets/images/tab_fst_78.png";
    }else if(day == 79) {
      return "assets/images/tab_fst_79.png";
    }else if(day == 80) {
      return "assets/images/tab_fst_80.png";
    }else if(day == 81) {
      return "assets/images/tab_fst_81.png";
    }else if(day == 82) {
      return "assets/images/tab_fst_82.png";
    }else if(day == 83) {
      return "assets/images/tab_fst_83.png";
    }else if(day == 84) {
      return "assets/images/tab_fst_84.png";
    }else if(day == 85) {
      return "assets/images/tab_fst_85.png";
    }else if(day == 86) {
      return "assets/images/tab_fst_86.png";
    }else if(day == 87) {
      return "assets/images/tab_fst_87.png";
    }else if(day == 88) {
      return "assets/images/tab_fst_88.png";
    }else if(day == 89) {
      return "assets/images/tab_fst_89.png";
    }else if(day == 90) {
      return "assets/images/tab_fst_90.png";
    }else if(day == 91) {
      return "assets/images/tab_fst_91.png";
    }else if(day == 92) {
      return "assets/images/tab_fst_92.png";
    }else if(day == 93) {
      return "assets/images/tab_fst_93.png";
    }else if(day == 94) {
      return "assets/images/tab_fst_94.png";
    }else if(day == 95) {
      return "assets/images/tab_fst_95.png";
    }else if(day == 96) {
      return "assets/images/tab_fst_96.png";
    }else if(day == 97) {
      return "assets/images/tab_fst_97.png";
    }else if(day == 98) {
      return "assets/images/tab_fst_98.png";
    }else if(day == 99) {
      return "assets/images/tab_fst_99.png";
    }else if(day == 100) {
      return "assets/images/tab_fst_100.png";
    }else{
      return "assets/images/tab_fst_0.png";
    }
  }

  static String checkFundsWithString({required String amount,}) {

    //final formatter = intl.NumberFormat.decimalPattern();

    NumberFormat format = NumberFormat.decimalPatternDigits(
        locale: Intl.defaultLocale,);
    if (amount.isNotEmpty) {
      return "${format.format(double.parse(amount))}";
    } else {
      return format.format(double.parse("0.00"));
    }
  }

  static String checkFundsWithCurrency(BuildContext context, {required String amount, required String currency,}) {

    NumberFormat format = NumberFormat.decimalPatternDigits(
        locale: Intl.defaultLocale,);
    if (amount.isNotEmpty) {
      return "${getCurrency(context, currency)} ${format.format(double.parse(amount))}";
    } else {
      return format.format(double.parse("0.00"));
    }
  }

  static NumberFormat getCurrency(BuildContext context, String currency) {
    Locale locale = Localizations.localeOf(context);
    return NumberFormat.simpleCurrency(
        locale: locale.toString(), name: currency);
  }

  static String levelImage({required int pointsInApp}) {
    if(pointsInApp <= Setup.level1MaxPoint){
      return "assets/images/lv_1.png";
    }else if (pointsInApp <= Setup.level2MaxPoint) {
      return "assets/images/lv_2.png";
    } else if (pointsInApp <= Setup.level3MaxPoint) {
      return "assets/images/lv_3.png";
    } else if (pointsInApp <= Setup.level4MaxPoint) {
      return "assets/images/lv_4.png";
    } else if (pointsInApp <= Setup.level5MaxPoint) {
      return "assets/images/lv_5.png";
    } else if (pointsInApp <= Setup.level6MaxPoint) {
      return "assets/images/lv_6.png";
    } else if (pointsInApp <= Setup.level7MaxPoint) {
      return "assets/images/lv_7.png";
    } else if (pointsInApp <= Setup.level8MaxPoint) {
      return "assets/images/lv_8.png";
    } else if (pointsInApp <= Setup.level9MaxPoint) {
      return "assets/images/lv_9.png";
    } else if (pointsInApp <= Setup.level10MaxPoint) {
      return "assets/images/lv_10.png";
    } else if (pointsInApp <= Setup.level11MaxPoint) {
      return "assets/images/lv_11.png";
    } else if (pointsInApp <= Setup.level12MaxPoint) {
      return "assets/images/lv_12.png";
    } else if (pointsInApp <= Setup.level13MaxPoint) {
      return "assets/images/lv_13.png";
    } else if (pointsInApp <= Setup.level14MaxPoint) {
      return "assets/images/lv_14.png";
    } else if (pointsInApp <= Setup.level15MaxPoint) {
      return "assets/images/lv_15.png";
    } else if (pointsInApp <= Setup.level16MaxPoint) {
      return "assets/images/lv_16.png";
    } else if (pointsInApp <= Setup.level17MaxPoint) {
      return "assets/images/lv_17.png";
    } else if (pointsInApp <= Setup.level18MaxPoint) {
      return "assets/images/lv_18.png";
    } else if (pointsInApp <= Setup.level19MaxPoint) {
      return "assets/images/lv_19.png";
    } else if (pointsInApp <= Setup.level20MaxPoint) {
      return "assets/images/lv_20.png";
    } else if (pointsInApp <= Setup.level21MaxPoint) {
      return "assets/images/lv_21.png";
    } else if (pointsInApp <= Setup.level22MaxPoint) {
      return "assets/images/lv_22.png";
    } else if (pointsInApp <= Setup.level23MaxPoint) {
      return "assets/images/lv_23.png";
    } else if (pointsInApp <= Setup.level24MaxPoint) {
      return "assets/images/lv_24.png";
    } else if (pointsInApp <= Setup.level25MaxPoint) {
      return "assets/images/lv_25.png";
    } else if (pointsInApp <= Setup.level26MaxPoint) {
      return "assets/images/lv_26.png";
    } else if (pointsInApp <= Setup.level27MaxPoint) {
      return "assets/images/lv_27.png";
    } else if (pointsInApp <= Setup.level28MaxPoint) {
      return "assets/images/lv_28.png";
    } else if (pointsInApp <= Setup.level29MaxPoint) {
      return "assets/images/lv_29.png";
    } else if (pointsInApp <= Setup.level30MaxPoint) {
      return "assets/images/lv_30.png";
    } else if (pointsInApp <= Setup.level31MaxPoint) {
      return "assets/images/lv_31.png";
    } else if (pointsInApp <= Setup.level32MaxPoint) {
      return "assets/images/lv_32.png";
    } else if (pointsInApp <= Setup.level33MaxPoint) {
      return "assets/images/lv_33.png";
    } else if (pointsInApp <= Setup.level34MaxPoint) {
      return "assets/images/lv_34.png";
    } else if (pointsInApp <= Setup.level35MaxPoint) {
      return "assets/images/lv_35.png";
    } else if (pointsInApp <= Setup.level36MaxPoint) {
      return "assets/images/lv_36.png";
    } else{
      return "assets/images/lv_1.png";
    }
  }

  static String levelImageWithBanner({required int pointsInApp}) {
    if(pointsInApp <= Setup.level1MaxPoint){
      return "assets/images/grade_big_1.png";
    }else if (pointsInApp <= Setup.level2MaxPoint) {
      return "assets/images/grade_big_2.png";
    } else if (pointsInApp <= Setup.level3MaxPoint) {
      return "assets/images/grade_big_3.png";
    } else if (pointsInApp <= Setup.level4MaxPoint) {
      return "assets/images/grade_big_4.png";
    } else if (pointsInApp <= Setup.level5MaxPoint) {
      return "assets/images/grade_big_5.png";
    } else if (pointsInApp <= Setup.level6MaxPoint) {
      return "assets/images/lv_6.png";
    } else if (pointsInApp <= Setup.level7MaxPoint) {
      return "assets/images/grade_big_6.png";
    } else if (pointsInApp <= Setup.level8MaxPoint) {
      return "assets/images/grade_big_7.png";
    } else if (pointsInApp <= Setup.level9MaxPoint) {
      return "assets/images/grade_big_8.png";
    } else if (pointsInApp <= Setup.level10MaxPoint) {
      return "assets/images/grade_big_9.png";
    } else if (pointsInApp <= Setup.level11MaxPoint) {
      return "assets/images/grade_big_10.png";
    } else if (pointsInApp <= Setup.level12MaxPoint) {
      return "assets/images/grade_big_11.png";
    } else if (pointsInApp <= Setup.level13MaxPoint) {
      return "assets/images/grade_big_12.png";
    } else if (pointsInApp <= Setup.level14MaxPoint) {
      return "assets/images/grade_big_13.png";
    } else if (pointsInApp <= Setup.level15MaxPoint) {
      return "assets/images/grade_big_14.png";
    } else if (pointsInApp <= Setup.level16MaxPoint) {
      return "assets/images/grade_big_15.png";
    } else if (pointsInApp <= Setup.level17MaxPoint) {
      return "assets/images/grade_big_16.png";
    } else if (pointsInApp <= Setup.level18MaxPoint) {
      return "assets/images/grade_big_17.png";
    } else if (pointsInApp <= Setup.level19MaxPoint) {
      return "assets/images/grade_big_18.png";
    } else if (pointsInApp <= Setup.level20MaxPoint) {
      return "assets/images/grade_big_19.png";
    } else if (pointsInApp <= Setup.level21MaxPoint) {
      return "assets/images/grade_big_20.png";
    } else if (pointsInApp <= Setup.level22MaxPoint) {
      return "assets/images/grade_big_21.png";
    } else if (pointsInApp <= Setup.level23MaxPoint) {
      return "assets/images/grade_big_22.png";
    } else if (pointsInApp <= Setup.level24MaxPoint) {
      return "assets/images/grade_big_23.png";
    } else if (pointsInApp <= Setup.level25MaxPoint) {
      return "assets/images/grade_big_24.png";
    } else if (pointsInApp <= Setup.level26MaxPoint) {
      return "assets/images/grade_big_25.png";
    } else{
      return "assets/images/grade_big_1.png";
    }
  }

  static String levelCaption({required int pointsInApp}) {
    if(pointsInApp <= Setup.level1MaxPoint){
      return "LV 1";
    }else if (pointsInApp <= Setup.level2MaxPoint) {
      return "LV 2";
    } else if (pointsInApp <= Setup.level3MaxPoint) {
      return "LV 3";
    } else if (pointsInApp <= Setup.level4MaxPoint) {
      return "LV 4";
    } else if (pointsInApp <= Setup.level5MaxPoint) {
      return "LV 5";
    } else if (pointsInApp <= Setup.level7MaxPoint) {
      return "LV 6";
    } else if (pointsInApp <= Setup.level8MaxPoint) {
      return "LV 7";
    } else if (pointsInApp <= Setup.level9MaxPoint) {
      return "LV 8";
    } else if (pointsInApp <= Setup.level10MaxPoint) {
      return "LV 9";
    } else if (pointsInApp <= Setup.level11MaxPoint) {
      return "LV 10";
    } else if (pointsInApp <= Setup.level12MaxPoint) {
      return "LV 11";
    } else if (pointsInApp <= Setup.level13MaxPoint) {
      return "LV 12";
    } else if (pointsInApp <= Setup.level14MaxPoint) {
      return "LV 13";
    } else if (pointsInApp <= Setup.level15MaxPoint) {
      return "LV 14";
    } else if (pointsInApp <= Setup.level16MaxPoint) {
      return "LV 15";
    } else if (pointsInApp <= Setup.level17MaxPoint) {
      return "LV 16";
    } else if (pointsInApp <= Setup.level18MaxPoint) {
      return "LV 17";
    } else if (pointsInApp <= Setup.level19MaxPoint) {
      return "LV 18";
    } else if (pointsInApp <= Setup.level20MaxPoint) {
      return "LV 19";
    } else if (pointsInApp <= Setup.level21MaxPoint) {
      return "LV 20";
    } else if (pointsInApp <= Setup.level22MaxPoint) {
      return "LV 21";
    } else if (pointsInApp <= Setup.level23MaxPoint) {
      return "LV 22";
    } else if (pointsInApp <= Setup.level24MaxPoint) {
      return "LV 23";
    } else if (pointsInApp <= Setup.level25MaxPoint) {
      return "LV 24";
    } else if (pointsInApp <= Setup.level26MaxPoint) {
      return "LV 26";
    } else{
      return "LV 0";
    }
  }

  static int levelPositionIndex({required int pointsInApp}) {
    if(pointsInApp <= Setup.level1MaxPoint){
      return 1;
    }else if (pointsInApp <= Setup.level2MaxPoint) {
      return 2;
    } else if (pointsInApp <= Setup.level3MaxPoint) {
      return 3;
    } else if (pointsInApp <= Setup.level4MaxPoint) {
      return 4;
    } else if (pointsInApp <= Setup.level5MaxPoint) {
      return 5;
    } else if (pointsInApp <= Setup.level7MaxPoint) {
      return 6;
    } else if (pointsInApp <= Setup.level8MaxPoint) {
      return 7;
    } else if (pointsInApp <= Setup.level9MaxPoint) {
      return 8;
    } else if (pointsInApp <= Setup.level10MaxPoint) {
      return 9;
    } else if (pointsInApp <= Setup.level11MaxPoint) {
      return 10;
    } else if (pointsInApp <= Setup.level12MaxPoint) {
      return 11;
    } else if (pointsInApp <= Setup.level13MaxPoint) {
      return 12;
    } else if (pointsInApp <= Setup.level14MaxPoint) {
      return 13;
    } else if (pointsInApp <= Setup.level15MaxPoint) {
      return 14;
    } else if (pointsInApp <= Setup.level16MaxPoint) {
      return 15;
    } else if (pointsInApp <= Setup.level17MaxPoint) {
      return 16;
    } else if (pointsInApp <= Setup.level18MaxPoint) {
      return 17;
    } else if (pointsInApp <= Setup.level19MaxPoint) {
      return 18;
    } else if (pointsInApp <= Setup.level20MaxPoint) {
      return 19;
    } else if (pointsInApp <= Setup.level21MaxPoint) {
      return 20;
    } else if (pointsInApp <= Setup.level22MaxPoint) {
      return 21;
    } else if (pointsInApp <= Setup.level23MaxPoint) {
      return 22;
    } else if (pointsInApp <= Setup.level24MaxPoint) {
      return 23;
    } else if (pointsInApp <= Setup.level25MaxPoint) {
      return 24;
    } else if (pointsInApp <= Setup.level26MaxPoint) {
      return 25;
    } else{
      return 0;
    }
  }

  static int levelPositionValues({required int pointsInApp}) {
    if(pointsInApp <= Setup.level1MaxPoint){
      return Setup.level1MaxPoint;
    }else if (pointsInApp <= Setup.level2MaxPoint) {
      return Setup.level2MaxPoint;
    } else if (pointsInApp <= Setup.level3MaxPoint) {
      return Setup.level3MaxPoint;
    } else if (pointsInApp <= Setup.level4MaxPoint) {
      return Setup.level4MaxPoint;
    } else if (pointsInApp <= Setup.level5MaxPoint) {
      return Setup.level5MaxPoint;
    } else if (pointsInApp <= Setup.level7MaxPoint) {
      return Setup.level7MaxPoint;
    } else if (pointsInApp <= Setup.level8MaxPoint) {
      return Setup.level8MaxPoint;
    } else if (pointsInApp <= Setup.level9MaxPoint) {
      return Setup.level9MaxPoint;
    } else if (pointsInApp <= Setup.level10MaxPoint) {
      return Setup.level10MaxPoint;
    } else if (pointsInApp <= Setup.level11MaxPoint) {
      return Setup.level11MaxPoint;
    } else if (pointsInApp <= Setup.level12MaxPoint) {
      return Setup.level12MaxPoint;
    } else if (pointsInApp <= Setup.level13MaxPoint) {
      return Setup.level13MaxPoint;
    } else if (pointsInApp <= Setup.level14MaxPoint) {
      return Setup.level14MaxPoint;
    } else if (pointsInApp <= Setup.level15MaxPoint) {
      return Setup.level15MaxPoint;
    } else if (pointsInApp <= Setup.level16MaxPoint) {
      return Setup.level16MaxPoint;
    } else if (pointsInApp <= Setup.level17MaxPoint) {
      return Setup.level17MaxPoint;
    } else if (pointsInApp <= Setup.level18MaxPoint) {
      return Setup.level18MaxPoint;
    } else if (pointsInApp <= Setup.level19MaxPoint) {
      return Setup.level19MaxPoint;
    } else if (pointsInApp <= Setup.level20MaxPoint) {
      return Setup.level20MaxPoint;
    } else if (pointsInApp <= Setup.level21MaxPoint) {
      return Setup.level21MaxPoint;
    } else if (pointsInApp <= Setup.level22MaxPoint) {
      return Setup.level22MaxPoint;
    } else if (pointsInApp <= Setup.level23MaxPoint) {
      return Setup.level23MaxPoint;
    } else if (pointsInApp <= Setup.level24MaxPoint) {
      return Setup.level24MaxPoint;
    } else if (pointsInApp <= Setup.level25MaxPoint) {
      return Setup.level25MaxPoint;
    } else if (pointsInApp <= Setup.level26MaxPoint) {
      return Setup.level26MaxPoint;
    } else{
      return 0;
    }
  }

  static int wealthLevelValue({required int creditSent}) {
    if(creditSent == 0) {
      return 0;
    }else if (creditSent <= 3000) {
      return 3000;
    } else if (creditSent <= 6000) {
      return 6000;
    } else if (creditSent <= 16000) {
      return 16000;
    } else if (creditSent <= 66000) {
      return 66000;
    } else if (creditSent <= 166000) {
      return 166000;
    } else if (creditSent <= 330000) {
      return 330000;
    } else if (creditSent <= 500000) {
      return 500000;
    } else if (creditSent <= 700000) {
      return 700000;
    } else if (creditSent <= 1000000) {
      return 1000000;
    } else if (creditSent <= 1100000) {
      return 1100000;
    } else if (creditSent <= 1300000) {
      return 1300000;
    } else if (creditSent <= 1600000) {
      return 1600000;
    } else if (creditSent <= 2000000) {
      return 2000000;
    } else if (creditSent <= 2600000) {
      return 2600000;
    } else if (creditSent <= 3400000) {
      return 3400000;
    } else if (creditSent <= 4400000) {
      return 4400000;
    } else if (creditSent <= 5600000) {
      return 5600000;
    } else if (creditSent <= 7000000) {
      return 7000000;
    } else if (creditSent <= 10000000) {
      return 10000000;
    } else if (creditSent <= 10500000) {
      return 10500000;
    } else if (creditSent <= 11500000) {
      return 11500000;
    } else if (creditSent <= 13000000) {
      return 13000000;
    } else if (creditSent <= 15000000) {
      return 15000000;
    } else if (creditSent <= 18000000) {
      return 18000000;
    } else if (creditSent <= 22000000) {
      return 22000000;
    } else if (creditSent <= 27000000) {
      return 27000000;
    } else if (creditSent <= 33000000) {
      return 33000000;
    } else if (creditSent <= 40000000) {
      return 40000000;
    } else if (creditSent <= 50000000) {
      return 50000000;
    } else if (creditSent <= 52000000) {
      return 52000000;
    } else if (creditSent <= 55000000) {
      return 55000000;
    } else if (creditSent <= 60000000) {
      return 60000000;
    } else if (creditSent <= 68000000) {
      return 68000000;
    } else if (creditSent <= 79000000) {
      return 79000000;
    } else if (creditSent <= 95000000) {
      return 95000000;
    } else if (creditSent <= 114000000) {
      return 114000000;
    } else if (creditSent <= 137000000) {
      return 137000000;
    } else if (creditSent <= 163000000) {
      return 163000000;
    } else if (creditSent <= 200000000) {
      return 200000000;
    } else if (creditSent <= 204000000) {
      return 204000000;
    } else if (creditSent <= 210000000) {
      return 210000000;
    } else if (creditSent <= 220000000) {
      return 220000000;
    } else if (creditSent <= 236000000) {
      return 236000000;
    } else if (creditSent <= 258000000) {
      return 258000000;
    } else if (creditSent <= 290000000) {
      return 290000000;
    } else if (creditSent <= 328000000) {
      return 328000000;
    } else if (creditSent <= 375000000) {
      return 375000000;
    } else if (creditSent <= 428000000) {
      return 428000000;
    } else if (creditSent <= 500000000) {
      return 500000000;
    } else if (creditSent <= 506000000) {
      return 506000000;
    } else if (creditSent <= 516000000) {
      return 516000000;
    } else if (creditSent <= 535000000) {
      return 535000000;
    } else if (creditSent <= 560000000) {
      return 560000000;
    } else if (creditSent <= 598000000) {
      return 598000000;
    } else if (creditSent <= 648000000) {
      return 648000000;
    } else if (creditSent <= 710000000) {
      return 710000000;
    } else if (creditSent <= 785000000) {
      return 785000000;
    } else if (creditSent <= 870000000) {
      return 870000000;
    } else if (creditSent <= 1000000000) {
      return 1000000000;
    } else if (creditSent <= 1020000000) {
      return 1020000000;
    } else if (creditSent <= 1060000000) {
      return 1060000000;
    } else if (creditSent <= 1120000000) {
      return 1120000000;
    } else if (creditSent <= 1220000000) {
      return 1220000000;
    } else if (creditSent <= 1360000000) {
      return 1360000000;
    } else if (creditSent <= 1560000000) {
      return 1560000000;
    } else if (creditSent <= 1800000000) {
      return 1800000000;
    } else if (creditSent <= 2100000000) {
      return 2100000000;
    } else if (creditSent <= 2440000000) {
      return 2440000000;
    } else if (creditSent <= 3000000000) {
      return 3000000000;
    } else if (creditSent <= 3020000000) {
      return 3020000000;
    } else if (creditSent <= 3060000000) {
      return 3060000000;
    } else if (creditSent <= 3120000000) {
      return 3120000000;
    } else if (creditSent <= 3220000000) {
      return 3220000000;
    } else if (creditSent <= 3220000000) {
      return 3220000000;
    } else if (creditSent <= 3360000000) {
      return 3360000000;
    } else if (creditSent <= 3560000000) {
      return 3560000000;
    } else if (creditSent <= 3800000000) {
      return 3800000000;
    } else if (creditSent <= 4100000000) {
      return 4100000000;
    } else if (creditSent <= 4440000000) {
      return 4440000000;
    } else if (creditSent <= 5000000000) {
      return 5000000000;
    } else if (creditSent <= 5050000000) {
      return 5050000000;
    } else if (creditSent <= 5150000000) {
      return 5150000000;
    } else if (creditSent <= 5300000000) {
      return 5300000000;
    } else if (creditSent <= 5550000000) {
      return 5550000000;
    } else if (creditSent <= 5900000000) {
      return 5900000000;
    } else if (creditSent <= 6400000000) {
      return 6400000000;
    } else if (creditSent <= 7000000000) {
      return 7000000000;
    } else if (creditSent <= 7750000000) {
      return 7750000000;
    } else if (creditSent <= 7750000000) {
      return 7750000000;
    } else if (creditSent <= 8600000000) {
      return 8600000000;
    } else if (creditSent <= 10000000000) {
      return 10000000000;
    } else if (creditSent <= 10100000000) {
      return 10100000000;
    } else if (creditSent <= 10300000000) {
      return 10300000000;
    } else if (creditSent <= 10600000000) {
      return 10600000000;
    } else if (creditSent <= 11100000000) {
      return 11100000000;
    } else if (creditSent <= 11800000000) {
      return 11800000000;
    } else if (creditSent <= 12800000000) {
      return 12800000000;
    } else if (creditSent <= 14000000000) {
      return 14000000000;
    } else if (creditSent <= 15500000000) {
      return 15500000000;
    } else if (creditSent <= 17200000000) {
      return 17200000000;
    } else if (creditSent <= 20600000000) {
      return 20600000000;
    } else if (creditSent <= 20710000000) {
      return 20710000000;
    } else if (creditSent <= 20930000000) {
      return 20930000000;
    } else if (creditSent <= 21260000000) {
      return 21260000000;
    } else if (creditSent <= 21810000000) {
      return 21810000000;
    } else if (creditSent <= 22580000000) {
      return 22580000000;
    } else if (creditSent <= 23680000000) {
      return 23680000000;
    } else if (creditSent <= 25000000000) {
      return 25000000000;
    } else if (creditSent <= 26650000000) {
      return 26650000000;
    } else if (creditSent <= 28520000000) {
      return 28520000000;
    } else if (creditSent <= 30200000000) {
      return 30200000000;
    } else if (creditSent <= 30320000000) {
      return 30320000000;
    } else if (creditSent <= 30560000000) {
      return 30560000000;
    } else if (creditSent <= 30920000000) {
      return 30920000000;
    } else if (creditSent <= 31520000000) {
      return 31520000000;
    } else if (creditSent <= 32360000000) {
      return 32360000000;
    } else if (creditSent <= 33560000000) {
      return 33560000000;
    } else if (creditSent <= 35000000000) {
      return 35000000000;
    } else if (creditSent <= 36800000000) {
      return 36800000000;
    } else if (creditSent <= 38840000000) {
      return 38840000000;
    } else if (creditSent <= 40688000000) {
      return 40688000000;
    } else if (creditSent <= 40820000000) {
      return 40820000000;
    } else if (creditSent <= 41084000000) {
      return 41084000000;
    } else if (creditSent <= 41480000000) {
      return 41480000000;
    } else if (creditSent <= 42140000000) {
      return 42140000000;
    } else if (creditSent <= 43064000000) {
      return 43064000000;
    } else if (creditSent <= 44384000000) {
      return 44384000000;
    } else if (creditSent <= 45968000000) {
      return 45968000000;
    } else if (creditSent <= 47948000000) {
      return 47948000000;
    } else if (creditSent <= 50192000000) {
      return 50192000000;
    } else if (creditSent <= 52208000000) {
      return 52208000000;
    } else if (creditSent <= 52352000000) {
      return 52352000000;
    } else if (creditSent <= 52640000000) {
      return 52640000000;
    } else if (creditSent <= 53072000000) {
      return 53072000000;
    } else if (creditSent <= 53792000000) {
      return 53792000000;
    } else if (creditSent <= 54800000000) {
      return 54800000000;
    } else if (creditSent <= 56240000000) {
      return 56240000000;
    } else if (creditSent <= 57968000000) {
      return 57968000000;
    } else if (creditSent <= 60128000000) {
      return 60128000000;
    } else if (creditSent <= 62576000000) {
      return 62576000000;
    } else if (creditSent <= 64793000000) {
      return 64793000000;
    } else if (creditSent <= 64952000000) {
      return 64952000000;
    } else if (creditSent <= 65268800000) {
      return 65268800000;
    } else if (creditSent <= 65744000000) {
      return 65744000000;
    } else if (creditSent <= 66536000000) {
      return 66536000000;
    } else if (creditSent <= 67644000000) {
      return 67644000000;
    } else if (creditSent <= 69228800000) {
      return 69228800000;
    } else if (creditSent <= 71129600000) {
      return 71129600000;
    } else if (creditSent <= 73505600000) {
      return 73505600000;
    } else if (creditSent <= 76198400000) {
      return 76198400000;
    } else if (creditSent <= 78617600000) {
      return 78617600000;
    } else if (creditSent <= 78790400000) {
      return 78790400000;
    } else if (creditSent <= 79136000000) {
      return 79136000000;
    } else if (creditSent <= 79654400000) {
      return 79654400000;
    } else if (creditSent <= 80518400000) {
      return 80518400000;
    } else if (creditSent <= 81728000000) {
      return 81728000000;
    } else if (creditSent <= 83456000000) {
      return 83456000000;
    } else if (creditSent <= 85529600000) {
      return 85529600000;
    } else if (creditSent <= 88121600000) {
      return 88121600000;
    } else if (creditSent <= 91059200000) {
      return 91059200000;
    } else if (creditSent <= 93720320000) {
      return 93720320000;
    } else if (creditSent <= 93910400000) {
      return 93910400000;
    } else if (creditSent <= 94290560000) {
      return 94290560000;
    } else if (creditSent <= 94860800000) {
      return 94860800000;
    } else if (creditSent <= 95811200000) {
      return 95811200000;
    } else if (creditSent <= 97141760000) {
      return 97141760000;
    } else if (creditSent <= 99042560000) {
      return 99042560000;
    } else if (creditSent <= 101324000000) {
      return 101324000000;
    } else if (creditSent <= 104174720000) {
      return 104174720000;
    } else if (creditSent <= 107406080000) {
      return 107406080000;
    } else if (creditSent <= 110309120000) {
      return 110309120000;
    } else if (creditSent <= 110516480000) {
      return 110516480000;
    } else if (creditSent <= 110931200000) {
      return 110931200000;
    } else if (creditSent <= 111553280000) {
      return 111553280000;
    } else if (creditSent <= 112590080000) {
      return 112590080000;
    } else if (creditSent <= 114041600000) {
      return 114041600000;
    } else if (creditSent <= 116115200000) {
      return 116115200000;
    } else if (creditSent <= 118603520000) {
      return 118603520000;
    } else if (creditSent <= 121713920000) {
      return 121713920000;
    } else if (creditSent <= 125239040000) {
      return 125239040000;
    } else if (creditSent <= 128432384000) {
      return 128432384000;
    } else if (creditSent <= 128660480000) {
      return 128660480000;
    } else if (creditSent <= 129116672000) {
      return 129116672000;
    } else if (creditSent <= 129800960000) {
      return 129800960000;
    } else if (creditSent <= 130941440000) {
      return 130941440000;
    } else if (creditSent <= 132538112000) {
      return 132538112000;
    } else if (creditSent <= 134819072000) {
      return 134819072000;
    } else if (creditSent <= 137556224000) {
      return 137556224000;
    } else if (creditSent <= 140977664000) {
      return 140977664000;
    } else if (creditSent <= 144855296000) {
      return 144855296000;
    } else if (creditSent <= 148587776000) {
      return 148587776000;
    } else if (creditSent <= 149085440000) {
      return 149085440000;
    } else if (creditSent <= 149831936000) {
      return 149831936000;
    } else if (creditSent <= 151076096000) {
      return 151076096000;
    } else if (creditSent <= 152817920000) {
      return 152817920000;
    } else if (creditSent <= 155306240000) {
      return 155306240000;
  } else if (creditSent <= 158292224000) {
    return 158292224000;
    } else if (creditSent <= 162024704000) {
    return 162024704000;
    } else if (creditSent <= 166254848000) {
    return 166254848000;
    } else if (creditSent <= 170086860800) {
    return 170086860800;
    } else if (creditSent <= 185286860800) {
    return 185286860800;
    } else {
    return 3000;
    }
  }

  static String wealthLevel({required int creditSent}) {
    if(creditSent == 0){
      return "assets/images/caifu_level_1.png";
    }else if (creditSent <= 3000) {
      return "assets/images/caifu_level_2.png";
    } else if (creditSent <= 6000) {
      return "assets/images/caifu_level_3.png";
    } else if (creditSent <= 16000) {
      return "assets/images/caifu_level_4.png";
    } else if (creditSent <= 66000) {
      return "assets/images/caifu_level_5.png";
    } else if (creditSent <= 166000) {
      return "assets/images/caifu_level_6.png";
    } else if (creditSent <= 330000) {
      return "assets/images/caifu_level_7.png";
    } else if (creditSent <= 500000) {
      return "assets/images/caifu_level_8.png";
    } else if (creditSent <= 700000) {
      return "assets/images/caifu_level_9.png";
    } else if (creditSent <= 1000000) {
      return "assets/images/caifu_level_10.png";
    } else if (creditSent <= 1100000) {
      return "assets/images/caifu_level_11.png";
    } else if (creditSent <= 1300000) {
      return "assets/images/caifu_level_12.png";
    } else if (creditSent <= 1600000) {
      return "assets/images/caifu_level_13.png";
    } else if (creditSent <= 2000000) {
      return "assets/images/caifu_level_14.png";
    } else if (creditSent <= 2600000) {
      return "assets/images/caifu_level_15.png";
    } else if (creditSent <= 3400000) {
      return "assets/images/caifu_level_16.png";
    } else if (creditSent <= 4400000) {
      return "assets/images/caifu_level_17.png";
    } else if (creditSent <= 5600000) {
      return "assets/images/caifu_level_18.png";
    } else if (creditSent <= 7000000) {
      return "assets/images/caifu_level_19.png";
    } else if (creditSent <= 10000000) {
      return "assets/images/caifu_level_20.png";
    } else if (creditSent <= 10500000) {
      return "assets/images/caifu_level_21.png";
    } else if (creditSent <= 11500000) {
      return "assets/images/caifu_level_22.png";
    } else if (creditSent <= 13000000) {
      return "assets/images/caifu_level_23.png";
    } else if (creditSent <= 15000000) {
      return "assets/images/caifu_level_24.png";
    } else if (creditSent <= 18000000) {
      return "assets/images/caifu_level_25.png";
    } else if (creditSent <= 22000000) {
      return "assets/images/caifu_level_26.png";
    } else if (creditSent <= 27000000) {
      return "assets/images/caifu_level_27.png";
    } else if (creditSent <= 33000000) {
      return "assets/images/caifu_level_28.png";
    } else if (creditSent <= 40000000) {
      return "assets/images/caifu_level_29.png";
    } else if (creditSent <= 50000000) {
      return "assets/images/caifu_level_30.png";
    } else if (creditSent <= 52000000) {
      return "assets/images/caifu_level_31.png";
    } else if (creditSent <= 55000000) {
      return "assets/images/caifu_level_32.png";
    } else if (creditSent <= 60000000) {
      return "assets/images/caifu_level_33.png";
    } else if (creditSent <= 68000000) {
      return "assets/images/caifu_level_34.png";
    } else if (creditSent <= 79000000) {
      return "assets/images/caifu_level_35.png";
    } else if (creditSent <= 95000000) {
      return "assets/images/caifu_level_36.png";
    } else if (creditSent <= 114000000) {
      return "assets/images/caifu_level_37.png";
    } else if (creditSent <= 137000000) {
      return "assets/images/caifu_level_38.png";
    } else if (creditSent <= 163000000) {
      return "assets/images/caifu_level_39.png";
    } else if (creditSent <= 200000000) {
      return "assets/images/caifu_level_40.png";
    } else if (creditSent <= 204000000) {
      return "assets/images/caifu_level_41.png";
    } else if (creditSent <= 210000000) {
      return "assets/images/caifu_level_42.png";
    } else if (creditSent <= 220000000) {
      return "assets/images/caifu_level_43.png";
    } else if (creditSent <= 236000000) {
      return "assets/images/caifu_level_44.png";
    } else if (creditSent <= 258000000) {
      return "assets/images/caifu_level_45.png";
    } else if (creditSent <= 290000000) {
      return "assets/images/caifu_level_46.png";
    } else if (creditSent <= 328000000) {
      return "assets/images/caifu_level_47.png";
    } else if (creditSent <= 375000000) {
      return "assets/images/caifu_level_48.png";
    } else if (creditSent <= 428000000) {
      return "assets/images/caifu_level_49.png";
    } else if (creditSent <= 500000000) {
      return "assets/images/caifu_level_50.png";
    } else if (creditSent <= 506000000) {
      return "assets/images/caifu_level_51.png";
    } else if (creditSent <= 516000000) {
      return "assets/images/caifu_level_52.png";
    } else if (creditSent <= 535000000) {
      return "assets/images/caifu_level_53.png";
    } else if (creditSent <= 560000000) {
      return "assets/images/caifu_level_54.png";
    } else if (creditSent <= 598000000) {
      return "assets/images/caifu_level_55.png";
    } else if (creditSent <= 648000000) {
      return "assets/images/caifu_level_56.png";
    } else if (creditSent <= 710000000) {
      return "assets/images/caifu_level_57.png";
    } else if (creditSent <= 785000000) {
      return "assets/images/caifu_level_58.png";
    } else if (creditSent <= 870000000) {
      return "assets/images/caifu_level_59.png";
    } else if (creditSent <= 1000000000) {
      return "assets/images/caifu_level_60.png";
    } else if (creditSent <= 1020000000) {
      return "assets/images/caifu_level_61.png";
    } else if (creditSent <= 1060000000) {
      return "assets/images/caifu_level_62.png";
    } else if (creditSent <= 1120000000) {
      return "assets/images/caifu_level_63.png";
    } else if (creditSent <= 1220000000) {
      return "assets/images/caifu_level_64.png";
    } else if (creditSent <= 1360000000) {
      return "assets/images/caifu_level_65.png";
    } else if (creditSent <= 1560000000) {
      return "assets/images/caifu_level_66.png";
    } else if (creditSent <= 1800000000) {
      return "assets/images/caifu_level_67.png";
    } else if (creditSent <= 2100000000) {
      return "assets/images/caifu_level_68.png";
    } else if (creditSent <= 2440000000) {
      return "assets/images/caifu_level_69.png";
    } else if (creditSent <= 3000000000) {
      return "assets/images/caifu_level_70.png";
    } else if (creditSent <= 3020000000) {
      return "assets/images/caifu_level_71.png";
    } else if (creditSent <= 3060000000) {
      return "assets/images/caifu_level_72.png";
    } else if (creditSent <= 3120000000) {
      return "assets/images/caifu_level_73.png";
    } else if (creditSent <= 3220000000) {
      return "assets/images/caifu_level_74.png";
    } else if (creditSent <= 3360000000) {
      return "assets/images/caifu_level_75.png";
    } else if (creditSent <= 3560000000) {
      return "assets/images/caifu_level_76.png";
    } else if (creditSent <= 3800000000) {
      return "assets/images/caifu_level_77.png";
    } else if (creditSent <= 4100000000) {
      return "assets/images/caifu_level_78.png";
    } else if (creditSent <= 4440000000) {
      return "assets/images/caifu_level_79.png";
    } else if (creditSent <= 5000000000) {
      return "assets/images/caifu_level_80.png";
    } else if (creditSent <= 5050000000) {
      return "assets/images/caifu_level_81.png";
    } else if (creditSent <= 5150000000) {
      return "assets/images/caifu_level_82.png";
    } else if (creditSent <= 5300000000) {
      return "assets/images/caifu_level_83.png";
    } else if (creditSent <= 5550000000) {
      return "assets/images/caifu_level_84.png";
    } else if (creditSent <= 5900000000) {
      return "assets/images/caifu_level_85.png";
    } else if (creditSent <= 6400000000) {
      return "assets/images/caifu_level_86.png";
    } else if (creditSent <= 7000000000) {
      return "assets/images/caifu_level_87.png";
    } else if (creditSent <= 7750000000) {
      return "assets/images/caifu_level_88.png";
    } else if (creditSent <= 8600000000) {
      return "assets/images/caifu_level_89.png";
    } else if (creditSent <= 10000000000) {
      return "assets/images/caifu_level_90.png";
    } else if (creditSent <= 10100000000) {
      return "assets/images/caifu_level_91.png";
    } else if (creditSent <= 10300000000) {
      return "assets/images/caifu_level_92.png";
    } else if (creditSent <= 10600000000) {
      return "assets/images/caifu_level_93.png";
    } else if (creditSent <= 11100000000) {
      return "assets/images/caifu_level_94.png";
    } else if (creditSent <= 11800000000) {
      return "assets/images/caifu_level_95.png";
    } else if (creditSent <= 12800000000) {
      return "assets/images/caifu_level_96.png";
    } else if (creditSent <= 14000000000) {
      return "assets/images/caifu_level_97.png";
    } else if (creditSent <= 15500000000) {
      return "assets/images/caifu_level_98.png";
    } else if (creditSent <= 17200000000) {
      return "assets/images/caifu_level_99.png";
    } else if (creditSent <= 20600000000) {
      return "assets/images/caifu_level_100.png";
    } else if (creditSent <= 20710000000) {
      return "assets/images/caifu_level_101.png";
    } else if (creditSent <= 20930000000) {
      return "assets/images/caifu_level_102.png";
    } else if (creditSent <= 21260000000) {
      return "assets/images/caifu_level_103.png";
    } else if (creditSent <= 21810000000) {
      return "assets/images/caifu_level_104.png";
    } else if (creditSent <= 22580000000) {
      return "assets/images/caifu_level_105.png";
    } else if (creditSent <= 23680000000) {
      return "assets/images/caifu_level_106.png";
    } else if (creditSent <= 25000000000) {
      return "assets/images/caifu_level_107.png";
    } else if (creditSent <= 26650000000) {
      return "assets/images/caifu_level_108.png";
    } else if (creditSent <= 28520000000) {
      return "assets/images/caifu_level_109.png";
    } else if (creditSent <= 30200000000) {
      return "assets/images/caifu_level_110.png";
    } else if (creditSent <= 30320000000) {
      return "assets/images/caifu_level_111.png";
    } else if (creditSent <= 30560000000) {
      return "assets/images/caifu_level_112.png";
    } else if (creditSent <= 30920000000) {
      return "assets/images/caifu_level_113.png";
    } else if (creditSent <= 31520000000) {
      return "assets/images/caifu_level_114.png";
    } else if (creditSent <= 32360000000) {
      return "assets/images/caifu_level_115.png";
    } else if (creditSent <= 33560000000) {
      return "assets/images/caifu_level_116.png";
    } else if (creditSent <= 35000000000) {
      return "assets/images/caifu_level_117.png";
    } else if (creditSent <= 36800000000) {
      return "assets/images/caifu_level_118.png";
    } else if (creditSent <= 38840000000) {
      return "assets/images/caifu_level_119.png";
    } else if (creditSent <= 40688000000) {
      return "assets/images/caifu_level_120.png";
    } else if (creditSent <= 40820000000) {
      return "assets/images/caifu_level_121.png";
    } else if (creditSent <= 41084000000) {
      return "assets/images/caifu_level_122.png";
    } else if (creditSent <= 41480000000) {
      return "assets/images/caifu_level_123.png";
    } else if (creditSent <= 42140000000) {
      return "assets/images/caifu_level_124.png";
    } else if (creditSent <= 43064000000) {
      return "assets/images/caifu_level_125.png";
    } else if (creditSent <= 44384000000) {
      return "assets/images/caifu_level_126.png";
    } else if (creditSent <= 45968000000) {
      return "assets/images/caifu_level_127.png";
    } else if (creditSent <= 47948000000) {
      return "assets/images/caifu_level_128.png";
    } else if (creditSent <= 50192000000) {
      return "assets/images/caifu_level_129.png";
    } else if (creditSent <= 52208000000) {
      return "assets/images/caifu_level_130.png";
    } else if (creditSent <= 52352000000) {
      return "assets/images/caifu_level_131.png";
    } else if (creditSent <= 52640000000) {
      return "assets/images/caifu_level_132.png";
    } else if (creditSent <= 53072000000) {
      return "assets/images/caifu_level_133.png";
    } else if (creditSent <= 53792000000) {
      return "assets/images/caifu_level_134.png";
    } else if (creditSent <= 54800000000) {
      return "assets/images/caifu_level_135.png";
    } else if (creditSent <= 56240000000) {
      return "assets/images/caifu_level_136.png";
    } else if (creditSent <= 57968000000) {
      return "assets/images/caifu_level_137.png";
    } else if (creditSent <= 60128000000) {
      return "assets/images/caifu_level_138.png";
    } else if (creditSent <= 62576000000) {
      return "assets/images/caifu_level_139.png";
    } else if (creditSent <= 64793000000) {
      return "assets/images/caifu_level_140.png";
    } else if (creditSent <= 64952000000) {
      return "assets/images/caifu_level_141.png";
    } else if (creditSent <= 65268800000) {
      return "assets/images/caifu_level_142.png";
    } else if (creditSent <= 65744000000) {
      return "assets/images/caifu_level_143.png";
    } else if (creditSent <= 66536000000) {
      return "assets/images/caifu_level_144.png";
    } else if (creditSent <= 67644000000) {
      return "assets/images/caifu_level_145.png";
    } else if (creditSent <= 69228800000) {
      return "assets/images/caifu_level_146.png";
    } else if (creditSent <= 71129600000) {
      return "assets/images/caifu_level_147.png";
    } else if (creditSent <= 73505600000) {
      return "assets/images/caifu_level_148.png";
    } else if (creditSent <= 76198400000) {
      return "assets/images/caifu_level_149.png";
    } else if (creditSent <= 78617600000) {
      return "assets/images/caifu_level_150.png";
    } else if (creditSent <= 78790400000) {
      return "assets/images/caifu_level_151.png";
    } else if (creditSent <= 79136000000) {
      return "assets/images/caifu_level_152.png";
    } else if (creditSent <= 79654400000) {
      return "assets/images/caifu_level_153.png";
    } else if (creditSent <= 80518400000) {
      return "assets/images/caifu_level_154.png";
    } else if (creditSent <= 81728000000) {
      return "assets/images/caifu_level_155.png";
    } else if (creditSent <= 83456000000) {
      return "assets/images/caifu_level_156.png";
    } else if (creditSent <= 85529600000) {
      return "assets/images/caifu_level_157.png";
    } else if (creditSent <= 88121600000) {
      return "assets/images/caifu_level_158.png";
    } else if (creditSent <= 91059200000) {
      return "assets/images/caifu_level_159.png";
    } else if (creditSent <= 93720320000) {
      return "assets/images/caifu_level_160.png";
    } else if (creditSent <= 93910400000) {
      return "assets/images/caifu_level_161.png";
    } else if (creditSent <= 94290560000) {
      return "assets/images/caifu_level_162.png";
    } else if (creditSent <= 94860800000) {
      return "assets/images/caifu_level_163.png";
    } else if (creditSent <= 95811200000) {
      return "assets/images/caifu_level_164.png";
    } else if (creditSent <= 97141760000) {
      return "assets/images/caifu_level_165.png";
    } else if (creditSent <= 99042560000) {
      return "assets/images/caifu_level_166.png";
    } else if (creditSent <= 101324000000) {
      return "assets/images/caifu_level_167.png";
    } else if (creditSent <= 104174720000) {
      return "assets/images/caifu_level_168.png";
    } else if (creditSent <= 107406080000) {
      return "assets/images/caifu_level_169.png";
    } else if (creditSent <= 110309120000) {
      return "assets/images/caifu_level_170.png";
    } else if (creditSent <= 110516480000) {
      return "assets/images/caifu_level_171.png";
    } else if (creditSent <= 110931200000) {
      return "assets/images/caifu_level_172.png";
    } else if (creditSent <= 111553280000) {
      return "assets/images/caifu_level_173.png";
    } else if (creditSent <= 112590080000) {
      return "assets/images/caifu_level_174.png";
    } else if (creditSent <= 114041600000) {
      return "assets/images/caifu_level_175.png";
    } else if (creditSent <= 116115200000) {
      return "assets/images/caifu_level_176.png";
    } else if (creditSent <= 118603520000) {
      return "assets/images/caifu_level_177.png";
    } else if (creditSent <= 121713920000) {
      return "assets/images/caifu_level_178.png";
    } else if (creditSent <= 125239040000) {
      return "assets/images/caifu_level_179.png";
    } else if (creditSent <= 128432384000) {
      return "assets/images/caifu_level_180.png";
    } else if (creditSent <= 128660480000) {
      return "assets/images/caifu_level_181.png";
    } else if (creditSent <= 129116672000) {
      return "assets/images/caifu_level_182.png";
    } else if (creditSent <= 129800960000) {
      return "assets/images/caifu_level_183.png";
    } else if (creditSent <= 130941440000) {
      return "assets/images/caifu_level_184.png";
    } else if (creditSent <= 132538112000) {
      return "assets/images/caifu_level_185.png";
    } else if (creditSent <= 134819072000) {
      return "assets/images/caifu_level_186.png";
    } else if (creditSent <= 137556224000) {
      return "assets/images/caifu_level_187.png";
    } else if (creditSent <= 140977664000) {
      return "assets/images/caifu_level_188.png";
    } else if (creditSent <= 144855296000) {
      return "assets/images/caifu_level_189.png";
    } else if (creditSent <= 148587776000) {
      return "assets/images/caifu_level_190.png";
    } else if (creditSent <= 149085440000) {
      return "assets/images/caifu_level_191.png";
    } else if (creditSent <= 149831936000) {
      return "assets/images/caifu_level_192.png";
    } else if (creditSent <= 151076096000) {
      return "assets/images/caifu_level_193.png";
    } else if (creditSent <= 152817920000) {
      return "assets/images/caifu_level_194.png";
    } else if (creditSent <= 155306240000) {
      return "assets/images/caifu_level_195.png";
  } else if (creditSent <= 158292224000) {
    return "assets/images/caifu_level_196.png";
    } else if (creditSent <= 162024704000) {
    return "assets/images/caifu_level_197.png";
    } else if (creditSent <= 166254848000) {
    return "assets/images/caifu_level_198.png";
    } else if (creditSent <= 170086860800) {
    return "assets/images/caifu_level_199.png";
    } else if (creditSent <= 189986860800) {
    return "assets/images/caifu_level_200.png";
    } else {
    return "assets/images/caifu_level_1.png";
    }
  }

  static String receivedGiftsLevelIcon({required int receivedGift}) {
    if (receivedGift == 0) {
      return "assets/images/zhibo_level_0.png";
    } else if (receivedGift <= 10000) {
      return "assets/images/zhibo_level_1.png";
    } else if (receivedGift <= 70000) {
      return "assets/images/zhibo_level_2.png";
    } else if (receivedGift <= 250000) {
      return "assets/images/zhibo_level_3.png";
    } else if (receivedGift <= 630000) {
      return "assets/images/zhibo_level_4.png";
    } else if (receivedGift <= 1410000) {
      return "assets/images/zhibo_level_5.png";
    } else if (receivedGift <= 3010000) {
      return "assets/images/zhibo_level_6.png";
    } else if (receivedGift <= 5710000) {
      return "assets/images/zhibo_level_7.png";
    } else if (receivedGift <= 10310000) {
      return "assets/images/zhibo_level_8.png";
    } else if (receivedGift <= 18110000) {
      return "assets/images/zhibo_level_9.png";
    } else if (receivedGift <= 31010000) {
      return "assets/images/zhibo_level_10.png";
    } else if (receivedGift <= 52010000) {
      return "assets/images/zhibo_level_11.png";
    } else if (receivedGift <= 85010000) {
      return "assets/images/zhibo_level_12.png";
    } else if (receivedGift <= 137010000) {
      return "assets/images/zhibo_level_13.png";
    } else if (receivedGift <= 214010000) {
      return "assets/images/zhibo_level_14.png";
    } else if (receivedGift <= 323010000) {
      return "assets/images/zhibo_level_15.png";
    } else if (receivedGift <= 492010000) {
      return "assets/images/zhibo_level_16.png";
    } else if (receivedGift <= 741010000) {
      return "assets/images/zhibo_level_17.png";
    } else if (receivedGift <= 11000100000) {
      return "assets/images/zhibo_level_18.png";
    } else if (receivedGift <= 16890100000) {
      return "assets/images/zhibo_level_19.png";
    } else if (receivedGift <= 25280100000) {
      return "assets/images/zhibo_level_20.png";
    } else if (receivedGift <= 36370100000) {
      return "assets/images/zhibo_level_21.png";
    } else if (receivedGift <= 51370100000) {
      return "assets/images/zhibo_level_22.png";
    } else if (receivedGift <= 73370100000) {
      return "assets/images/zhibo_level_23.png";
    } else if (receivedGift <= 10137010000) {
      return "assets/images/zhibo_level_24.png";
    } else if (receivedGift <= 141370100000) {
      return "assets/images/zhibo_level_25.png";
    } else if (receivedGift <= 191370100000) {
      return "assets/images/zhibo_level_26.png";
    } else if (receivedGift <= 300000000000) {
      return "assets/images/zhibo_level_27.png";
    } else if (receivedGift <= 450000000000) {
      return "assets/images/zhibo_level_28.png";
    } else if (receivedGift <= 600000000000) {
      return "assets/images/zhibo_level_29.png";
    } else if (receivedGift <= 800000000000) {
      return "assets/images/zhibo_level_30.png";
    } else if (receivedGift <= 100000000000) {
      return "assets/images/zhibo_level_31.png";
    } else if (receivedGift <= 130000000000) {
      return "assets/images/zhibo_level_32.png";
    } else if (receivedGift <= 160000000000) {
      return "assets/images/zhibo_level_33.png";
    } else if (receivedGift <= 2000000000000) {
      return "assets/images/zhibo_level_34.png";
    } else {
      return "assets/images/zhibo_level_0.png";
    }
  }

  static int receivedGiftsValue({required int receivedGift}) {
    if (receivedGift == 0) {
      return 0;
    } else if (receivedGift <= 10000) {
      return 10000;
    } else if (receivedGift <= 70000) {
      return 70000;
    } else if (receivedGift <= 250000) {
      return 250000;
    } else if (receivedGift <= 630000) {
      return 630000;
    } else if (receivedGift <= 1410000) {
      return 1410000;
    } else if (receivedGift <= 3010000) {
      return 3010000;
    } else if (receivedGift <= 5710000) {
      return 5710000;
    } else if (receivedGift <= 10310000) {
      return 10310000;
    } else if (receivedGift <= 18110000) {
      return 18110000;
    } else if (receivedGift <= 31010000) {
      return 31010000;
    } else if (receivedGift <= 52010000) {
      return 52010000;
    } else if (receivedGift <= 85010000) {
      return 85010000;
    } else if (receivedGift <= 137010000) {
      return 137010000;
    } else if (receivedGift <= 214010000) {
      return 214010000;
    } else if (receivedGift <= 323010000) {
      return 323010000;
    } else if (receivedGift <= 492010000) {
      return 492010000;
    } else if (receivedGift <= 741010000) {
      return 741010000;
    } else if (receivedGift <= 11000100000) {
      return 11000100000;
    } else if (receivedGift <= 16890100000) {
      return 16890100000;
    } else if (receivedGift <= 25280100000) {
      return 2528010000;
    } else if (receivedGift <= 36370100000) {
      return 36370100000;
    } else if (receivedGift <= 51370100000) {
      return 51370100000;
    } else if (receivedGift <= 73370100000) {
      return 73370100000;
    } else if (receivedGift <= 10137010000) {
      return 10137010000;
    } else if (receivedGift <= 141370100000) {
      return 141370100000;
    } else if (receivedGift <= 191370100000) {
      return 191370100000;
    } else if (receivedGift <= 300000000000) {
      return 30000000000;
    } else if (receivedGift <= 450000000000) {
      return 45000000000;
    } else if (receivedGift <= 600000000000) {
      return 60000000000;
    } else if (receivedGift <= 800000000000) {
      return 80000000000;
    } else if (receivedGift <= 100000000000) {
      return 100000000000;
    } else if (receivedGift <= 130000000000) {
      return 130000000000;
    } else if (receivedGift <= 160000000000) {
      return 160000000000;
    } else if (receivedGift <= 2000000000000) {
      return 2000000000000;
    } else {
      return 0;
    }
  }

  static int receivedGiftsLevelNumber({required int receivedGift}) {
    if (receivedGift == 0) {
      return 0;
    } else if (receivedGift <= 10000) {
      return 1;
    } else if (receivedGift <= 70000) {
      return 2;
    } else if (receivedGift <= 250000) {
      return 3;
    } else if (receivedGift <= 630000) {
      return 4;
    } else if (receivedGift <= 1410000) {
      return 5;
    } else if (receivedGift <= 3010000) {
      return 6;
    } else if (receivedGift <= 5710000) {
      return 7;
    } else if (receivedGift <= 10310000) {
      return 8;
    } else if (receivedGift <= 18110000) {
      return 9;
    } else if (receivedGift <= 31010000) {
      return 10;
    } else if (receivedGift <= 52010000) {
      return 11;
    } else if (receivedGift <= 85010000) {
      return 12;
    } else if (receivedGift <= 137010000) {
      return 13;
    } else if (receivedGift <= 214010000) {
      return 14;
    } else if (receivedGift <= 323010000) {
      return 15;
    } else if (receivedGift <= 492010000) {
      return 16;
    } else if (receivedGift <= 741010000) {
      return 17;
    } else if (receivedGift <= 11000100000) {
      return 18;
    } else if (receivedGift <= 16890100000) {
      return 19;
    } else if (receivedGift <= 25280100000) {
      return 20;
    } else if (receivedGift <= 36370100000) {
      return 21;
    } else if (receivedGift <= 51370100000) {
      return 22;
    } else if (receivedGift <= 73370100000) {
      return 23;
    } else if (receivedGift <= 10137010000) {
      return 24;
    } else if (receivedGift <= 141370100000) {
      return 25;
    } else if (receivedGift <= 191370100000) {
      return 26;
    } else if (receivedGift <= 300000000000) {
      return 27;
    } else if (receivedGift <= 450000000000) {
      return 28;
    } else if (receivedGift <= 600000000000) {
      return 29;
    } else if (receivedGift <= 800000000000) {
      return 30;
    } else if (receivedGift <= 100000000000) {
      return 31;
    } else if (receivedGift <= 130000000000) {
      return 32;
    } else if (receivedGift <= 160000000000) {
      return 33;
    } else if (receivedGift <= 2000000000000) {
      return 34;
    } else {
      return 0;
    }
  }

  static int wealthLevelNumber({required int creditSent}) {
    if(creditSent == 0){
      return 0;
    }else if (creditSent < 3000) {
      return 1;
    } else if (creditSent <= 6000) {
      return 2;
    } else if (creditSent <= 16000) {
      return 3;
    } else if (creditSent <= 66000) {
      return 4;
    } else if (creditSent <= 166000) {
      return 5;
    } else if (creditSent <= 330000) {
      return 6;
    } else if (creditSent <= 500000) {
      return 7;
    } else if (creditSent <= 700000) {
      return 8;
    } else if (creditSent <= 1000000) {
      return 9;
    } else if (creditSent <= 1100000) {
      return 10;
    } else if (creditSent <= 1300000) {
      return 11;
    } else if (creditSent <= 1600000) {
      return 12;
    } else if (creditSent <= 2000000) {
      return 13;
    } else if (creditSent <= 2600000) {
      return 14;
    } else if (creditSent <= 3400000) {
      return 15;
    } else if (creditSent <= 4400000) {
      return 16;
    } else if (creditSent <= 5600000) {
      return 17;
    } else if (creditSent <= 7000000) {
      return 18;
    } else if (creditSent <= 10000000) {
      return 19;
    } else if (creditSent <= 10500000) {
      return 20;
    } else if (creditSent <= 11500000) {
      return 21;
    } else if (creditSent <= 13000000) {
      return 22;
    } else if (creditSent <= 15000000) {
      return 23;
    } else if (creditSent <= 18000000) {
      return 24;
    } else if (creditSent <= 22000000) {
      return 25;
    } else if (creditSent <= 27000000) {
      return 26;
    } else if (creditSent <= 33000000) {
      return 27;
    } else if (creditSent <= 40000000) {
      return 28;
    } else if (creditSent <= 50000000) {
      return 29;
    } else if (creditSent <= 52000000) {
      return 30;
    } else if (creditSent <= 55000000) {
      return 31;
    } else if (creditSent <= 60000000) {
      return 32;
    } else if (creditSent <= 68000000) {
      return 34;
    } else if (creditSent <= 79000000) {
      return 35;
    } else if (creditSent <= 95000000) {
      return 36;
    } else if (creditSent <= 114000000) {
      return 37;
    } else if (creditSent <= 137000000) {
      return 38;
    } else if (creditSent <= 163000000) {
      return 39;
    } else if (creditSent <= 200000000) {
      return 40;
    } else if (creditSent <= 204000000) {
      return 41;
    } else if (creditSent <= 210000000) {
      return 42;
    } else if (creditSent <= 220000000) {
      return 43;
    } else if (creditSent <= 236000000) {
      return 44;
    } else if (creditSent <= 258000000) {
      return 45;
    } else if (creditSent <= 290000000) {
      return 46;
    } else if (creditSent <= 328000000) {
      return 47;
    } else if (creditSent <= 375000000) {
      return 48;
    } else if (creditSent <= 428000000) {
      return 49;
    } else if (creditSent <= 500000000) {
      return 50;
    } else if (creditSent <= 506000000) {
      return 51;
    } else if (creditSent <= 516000000) {
      return 52;
    } else if (creditSent <= 535000000) {
      return 53;
    } else if (creditSent <= 560000000) {
      return 54;
    } else if (creditSent <= 598000000) {
      return 55;
    } else if (creditSent <= 648000000) {
      return 56;
    } else if (creditSent <= 710000000) {
      return 57;
    } else if (creditSent <= 785000000) {
      return 58;
    } else if (creditSent <= 870000000) {
      return 59;
    } else if (creditSent <= 1000000000) {
      return 60;
    } else if (creditSent <= 1020000000) {
      return 61;
    } else if (creditSent <= 1060000000) {
      return 62;
    } else if (creditSent <= 1120000000) {
      return 63;
    } else if (creditSent <= 1220000000) {
      return 64;
    } else if (creditSent <= 1360000000) {
      return 65;
    } else if (creditSent <= 1560000000) {
      return 66;
    } else if (creditSent <= 1800000000) {
      return 67;
    } else if (creditSent <= 2100000000) {
      return 68;
    } else if (creditSent <= 2440000000) {
      return 69;
    } else if (creditSent <= 3000000000) {
      return 70;
    } else if (creditSent <= 3020000000) {
      return 71;
    } else if (creditSent <= 3060000000) {
      return 72;
    } else if (creditSent <= 3120000000) {
      return 73;
    } else if (creditSent <= 3220000000) {
      return 74;
    } else if (creditSent <= 3220000000) {
      return 75;
    } else if (creditSent <= 3360000000) {
      return 76;
    } else if (creditSent <= 3560000000) {
      return 77;
    } else if (creditSent <= 3800000000) {
      return 78;
    } else if (creditSent <= 4100000000) {
      return 79;
    } else if (creditSent <= 4440000000) {
      return 80;
    } else if (creditSent <= 5000000000) {
      return 81;
    } else if (creditSent <= 5050000000) {
      return 82;
    } else if (creditSent <= 5150000000) {
      return 83;
    } else if (creditSent <= 5300000000) {
      return 84;
    } else if (creditSent <= 5550000000) {
      return 85;
    } else if (creditSent <= 5900000000) {
      return 86;
    } else if (creditSent <= 6400000000) {
      return 87;
    } else if (creditSent <= 7000000000) {
      return 88;
    } else if (creditSent <= 7750000000) {
      return 89;
    } else if (creditSent <= 7750000000) {
      return 90;
    } else if (creditSent <= 8600000000) {
      return 91;
    } else if (creditSent <= 10000000000) {
      return 92;
    } else if (creditSent <= 10100000000) {
      return 93;
    } else if (creditSent <= 10300000000) {
      return 94;
    } else if (creditSent <= 10600000000) {
      return 95;
    } else if (creditSent <= 11100000000) {
      return 97;
    } else if (creditSent <= 11800000000) {
      return 98;
    } else if (creditSent <= 12800000000) {
      return 99;
    } else if (creditSent <= 14000000000) {
      return 100;
    } else if (creditSent <= 15500000000) {
      return 101;
    } else if (creditSent <= 17200000000) {
      return 102;
    } else if (creditSent <= 20600000000) {
      return 103;
    } else if (creditSent <= 20710000000) {
      return 104;
    } else if (creditSent <= 20930000000) {
      return 105;
    } else if (creditSent <= 21260000000) {
      return 106;
    } else if (creditSent <= 21810000000) {
      return 107;
    } else if (creditSent <= 22580000000) {
      return 108;
    } else if (creditSent <= 23680000000) {
      return 109;
    } else if (creditSent <= 25000000000) {
      return 110;
    } else if (creditSent <= 26650000000) {
      return 111;
    } else if (creditSent <= 28520000000) {
      return 112;
    } else if (creditSent <= 30200000000) {
      return 113;
    } else if (creditSent <= 30320000000) {
      return 114;
    } else if (creditSent <= 30560000000) {
      return 115;
    } else if (creditSent <= 30920000000) {
      return 116;
    } else if (creditSent <= 31520000000) {
      return 117;
    } else if (creditSent <= 32360000000) {
      return 118;
    } else if (creditSent <= 33560000000) {
      return 119;
    } else if (creditSent <= 35000000000) {
      return 120;
    } else if (creditSent <= 36800000000) {
      return 121;
    } else if (creditSent <= 38840000000) {
      return 122;
    } else if (creditSent <= 40688000000) {
      return 123;
    } else if (creditSent <= 40820000000) {
      return 124;
    } else if (creditSent <= 41084000000) {
      return 125;
    } else if (creditSent <= 41480000000) {
      return 126;
    } else if (creditSent <= 42140000000) {
      return 127;
    } else if (creditSent <= 43064000000) {
      return 128;
    } else if (creditSent <= 44384000000) {
      return 129;
    } else if (creditSent <= 45968000000) {
      return 130;
    } else if (creditSent <= 47948000000) {
      return 131;
    } else if (creditSent <= 50192000000) {
      return 132;
    } else if (creditSent <= 52208000000) {
      return 133;
    } else if (creditSent <= 52352000000) {
      return 134;
    } else if (creditSent <= 52640000000) {
      return 135;
    } else if (creditSent <= 53072000000) {
      return 136;
    } else if (creditSent <= 53792000000) {
      return 137;
    } else if (creditSent <= 54800000000) {
      return 138;
    } else if (creditSent <= 56240000000) {
      return 139;
    } else if (creditSent <= 57968000000) {
      return 140;
    } else if (creditSent <= 60128000000) {
      return 141;
    } else if (creditSent <= 62576000000) {
      return 142;
    } else if (creditSent <= 64793000000) {
      return 143;
    } else if (creditSent <= 64952000000) {
      return 144;
    } else if (creditSent <= 65268800000) {
      return 145;
    } else if (creditSent <= 65744000000) {
      return 146;
    } else if (creditSent <= 66536000000) {
      return 147;
    } else if (creditSent <= 67644000000) {
      return 148;
    } else if (creditSent <= 69228800000) {
      return 149;
    } else if (creditSent <= 71129600000) {
      return 150;
    } else if (creditSent <= 73505600000) {
      return 151;
    } else if (creditSent <= 76198400000) {
      return 152;
    } else if (creditSent <= 78617600000) {
      return 153;
    } else if (creditSent <= 78790400000) {
      return 154;
    } else if (creditSent <= 79136000000) {
      return 155;
    } else if (creditSent <= 79654400000) {
      return 156;
    } else if (creditSent <= 80518400000) {
      return 157;
    } else if (creditSent <= 81728000000) {
      return 158;
    } else if (creditSent <= 83456000000) {
      return 159;
    } else if (creditSent <= 85529600000) {
      return 160;
    } else if (creditSent <= 88121600000) {
      return 161;
    } else if (creditSent <= 91059200000) {
      return 162;
    } else if (creditSent <= 93720320000) {
      return 163;
    } else if (creditSent <= 93910400000) {
      return 164;
    } else if (creditSent <= 94290560000) {
      return 165;
    } else if (creditSent <= 94860800000) {
      return 166;
    } else if (creditSent <= 95811200000) {
      return 167;
    } else if (creditSent <= 97141760000) {
      return 168;
    } else if (creditSent <= 99042560000) {
      return 169;
    } else if (creditSent <= 101324000000) {
      return 170;
    } else if (creditSent <= 104174720000) {
      return 171;
    } else if (creditSent <= 107406080000) {
      return 172;
    } else if (creditSent <= 110309120000) {
      return 173;
    } else if (creditSent <= 110516480000) {
      return 174;
    } else if (creditSent <= 110931200000) {
      return 175;
    } else if (creditSent <= 111553280000) {
      return 176;
    } else if (creditSent <= 112590080000) {
      return 177;
    } else if (creditSent <= 114041600000) {
      return 178;
    } else if (creditSent <= 116115200000) {
      return 179;
    } else if (creditSent <= 118603520000) {
      return 180;
    } else if (creditSent <= 121713920000) {
      return 181;
    } else if (creditSent <= 125239040000) {
      return 182;
    } else if (creditSent <= 128432384000) {
      return 183;
    } else if (creditSent <= 128660480000) {
      return 184;
    } else if (creditSent <= 129116672000) {
      return 185;
    } else if (creditSent <= 129800960000) {
      return 186;
    } else if (creditSent <= 130941440000) {
      return 187;
    } else if (creditSent <= 132538112000) {
      return 188;
    } else if (creditSent <= 134819072000) {
      return 189;
    } else if (creditSent <= 137556224000) {
      return 190;
    } else if (creditSent <= 140977664000) {
      return 191;
    } else if (creditSent <= 144855296000) {
      return 192;
    } else if (creditSent <= 148587776000) {
      return 193;
    } else if (creditSent <= 149085440000) {
      return 194;
    } else if (creditSent <= 149831936000) {
      return 195;
    } else if (creditSent <= 151076096000) {
      return 196;
    } else if (creditSent <= 152817920000) {
      return 197;
    } else if (creditSent <= 155306240000) {
      return 198;
  } else if (creditSent <= 158292224000) {
    return 199;
    } else if (creditSent <= 162024704000) {
    return 200;
    } else if (creditSent <= 166254848000) {
    return 201;
    } else if (creditSent <= 170086860800) {
    return 202;
    } else if (creditSent <= 185286860800) {
    return 203;
    } else {
    return 0;
    }
  }

  static List<String> getBusinessCooperationIssuesList() {
    List<String> list = [
      ReportModel.BUSINESS_AGENCY_APPLICATION,
      ReportModel.BUSINESS_AGENCY_HOST,
    ];

    return list;
  }

  static String getBusinessCooperationIssuesByCode(String code) {
    switch (code) {
      case ReportModel.BUSINESS_AGENCY_APPLICATION:
        return "business_cooperation_issue.agency_application".tr();

      case ReportModel.BUSINESS_AGENCY_HOST:
        return "business_cooperation_issue.agency_host".tr();

      default:
        return "";
    }
  }

  static List<String> getFeedbackIssuesList() {
    List<String> list = [
      ReportModel.FEEDBACK_ACCOUNT_SECURE,
      ReportModel.FEEDBACK_GAME,
      ReportModel.FEEDBACK_SOFTWARE_DEFECT,
      ReportModel.FEEDBACK_FEATURE_REQUEST,
      ReportModel.FEEDBACK_SPOT_ERROR_GET_COINS,
    ];

    return list;
  }

  static String getFeedbackIssuesByCode(String code) {
    switch (code) {
      case ReportModel.FEEDBACK_ACCOUNT_SECURE:
        return "feedbacks_issue.account_security".tr();

      case ReportModel.FEEDBACK_GAME:
        return "feedbacks_issue.game_".tr();

      case ReportModel.FEEDBACK_SOFTWARE_DEFECT:
        return "feedbacks_issue.software_defect".tr();

      case ReportModel.FEEDBACK_FEATURE_REQUEST:
        return "feedbacks_issue.feature_requests".tr();

      case ReportModel.FEEDBACK_SPOT_ERROR_GET_COINS:
        return "feedbacks_issue.spot_error_coins".tr();

      default:
        return "";
    }
  }

  static List<String> getReportComplaintsIssuesList() {
    List<String> list = [
      ReportModel.REPORT_COMPLAINT_REPORT,
      ReportModel.REPORT_LIVE_VIOLATION,
    ];

    return list;
  }

  static String getReportComplaintsIssuesByCode(String code) {
    switch (code) {
      case ReportModel.REPORT_COMPLAINT_REPORT:
        return "report_complaints_issue.complaint_".tr();

      case ReportModel.REPORT_LIVE_VIOLATION:
        return "report_complaints_issue.live_broadcast_violation".tr();

      default:
        return "";
    }
  }

  static String getAnyIssueDetailByCode(String code) {
    switch (code) {
      case ReportModel.BUSINESS_AGENCY_APPLICATION:
        return "business_cooperation_issue.agency_application".tr();

      case ReportModel.BUSINESS_AGENCY_HOST:
        return "business_cooperation_issue.agency_host".tr();

      case ReportModel.FEEDBACK_ACCOUNT_SECURE:
        return "feedbacks_issue.account_security".tr();

      case ReportModel.FEEDBACK_GAME:
        return "feedbacks_issue.game_".tr();

      case ReportModel.FEEDBACK_SOFTWARE_DEFECT:
        return "feedbacks_issue.software_defect".tr();

      case ReportModel.FEEDBACK_FEATURE_REQUEST:
        return "feedbacks_issue.feature_requests".tr();

      case ReportModel.FEEDBACK_SPOT_ERROR_GET_COINS:
        return "feedbacks_issue.spot_error_coins".tr();

      case ReportModel.REPORT_COMPLAINT_REPORT:
        return "report_complaints_issue.complaint_".tr();

      case ReportModel.REPORT_LIVE_VIOLATION:
        return "report_complaints_issue.live_broadcast_violation".tr();

      case ReportModel.CONSULT_HOST_REWARD:
        return "consult_issue.host_tasks_rewards".tr();

      case ReportModel.CONSULT_FAILURE_RECEIVING_COIN:
        return "consult_issue.failure_receiving_coins".tr();

      case ReportModel.CONSULT_FACE_AUTHENTICATION:
        return "consult_issue.face_authentication".tr();

      case ReportModel.CONSULT_CHANGE_GENDER:
        return "consult_issue.change_gender_country".tr();

      case ReportModel.CONSULT_APPEAL_ACCOUNT_SUSPENSION:
        return "consult_issue.appeal_account_suspension".tr();

      case ReportModel.CONSULT_INVITATION_REWARD:
        return "consult_issue.invitation_reward".tr();

      case ReportModel.CONSULT_OTHER:
        return "consult_issue.others_".tr();

      default:
        return "";
    }
  }

  static List<String> getConsultIssuesList() {
    List<String> list = [
      ReportModel.CONSULT_HOST_REWARD,
      ReportModel.CONSULT_FAILURE_RECEIVING_COIN,
      ReportModel.CONSULT_FACE_AUTHENTICATION,
      ReportModel.CONSULT_CHANGE_GENDER,
      ReportModel.CONSULT_APPEAL_ACCOUNT_SUSPENSION,
      ReportModel.CONSULT_INVITATION_REWARD,
      ReportModel.CONSULT_OTHER,
    ];

    return list;
  }

  static String getConsultIssuesByCode(String code) {
    switch (code) {
      case ReportModel.CONSULT_HOST_REWARD:
        return "consult_issue.host_tasks_rewards".tr();

      case ReportModel.CONSULT_FAILURE_RECEIVING_COIN:
        return "consult_issue.failure_receiving_coins".tr();

      case ReportModel.CONSULT_FACE_AUTHENTICATION:
        return "consult_issue.face_authentication".tr();

      case ReportModel.CONSULT_CHANGE_GENDER:
        return "consult_issue.change_gender_country".tr();

      case ReportModel.CONSULT_APPEAL_ACCOUNT_SUSPENSION:
        return "consult_issue.appeal_account_suspension".tr();

      case ReportModel.CONSULT_INVITATION_REWARD:
        return "consult_issue.invitation_reward".tr();

      case ReportModel.CONSULT_OTHER:
        return "consult_issue.others_".tr();

      default:
        return "";
    }
  }

  static List<String> getCategoryQuestionList() {
    List<String> list = [
      ReportModel.CATEGORY_CONSULT,
      ReportModel.CATEGORY_REPORT_COMPLAINT,
      ReportModel.CATEGORY_FEEDBACKS,
      ReportModel.CATEGORY_BUSINESS_COOPERATION,
    ];

    return list;
  }

  static String getCategoryQuestionByCode(String code) {
    switch (code) {
      case ReportModel.CATEGORY_CONSULT:
        return "category_question.consult_".tr();

      case ReportModel.CATEGORY_REPORT_COMPLAINT:
        return "category_question.report_complaints".tr();

      case ReportModel.CATEGORY_FEEDBACKS:
        return "category_question.feedbacks_".tr();

      case ReportModel.CATEGORY_BUSINESS_COOPERATION:
        return "category_question.business_cooperation".tr();

      default:
        return "";
    }
  }

  static List<String> getUserStatesList() {
    List<String> list = [
      UserModel.userOnline,
      UserModel.userOffline,
      UserModel.userParty,
      UserModel.userViewing,
      UserModel.userLiving,
    ];

    return list;
  }

  static String getUserStatesByCode(String code) {
    switch (code) {
      case UserModel.userOnline:
        return "user_state_in_app.online_".tr();

      case UserModel.userOffline:
        return "user_state_in_app.offline_".tr();

      case UserModel.userParty:
        return "user_state_in_app.party_".tr();

      case UserModel.userViewing:
        return "user_state_in_app.viewing_".tr();

      case UserModel.userLiving:
        return "user_state_in_app.living_".tr();

      default:
        return "";
    }
  }

  static String getUserStatesIcon(String code) {
    switch (code) {
      case UserModel.userOnline:
        return "assets/lotties/ic_online.json";

      case UserModel.userOffline:
        return "assets/lotties/ic_offline.json";

      case UserModel.userParty:
        return "assets/lotties/ic_live_animation.json";

      case UserModel.userViewing:
        return "assets/lotties/ic_viewer.json";

      case UserModel.userLiving:
        return "assets/lotties/ic_on_live.json";

      default:
        return "";
    }
  }

  static List<String> getReportCodeMessageList() {
    List<String> list = [
      ReportModel.THIS_POST_HAS_SEXUAL_CONTENTS,
      ReportModel.FAKE_PROFILE_SPAN,
      ReportModel.INAPPROPRIATE_MESSAGE,
      ReportModel.SOMEONE_IS_IN_DANGER,
    ];

    return list;
  }

  static String getReportMessage(String code) {
    switch (code) {
      case ReportModel.THIS_POST_HAS_SEXUAL_CONTENTS:
        return "message_report.report_without_interest".tr();

      case ReportModel.FAKE_PROFILE_SPAN:
        return "message_report.report_fake_profile".tr();

      case ReportModel.INAPPROPRIATE_MESSAGE:
        return "message_report.report_inappropriate_message".tr();

      case ReportModel.SOMEONE_IS_IN_DANGER:
        return "message_report.report_some_in_danger".tr();

      default:
        return "";
    }
  }

  static List<String> getLiveTagsList() {
    List<String> list = [
      LiveStreamingModel.liveSubAll,
      LiveStreamingModel.liveSubTalking,
      LiveStreamingModel.liveSubSinging,
      LiveStreamingModel.liveSubDancing,
      LiveStreamingModel.liveSubFriends,
      LiveStreamingModel.tagMusic,
      LiveStreamingModel.tagDancing,
      LiveStreamingModel.tagCosplay,
      LiveStreamingModel.tagTalkShow,
      LiveStreamingModel.tagModel,
      LiveStreamingModel.tagGossip,
      LiveStreamingModel.tagMakeup,
      LiveStreamingModel.tagMimicryShow,
      LiveStreamingModel.tagCharming,
      LiveStreamingModel.tagDJ,
      LiveStreamingModel.tagTarot,
      LiveStreamingModel.tagPoleDance,
      LiveStreamingModel.tagRadio,
      LiveStreamingModel.tagFitness,
    ];

    return list;
  }

  static String getLiveTagsByCode(String code) {
    switch (code) {
      case LiveStreamingModel.liveSubAll:
        return "coins_and_points_screen.all_".tr();

      case LiveStreamingModel.tagFitness:
        return "go_live_options.fitness".tr();

      case LiveStreamingModel.tagRadio:
        return "go_live_options.radio".tr();

      case LiveStreamingModel.tagPoleDance:
        return "go_live_options.pole_dance".tr();

      case LiveStreamingModel.tagTarot:
        return "go_live_options.tarot_".tr();

      case LiveStreamingModel.tagDJ:
        return "go_live_options.do_".tr();

      case LiveStreamingModel.tagCharming:
        return "go_live_options.charming_".tr();

      case LiveStreamingModel.tagMimicryShow:
        return "go_live_options.mimicry_show".tr();

      case LiveStreamingModel.tagMakeup:
        return "go_live_options.makeup_".tr();

      case LiveStreamingModel.tagGossip:
        return "go_live_options.gossip_".tr();

      case LiveStreamingModel.tagModel:
        return "go_live_options.model_".tr();

      case LiveStreamingModel.tagTalkShow:
        return "go_live_options.talk_show".tr();

      case LiveStreamingModel.tagCosplay:
        return "go_live_options.cosplay_".tr();

      case LiveStreamingModel.tagDancing:
        return "go_live_options.dancing_".tr();

      case LiveStreamingModel.tagMusic:
        return "go_live_options.music_".tr();

      case LiveStreamingModel.liveSubTalking:
        return "live_type.talking_".tr();

      case LiveStreamingModel.liveSubSinging:
        return "live_type.singing_".tr();

      case LiveStreamingModel.liveSubDancing:
        return "live_type.dancing".tr();

      case LiveStreamingModel.liveSubFriends:
        return "live_type.friends_".tr();

      case LiveStreamingModel.liveSubGame:
        return "live_type.game_".tr();

      default:
        return "";
    }
  }

  static Color getColorSettingsBg() {
    if (isDarkModeNoContext()) {
      return kContentColorLightTheme;
    } else {
      return kSettingsBg;
    }
  }

  static String getDurationInMinutes({Duration? duration}) {
    if (duration != null) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

      if (duration.inHours > 0) {
        return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
      } else {
        return "$twoDigitMinutes:$twoDigitSeconds";
      }
    } else {
      return "00:00";
    }
  }

  static String formatTime(int second) {
    var hour = (second / 3600).floor();
    var minutes = ((second - hour * 3600) / 60).floor();
    var seconds = (second - hour * 3600 - minutes * 60).floor();

    var secondExtraZero = (seconds < 10) ? "0" : "";
    var minuteExtraZero = (minutes < 10) ? "0" : "";
    var hourExtraZero = (hour < 10) ? "0" : "";

    if (hour > 0) {
      return "$hourExtraZero$hour:$minuteExtraZero$minutes:$secondExtraZero$seconds";
    } else {
      return "$minuteExtraZero$minutes:$secondExtraZero$seconds";
    }
  }

  static Color getColorTextCustom1({bool? inverse}) {
    if (isDarkModeNoContext()) {
      if (inverse != null && inverse) {
        return kContentColorLightTheme;
      } else {
        return kContentColorDarkTheme;
      }
    } else {
      if (inverse != null && inverse) {
        return kContentColorDarkTheme;
      } else {
        return kContentColorLightTheme;
      }
    }
  }

  static Color getColorToolbarIcons() {
    if (isDarkModeNoContext()) {
      return kContentColorDarkTheme;
    } else {
      return kColorsGrey600;
    }
  }

  static bool isDarkMode(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  static bool isDarkModeNoContext() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    return brightness == Brightness.dark;
  }

  static bool isWebPlatform() {
    return UniversalPlatform.isWeb;
  }

  static bool isAndroidPlatform() {
    return UniversalPlatform.isAndroid;
  }

  static bool isFuchsiaPlatform() {
    return UniversalPlatform.isFuchsia;
  }

  static bool isIOSPlatform() {
    return UniversalPlatform.isIOS;
  }

  static bool isMacOsPlatform() {
    return UniversalPlatform.isMacOS;
  }

  static bool isLinuxPlatform() {
    return UniversalPlatform.isLinux;
  }

  static bool isWindowsPlatform() {
    return UniversalPlatform.isWindows;
  }

  // Get country code
  static String? getCountryIso() {
    final List<Locale>? systemLocales = WidgetsBinding.instance.window.locales;
    return systemLocales?.first.countryCode;
  }

  static String? getCountryCodeFromLocal(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);

    return myLocale.countryCode;
  }

  // Save Installation
  static Future<void> initInstallation(UserModel? user, String? token) async {
    DateTime dateTime = DateTime.now().toLocal();

    ParseInstallation installation = ParseInstallation.forQuery();
    ParseInstallation installationCurrent =
        await ParseInstallation.currentInstallation();

    if (token != null) {
      installation.set('deviceToken', token);
    } else {
      installation.unset('deviceToken');
    }

    installation.set('GCMSenderId', Config.pushGcm);
    installation.set('timeZone', dateTime.timeZoneName);
    installation.set('installationId', installationCurrent.installationId);

    if (kIsWeb) {
      installation.set('deviceType', 'web');
      installation.set('pushType', 'FCM');
    } else if (Platform.isAndroid) {
      installation.set('deviceType', 'android');
      installation.set('pushType', 'FCM');
    } else if (Platform.isIOS) {
      installation.set('deviceType', 'ios');
      installation.set('pushType', 'APN');
    }

    if (user != null) {
      installation.set('user', user);
      installation.subscribeToChannel('global');
    } else {
      installation.unset('user');
      installation.unsubscribeFromChannel('global');
    }
  }

  static setCurrentUser(UserModel? userModel, {StateSetter? setState}) async {
    UserModel userModel = await ParseUser.currentUser();

    if (setState != null) {
      setState(() {
        userModel = userModel;
      });
    } else {
      userModel = userModel;
    }
  }

  static Future<UserModel?>? getCurrentUser() async {
    UserModel? currentUser = await ParseUser.currentUser();
    return currentUser;
  }

  static Future<UserModel?> getCurrentUserModel(UserModel? userModel) async {
    UserModel currentUser = await ParseUser.currentUser();
    return currentUser;
  }

  static Future<UserModel> getUserModelResult(dynamic d) async {
    UserModel? user = await ParseUser.currentUser();
    user = UserModel.clone()..fromJson(d as Map<String, dynamic>);

    return user;
  }

  static Future<UserModel?> getUserAwait() async {
    UserModel? currentUser = await ParseUser.currentUser();

    if (currentUser != null) {
      ParseResponse response = await currentUser.getUpdatedUser();
      if (response.success) {
        currentUser = response.result;
        return currentUser;
      } else if (response.error!.code == 100) {
        // Return stored user

        return currentUser;
      } else if (response.error!.code == 101) {
        // User deleted or doesn't exist.

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else if (response.error!.code == 209) {
        // Invalid session token

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else {
        // General error

        return currentUser;
      }
    } else {
      return null;
    }
  }

  static Future<UserModel?> getUser(UserModel? currentUser) async {
    currentUser = await ParseUser.currentUser();

    if (currentUser != null) {
      ParseResponse response = await currentUser.getUpdatedUser();

      if (response.success) {
        UserModel userModel = response.results!.first!;

        return userModel;
      } else if (response.error!.code == 100) {
        // Return stored user

        return currentUser;
      } else if (response.error!.code == 101) {
        // User deleted or doesn't exist.

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else if (response.error!.code == 209) {
        // Invalid session token

        currentUser.logout(deleteLocalUserData: true);
        return null;
      } else {
        // General error

        return currentUser;
      }
    } else {
      return null;
    }
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  // Check if string has only number(s)
  static bool isNumeric(String string) {
    return double.tryParse(string) != null;
  }

  static bool isPasswordCompliant(String password, [int minLength = 6]) {
    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasSpecialCharacters =
        password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasSpecialCharacters &
        hasMinLength;
  }

  static DateTime getDateFromString(String date, String format) {
    return new DateFormat(format).parse(date);
  }

  static Object getDateDynamic(String date) {
    DateFormat dateFormat = DateFormat(dateFormatDmy);
    DateTime dateTime = dateFormat.parse(date);

    return json.encode(dateTime, toEncodable: myEncode);
  }

  static dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  static DateTime getDate(String date) {
    DateFormat dateFormat = DateFormat(dateFormatDmy);
    DateTime dateTime = dateFormat.parse(date);

    return dateTime;
  }

  static bool isValidDateBirth(String date, String format) {
    try {
      int day = 1, month = 1, year = 2000;

      //Get separator data  10/10/2020, 2020-10-10, 10.10.2020
      String separator = RegExp("([-/.])").firstMatch(date)!.group(0)![0];

      //Split by separator [mm, dd, yyyy]
      var frSplit = format.split(separator);
      //Split by separtor [10, 10, 2020]
      var dtSplit = date.split(separator);

      for (int i = 0; i < frSplit.length; i++) {
        var frm = frSplit[i].toLowerCase();
        var vl = dtSplit[i];

        if (frm == "dd")
          day = int.parse(vl);
        else if (frm == "mm")
          month = int.parse(vl);
        else if (frm == "yyyy") year = int.parse(vl);
      }

      //First date check
      //The dart does not throw an exception for invalid date.
      var now = DateTime.now();
      if (month > 12 ||
          month < 1 ||
          day < 1 ||
          day > daysInMonth(month, year) ||
          year < 1810 ||
          (year > now.year && day > now.day && month > now.month))
        throw Exception("Date birth invalid.");

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool minimumAgeAllowed(String birthDateString, String datePattern) {
    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 18 years ahead
    DateTime adultDate = DateTime(
      birthDate.year + Setup.minimumAgeToRegister,
      birthDate.month,
      birthDate.day,
    );

    return adultDate.isBefore(today);
  }

  static int daysInMonth(int month, int year) {
    int days = 28 +
        (month + (month / 8).floor()) % 2 +
        2 % month +
        2 * (1 / month).floor();
    return (isLeapYear(year) && month == 2) ? 29 : days;
  }

  static bool isLeapYear(int year) =>
      ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0);

  static void showLoadingDialog(BuildContext context, {bool? isDismissible}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible != null ? isDismissible : false,
        builder: (BuildContext context) {
          return showLoadingAnimation(); //LoadingDialog();
        });
  }

  static void hideLoadingDialog(BuildContext context, {dynamic result}) {
    Navigator.pop(context, result);
  }

  static goToNavigator(BuildContext context, String route,
      {Object? arguments, ResumableState? resumeState}) {
    Future.delayed(Duration.zero, () {
      if (resumeState != null) {
        resumeState.pushNamed(context, route, arguments: arguments);
      } else {
        Navigator.of(context).pushNamed(route, arguments: arguments);
       /* NavigationService.navigatorKey.currentState
            ?.pushNamed(route, arguments: arguments);*/
      }
    });
  }

  static gotoChat(BuildContext context,
      {UserModel? currentUser,
      UserModel? mUser,}) {
    QuickHelp.goToNavigatorScreen(
        context,
        MessageScreen(
            currentUser: currentUser, mUser: mUser));
  }

  static goToNavigatorScreen(BuildContext context, Widget widget,
      {bool? finish = false, bool? back = true}) {
    if (finish == false) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => widget,
        ),
      );
    } else {
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => widget,
        ),
        (route) => back!, //if you want to disable back feature set to false
      );
    }
  }

  static Future<dynamic> goToNavigatorScreenForResult(
      BuildContext context, Widget widget) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          //settings: RouteSettings(name: route),
          builder: (context) => widget),
    );

    return result;
  }

  static void goBack(BuildContext context, {Object? arguments}) {
    Navigator.pop(context, arguments);
  }

  /*static goToNavigatorAndClear(BuildContext context, String route,
      {Object? arguments}) {
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false,
          arguments: arguments);
    });
  }*/

  static goToPageWithClear(BuildContext context, Widget widget) {
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => widget,
      ),
      (route) => false, //if you want to disable back feature set to false
    );
  }

  static void goBackToPreviousPage(BuildContext context,
      {bool? useCustomAnimation,
      PageTransitionsBuilder? pageTransitionsBuilder,
      dynamic result}) {
    Navigator.of(context).pop(result);
  }

  static checkRoute(BuildContext context, bool authNeeded, Widget widget) {
    if (authNeeded && QuickHelp.getCurrentUser() != null) {
      return widget;
    } else {
      return QuickHelp.goBackToPreviousPage(context);
    }
  }

  /*static _logout(BuildContext context, UserModel? userModel) async {
    Navigator.pop(context);
    QuickHelp.showLoadingDialog(context);

    ParseResponse response = await userModel!.logout(deleteLocalUserData: true);
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      //QuickHelp.goToPageWithClear(context, WelcomeScreen(), route: WelcomeScreen.route);
      //goToNavigatorAndClear(context, '/');
      QuickHelp.goToNavigatorScreen(
          context, WelcomeScreen(), finish: true, back: false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      //QuickHelp.goToPageWithClear(context, WelcomeScreen(), route: WelcomeScreen.route);
      QuickHelp.goToNavigatorScreen(
          context, WelcomeScreen(), finish: true, back: false);
    }
  }*/

  static void showDialogWithButton(
      {required BuildContext context,
      String? message,
      String? title,
      String? buttonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: Text(message!),
          actions: [
            new ElevatedButton(
              child: Text(buttonText!),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showDialogWithButtonCustom(
      {required BuildContext context,
      String? message,
      String? title,
      required String? cancelButtonText,
      required String? confirmButtonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          title: TextWithTap(
            title!,
            fontWeight: FontWeight.bold,
          ),
          content: Text(message!),
          actions: [
            TextWithTap(
              cancelButtonText!,
              fontWeight: FontWeight.bold,
              marginRight: 10,
              marginLeft: 10,
              marginBottom: 10,
              onTap: () => Navigator.of(context).pop(),
            ),
            TextWithTap(
              confirmButtonText!,
              fontWeight: FontWeight.bold,
              marginRight: 10,
              marginLeft: 10,
              marginBottom: 10,
              onTap: () {
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static void showDialogHeyto(
      {required BuildContext context,
      String? message,
      String? title,
      required String? cancelButtonText,
      required String? confirmButtonText,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Column(
            children: [
              Center(
                child: Container(
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    'assets/svg/ic_icon.svg',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              TextWithTap(
                title!,
                marginTop: 28,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 30,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 16,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
                TextWithTap(
                  cancelButtonText!.toUpperCase(),
                  fontWeight: FontWeight.bold,
                  color: kPrimacyGrayColor,
                  marginRight: 10,
                  marginLeft: 10,
                  fontSize: 15,
                  marginBottom: 10,
                  textAlign: TextAlign.center,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showDialogPermission(
      {required BuildContext context,
      String? message,
      String? title,
      required String? confirmButtonText,
      VoidCallback? onPressed,
      bool? dismissible = true}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible!,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: TextWithTap(
            title!,
            marginTop: 5,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
            color: kSecondaryGrayColor,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 20,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 15,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showDialogLivEend(
      {required BuildContext context,
      String? message,
      String? title,
      required String? confirmButtonText,
      VoidCallback? onPressed,
      bool? dismiss = true}) {
    showDialog(
      barrierDismissible: dismiss!,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kContentColorDarkTheme,
          elevation: 2,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: TextWithTap(
            title!,
            marginTop: 5,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          content: TextWithTap(
            message!,
            textAlign: TextAlign.center,
            color: kSecondaryGrayColor,
          ),
          actions: [
            Column(
              children: [
                RoundedGradientButton(
                  text: confirmButtonText!,
                  //width: 150,
                  height: 48,
                  marginLeft: 30,
                  marginRight: 30,
                  marginBottom: 20,
                  borderRadius: 60,
                  textColor: Colors.white,
                  borderRadiusBottomLeft: 15,
                  colors: [kPrimaryColor, kSecondaryColor],
                  marginTop: 0,
                  fontSize: 15,
                  onTap: () {
                    if (onPressed != null) {
                      onPressed();
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showError(
      {required BuildContext context,
      String? message,
      VoidCallback? onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(message!),
          actions: <Widget>[
            new ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                if (onPressed != null) {
                  onPressed();
                }
              },
            ),
          ],
        );
      },
    );
  }

  static bool isAccountDisabled(UserModel? user) {
    if (user!.getActivationStatus == true) {
      return true;
    } else if (user.getAccountDeleted == true) {
      return true;
    } else {
      return false;
    }
  }

  static updateUserServer(
      {required String column,
      required dynamic value,
      required UserModel user}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.updateUserGlobalParam);
    Map<String, dynamic> params = <String, dynamic>{
      CloudParams.columnGlobal: column,
      CloudParams.valueGlobal: value,
      CloudParams.userGlobal: user.getUsername!,
    };

    ParseResponse parseResponse = await function.execute(parameters: params);
    if (parseResponse.success) {
      UserModel.getUserResult(parseResponse.result);
    }
  }

  // Use this example
  /* Map<String, dynamic> paramsList = <String, dynamic>{
     CloudParams.userGlobal: user.getUsername!,
     UserModel.keyFirstName: "Maravilho",
     UserModel.keyLastName: "Singa",
     UserModel.keyAge: 26,
  }; */

  static updateUserServerList({required Map<String, dynamic> map}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.updateUserGlobalListParam);
    Map<String, dynamic> params = map;

    ParseResponse parseResponse = await function.execute(parameters: params);
    if (parseResponse.success) {
      UserModel.getUserResult(parseResponse.result);
    }
  }

  //final emailSendingCallback? _sendingCallback;

  static sendEmail(String accountNumber, String emailType,
      {EmailSendingCallback? sendingCallback}) async {
    ParseCloudFunction function =
        ParseCloudFunction(CloudParams.sendEmailParam);
    Map<String, String> params = <String, String>{
      CloudParams.userGlobal: accountNumber,
      CloudParams.emailType: emailType
    };
    ParseResponse result = await function.execute(parameters: params);

    if (result.success) {
      sendingCallback!(true, null);
    } else {
      sendingCallback!(false, result.error);
    }
  }

  static bool isMobile() {
    if (isWebPlatform()) {
      return false;
    } else if (isAndroidPlatform()) {
      return true;
    } else if (isIOSPlatform()) {
      return true;
    } else {
      return false;
    }
  }

  static goToWebPage(BuildContext context, {required String pageType}) {
    goToNavigator(context, pageType);
  }

  static void showErrorResult(BuildContext context, int error) {
    QuickHelp.hideLoadingDialog(context);

    if (error == DatooException.connectionFailed) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "not_connected".tr(),
        isError: true,
      );
    } else if (error == DatooException.otherCause) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "not_connected".tr(),
        isError: true,
      );
    } else if (error == DatooException.emailTaken) {
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "auth.email_taken".tr(),
        isError: true,
      );
    }

    /*else if(error == DatooException.accountBlocked){
      // Internet problem
      QuickHelp.showAlertError(context: context, title: "error".tr(), message: "auth.account_blocked".tr());
    }*/
    else {
      // Invalid credentials
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "auth.invalid_credentials".tr(),
        isError: true,
      );
    }
  }

  static bool isAndroidLogin() {
    if (QuickHelp.isAndroidPlatform()) {
      return false;
    } else if (QuickHelp.isIOSPlatform() && Setup.isAppleLoginEnabled) {
      return true;
    } else {
      return false;
    }
  }

  static final bool areSocialLoginsDisabled = !Setup.isPhoneLoginEnabled &&
      !Setup.isGoogleLoginEnabled &&
      !isAndroidLogin();

  static int generateUId() {
    Random rnd = new Random();
    return 1000000000 + rnd.nextInt(999999999);
  }

  static int generateShortUId() {
    Random rnd = new Random();
    return 1000 + rnd.nextInt(9999);
  }

  static Future<String> downloadFilePath(
      String url, String fileName, String dir) async {
    HttpClient httpClient = new HttpClient();
    File file;
    String filePath = '';
    String myUrl = '';

    try {
      myUrl = url + '/' + fileName;
      var request = await httpClient.getUrl(Uri.parse(myUrl));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        filePath = '$dir/$fileName';
        file = File(filePath);
        await file.writeAsBytes(bytes);
      } else
        filePath = 'Error code: ' + response.statusCode.toString();
    } catch (ex) {
      filePath = 'Can not fetch url';
    }

    return filePath;
  }

  static Map<String, dynamic>? getInfoFromToken(String token) {
    // validate token

    final List<String> parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    // retrieve token payload
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    if (payloadMap is! Map<String, dynamic>) {
      return null;
    }
    return payloadMap;
  }

  static Future<dynamic> downloadFile(String url, String filename) async {
    HttpClient httpClient = new HttpClient();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  static setWebPageTitle(BuildContext context, String title) {
    SystemChrome.setApplicationSwitcherDescription(
        ApplicationSwitcherDescription(
      label: '${Setup.appName} - $title',
      primaryColor: Theme.of(context).primaryColor.value,
    ));
  }

  /*static List<InAppPurchaseModel> getMoods() {
    InAppPurchaseModel rc = new InAppPurchaseModel();
    rc.setName("profile_tab.mood_rc".tr());
    rc.setCode("RC");

    InAppPurchaseModel lmu = new InAppPurchaseModel();
    lmu.setName("profile_tab.mood_lmu".tr());
    lmu.setCode("LMU");

    InAppPurchaseModel hle = new InAppPurchaseModel();
    hle.setName("profile_tab.mood_hle".tr());
    hle.setCode("HLE");

    InAppPurchaseModel bmm = new InAppPurchaseModel();
    bmm.setName("profile_tab.mood_bmm".tr());
    bmm.setCode("BMM");

    InAppPurchaseModel cc = new InAppPurchaseModel();
    cc.setName("profile_tab.mood_cc".tr());
    cc.setCode("CC");

    InAppPurchaseModel rfd = new InAppPurchaseModel();
    rfd.setName("profile_tab.mood_rfd".tr());
    rfd.setCode("RFD");

    InAppPurchaseModel icud = new InAppPurchaseModel();
    icud.setName("profile_tab.mood_icud".tr());
    icud.setCode("ICUD");

    InAppPurchaseModel jpt = new InAppPurchaseModel();
    jpt.setName("profile_tab.mood_jpt".tr());
    jpt.setCode("JPT");

    InAppPurchaseModel mml = new InAppPurchaseModel();
    mml.setName("profile_tab.mood_mml".tr());
    mml.setCode("MML");

    InAppPurchaseModel sm = new InAppPurchaseModel();
    sm.setName("profile_tab.mood_sm".tr());
    sm.setCode("SM");

    InAppPurchaseModel none = new InAppPurchaseModel();
    none.setName("profile_tab.mood_none".tr());
    none.setCode("");

    List<InAppPurchaseModel> moodModelArrayList = [];

    moodModelArrayList.add(rc);
    moodModelArrayList.add(lmu);
    moodModelArrayList.add(hle);
    moodModelArrayList.add(bmm);
    moodModelArrayList.add(cc);
    moodModelArrayList.add(rfd);
    moodModelArrayList.add(icud);
    moodModelArrayList.add(jpt);
    moodModelArrayList.add(mml);
    moodModelArrayList.add(sm);
    moodModelArrayList.add(none);

    return moodModelArrayList;
  }*/

  /*static String getMoodName(InAppPurchaseModel moodModel) {
    switch (moodModel.getCode()) {
      case "RC":
        return "profile_tab.mood_rc".tr();

      case "LMU":
        return "profile_tab.mood_lmu".tr();

      case "HLE":
        return "profile_tab.mood_hle".tr();

      case "BMM":
        return "profile_tab.mood_bmm".tr();

      case "CC":
        return "profile_tab.mood_cc".tr();

      case "RFD":
        return "profile_tab.mood_rfd".tr();

      case "ICUD":
        return "profile_tab.mood_icud".tr();

      case "JPT":
        return "profile_tab.mood_jpt".tr();

      case "MML":
        return "profile_tab.mood_mml".tr();

      case "SM":
        return "profile_tab.mood_sm".tr();

      default:
        return "profile_tab.mood_none".tr();
    }
  }*/

  static String getMoodNameByCode(String modeCode) {
    switch (modeCode) {
      case "RC":
        return "profile_tab.mood_rc".tr();

      case "LMU":
        return "profile_tab.mood_lmu".tr();

      case "HLE":
        return "profile_tab.mood_hle".tr();

      case "BMM":
        return "profile_tab.mood_bmm".tr();

      case "CC":
        return "profile_tab.mood_cc".tr();

      case "RFD":
        return "profile_tab.mood_rfd".tr();

      case "ICUD":
        return "profile_tab.mood_icud".tr();

      case "JPT":
        return "profile_tab.mood_jpt".tr();

      case "MML":
        return "profile_tab.mood_mml".tr();

      case "SM":
        return "profile_tab.mood_sm".tr();

      default:
        return "profile_tab.mood_none".tr();
    }
  }

  static void setRandomArray(List arrayList) {
    arrayList.shuffle();
  }

  static int getAgeFromDate(DateTime birthday) {
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthday.year;

    int month1 = currentDate.month;
    int month2 = birthday.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthday.day;

      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static int getAgeFromDateString(String birthDateString, String datePattern) {
    // Parsed date to check
    DateTime birthday = DateFormat(datePattern).parse(birthDateString);

    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthday.year;

    int month1 = currentDate.month;
    int month2 = birthday.month;

    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthday.day;

      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static DateTime incrementDate(int days) {
    DateTime limitDate = DateTime.now();
    limitDate.add(Duration(days: days));

    return limitDate;
  }

  static String getStringFromDate(DateTime utcTime) {
    final dateTime = utcTime.toLocal();

    return DateFormat(dateFormatDmy).format(dateTime);
  }

  static String getTimeAgoForFeed(DateTime utcTime) {
    // Get local time based on UTC time
    final dateTime = utcTime.toLocal();

    DateTime now = DateTime.now();
    int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (dateDiff == -1) {
      // Yesterday
      return "date_time.yesterday_".tr();
    } else if (dateDiff == 0) {
      // today
      return DateFormat().add_Hm().format(dateTime);
    } else {
      return DateFormat().add_MMMEd().add_Hm().format(dateTime);
    }
  }

  static String convertToK(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  static String getBirthdayFromDate(DateTime date) {
    return DateFormat(dateFormatDmy).format(date.add(Duration(days: 1)));
  }

  static saveCoinTransaction({
    required UserModel author,
    UserModel? receiver,
    required int amountTransacted
  }) {
    CoinsTransactionsModel coinsTransactionsModel = CoinsTransactionsModel();

    coinsTransactionsModel.setAuthor = author;
    coinsTransactionsModel.setAuthorId = author.objectId!;

    if(receiver != null) {
      coinsTransactionsModel.setReceiver = receiver;
      coinsTransactionsModel.setReceiverId = receiver.objectId!;
      coinsTransactionsModel.setTransactionType = CoinsTransactionsModel.transactionTypeSent;
    }else{
      coinsTransactionsModel.setTransactionType = CoinsTransactionsModel.transactionTypeTopUP;
    }

    coinsTransactionsModel.setTransactedAmount = amountTransacted;
    coinsTransactionsModel.setAmountAfterTransaction = author.getCredits!;
    coinsTransactionsModel.save();
  }

  static saveReceivedGifts({
    required UserModel receiver,
    required UserModel author,
    required GiftsModel gift,
  }) async {
    QueryBuilder<GiftsReceivedModel> query =
        QueryBuilder<GiftsReceivedModel>(GiftsReceivedModel());

    query.whereEqualTo(
      GiftsReceivedModel.keyReceiverId,
      receiver.objectId,
    );

    query.whereEqualTo(
      GiftsReceivedModel.keyGiftId,
      gift.objectId,
    );

    ParseResponse verificationResponse = await query.query();

    if (verificationResponse.success && verificationResponse.results != null) {
      GiftsReceivedModel giftReceived = verificationResponse.results!.first;
      giftReceived.incrementQuantity = 1;
      giftReceived.save();
    } else {
      GiftsReceivedModel receivedGIft = new GiftsReceivedModel();
      receivedGIft.setAuthor = author;
      receivedGIft.setAuthorId = author.objectId!;
      receivedGIft.setQuantity = 1;
      receivedGIft.setReceiver = receiver;
      receivedGIft.setReceiverId = receiver.objectId!;

      receivedGIft.setGift = gift;
      receivedGIft.setGiftId = gift.objectId!;

      await receivedGIft.save();
    }
  }

  static Map<String, String> countryDialCodes = {
    'AF': '+93', 'AL': '+355', 'DZ': '+213', 'AS': '+1-684', 'AD': '+376',
    'AO': '+244', 'AI': '+1-264', 'AQ': '+672', 'AG': '+1-268', 'AR': '+54',
    'AM': '+374', 'AW': '+297', 'AU': '+61', 'AT': '+43', 'AZ': '+994',
    'BS': '+1-242', 'BH': '+973', 'BD': '+880', 'BB': '+1-246', 'BY': '+375',
    'BE': '+32', 'BZ': '+501', 'BJ': '+229', 'BM': '+1-441', 'BT': '+975',
    'BO': '+591', 'BA': '+387', 'BW': '+267', 'BR': '+55', 'IO': '+246',
    'VG': '+1-284', 'BN': '+673', 'BG': '+359', 'BF': '+226', 'BI': '+257',
    'KH': '+855', 'CM': '+237', 'CA': '+1', 'CV': '+238', 'KY': '+1-345',
    'CF': '+236', 'TD': '+235', 'CL': '+56', 'CN': '+86', 'CO': '+57',
    'KM': '+269', 'CG': '+242', 'CD': '+243', 'CK': '+682', 'CR': '+506',
    'CI': '+225', 'HR': '+385', 'CU': '+53', 'CW': '+599', 'CY': '+357',
    'CZ': '+420', 'DK': '+45', 'DJ': '+253', 'DM': '+1-767', 'DO': '+1-809',
    'EC': '+593', 'EG': '+20', 'SV': '+503', 'GQ': '+240', 'ER': '+291',
    'EE': '+372', 'ET': '+251', 'FJ': '+679', 'FI': '+358', 'FR': '+33',
    'GF': '+594', 'PF': '+689', 'GA': '+241', 'GM': '+220', 'GE': '+995',
    'DE': '+49', 'GH': '+233', 'GI': '+350', 'GR': '+30', 'GL': '+299',
    'GD': '+1-473', 'GP': '+590', 'GU': '+1-671', 'GT': '+502', 'GN': '+224',
    'GW': '+245', 'GY': '+592', 'HT': '+509', 'HN': '+504', 'HK': '+852',
    'HU': '+36', 'IS': '+354', 'IN': '+91', 'ID': '+62', 'IR': '+98',
    'IQ': '+964', 'IE': '+353', 'IL': '+972', 'IT': '+39', 'JM': '+1-876',
    'JP': '+81', 'JO': '+962', 'KZ': '+7', 'KE': '+254', 'KI': '+686',
    'KP': '+850', 'KR': '+82', 'KW': '+965', 'KG': '+996', 'LA': '+856',
    'LV': '+371', 'LB': '+961', 'LS': '+266', 'LR': '+231', 'LY': '+218',
    'LI': '+423', 'LT': '+370', 'LU': '+352', 'MO': '+853', 'MK': '+389',
    'MG': '+261', 'MW': '+265', 'MY': '+60', 'MV': '+960', 'ML': '+223',
    'MT': '+356', 'MH': '+692', 'MQ': '+596', 'MR': '+222', 'MU': '+230',
    'YT': '+262', 'MX': '+52', 'FM': '+691', 'MD': '+373', 'MC': '+377',
    'MN': '+976', 'ME': '+382', 'MS': '+1-664', 'MA': '+212', 'MZ': '+258',
    'MM': '+95', 'NA': '+264', 'NR': '+674', 'NP': '+977', 'NL': '+31',
    'NC': '+687', 'NZ': '+64', 'NI': '+505', 'NE': '+227', 'NG': '+234',
    'NU': '+683', 'NF': '+672', 'MP': '+1-670', 'NO': '+47', 'OM': '+968',
    'PK': '+92', 'PW': '+680', 'PS': '+970', 'PA': '+507', 'PG': '+675',
    'PY': '+595', 'PE': '+51', 'PH': '+63', 'PL': '+48', 'PT': '+351',
    'PR': '+1-787', 'QA': '+974', 'RE': '+262', 'RO': '+40', 'RU': '+7',
    'RW': '+250', 'BL': '+590', 'SH': '+290', 'KN': '+1-869', 'LC': '+1-758',
    'MF': '+590', 'PM': '+508', 'VC': '+1-784', 'WS': '+685', 'SM': '+378',
    'ST': '+239', 'SA': '+966', 'SN': '+221', 'RS': '+381', 'SC': '+248',
    'SL': '+232', 'SG': '+65', 'SX': '+1-721', 'SK': '+421', 'SI': '+386',
    'SB': '+677', 'SO': '+252', 'ZA': '+27', 'SS': '+211', 'ES': '+34',
    'LK': '+94', 'SD': '+249', 'SR': '+597', 'SZ': '+268', 'SE': '+46',
    'CH': '+41', 'SY': '+963', 'TW': '+886', 'TJ': '+992', 'TZ': '+255',
    'TH': '+66', 'TL': '+670', 'TG': '+228', 'TK': '+690', 'TO': '+676',
    'TT': '+1-868', 'TN': '+216', 'TR': '+90', 'TM': '+993', 'TC': '+1-649',
    'TV': '+688', 'UG': '+256', 'UA': '+380', 'AE': '+971', 'GB': '+44',
    'US': '+1', 'UY': '+598', 'UZ': '+998', 'VU': '+678', 'VA': '+379',
    'VE': '+58', 'VN': '+84', 'WF': '+681', 'EH': '+212', 'YE': '+967',
    'ZM': '+260', 'ZW': '+263', "AX": "+358", "BQ": "+599", "CC":"+61", 'CX':'+61',
    'FK':'+500', 'FO':'+298', 'GB-ENG':'+44', 'GB-NIR':"+44", "GB-SCT":"+44", 'GB-WLS':"+44",
    "GG":"+44 1481", "GS":"+500", "IM":"+44 1624", "JE":"+44 1534", "PN":"+64","TF":"+262",
    "VI":"+1-340", "XK":"+383"
  };

  static String getCountryDialCode(String isoCode) {
    return countryDialCodes[isoCode.toUpperCase()] ?? "no_data".tr();
  }

  static List countriesIsoList = [
  keyAndoraIso,
  keyUnitedArabEmirates,
  keyAfghanistan,
  keyAntiguaAndBarbuda,
  keyAnguilla,
  keyAlbania,
  keyArmenia,
  keyAngola,
  keyAntarctica,
  keyArgentina,
  keyAmericanSamoa,
  keyAustria,
  keyAustralia,
  keyAruba,
  keyAlandIslands,
  keyAzerbaijan,
  keyBosniaAndHerzegovina,
  keyBarbados,
  keyBangladesh,
  keyBelgium,
  keyBurkinaFaso,
  keyBulgaria,
  keyBahrain,
  keyBurundi,
  keyBenin,
  keySaintBarthelemy,
  keyBermuda,
  keyBruneiDarussalam,
  keyBolivia,
  keyBonaireSintEustatiusAndSaba,
  keyBrazil,
  keyBahamas,
  keyBhutan,
  keyBotswana,
  keyBelarus,
  keyBelize,
  keyCanada,
  keyCocosIslands,
  keyCongoDemocraticRepublic,
  keyCentralAfricanRepublic,
  keyCongo,
  keySwitzerland,
  keyCoteDIvoire,
  keyCookIslands,
  keyChile,
  keyCameroon,
  keyChina,
  keyColombia,
  keyCostaRica,
  keyCuba,
  keyCaboVerde,
  keyCuracao,
  keyChristmasIsland,
  keyCyprus,
  keyCzechia,
  keyGermany,
  keyDjibouti,
  keyDenmark,
  keyDominica,
  keyDominicanRepublic,
  keyAlgeria,
  keyEcuador,
  keyEstonia,
  keyEgypt,
  keyWesternSahara,
  keyEritrea,
  keySpain,
  keyEthiopia,
  keyFinland,
  keyFiji,
  keyFrance,
  keyFalklandIslands,
  keyMicronesia,
  keyFaroeIslands,
  keyGabon,
  keyUnitedKingdom,
  keyEngland,
  keyNorthernIreland,
  keyScotLand,
  keyWales,
  keyGrenada,
  keyGeorgia,
  keyFrenchGuiana,
  keyGuernsey,
  keyGhana,
  keyGibraltar,
  keyGreenland,
  keyGambia,
  keyGuinea,
  keyGuadeloupe,
  keyEquatorialGuinea,
  keyGreece,
  keySouthGeorgia,
  keyGuatemala,
  keyGuam,
  keyGuineaBissau,
  keyGuyana,
  keyHongKong,
  keyHeardIslandMcDonaldIslands,
  keyHonduras,
  keyCroatia,
  keyHaiti,
  keyHungary,
  keyIndonesia,
  keyIreland,
  keyIsrael,
  keyIsleOfMan,
  keyIndia,
  keyBritishIndianOceanTerritory ,
  keyIraq,
  keyIran,
  keyIceland,
  keyItaly,
  keyJersey,
  keyJamaica,
  keyJordan,
  keyJapan,
  keyKenya,
  keyKyrgyzstan,
  keyCambodia,
  keyKiribati,
  keyComoros,
  keySaintKittsNevis,
  keyNorthKorea,
  keySouthKorea,
  keyKuwait,
  keyCaymanIslands,
  keyKazakhstan,
  keyLaos,
  keyLebanon,
  keySaintLucia,
  keyLiechtenstein,
  keySriLanka,
  keyLiberia,
  keyLesotho,
  keyLithuania,
  keyLuxembourg,
  keyLatvia,
  keyLibya,
  keyMorocco,
  keyMonaco,
  keyMoldova,
  keyMontenegro,
  keySaintMartinFrench,
  keyMadagascar,
  keyMarshallIslands,
  keyNorthMacedonia,
  keyMali,
  keyMyanmar,
  keyMongolia,
  keyMacao,
  keyNorthernMarianaIslands,
  keyMartinique,
  keyMauritania,
  keyMontserrat,
  keyMalta,
  keyMauritius,
  keyMaldives,
  keyMalawi,
  keyMexico,
  keyMalaysia,
  keyMozambique,
  keyNamibia,
  keyNewCaledonia,
  keyNiger,
  keyNorfolkIsland,
  keyNigeria,
  keyNicaragua,
  keyNetherlands,
  keyNorway,
  keyNepal,
  keyNauru,
  keyNiue,
  keyNewZealand,
  keyOman,
  keyPanama,
  keyPeru,
  keyFrenchPolynesia,
  keyPapuaNewGuinea,
  keyPhilippines,
  keyPakistan,
  keyPoland,
  keySaintPierreMiquelon,
  keyPitcairn,
  keyPuertoRico,
  keyPalestineState,
  keyPortugal,
  keyPalau,
  keyParaguay,
  keyQatar,
  keyReunion,
  keyRomania,
  keySerbia,
  keyRussianFederation,
  keyRwanda,
  keySaudiArabia,
  keySolomonIslands,
  keySeychelles,
  keySudan,
  keySweden,
  keySingapore,
  keySaintHelena,
  keySlovenia,
  keySlovakia,
  keySierraLeone,
  keySanMarino,
  keySenegal,
  keySomalia,
  keySuriname,
  keySouthSudan,
  keySaoTomePrincipe,
  keyElSalvador,
  keySintMaarten,
  keySyrianArabRepublic,
  keyEswatini,
  keyTurksCaicosIslands,
  keyChad,
  keyFrenchSouthernTerritories,
  keyTogo,
  keyThailand,
  keyTajikistan,
  keyTokelau,
  keyTimorLeste,
  keyTurkmenistan,
  keyTunisia,
  keyTonga,
  keyTurkey,
  keyTrinidadTobago,
  keyTuvalu,
  keyTaiwan,
  keyTanzania,
  keyUkraine,
  keyUganda,
  keyUnitedStatesAmerica,
  keyUruguay,
  keyUzbekistan,
  keyHolySee,
  keySaintVincentGrenadines,
  keyVenezuela,
  keyVirginIslandsBritish,
  keyVirginIslandsUs,
  keyVietNam,
  keyVanuatu,
  keyWallisFutuna,
  keySamoa,
  keyKosovo,
  keyYemen,
  keyMayotte,
  keySouthAfrica,
  keyZambia,
  keyZimbabwe,
  ];

  static List<String> getLanguageByCountryIso({required String code}) {
    String receivedCode = code.toLowerCase();

    if (receivedCode == keyAndoraIso) {
      return [keyCatalan];
    } else if (receivedCode == keyUnitedArabEmirates) {
      return [keyArabic];
    } else if (receivedCode == keyAfghanistan) {
      return [keyPashto, "fa"];
    } else if (receivedCode == keyAntiguaAndBarbuda) {
      return [keyEnglish];
    } else if (receivedCode == keyAnguilla) {
      return [keyEnglish];
    } else if (receivedCode == keyAlbania) {
      return [keyAlbanian];
    } else if (receivedCode == keyArmenia) {
      return [keyArmenian];
    } else if (receivedCode == keyAngola) {
      return [keyPortuguese];
    } else if (receivedCode == keyAntarctica) {
      return [keyEnglish];
    } else if (receivedCode == keyArgentina) {
      return [keySpanish];
    } else if (receivedCode == keyAmericanSamoa) {
      return [keySamoan, keyEnglish];
    } else if (receivedCode == keyAustria) {
      return [keyGerman];
    } else if (receivedCode == keyAustralia) {
      return [keyEnglish];
    } else if (receivedCode == keyAruba) {
      return ["pap", keyDutch];
    } else if (receivedCode == keyAlandIslands) {
      return [keySwedish];
    } else if (receivedCode == keyAzerbaijan) {
      return [keyAzerbaijani];
    } else if (receivedCode == keyBosniaAndHerzegovina) {
      return [keyBosnian, keyCroatian, keySerbian];
    } else if (receivedCode == keyBarbados) {
      return [keyEnglish];
    } else if (receivedCode == keyBangladesh) {
      return [keyBengali];
    } else if (receivedCode == keyBelgium) {
      return [keyDutch, keyFrench, keyGerman];
    } else if (receivedCode == keyBurkinaFaso) {
      return [keyFrench];
    } else if (receivedCode == keyBulgaria) {
      return [keyBulgarian];
    } else if (receivedCode == keyBahrain) {
      return [keyArabic];
    } else if (receivedCode == keyBurundi) {
      return [keyRundi, keyFrench];
    } else if (receivedCode == keyBenin) {
      return [keyFrench];
    } else if (receivedCode == keySaintBarthelemy) {
      return [keyFrench];
    } else if (receivedCode == keyBermuda) {
      return [keyEnglish];
    } else if (receivedCode == keyBruneiDarussalam) {
      return [keyMalay];
    } else if (receivedCode == keyBolivia) {
      return [keySpanish, keyAymara, keyQuechua];
    } else if (receivedCode == keyBonaireSintEustatiusAndSaba) {
      return [keyDutch, "pap", keyEnglish];
    } else if (receivedCode == keyBrazil) {
      return [keyPortuguese];
    } else if (receivedCode == keyBahamas) {
      return [keyEnglish];
    } else if (receivedCode == keyBhutan) {
      return [keyDzongkha];
    } else if (receivedCode == keyBotswana) {
      return [keyEnglish, keyTswana];
    } else if (receivedCode == keyBelarus) {
      return [keyBelarusian, keyRussian];
    } else if (receivedCode == keyBelize) {
      return [keyEnglish];
    } else if (receivedCode == keyCanada) {
      return [keyEnglish, keyFrench];
    } else if (receivedCode == keyCocosIslands) {
      return [keyEnglish, keyMalay];
    } else if (receivedCode == keyCongoDemocraticRepublic) {
      return [keyFrench];
    } else if (receivedCode == keyCentralAfricanRepublic) {
      return [keyFrench, keySango];
    } else if (receivedCode == keyCongo) {
      return [keyFrench];
    } else if (receivedCode == keySwitzerland) {
      return [keyGerman, keyFrench, keyItalian, keyRomansh];
    } else if (receivedCode == keyCoteDIvoire) {
      return [keyFrench];
    } else if (receivedCode == keyCookIslands) {
      return [keyEnglish, "rar"];
    } else if (receivedCode == keyChile) {
      return [keySpanish];
    } else if (receivedCode == keyCameroon) {
      return [keyEnglish, keyFrench];
    } else if (receivedCode == keyChina) {
      return [keyChinese];
    } else if (receivedCode == keyColombia) {
      return [keySpanish];
    } else if (receivedCode == keyCostaRica) {
      return [keySpanish];
    } else if (receivedCode == keyCuba) {
      return [keySpanish];
    } else if (receivedCode == keyCaboVerde) {
      return [keyPortuguese, "kea"];
    } else if (receivedCode == keyCuracao) {
      return [keyDutch, "pap", keyEnglish];
    } else if (receivedCode == keyChristmasIsland) {
      return [keyEnglish];
    } else if (receivedCode == keyCyprus) {
      return [keyGreek, keyTurkish];
    } else if (receivedCode == keyCzechia) {
      return [keyCzech];
    } else if (receivedCode == keyGermany) {
      return [keyGerman];
    } else if (receivedCode == keyDjibouti) {
      return [keyFrench, keyArabic];
    } else if (receivedCode == keyDenmark) {
      return [keyDanish];
    } else if (receivedCode == keyDominica) {
      return [keyEnglish];
    } else if (receivedCode == keyDominicanRepublic) {
      return [keySpanish];
    } else if (receivedCode == keyAlgeria) {
      return [keyArabic, "ber"];
    } else if (receivedCode == keyEcuador) {
      return [keySpanish];
    } else if (receivedCode == keyEstonia) {
      return [keyEstonian];
    } else if (receivedCode == keyEgypt) {
      return [keyArabic];
    } else if (receivedCode == keyWesternSahara) {
      return [keyArabic];
    } else if (receivedCode == keyEritrea) {
      return [keyTigrinya, keyArabic, keyEnglish];
    } else if (receivedCode == keySpain) {
      return [keySpanish];
    } else if (receivedCode == keyEthiopia) {
      return [keyAmharic];
    } else if (receivedCode == keyFinland) {
      return [keyFinnish, keySwedish];
    } else if (receivedCode == keyFiji) {
      return [keyEnglish, keyFijian, "hif"];
    } else if (receivedCode == keyFalklandIslands) {
      return [keyEnglish];
    } else if (receivedCode == keyMicronesia) {
      return [keyEnglish];
    } else if (receivedCode == keyFaroeIslands) {
      return [keyFaroese, keyDanish];
    } else if (receivedCode == keyGabon) {
      return [keyFrench];
    } else if (receivedCode == keyUnitedKingdom) {
      return [keyEnglish];
    } else if (receivedCode == keyEngland) {
      return [keyEnglish];
    } else if (receivedCode == keyNorthernIreland) {
      return [keyEnglish, keyIrish, "sco"];
    } else if (receivedCode == keyScotLand) {
      return [keyEnglish, "gd", "sco"];
    } else if (receivedCode == keyWales) {
      return [keyEnglish, keyWelsh];
    } else if (receivedCode == keyGrenada) {
      return [keyEnglish];
    } else if (receivedCode == keyGeorgia) {
      return [keyGeorgian];
    } else if (receivedCode == keyFrenchGuiana) {
      return [keyFrench];
    } else if (receivedCode == keyGuernsey) {
      return [keyEnglish];
    } else if (receivedCode == keyGhana) {
      return [keyEnglish];
    } else if (receivedCode == keyGibraltar) {
      return [keyEnglish];
    } else if (receivedCode == keyGreenland) {
      return [keyKalaallisut, keyDanish];
    } else if (receivedCode == keyGambia) {
      return [keyEnglish];
    } else if (receivedCode == keyGuinea) {
      return [keyFrench];
    } else if (receivedCode == keyGuadeloupe) {
      return [keyFrench];
    } else if (receivedCode == keyEquatorialGuinea) {
      return [keySpanish, keyFrench, keyPortuguese];
    } else if (receivedCode == keyGreece) {
      return [keyGreek];
    } else if (receivedCode == keySouthGeorgia) {
      return [keyEnglish];
    } else if (receivedCode == keyGuatemala) {
      return [keySpanish];
    } else if (receivedCode == keyGuam) {
      return [keyEnglish, keyChamorro];
    } else if (receivedCode == keyGuineaBissau) {
      return [keyPortuguese, "pov"];
    } else if (receivedCode == keyGuyana) {
      return [keyEnglish];
    } else if (receivedCode == keyHongKong) {
      return [keyChinese, keyEnglish];
    } else if (receivedCode == keyHeardIslandMcDonaldIslands) {
      return [keyEnglish];
    } else if (receivedCode == keyHonduras) {
      return [keySpanish];
    } else if (receivedCode == keyCroatia) {
      return [keyCroatian];
    } else if (receivedCode == keyHaiti) {
      return [keyFrench, keyHaitian];
    } else if (receivedCode == keyHungary) {
      return [keyHungarian];
    } else if (receivedCode == keyIndonesia) {
      return [keyIndonesian];
    } else if (receivedCode == keyIreland) {
      return [keyIrish, keyEnglish];
    } else if (receivedCode == keyIsrael) {
      return [keyHebrew, keyArabic];
    } else if (receivedCode == keyIsleOfMan) {
      return [keyEnglish, keyManx];
    } else if (receivedCode == keyIndia) {
      return [keyHindi, keyEnglish];
    } else if (receivedCode == keyBritishIndianOceanTerritory) {
      return [keyEnglish];
    } else if (receivedCode == keyIraq) {
      return [keyArabic, keyKurdish];
    } else if (receivedCode == keyIran) {
      return ["fa"];
    } else if (receivedCode == keyIceland) {
      return [keyIcelandic];
    } else if (receivedCode == keyItaly) {
      return [keyItalian];
    } else if (receivedCode == keyJersey) {
      return [keyEnglish, keyFrench];
    } else if (receivedCode == keyJamaica) {
      return [keyEnglish];
    } else if (receivedCode == keyJordan) {
      return [keyArabic];
    } else if (receivedCode == keyJapan) {
      return [keyJapanese];
    } else if (receivedCode == keyKenya) {
      return [keyEnglish, keySwahili];
    } else if (receivedCode == keyKyrgyzstan) {
      return [keyKirghiz, keyRussian];
    } else if (receivedCode == keyCambodia) {
      return [keyKhmer];
    } else if (receivedCode == keyKiribati) {
      return [keyEnglish, "gil"];
    } else if (receivedCode == keyComoros) {
      return ["zdj", keyArabic, keyFrench];
    } else if (receivedCode == keySaintKittsNevis) {
      return [keyEnglish];
    } else if (receivedCode == keyNorthKorea) {
      return [keyKorean];
    } else if (receivedCode == keySouthKorea) {
      return [keyKorean];
    } else if (receivedCode == keyKuwait) {
      return [keyArabic];
    } else if (receivedCode == keyCaymanIslands) {
      return [keyEnglish];
    } else if (receivedCode == keyKazakhstan) {
      return [keyKazakh, keyRussian];
    } else if (receivedCode == keyLaos) {
      return [keyLao];
    } else if (receivedCode == keyLebanon) {
      return [keyArabic];
    } else if (receivedCode == keySaintLucia) {
      return [keyEnglish];
    } else if (receivedCode == keyLiechtenstein) {
      return [keyGerman];
    } else if (receivedCode == keySriLanka) {
      return [keySinhalese, keyTamil];
    } else if (receivedCode == keyLiberia) {
      return [keyEnglish];
    } else if (receivedCode == keyLesotho) {
      return [keySotho, keyEnglish];
    } else if (receivedCode == keyLithuania) {
      return [keyLithuanian];
    } else if (receivedCode == keyLuxembourg) {
      return [keyLuxembourgish, keyFrench, keyGerman];
    } else if (receivedCode == keyLatvia) {
      return [keyLatvian];
    } else if (receivedCode == keyLibya) {
      return [keyArabic];
    } else if (receivedCode == keyMorocco) {
      return [keyArabic, "ber"];
    } else if (receivedCode == keyMonaco) {
      return [keyFrench];
    } else if (receivedCode == keyMoldova) {
      return [keyRomanian];
    } else if (receivedCode == keyMontenegro) {
      return [keySerbian];
    } else if (receivedCode == keySaintMartinFrench) {
      return [keyFrench];
    } else if (receivedCode == keyMadagascar) {
      return [keyMalagasy, keyFrench];
    } else if (receivedCode == keyMarshallIslands) {
      return [keyEnglish, keyMarshallese];
    } else if (receivedCode == keyNorthMacedonia) {
      return [keyMacedonian];
    } else if (receivedCode == keyMali) {
      return [keyFrench];
    } else if (receivedCode == keyMyanmar) {
      return [keyBurmese];
    } else if (receivedCode == keyMongolia) {
      return [keyMongolian];
    } else if (receivedCode == keyMacao) {
      return [keyChinese, keyPortuguese];
    } else if (receivedCode == keyNorthernMarianaIslands) {
      return [keyEnglish, keyChamorro, "cal"];
    } else if (receivedCode == keyMartinique) {
      return [keyFrench];
    } else if (receivedCode == keyMauritania) {
      return [keyArabic];
    } else if (receivedCode == keyMontserrat) {
      return [keyEnglish];
    } else if (receivedCode == keyMalta) {
      return [keyMaltese, keyEnglish];
    } else if (receivedCode == keyMauritius) {
      return [keyEnglish, keyFrench];
    } else if (receivedCode == keyMaldives) {
      return [keyDivehi];
    } else if (receivedCode == keyMalawi) {
      return [keyEnglish, keyChichewa];
    } else if (receivedCode == keyMexico) {
      return [keySpanish];
    } else if (receivedCode == keyMalaysia) {
      return [keyMalay];
    } else if (receivedCode == keyMozambique) {
      return [keyPortuguese];
    } else if (receivedCode == keyNamibia) {
      return [keyEnglish];
    } else if (receivedCode == keyNewCaledonia) {
      return [keyFrench];
    } else if (receivedCode == keyNiger) {
      return [keyFrench];
    } else if (receivedCode == keyNorfolkIsland) {
      return [keyEnglish, "pih"];
    } else if (receivedCode == keyNigeria) {
      return [keyEnglish];
    } else if (receivedCode == keyNicaragua) {
      return [keySpanish];
    } else if (receivedCode == keyNetherlands) {
      return [keyDutch];
    } else if (receivedCode == keyNorway) {
      return [keyNorwegianBokmal, keyNorwegianNynorsk];
    } else if (receivedCode == keyNepal) {
      return [keyNepali];
    } else if (receivedCode == keyNauru) {
      return [keyNauruIso, keyEnglish];
    } else if (receivedCode == keyNiue) {
      return ["niu", keyEnglish];
    } else if (receivedCode == keyNewZealand) {
      return [keyEnglish, keyMaori];
    } else if (receivedCode == keyOman) {
      return [keyArabic];
    } else if (receivedCode == keyPanama) {
      return [keySpanish];
    } else if (receivedCode == keyPeru) {
      return [keySpanish, keyQuechua, keyAymara];
    } else if (receivedCode == keyFrenchPolynesia) {
      return [keyFrench];
    } else if (receivedCode == keyPapuaNewGuinea) {
      return [keyEnglish, "tpi", keyHiriMotu];
    } else if (receivedCode == keyPhilippines) {
      return ["fil", keyEnglish];
    } else if (receivedCode == keyPakistan) {
      return [keyUrdu, keyEnglish];
    } else if (receivedCode == keyPoland) {
      return [keyPolish];
    } else if (receivedCode == keySaintPierreMiquelon) {
      return [keyFrench];
    } else if (receivedCode == keyPitcairn) {
      return [keyEnglish, "pih"];
    } else if (receivedCode == keyPuertoRico) {
      return [keySpanish, keyEnglish];
    } else if (receivedCode == keyPalestineState) {
      return [keyArabic];
    } else if (receivedCode == keyPortugal) {
      return [keyPortuguese];
    } else if (receivedCode == keyPalau) {
      return [keyEnglish, "pau"];
    } else if (receivedCode == keyParaguay) {
      return [keySpanish, keyGuarani];
    } else if (receivedCode == keyQatar) {
      return [keyArabic];
    } else if (receivedCode == keyReunion) {
      return [keyFrench];
    } else if (receivedCode == keyRomania) {
      return [keyRomanian];
    } else if (receivedCode == keySerbia) {
      return [keySerbian];
    } else if (receivedCode == keyRussianFederation) {
    return [keyRussian];
    } else if (receivedCode == keyRwanda) {
    return [keyKinyarwanda, keyFrench, keyEnglish];
    } else if (receivedCode == keySaudiArabia) {
    return [keyArabic];
    }else if(receivedCode == keySolomonIslands) {
    return [keyEnglish];
    }else if(receivedCode == keySeychelles) {
    return ["crs", keyFrench, keyEnglish];
    }else if(receivedCode == keySudan) {
    return [keyArabic, keyEnglish];
    }else if(receivedCode == keySweden) {
    return [keySwedish];
    }else if(receivedCode == keySingapore) {
    return [keyEnglish, keyMalay, keyChinese];
    }else if(receivedCode == keySaintHelena) {
    return [keyTamil];
    }else if(receivedCode == keySlovenia) {
    return [keySlovenian];
    }else if(receivedCode == keySlovakia) {
    return [keySlovak];
    }else if(receivedCode == keySierraLeone) {
    return [keyEnglish];
    }else if(receivedCode == keySanMarino) {
    return [keyItalian];
    }else if(receivedCode == keySenegal) {
    return [keyFrench];
    }else if(receivedCode == keySomalia) {
    return [keySomali, keyArabic];
    }else if(receivedCode == keySuriname) {
    return [keyDutch];
    }else if(receivedCode == keySouthSudan) {
    return [keyEnglish];
    }else if(receivedCode == keySaoTomePrincipe) {
    return [keyPortuguese];
    }else if(receivedCode == keyElSalvador) {
    return [keySpanish];
    }else if(receivedCode == keySintMaarten) {
    return [keyDutch, keyEnglish];
    }else if(receivedCode == keySyrianArabRepublic) {
    return [keyArabic];
    }else if(receivedCode == keyEswatini) {
    return [keyEnglish, keySwati];
    }else if(receivedCode == keyTurksCaicosIslands) {
    return [keyEnglish];
    }else if(receivedCode == keyChad) {
    return [keyFrench, keyArabic];
    }else if(receivedCode == keyFrenchSouthernTerritories) {
    return [keyFrench];
    }else if(receivedCode == keyTogo) {
    return [keyFrench];
    }else if(receivedCode == keyThailand) {
    return [keyThai];
    }else if(receivedCode == keyTajikistan) {
    return [keyTajik];
    }else if(receivedCode == keyTokelau) {
    return ["tkl", keyEnglish];
    }else if(receivedCode == keyTimorLeste) {
    return [keyPortuguese, "tet"];
    }else if(receivedCode == keyTurkmenistan) {
    return [keyTurkmen];
    }else if(receivedCode == keyTunisia) {
    return [keyArabic];
    }else if(receivedCode == keyTonga) {
    return [keyTongaIso, keyEnglish];
    }else if(receivedCode == keyTurkey) {
    return [keyTurkish];
    }else if(receivedCode == keyTrinidadTobago) {
    return [keyEnglish];
    }else if(receivedCode == keyTuvalu) {
    return ["tvl", keyEnglish];
    }else if(receivedCode == keyTaiwan) {
    return [keyChinese];
    }else if(receivedCode == keyTanzania) {
    return [keySwahili, keyEnglish];
    }else if(receivedCode == keyUkraine) {
    return [keyUkrainian];
    }else if(receivedCode == keyUganda) {
    return [keyEnglish, keySwahili];
    }else if(receivedCode == keyUnitedStatesAmerica) {
    return [keyEnglish];
    }else if(receivedCode == keyUruguay) {
    return [keySpanish];
    }else if(receivedCode == keyUzbekistan) {
    return [keyUzbek];
    }else if(receivedCode == keyHolySee) {
    return [keyItalian, keyLatin];
    }else if(receivedCode == keySaintVincentGrenadines) {
    return [keyEnglish];
    }else if(receivedCode == keyVenezuela) {
    return [keySpanish];
    }else if(receivedCode == keyVirginIslandsBritish) {
    return [keyEnglish];
    }else if(receivedCode == keyVirginIslandsUs) {
    return [keyEnglish];
    }else if(receivedCode == keyVietNam) {
    return [keyVietnamese];
    }else if(receivedCode == keyVanuatu) {
    return [keyBislama, keyFrench, keyEnglish];
    }else if(receivedCode == keyWallisFutuna) {
    return [keyFrench];
    }else if(receivedCode == keySamoa) {
    return [keySamoan, keyEnglish];
    }else if(receivedCode == keyKosovo) {
    return [keyAlbanian, keySerbian];
    }else if(receivedCode == keyYemen) {
    return [keyArabic];
    }else if(receivedCode == keyMayotte) {
    return [keyFrench];
    }else if(receivedCode == keySouthAfrica) {
    return [keyEnglish, keyZulu, keyXhosa, keyAfrikaans, "nso", keyTswana, keySotho, keyTsonga, keySwati, keyVenda, "nr"];
    }else if(receivedCode == keyZambia) {
    return [keyEnglish];
    }else if(receivedCode == keyZimbabwe) {
    return [keyEnglish, keyShona, "nr"];
    }else if(receivedCode == keyFrance) {
    return [keyFrench];
    }

    return [];
  }

  static String getLanguageNameByCode({required String code}) {
    String receivedCode = code.toLowerCase();

    if (receivedCode == keyAbkhazian) {
      return "languages_iso.ab_".tr();
    } else if (receivedCode == keyAfar) {
      return "languages_iso.aa_".tr();
    } else if (receivedCode == keyAfrikaans) {
      return "languages_iso.af_".tr();
    } else if (receivedCode == keyAkan) {
      return "languages_iso.ak_".tr();
    } else if (receivedCode == keyAlbanian) {
      return "languages_iso.sq_".tr();
    } else if (receivedCode == keyAmharic) {
      return "languages_iso.am_".tr();
    } else if (receivedCode == keyArabic) {
      return "languages_iso.ar_".tr();
    } else if (receivedCode == keyAragonese) {
      return "languages_iso.an_".tr();
    } else if (receivedCode == keyArmenian) {
      return "languages_iso.hy_".tr();
    } else if (receivedCode == keyAssamese) {
      return "languages_iso.as_".tr();
    } else if (receivedCode == keyAvaric) {
      return "languages_iso.av_".tr();
    } else if (receivedCode == keyAvestan) {
      return "languages_iso.ae_".tr();
    } else if (receivedCode == keyAymara) {
      return "languages_iso.ay_".tr();
    } else if (receivedCode == keyAzerbaijani) {
      return "languages_iso.az_".tr();
    } else if (receivedCode == keyBambara) {
      return "languages_iso.bm_".tr();
    } else if (receivedCode == keyBashkir) {
      return "languages_iso.ba_".tr();
    } else if (receivedCode == keyBasque) {
      return "languages_iso.eu_".tr();
    } else if (receivedCode == keyBelarusian) {
      return "languages_iso.be_".tr();
    } else if (receivedCode == keyBengali) {
      return "languages_iso.bn_".tr();
    } else if (receivedCode == keyBislama) {
      return "languages_iso.bi_".tr();
    } else if (receivedCode == keyBosnian) {
      return "languages_iso.bs_".tr();
    } else if (receivedCode == keyBreton) {
      return "languages_iso.br_".tr();
    } else if (receivedCode == keyBulgarian) {
      return "languages_iso.bg_".tr();
    } else if (receivedCode == keyBurmese) {
      return "languages_iso.my_".tr();
    } else if (receivedCode == keyCatalan) {
      return "languages_iso.ca_".tr();
    } else if (receivedCode == keyChamorro) {
      return "languages_iso.ch_".tr();
    } else if (receivedCode == keyChechen) {
      return "languages_iso.ce_".tr();
    } else if (receivedCode == keyChichewa) {
      return "languages_iso.ny_".tr();
    } else if (receivedCode == keyChinese) {
      return "languages_iso.zh_".tr();
    } else if (receivedCode == keyChuvash) {
      return "languages_iso.cv_".tr();
    } else if (receivedCode == keyCornish) {
      return "languages_iso.kw_".tr();
    } else if (receivedCode == keyCorsican) {
      return "languages_iso.co_".tr();
    } else if (receivedCode == keyCree) {
      return "languages_iso.cr_".tr();
    } else if (receivedCode == keyCroatian) {
      return "languages_iso.hr_".tr();
    } else if (receivedCode == keyCzech) {
      return "languages_iso.cs_".tr();
    } else if (receivedCode == keyDanish) {
      return "languages_iso.da_".tr();
    } else if (receivedCode == keyDivehi) {
      return "languages_iso.dv_".tr();
    } else if (receivedCode == keyDutch) {
      return "languages_iso.nl_".tr();
    } else if (receivedCode == keyDzongkha) {
      return "languages_iso.dz_".tr();
    } else if (receivedCode == keyEnglish) {
      return "languages_iso.en_".tr();
    } else if (receivedCode == keyEsperanto) {
      return "languages_iso.eo_".tr();
    } else if (receivedCode == keyEstonian) {
      return "languages_iso.et_".tr();
    } else if (receivedCode == keyEwe) {
      return "languages_iso.ee_".tr();
    } else if (receivedCode == keyFaroese) {
      return "languages_iso.fo_".tr();
    } else if (receivedCode == keyFijian) {
      return "languages_iso.fj_".tr();
    } else if (receivedCode == keyFinnish) {
      return "languages_iso.fi_".tr();
    } else if (receivedCode == keyFrench) {
      return "languages_iso.fr_".tr();
    } else if (receivedCode == keyFulah) {
      return "languages_iso.ff_".tr();
    } else if (receivedCode == keyGalician) {
      return "languages_iso.gl_".tr();
    } else if (receivedCode == keyGeorgian) {
      return "languages_iso.ka_".tr();
    } else if (receivedCode == keyGerman) {
      return "languages_iso.de_".tr();
    } else if (receivedCode == keyGreek) {
      return "languages_iso.el_".tr();
    } else if (receivedCode == keyGuarani) {
      return "languages_iso.gn_".tr();
    } else if (receivedCode == keyGujarati) {
      return "languages_iso.gu_".tr();
    } else if (receivedCode == keyHaitian) {
      return "languages_iso.ht_".tr();
    } else if (receivedCode == keyHausa) {
      return "languages_iso.ha_".tr();
    } else if (receivedCode == keyHebrew) {
      return "languages_iso.he_".tr();
    } else if (receivedCode == keyHerero) {
      return "languages_iso.hz_".tr();
    } else if (receivedCode == keyHindi) {
      return "languages_iso.hi_".tr();
    } else if (receivedCode == keyHiriMotu) {
      return "languages_iso.ho_".tr();
    } else if (receivedCode == keyHungarian) {
      return "languages_iso.hu_".tr();
    } else if (receivedCode == keyIcelandic) {
      return "languages_iso.is_".tr();
    } else if (receivedCode == keyIdo) {
      return "languages_iso.io_".tr();
    } else if (receivedCode == keyIgbo) {
      return "languages_iso.ig_".tr();
    } else if (receivedCode == keyIndonesian) {
      return "languages_iso.id_".tr();
    } else if (receivedCode == keyInterlingua) {
      return "languages_iso.ia_".tr();
    } else if (receivedCode == keyInterlingue) {
      return "languages_iso.ie_".tr();
    } else if (receivedCode == keyInuktitut) {
      return "languages_iso.iu_".tr();
    } else if (receivedCode == keyInupiaq) {
      return "languages_iso.ik_".tr();
    } else if (receivedCode == keyIrish) {
      return "languages_iso.ga_".tr();
    } else if (receivedCode == keyItalian) {
      return "languages_iso.it_".tr();
    } else if (receivedCode == keyJapanese) {
      return "languages_iso.ja_".tr();
    } else if (receivedCode == keyJavanese) {
      return "languages_iso.jv_".tr();
    } else if (receivedCode == keyKalaallisut) {
      return "languages_iso.kl_".tr();
    } else if (receivedCode == keyKannada) {
      return "languages_iso.kn_".tr();
    } else if (receivedCode == keyKanuri) {
      return "languages_iso.kr_".tr();
    } else if (receivedCode == keyKashmiri) {
      return "languages_iso.ks_".tr();
    } else if (receivedCode == keyKazakh) {
      return "languages_iso.kk_".tr();
    } else if (receivedCode == keyKhmer) {
      return "languages_iso.km_".tr();
    } else if (receivedCode == keyKikuyu) {
      return "languages_iso.ki_".tr();
    } else if (receivedCode == keyKinyarwanda) {
      return "languages_iso.rw_".tr();
    } else if (receivedCode == keyKirghiz) {
      return "languages_iso.ky_".tr();
    } else if (receivedCode == keyKomi) {
      return "languages_iso.kv_".tr();
    } else if (receivedCode == keyKongo) {
      return "languages_iso.kg_".tr();
    } else if (receivedCode == keyKorean) {
      return "languages_iso.ko_".tr();
    } else if (receivedCode == keyKuanyama) {
      return "languages_iso.kj_".tr();
    } else if (receivedCode == keyKurdish) {
      return "languages_iso.ku_".tr();
    } else if (receivedCode == keyLao) {
      return "languages_iso.lo_".tr();
    } else if (receivedCode == keyLatin) {
      return "languages_iso.la_".tr();
    } else if (receivedCode == keyLatvian) {
      return "languages_iso.lv_".tr();
    } else if (receivedCode == keyLimburgan) {
      return "languages_iso.li_".tr();
    } else if (receivedCode == keyLingala) {
      return "languages_iso.ln_".tr();
    } else if (receivedCode == keyLithuanian) {
      return "languages_iso.lt_".tr();
    } else if (receivedCode == keyLubaKatanga) {
      return "languages_iso.lu_".tr();
    } else if (receivedCode == keyLuxembourgish) {
      return "languages_iso.lb_".tr();
    } else if (receivedCode == keyMacedonian) {
      return "languages_iso.mk_".tr();
    } else if (receivedCode == keyMalagasy) {
      return "languages_iso.mg_".tr();
    } else if (receivedCode == keyMalay) {
      return "languages_iso.ms_".tr();
    } else if (receivedCode == keyMalayalam) {
      return "languages_iso.ml_".tr();
    } else if (receivedCode == keyMaltese) {
      return "languages_iso.mt_".tr();
    } else if (receivedCode == keyManx) {
      return "languages_iso.gv_".tr();
    } else if (receivedCode == keyMaori) {
      return "languages_iso.mi_".tr();
    } else if (receivedCode == keyMarathi) {
      return "languages_iso.mr_".tr();
    } else if (receivedCode == keyMarshallese) {
      return "languages_iso.mh_".tr();
    } else if (receivedCode == keyMongolian) {
      return "languages_iso.mn_".tr();
    } else if (receivedCode == keyNauruIso) {
      return "languages_iso.na_".tr();
    } else if (receivedCode == keyNavajo) {
      return "languages_iso.nv_".tr();
    } else if (receivedCode == keyNdonga) {
      return "languages_iso.ng_".tr();
    } else if (receivedCode == keyNepali) {
      return "languages_iso.ne_".tr();
    } else if (receivedCode == keyNorthNdebele) {
      return "languages_iso.nd_".tr();
    } else if (receivedCode == keyNorthernSami) {
      return "languages_iso.se_".tr();
    } else if (receivedCode == keyNorwegian) {
      return "languages_iso.no_".tr();
    } else if (receivedCode == keyNorwegianBokmal) {
      return "languages_iso.nb_".tr();
    } else if (receivedCode == keyNorwegianNynorsk) {
      return "languages_iso.nn_".tr();
    } else if (receivedCode == keyOccitan) {
      return "languages_iso.oc_".tr();
    } else if (receivedCode == keyOjibwe) {
      return "languages_iso.oj_".tr();
    } else if (receivedCode == keyOromo) {
      return "languages_iso.om_".tr();
    }else if (receivedCode == keyOssetian) {
      return "languages_iso.os_".tr();
    } else if (receivedCode == keyPanjabi) {
      return "languages_iso.pa_".tr();
    } else if (receivedCode == keyPali) {
      return "languages_iso.pi_".tr();
    } else if (receivedCode == keyPashto) {
      return "languages_iso.ps_".tr();
    } else if (receivedCode == keyPolish) {
      return "languages_iso.pl_".tr();
    } else if (receivedCode == keyPortuguese) {
      return "languages_iso.pt_".tr();
    } else if (receivedCode == keyQuechua) {
      return "languages_iso.qu_".tr();
    } else if (receivedCode == keyRomansh) {
      return "languages_iso.rm_".tr();
    } else if (receivedCode == keyRundi) {
      return "languages_iso.rn_".tr();
    } else if (receivedCode == keyRomanian) {
      return "languages_iso.ro_".tr();
    } else if (receivedCode == keyRussian) {
      return "languages_iso.ru_".tr();
    } else if (receivedCode == keySamoan) {
      return "languages_iso.sm_".tr();
    } else if (receivedCode == keySango) {
      return "languages_iso.sg_".tr();
    } else if (receivedCode == keySanskrit) {
      return "languages_iso.sa_".tr();
    } else if (receivedCode == keySerbian) {
      return "languages_iso.sr_".tr();
    } else if (receivedCode == keyShona) {
      return "languages_iso.sn_".tr();
    } else if (receivedCode == keySindhi) {
      return "languages_iso.sd_".tr();
    } else if (receivedCode == keySinhalese) {
      return "languages_iso.si_".tr();
    } else if (receivedCode == keySlovak) {
      return "languages_iso.sk_".tr();
    } else if (receivedCode == keySlovenian) {
      return "languages_iso.sl_".tr();
    } else if (receivedCode == keySomali) {
      return "languages_iso.so_".tr();
    } else if (receivedCode == keySotho) {
      return "languages_iso.st_".tr();
    } else if (receivedCode == keySpanish) {
      return "languages_iso.es_".tr();
    } else if (receivedCode == keySundanese) {
      return "languages_iso.su_".tr();
    } else if (receivedCode == keySwahili) {
      return "languages_iso.sw_".tr();
    } else if (receivedCode == keySwati) {
      return "languages_iso.ss_".tr();
    } else if (receivedCode == keySwedish) {
      return "languages_iso.sv_".tr();
    } else if (receivedCode == keyTagalog) {
      return "languages_iso.tl_".tr();
    } else if (receivedCode == keyTahitian) {
      return "languages_iso.ty_".tr();
    } else if (receivedCode == keyTajik) {
      return "languages_iso.tg_".tr();
    } else if (receivedCode == keyTamil) {
      return "languages_iso.ta_".tr();
    } else if (receivedCode == keyTatar) {
      return "languages_iso.tt_".tr();
    } else if (receivedCode == keyTelugu) {
      return "languages_iso.te_".tr();
    } else if (receivedCode == keyThai) {
      return "languages_iso.th_".tr();
    } else if (receivedCode == keyTibetan) {
      return "languages_iso.bo_".tr();
    } else if (receivedCode == keyTigrinya) {
      return "languages_iso.ti_".tr();
    } else if (receivedCode == keyTongaIso) {
      return "languages_iso.to_".tr();
    } else if (receivedCode == keyTsonga) {
      return "languages_iso.ts_".tr();
    } else if (receivedCode == keyTswana) {
      return "languages_iso.tn_".tr();
    } else if (receivedCode == keyTurkish) {
      return "languages_iso.tr_".tr();
    } else if (receivedCode == keyTurkmen) {
      return "languages_iso.tk_".tr();
    } else if (receivedCode == keyTwi) {
      return "languages_iso.tw_".tr();
    } else if (receivedCode == keyUyghur) {
      return "languages_iso.ug_".tr();
    } else if (receivedCode == keyUkrainian) {
      return "languages_iso.uk_".tr();
    } else if (receivedCode == keyUrdu) {
      return "languages_iso.ur_".tr();
    } else if (receivedCode == keyUzbek) {
      return "languages_iso.uz_".tr();
    } else if (receivedCode == keyVenda) {
      return "languages_iso.ve_".tr();
    } else if (receivedCode == keyVietnamese) {
      return "languages_iso.vi_".tr();
    } else if (receivedCode == keyVolapuk) {
      return "languages_iso.vo_".tr();
    } else if (receivedCode == keyWalloon) {
      return "languages_iso.wa_".tr();
    } else if (receivedCode == keyWelsh) {
      return "languages_iso.cy_".tr();
    } else if (receivedCode == keyWolof) {
      return "languages_iso.wo_".tr();
    } else if (receivedCode == keyXhosa) {
      return "languages_iso.xh_".tr();
    } else if (receivedCode == keyYiddish) {
      return "languages_iso.yi_".tr();
    } else if (receivedCode == keyYoruba) {
      return "languages_iso.yo_".tr();
    } else if (receivedCode == keyZhuang) {
      return "languages_iso.za_".tr();
    } else if (receivedCode == keyZulu) {
      return "languages_iso.zu_".tr();
    }

    return "";
  }

  static String getCountryFlag({required String code}) {
    String receivedCode = code.toLowerCase();

    if (receivedCode == keyAndoraIso) {
      return "assets/countries/ad.png";
    } else if (receivedCode == keyUnitedArabEmirates) {
      return "assets/countries/ae.png";
    } else if (receivedCode == keyAfghanistan) {
      return "assets/countries/af.png";
    } else if (receivedCode == keyAntiguaAndBarbuda) {
      return "assets/countries/ag.png";
    } else if (receivedCode == keyAnguilla) {
      return "assets/countries/ai.png";
    } else if (receivedCode == keyAlbania) {
      return "assets/countries/al.png";
    } else if (receivedCode == keyArmenia) {
      return "assets/countries/am.png";
    } else if (receivedCode == keyAngola) {
      return "assets/countries/ao.png";
    } else if (receivedCode == keyAntarctica) {
      return "assets/countries/aq.png";
    } else if (receivedCode == keyArgentina) {
      return "assets/countries/ar.png";
    } else if (receivedCode == keyAmericanSamoa) {
      return "assets/countries/as.png";
    } else if (receivedCode == keyAustria) {
      return "assets/countries/at.png";
    } else if (receivedCode == keyAustralia) {
      return "assets/countries/au.png";
    } else if (receivedCode == keyAruba) {
      return "assets/countries/aw.png";
    } else if (receivedCode == keyAlandIslands) {
      return "assets/countries/ax.png";
    } else if (receivedCode == keyAzerbaijan) {
      return "assets/countries/az.png";
    } else if (receivedCode == keyBosniaAndHerzegovina) {
      return "assets/countries/ba.png";
    } else if (receivedCode == keyBarbados) {
      return "assets/countries/bb.png";
    } else if (receivedCode == keyBangladesh) {
      return "assets/countries/bd.png";
    } else if (receivedCode == keyBelgium) {
      return "assets/countries/be.png";
    } else if (receivedCode == keyBurkinaFaso) {
      return "assets/countries/bf.png";
    } else if (receivedCode == keyBulgaria) {
      return "assets/countries/bg.png";
    } else if (receivedCode == keyBahrain) {
      return "assets/countries/bh.png";
    } else if (receivedCode == keyBurundi) {
      return "assets/countries/bi.png";
    } else if (receivedCode == keyBenin) {
      return "assets/countries/bj.png";
    } else if (receivedCode == keySaintBarthelemy) {
      return "assets/countries/bl.png";
    } else if (receivedCode == keyBermuda) {
      return "assets/countries/bm.png";
    } else if (receivedCode == keyBruneiDarussalam) {
      return "assets/countries/bn.png";
    } else if (receivedCode == keyBolivia) {
      return "assets/countries/bo.png";
    } else if (receivedCode == keyBonaireSintEustatiusAndSaba) {
      return "assets/countries/bq.png";
    } else if (receivedCode == keyBrazil) {
      return "assets/countries/br.png";
    } else if (receivedCode == keyBahamas) {
      return "assets/countries/bs.png";
    } else if (receivedCode == keyBhutan) {
      return "assets/countries/bt.png";
    } else if (receivedCode == keyBotswana) {
      return "assets/countries/bw.png";
    } else if (receivedCode == keyBelarus) {
      return "assets/countries/by.png";
    } else if (receivedCode == keyBelize) {
      return "assets/countries/bz.png";
    } else if (receivedCode == keyCanada) {
      return "assets/countries/ca.png";
    } else if (receivedCode == keyCocosIslands) {
      return "assets/countries/cc.png";
    } else if (receivedCode == keyCongoDemocraticRepublic) {
      return "assets/countries/cd.png";
    } else if (receivedCode == keyCentralAfricanRepublic) {
      return "assets/countries/cf.png";
    } else if (receivedCode == keyCongo) {
      return "assets/countries/cg.png";
    } else if (receivedCode == keySwitzerland) {
      return "assets/countries/ch.png";
    } else if (receivedCode == keyCoteDIvoire) {
      return "assets/countries/ci.png";
    } else if (receivedCode == keyCookIslands) {
      return "assets/countries/ck.png";
    } else if (receivedCode == keyChile) {
      return "assets/countries/cl.png";
    } else if (receivedCode == keyCameroon) {
      return "assets/countries/cm.png";
    } else if (receivedCode == keyChina) {
      return "assets/countries/cn.png";
    } else if (receivedCode == keyColombia) {
      return "assets/countries/co.png";
    } else if (receivedCode == keyCostaRica) {
      return "assets/countries/cr.png";
    } else if (receivedCode == keyCuba) {
      return "assets/countries/cu.png";
    } else if (receivedCode == keyCaboVerde) {
      return "assets/countries/cv.png";
    } else if (receivedCode == keyCuracao) {
      return "assets/countries/cw.png";
    } else if (receivedCode == keyChristmasIsland) {
      return "assets/countries/cx.png";
    } else if (receivedCode == keyCyprus) {
      return "assets/countries/cy.png";
    } else if (receivedCode == keyCzechia) {
      return "assets/countries/cz.png";
    } else if (receivedCode == keyGermany) {
      return "assets/countries/de.png";
    } else if (receivedCode == keyDjibouti) {
      return "assets/countries/dj.png";
    } else if (receivedCode == keyDenmark) {
      return "assets/countries/dk.png";
    } else if (receivedCode == keyDominica) {
      return "assets/countries/dm.png";
    } else if (receivedCode == keyDominicanRepublic) {
      return "assets/countries/do.png";
    } else if (receivedCode == keyAlgeria) {
      return "assets/countries/dz.png";
    } else if (receivedCode == keyEcuador) {
      return "assets/countries/ec.png";
    } else if (receivedCode == keyEstonia) {
      return "assets/countries/ee.png";
    } else if (receivedCode == keyEgypt) {
      return "assets/countries/eg.png";
    } else if (receivedCode == keyWesternSahara) {
      return "assets/countries/eh.png";
    } else if (receivedCode == keyEritrea) {
      return "assets/countries/er.png";
    } else if (receivedCode == keySpain) {
      return "assets/countries/es.png";
    } else if (receivedCode == keyEthiopia) {
      return "assets/countries/et.png";
    } else if (receivedCode == keyFinland) {
      return "assets/countries/fi.png";
    } else if (receivedCode == keyFiji) {
      return "assets/countries/fj.png";
    } else if (receivedCode == keyFalklandIslands) {
      return "assets/countries/fk.png";
    } else if (receivedCode == keyMicronesia) {
      return "assets/countries/fm.png";
    } else if (receivedCode == keyFaroeIslands) {
      return "assets/countries/fo.png";
    } else if (receivedCode == keyGabon) {
      return "assets/countries/ga.png";
    } else if (receivedCode == keyUnitedKingdom) {
      return "assets/countries/gb.png";
    } else if (receivedCode == keyEngland) {
      return "assets/countries/gb-eng.png";
    } else if (receivedCode == keyNorthernIreland) {
      return "assets/countries/gb-nir.png";
    } else if (receivedCode == keyScotLand) {
      return "assets/countries/gb-sct.png";
    } else if (receivedCode == keyWales) {
      return "assets/countries/gb-wls.png";
    } else if (receivedCode == keyGrenada) {
      return "assets/countries/gd.png";
    } else if (receivedCode == keyGeorgia) {
      return "assets/countries/ge.png";
    } else if (receivedCode == keyFrenchGuiana) {
      return "assets/countries/gf.png";
    } else if (receivedCode == keyGuernsey) {
      return "assets/countries/gg.png";
    } else if (receivedCode == keyGhana) {
      return "assets/countries/gh.png";
    } else if (receivedCode == keyGibraltar) {
      return "assets/countries/gi.png";
    } else if (receivedCode == keyGreenland) {
      return "assets/countries/gl.png";
    } else if (receivedCode == keyGambia) {
      return "assets/countries/gm.png";
    } else if (receivedCode == keyGuinea) {
      return "assets/countries/gn.png";
    } else if (receivedCode == keyGuadeloupe) {
      return "assets/countries/gp.png";
    } else if (receivedCode == keyEquatorialGuinea) {
      return "assets/countries/gq.png";
    } else if (receivedCode == keyGreece) {
      return "assets/countries/gr.png";
    } else if (receivedCode == keySouthGeorgia) {
      return "assets/countries/gs.png";
    } else if (receivedCode == keyGuatemala) {
      return "assets/countries/gt.png";
    } else if (receivedCode == keyGuam) {
      return "assets/countries/gu.png";
    } else if (receivedCode == keyGuineaBissau) {
      return "assets/countries/gw.png";
    } else if (receivedCode == keyGuyana) {
      return "assets/countries/gy.png";
    } else if (receivedCode == keyHongKong) {
      return "assets/countries/hk.png";
    } else if (receivedCode == keyHeardIslandMcDonaldIslands) {
      return "assets/countries/hm.png";
    } else if (receivedCode == keyHonduras) {
      return "assets/countries/hn.png";
    } else if (receivedCode == keyCroatia) {
      return "assets/countries/hr.png";
    } else if (receivedCode == keyHaiti) {
      return "assets/countries/ht.png";
    } else if (receivedCode == keyHungary) {
      return "assets/countries/hu.png";
    } else if (receivedCode == keyIndonesia) {
      return "assets/countries/id.png";
    } else if (receivedCode == keyIreland) {
      return "assets/countries/ie.png";
    } else if (receivedCode == keyIsrael) {
      return "assets/countries/il.png";
    } else if (receivedCode == keyIsleOfMan) {
      return "assets/countries/im.png";
    } else if (receivedCode == keyIndia) {
      return "assets/countries/in.png";
    } else if (receivedCode == keyBritishIndianOceanTerritory) {
      return "assets/countries/io.png";
    } else if (receivedCode == keyIraq) {
      return "assets/countries/iq.png";
    } else if (receivedCode == keyIran) {
      return "assets/countries/ir.png";
    } else if (receivedCode == keyIceland) {
      return "assets/countries/is.png";
    } else if (receivedCode == keyItaly) {
      return "assets/countries/it.png";
    } else if (receivedCode == keyJersey) {
      return "assets/countries/je.png";
    } else if (receivedCode == keyJamaica) {
      return "assets/countries/jm.png";
    } else if (receivedCode == keyJordan) {
      return "assets/countries/jo.png";
    } else if (receivedCode == keyJapan) {
      return "assets/countries/jp.png";
    } else if (receivedCode == keyKenya) {
      return "assets/countries/ke.png";
    } else if (receivedCode == keyKyrgyzstan) {
      return "assets/countries/kg.png";
    } else if (receivedCode == keyCambodia) {
      return "assets/countries/kh.png";
    } else if (receivedCode == keyKiribati) {
      return "assets/countries/ki.png";
    } else if (receivedCode == keyComoros) {
      return "assets/countries/km.png";
    } else if (receivedCode == keySaintKittsNevis) {
      return "assets/countries/kn.png";
    } else if (receivedCode == keyNorthKorea) {
      return "assets/countries/kp.png";
    } else if (receivedCode == keySouthKorea) {
      return "assets/countries/kr.png";
    } else if (receivedCode == keyKuwait) {
      return "assets/countries/kw.png";
    } else if (receivedCode == keyCaymanIslands) {
      return "assets/countries/ky.png";
    } else if (receivedCode == keyKazakhstan) {
      return "assets/countries/kz.png";
    } else if (receivedCode == keyLaos) {
      return "assets/countries/la.png";
    } else if (receivedCode == keyLebanon) {
      return "assets/countries/lb.png";
    } else if (receivedCode == keySaintLucia) {
      return "assets/countries/lc.png";
    } else if (receivedCode == keyLiechtenstein) {
      return "assets/countries/li.png";
    } else if (receivedCode == keySriLanka) {
      return "assets/countries/lk.png";
    } else if (receivedCode == keyLiberia) {
      return "assets/countries/lr.png";
    } else if (receivedCode == keyLesotho) {
      return "assets/countries/ls.png";
    } else if (receivedCode == keyLithuania) {
      return "assets/countries/lt.png";
    } else if (receivedCode == keyLuxembourg) {
      return "assets/countries/lu.png";
    } else if (receivedCode == keyLatvia) {
      return "assets/countries/lv.png";
    } else if (receivedCode == keyLibya) {
      return "assets/countries/ly.png";
    } else if (receivedCode == keyMorocco) {
      return "assets/countries/ma.png";
    } else if (receivedCode == keyMonaco) {
      return "assets/countries/mc.png";
    } else if (receivedCode == keyMoldova) {
      return "assets/countries/md.png";
    } else if (receivedCode == keyMontenegro) {
      return "assets/countries/me.png";
    } else if (receivedCode == keySaintMartinFrench) {
      return "assets/countries/mf.png";
    } else if (receivedCode == keyMadagascar) {
      return "assets/countries/mg.png";
    } else if (receivedCode == keyMarshallIslands) {
      return "assets/countries/mh.png";
    } else if (receivedCode == keyNorthMacedonia) {
      return "assets/countries/mk.png";
    } else if (receivedCode == keyMali) {
      return "assets/countries/ml.png";
    } else if (receivedCode == keyMyanmar) {
      return "assets/countries/mm.png";
    } else if (receivedCode == keyMongolia) {
      return "assets/countries/mn.png";
    } else if (receivedCode == keyMacao) {
      return "assets/countries/mo.png";
    } else if (receivedCode == keyNorthernMarianaIslands) {
      return "assets/countries/mp.png";
    } else if (receivedCode == keyMartinique) {
      return "assets/countries/mq.png";
    } else if (receivedCode == keyMauritania) {
      return "assets/countries/mr.png";
    } else if (receivedCode == keyMontserrat) {
      return "assets/countries/ms.png";
    } else if (receivedCode == keyMalta) {
      return "assets/countries/mt.png";
    } else if (receivedCode == keyMauritius) {
      return "assets/countries/mu.png";
    } else if (receivedCode == keyMaldives) {
      return "assets/countries/mv.png";
    } else if (receivedCode == keyMalawi) {
      return "assets/countries/mw.png";
    } else if (receivedCode == keyMexico) {
      return "assets/countries/mx.png";
    } else if (receivedCode == keyMalaysia) {
      return "assets/countries/my.png";
    } else if (receivedCode == keyMozambique) {
      return "assets/countries/mz.png";
    } else if (receivedCode == keyNamibia) {
      return "assets/countries/na.png";
    } else if (receivedCode == keyNewCaledonia) {
      return "assets/countries/nc.png";
    } else if (receivedCode == keyNiger) {
      return "assets/countries/ne.png";
    } else if (receivedCode == keyNorfolkIsland) {
      return "assets/countries/nf.png";
    } else if (receivedCode == keyNigeria) {
      return "assets/countries/ng.png";
    } else if (receivedCode == keyNicaragua) {
      return "assets/countries/ni.png";
    } else if (receivedCode == keyNetherlands) {
      return "assets/countries/nl.png";
    } else if (receivedCode == keyNorway) {
      return "assets/countries/no.png";
    } else if (receivedCode == keyNepal) {
      return "assets/countries/np.png";
    } else if (receivedCode == keyNauru) {
      return "assets/countries/nr.png";
    } else if (receivedCode == keyNiue) {
      return "assets/countries/nu.png";
    } else if (receivedCode == keyNewZealand) {
      return "assets/countries/nz.png";
    } else if (receivedCode == keyOman) {
      return "assets/countries/om.png";
    } else if (receivedCode == keyPanama) {
      return "assets/countries/pa.png";
    } else if (receivedCode == keyPeru) {
      return "assets/countries/pe.png";
    } else if (receivedCode == keyFrenchPolynesia) {
      return "assets/countries/pf.png";
    } else if (receivedCode == keyPapuaNewGuinea) {
      return "assets/countries/pg.png";
    } else if (receivedCode == keyPhilippines) {
      return "assets/countries/ph.png";
    } else if (receivedCode == keyPakistan) {
      return "assets/countries/pk.png";
    } else if (receivedCode == keyPoland) {
      return "assets/countries/pl.png";
    } else if (receivedCode == keySaintPierreMiquelon) {
      return "assets/countries/pm.png";
    } else if (receivedCode == keyPitcairn) {
      return "assets/countries/pn.png";
    } else if (receivedCode == keyPuertoRico) {
      return "assets/countries/pr.png";
    } else if (receivedCode == keyPalestineState) {
      return "assets/countries/ps.png";
    } else if (receivedCode == keyPortugal) {
      return "assets/countries/pt.png";
    } else if (receivedCode == keyPalau) {
      return "assets/countries/pw.png";
    } else if (receivedCode == keyParaguay) {
      return "assets/countries/py.png";
    } else if (receivedCode == keyQatar) {
      return "assets/countries/qa.png";
    } else if (receivedCode == keyReunion) {
      return "assets/countries/re.png";
    } else if (receivedCode == keyRomania) {
      return "assets/countries/ro.png";
    } else if (receivedCode == keySerbia) {
      return "assets/countries/rs.png";
    } else if (receivedCode == keyRussianFederation) {
      return "assets/countries/ru.png";
    } else if (receivedCode == keyRwanda) {
      return "assets/countries/rw.png";
    } else if (receivedCode == keySaudiArabia) {
      return "assets/countries/sa.png";
  }else if(receivedCode == keySolomonIslands) {
    return "assets/countries/sb.png";
    }else if(receivedCode == keySeychelles) {
    return "assets/countries/sc.png";
    }else if(receivedCode == keySudan) {
    return "assets/countries/sd.png";
    }else if(receivedCode == keySweden) {
    return "assets/countries/se.png";
    }else if(receivedCode == keySingapore) {
    return "assets/countries/sg.png";
    }else if(receivedCode == keySaintHelena) {
    return "assets/countries/sh.png";
    }else if(receivedCode == keySlovenia) {
    return "assets/countries/si.png";
    }else if(receivedCode == keySlovakia) {
    return "assets/countries/sk.png";
    }else if(receivedCode == keySierraLeone) {
    return "assets/countries/sl.png";
    }else if(receivedCode == keySanMarino) {
    return "assets/countries/sm.png";
    }else if(receivedCode == keySenegal) {
    return "assets/countries/sn.png";
    }else if(receivedCode == keySomalia) {
    return "assets/countries/so.png";
    }else if(receivedCode == keySuriname) {
    return "assets/countries/sr.png";
    }else if(receivedCode == keySouthSudan) {
    return "assets/countries/ss.png";
    }else if(receivedCode == keySaoTomePrincipe) {
    return "assets/countries/st.png";
    }else if(receivedCode == keyElSalvador) {
    return "assets/countries/sv.png";
    }else if(receivedCode == keySintMaarten) {
    return "assets/countries/sx.png";
    }else if(receivedCode == keySyrianArabRepublic) {
    return "assets/countries/sy.png";
    }else if(receivedCode == keyEswatini) {
    return "assets/countries/sz.png";
    }else if(receivedCode == keyTurksCaicosIslands) {
    return "assets/countries/tc.png";
    }else if(receivedCode == keyChad) {
    return "assets/countries/td.png";
    }else if(receivedCode == keyFrenchSouthernTerritories) {
    return "assets/countries/tf.png";
    }else if(receivedCode == keyTogo) {
    return "assets/countries/tg.png";
    }else if(receivedCode == keyThailand) {
    return "assets/countries/th.png";
    }else if(receivedCode == keyTajikistan) {
    return "assets/countries/tj.png";
    }else if(receivedCode == keyTokelau) {
    return "assets/countries/tk.png";
    }else if(receivedCode == keyTimorLeste) {
    return "assets/countries/tl.png";
    }else if(receivedCode == keyTurkmenistan) {
    return "assets/countries/tm.png";
    }else if(receivedCode == keyTunisia) {
    return "assets/countries/tn.png";
    }else if(receivedCode == keyTonga) {
    return "assets/countries/to.png";
    }else if(receivedCode == keyTurkey) {
    return "assets/countries/tr.png";
    }else if(receivedCode == keyTrinidadTobago) {
    return "assets/countries/tt.png";
    }else if(receivedCode == keyTuvalu) {
    return "assets/countries/tv.png";
    }else if(receivedCode == keyTaiwan) {
    return "assets/countries/tw.png";
    }else if(receivedCode == keyTanzania) {
    return "assets/countries/tz.png";
    }else if(receivedCode == keyUkraine) {
    return "assets/countries/ua.png";
    }else if(receivedCode == keyUganda) {
    return "assets/countries/ug.png";
    }else if(receivedCode == keyUnitedStatesAmerica) {
    return "assets/countries/us.png";
    }else if(receivedCode == keyUruguay) {
    return "assets/countries/uy.png";
    }else if(receivedCode == keyUzbekistan) {
    return "assets/countries/uz.png";
    }else if(receivedCode == keyHolySee) {
    return "assets/countries/va.png";
    }else if(receivedCode == keySaintVincentGrenadines) {
    return "assets/countries/vc.png";
    }else if(receivedCode == keyVenezuela) {
    return "assets/countries/ve.png";
    }else if(receivedCode == keyVirginIslandsBritish) {
    return "assets/countries/vg.png";
    }else if(receivedCode == keyVirginIslandsUs) {
    return "assets/countries/vi.png";
    }else if(receivedCode == keyVietNam) {
    return "assets/countries/vn.png";
    }else if(receivedCode == keyVanuatu) {
    return "assets/countries/vu.png";
    }else if(receivedCode == keyWallisFutuna) {
    return "assets/countries/wf.png";
    }else if(receivedCode == keySamoa) {
    return "assets/countries/ws.png";
    }else if(receivedCode == keyKosovo) {
    return "assets/countries/xk.png";
    }else if(receivedCode == keyYemen) {
    return "assets/countries/ye.png";
    }else if(receivedCode == keyMayotte) {
    return "assets/countries/yt.png";
    }else if(receivedCode == keySouthAfrica) {
    return "assets/countries/za.png";
    }else if(receivedCode == keyZambia) {
    return "assets/countries/zm.png";
    }else if(receivedCode == keyZimbabwe) {
    return "assets/countries/zw.png";
    }else if(receivedCode == keyFrance) {
    return "assets/countries/fr.png";
    }

    return "assets/countries/tt.png";
  }

  static String getCountryName({required String code}) {
    String receivedCode = code.toLowerCase();

    if (receivedCode == keyAndoraIso) {
      return "counties_iso.ad_".tr();
    } else if (receivedCode == keyUnitedArabEmirates) {
      return "counties_iso.ae_".tr();
    } else if (receivedCode == keyAfghanistan) {
      return "counties_iso.af_".tr();
    } else if (receivedCode == keyAntiguaAndBarbuda) {
      return "counties_iso.ag_".tr();
    } else if (receivedCode == keyAnguilla) {
      return "counties_iso.ai_".tr();
    } else if (receivedCode == keyAlbania) {
      return "counties_iso.al_".tr();
    } else if (receivedCode == keyArmenia) {
      return "counties_iso.am_".tr();
    } else if (receivedCode == keyAngola) {
      return "counties_iso.ao_".tr();
    } else if (receivedCode == keyAntarctica) {
      return "counties_iso.aq_".tr();
    } else if (receivedCode == keyArgentina) {
      return "counties_iso.ar_".tr();
    } else if (receivedCode == keyAmericanSamoa) {
      return "counties_iso.as_".tr();
    } else if (receivedCode == keyAustria) {
      return "counties_iso.at_".tr();
    } else if (receivedCode == keyAustralia) {
      return "counties_iso.au_".tr();
    } else if (receivedCode == keyAruba) {
      return "counties_iso.aw_".tr();
    } else if (receivedCode == keyAlandIslands) {
      return "counties_iso.ax_".tr();
    } else if (receivedCode == keyAzerbaijan) {
      return "counties_iso.az_".tr();
    } else if (receivedCode == keyBosniaAndHerzegovina) {
      return "counties_iso.ba_".tr();
    } else if (receivedCode == keyBarbados) {
      return "counties_iso.bb_".tr();
    } else if (receivedCode == keyBangladesh) {
      return "counties_iso.bd_".tr();
    } else if (receivedCode == keyBelgium) {
      return "counties_iso.be_".tr();
    } else if (receivedCode == keyBurkinaFaso) {
      return "counties_iso.bf_".tr();
    } else if (receivedCode == keyBulgaria) {
      return "counties_iso.bg_".tr();
    } else if (receivedCode == keyBahrain) {
      return "counties_iso.bh_".tr();
    } else if (receivedCode == keyBurundi) {
      return "counties_iso.bi_".tr();
    } else if (receivedCode == keyBenin) {
      return "counties_iso.bj_".tr();
    } else if (receivedCode == keySaintBarthelemy) {
      return "counties_iso.bl_".tr();
    } else if (receivedCode == keyBermuda) {
      return "counties_iso.bm_".tr();
    } else if (receivedCode == keyBruneiDarussalam) {
      return "counties_iso.bn_".tr();
    } else if (receivedCode == keyBolivia) {
      return "counties_iso.bo_".tr();
    } else if (receivedCode == keyBonaireSintEustatiusAndSaba) {
      return "counties_iso.bq_".tr();
    } else if (receivedCode == keyBrazil) {
      return "counties_iso.br_".tr();
    } else if (receivedCode == keyBahamas) {
      return "counties_iso.bs_".tr();
    } else if (receivedCode == keyBhutan) {
      return "counties_iso.bt_".tr();
    } else if (receivedCode == keyBotswana) {
      return "counties_iso.bw_".tr();
    } else if (receivedCode == keyBelarus) {
      return "counties_iso.by_".tr();
    } else if (receivedCode == keyBelize) {
      return "counties_iso.bz_".tr();
    } else if (receivedCode == keyCanada) {
      return "counties_iso.ca_".tr();
    } else if (receivedCode == keyCocosIslands) {
      return "counties_iso.cc_".tr();
    } else if (receivedCode == keyCongoDemocraticRepublic) {
      return "counties_iso.cd_".tr();
    } else if (receivedCode == keyCentralAfricanRepublic) {
      return "counties_iso.cf_".tr();
    } else if (receivedCode == keyCongo) {
      return "counties_iso.cg_".tr();
    } else if (receivedCode == keySwitzerland) {
      return "counties_iso.ch_".tr();
    } else if (receivedCode == keyCoteDIvoire) {
      return "counties_iso.ci_".tr();
    } else if (receivedCode == keyCookIslands) {
      return "counties_iso.ck_".tr();
    } else if (receivedCode == keyChile) {
      return "counties_iso.cl_".tr();
    } else if (receivedCode == keyCameroon) {
      return "counties_iso.cm_".tr();
    } else if (receivedCode == keyChina) {
      return "counties_iso.cn_".tr();
    } else if (receivedCode == keyColombia) {
      return "counties_iso.co_".tr();
    } else if (receivedCode == keyCostaRica) {
      return "counties_iso.cr_".tr();
    } else if (receivedCode == keyCuba) {
      return "counties_iso.cu_".tr();
    } else if (receivedCode == keyCaboVerde) {
      return "counties_iso.cv_".tr();
    } else if (receivedCode == keyCuracao) {
      return "counties_iso.cw_".tr();
    } else if (receivedCode == keyChristmasIsland) {
      return "counties_iso.cx_".tr();
    } else if (receivedCode == keyCyprus) {
      return "counties_iso.cy_".tr();
    } else if (receivedCode == keyCzechia) {
      return "counties_iso.cy_".tr();
    } else if (receivedCode == keyGermany) {
      return "counties_iso.de_".tr();
    } else if (receivedCode == keyDjibouti) {
      return "counties_iso.dj_".tr();
    } else if (receivedCode == keyDenmark) {
      return "counties_iso.dk_".tr();
    } else if (receivedCode == keyDominica) {
      return "counties_iso.dm_".tr();
    } else if (receivedCode == keyDominicanRepublic) {
      return "counties_iso.do_".tr();
    } else if (receivedCode == keyAlgeria) {
      return "counties_iso.dz_".tr();
    } else if (receivedCode == keyEcuador) {
      return "counties_iso.ec_".tr();
    } else if (receivedCode == keyEstonia) {
      return "counties_iso.ee_".tr();
    } else if (receivedCode == keyEgypt) {
      return "counties_iso.eg_".tr();
    } else if (receivedCode == keyWesternSahara) {
      return "counties_iso.eh_".tr();
    } else if (receivedCode == keyEritrea) {
      return "counties_iso.er_".tr();
    } else if (receivedCode == keySpain) {
      return "counties_iso.es_".tr();
    } else if (receivedCode == keyEthiopia) {
      return "counties_iso.et_".tr();
    } else if (receivedCode == keyFinland) {
      return "counties_iso.fi_".tr();
    } else if (receivedCode == keyFiji) {
      return "counties_iso.fj_".tr();
    } else if (receivedCode == keyFalklandIslands) {
      return "counties_iso.fk_".tr();
    } else if (receivedCode == keyMicronesia) {
      return "counties_iso.fm_".tr();
    } else if (receivedCode == keyFaroeIslands) {
      return "counties_iso.fo_".tr();
    } else if (receivedCode == keyGabon) {
      return "counties_iso.ga_".tr();
    } else if (receivedCode == keyUnitedKingdom) {
      return "counties_iso.gb_".tr();
    } else if (receivedCode == keyEngland) {
      return "counties_iso.gb_".tr();
    } else if (receivedCode == keyNorthernIreland) {
      return "counties_iso.nir_".tr();
    } else if (receivedCode == keyScotLand) {
      return "counties_iso.sct_".tr();
    } else if (receivedCode == keyWales) {
      return "counties_iso.wls_".tr();
    } else if (receivedCode == keyGrenada) {
      return "counties_iso.gd_".tr();
    } else if (receivedCode == keyGeorgia) {
      return "counties_iso.ge_".tr();
    } else if (receivedCode == keyFrenchGuiana) {
      return "counties_iso.gf_".tr();
    } else if (receivedCode == keyGuernsey) {
      return "counties_iso.gg_".tr();
    } else if (receivedCode == keyGhana) {
      return "counties_iso.gh_".tr();
    } else if (receivedCode == keyGibraltar) {
      return "counties_iso.gi_".tr();
    } else if (receivedCode == keyGreenland) {
      return "counties_iso.gl_".tr();
    } else if (receivedCode == keyGambia) {
      return "counties_iso.gm_".tr();
    } else if (receivedCode == keyGuinea) {
      return "counties_iso.gn_".tr();
    } else if (receivedCode == keyGuadeloupe) {
      return "counties_iso.gp_".tr();
    } else if (receivedCode == keyEquatorialGuinea) {
      return "counties_iso.gq_".tr();
    } else if (receivedCode == keyGreece) {
      return "counties_iso.gr_".tr();
    } else if (receivedCode == keySouthGeorgia) {
      return "counties_iso.gs_".tr();
    } else if (receivedCode == keyGuatemala) {
      return "counties_iso.gt_".tr();
    } else if (receivedCode == keyGuam) {
      return "counties_iso.gu_".tr();
    } else if (receivedCode == keyGuineaBissau) {
      return "counties_iso.gw_".tr();
    } else if (receivedCode == keyGuyana) {
      return "counties_iso.gy_".tr();
    } else if (receivedCode == keyHongKong) {
      return "counties_iso.hk_".tr();
    } else if (receivedCode == keyHeardIslandMcDonaldIslands) {
      return "counties_iso.hm_".tr();
    } else if (receivedCode == keyHonduras) {
      return "counties_iso.hn_".tr();
    } else if (receivedCode == keyCroatia) {
      return "counties_iso.hr_".tr();
    } else if (receivedCode == keyHaiti) {
      return "counties_iso.ht_".tr();
    } else if (receivedCode == keyHungary) {
      return "counties_iso.hu_".tr();
    } else if (receivedCode == keyIndonesia) {
      return "counties_iso.id_".tr();
    } else if (receivedCode == keyIreland) {
      return "counties_iso.ie_".tr();
    } else if (receivedCode == keyIsrael) {
      return "counties_iso.il_".tr();
    } else if (receivedCode == keyIsleOfMan) {
      return "counties_iso.im_".tr();
    } else if (receivedCode == keyIndia) {
      return "counties_iso.in_".tr();
    } else if (receivedCode == keyBritishIndianOceanTerritory) {
      return "counties_iso.io_".tr();
    } else if (receivedCode == keyIraq) {
      return "counties_iso.iq_".tr();
    } else if (receivedCode == keyIran) {
      return "counties_iso.ir_".tr();
    } else if (receivedCode == keyIceland) {
      return "counties_iso.is_".tr();
    } else if (receivedCode == keyItaly) {
      return "counties_iso.it_".tr();
    } else if (receivedCode == keyJersey) {
      return "counties_iso.je_".tr();
    } else if (receivedCode == keyJamaica) {
      return "counties_iso.jm_".tr();
    } else if (receivedCode == keyJordan) {
      return "counties_iso.jo_".tr();
    } else if (receivedCode == keyJapan) {
      return "counties_iso.jp_".tr();
    } else if (receivedCode == keyKenya) {
      return "counties_iso.ke_".tr();
    } else if (receivedCode == keyKyrgyzstan) {
      return "counties_iso.kg_".tr();
    } else if (receivedCode == keyCambodia) {
      return "counties_iso.kh_".tr();
    } else if (receivedCode == keyKiribati) {
      return "counties_iso.ki_".tr();
    } else if (receivedCode == keyComoros) {
      return "counties_iso.km_".tr();
    } else if (receivedCode == keySaintKittsNevis) {
      return "counties_iso.kn_".tr();
    } else if (receivedCode == keyNorthKorea) {
      return "counties_iso.kp_".tr();
    } else if (receivedCode == keySouthKorea) {
      return "counties_iso.kr_".tr();
    } else if (receivedCode == keyKuwait) {
      return "counties_iso.kw_".tr();
    } else if (receivedCode == keyCaymanIslands) {
      return "counties_iso.ky_".tr();
    } else if (receivedCode == keyKazakhstan) {
      return "counties_iso.kz_".tr();
    } else if (receivedCode == keyLaos) {
      return "counties_iso.la_".tr();
    } else if (receivedCode == keyLebanon) {
      return "counties_iso.lb_".tr();
    } else if (receivedCode == keySaintLucia) {
      return "counties_iso.lc_".tr();
    } else if (receivedCode == keyLiechtenstein) {
      return "counties_iso.li_".tr();
    } else if (receivedCode == keySriLanka) {
      return "counties_iso.lk_".tr();
    } else if (receivedCode == keyLiberia) {
      return "counties_iso.lr_".tr();
    } else if (receivedCode == keyLesotho) {
      return "counties_iso.ls_".tr();
    } else if (receivedCode == keyLithuania) {
      return "counties_iso.lt_".tr();
    } else if (receivedCode == keyLuxembourg) {
      return "counties_iso.lu_".tr();
    } else if (receivedCode == keyLatvia) {
      return "counties_iso.lv_".tr();
    } else if (receivedCode == keyLibya) {
      return "counties_iso.ly_".tr();
    } else if (receivedCode == keyMorocco) {
      return "counties_iso.ma_".tr();
    } else if (receivedCode == keyMonaco) {
      return "counties_iso.mc_".tr();
    } else if (receivedCode == keyMoldova) {
      return "counties_iso.md_".tr();
    } else if (receivedCode == keyMontenegro) {
      return "counties_iso.me_".tr();
    } else if (receivedCode == keySaintMartinFrench) {
      return "counties_iso.mf_".tr();
    } else if (receivedCode == keyMadagascar) {
      return "counties_iso.mg_".tr();
    } else if (receivedCode == keyMarshallIslands) {
      return "counties_iso.mh_".tr();
    } else if (receivedCode == keyNorthMacedonia) {
      return "counties_iso.mk_".tr();
    } else if (receivedCode == keyMali) {
      return "counties_iso.ml_".tr();
    } else if (receivedCode == keyMyanmar) {
      return "counties_iso.mm_".tr();
    } else if (receivedCode == keyMongolia) {
      return "counties_iso.mn_".tr();
    } else if (receivedCode == keyMacao) {
      return "counties_iso.mo_".tr();
    } else if (receivedCode == keyNorthernMarianaIslands) {
      return "counties_iso.mp_".tr();
    } else if (receivedCode == keyMartinique) {
      return "counties_iso.mq_".tr();
    } else if (receivedCode == keyMauritania) {
      return "counties_iso.mr_".tr();
    } else if (receivedCode == keyMontserrat) {
      return "counties_iso.ms_".tr();
    } else if (receivedCode == keyMalta) {
      return "counties_iso.mt_".tr();
    } else if (receivedCode == keyMauritius) {
      return "counties_iso.mu_".tr();
    } else if (receivedCode == keyMaldives) {
      return "counties_iso.mv_".tr();
    } else if (receivedCode == keyMalawi) {
      return "counties_iso.mw_".tr();
    } else if (receivedCode == keyMexico) {
      return "counties_iso.mx_".tr();
    } else if (receivedCode == keyMalaysia) {
      return "counties_iso.my_".tr();
    } else if (receivedCode == keyMozambique) {
      return "counties_iso.mz_".tr();
    } else if (receivedCode == keyNamibia) {
      return "counties_iso.na_".tr();
    } else if (receivedCode == keyNewCaledonia) {
      return "counties_iso.nc_".tr();
    } else if (receivedCode == keyNiger) {
      return "counties_iso.ne_".tr();
    } else if (receivedCode == keyNorfolkIsland) {
      return "counties_iso.nf_".tr();
    } else if (receivedCode == keyNigeria) {
      return "counties_iso.ng_".tr();
    } else if (receivedCode == keyNicaragua) {
      return "counties_iso.ni_".tr();
    } else if (receivedCode == keyNetherlands) {
      return "counties_iso.nl_".tr();
    } else if (receivedCode == keyNorway) {
      return "counties_iso.no_".tr();
    } else if (receivedCode == keyNepal) {
      return "counties_iso.np_".tr();
    } else if (receivedCode == keyNauru) {
      return "counties_iso.nr_".tr();
    } else if (receivedCode == keyNiue) {
      return "counties_iso.nu_".tr();
    } else if (receivedCode == keyNewZealand) {
      return "counties_iso.nz_".tr();
    } else if (receivedCode == keyOman) {
      return "counties_iso.om_".tr();
    } else if (receivedCode == keyPanama) {
      return "counties_iso.pa_".tr();
    } else if (receivedCode == keyPeru) {
      return "counties_iso.pe_".tr();
    } else if (receivedCode == keyFrenchPolynesia) {
      return "counties_iso.pf_".tr();
    } else if (receivedCode == keyPapuaNewGuinea) {
      return "counties_iso.pg_".tr();
    } else if (receivedCode == keyPhilippines) {
      return "counties_iso.ph_".tr();
    } else if (receivedCode == keyPakistan) {
      return "counties_iso.pk_".tr();
    } else if (receivedCode == keyPoland) {
      return "counties_iso.pl_".tr();
    } else if (receivedCode == keySaintPierreMiquelon) {
      return "counties_iso.pm_".tr();
    } else if (receivedCode == keyPitcairn) {
      return "counties_iso.pn_".tr();
    } else if (receivedCode == keyPuertoRico) {
      return "counties_iso.pr_".tr();
    } else if (receivedCode == keyPalestineState) {
      return "counties_iso.ps_".tr();
    } else if (receivedCode == keyPortugal) {
      return "counties_iso.pt_".tr();
    } else if (receivedCode == keyPalau) {
      return "counties_iso.pw_".tr();
    } else if (receivedCode == keyParaguay) {
      return "counties_iso.py_".tr();
    } else if (receivedCode == keyQatar) {
      return "counties_iso.qa_".tr();
    } else if (receivedCode == keyReunion) {
      return "counties_iso.re_".tr();
    } else if (receivedCode == keyRomania) {
      return "counties_iso.ro_".tr();
    } else if (receivedCode == keySerbia) {
      return "counties_iso.rs_".tr();
    } else if (receivedCode == keyRussianFederation) {
      return "counties_iso.ru_".tr();
    } else if (receivedCode == keyRwanda) {
      return "counties_iso.rw_".tr();
    } else if (receivedCode == keySaudiArabia) {
      return
    "counties_iso.sa_".tr();
  }else if(receivedCode == keySolomonIslands) {
    return "counties_iso.sb_".tr();
    }else if(receivedCode == keySeychelles) {
    return "counties_iso.sc_".tr();
    }else if(receivedCode == keySudan) {
    return "counties_iso.sd_".tr();
    }else if(receivedCode == keySweden) {
    return "counties_iso.se_".tr();
    }else if(receivedCode == keySingapore) {
    return "counties_iso.sg_".tr();
    }else if(receivedCode == keySaintHelena) {
    return "counties_iso.sh_".tr();
    }else if(receivedCode == keySlovenia) {
    return "counties_iso.si_".tr();
    }else if(receivedCode == keySlovakia) {
    return "counties_iso.sk_".tr();
    }else if(receivedCode == keySierraLeone) {
    return "counties_iso.sl_".tr();
    }else if(receivedCode == keySanMarino) {
    return "counties_iso.sm_".tr();
    }else if(receivedCode == keySenegal) {
    return "counties_iso.sn_".tr();
    }else if(receivedCode == keySomalia) {
    return "counties_iso.so_".tr();
    }else if(receivedCode == keySuriname) {
    return "counties_iso.sr_".tr();
    }else if(receivedCode == keySouthSudan) {
    return "counties_iso.ss_".tr();
    }else if(receivedCode == keySaoTomePrincipe) {
    return "counties_iso.st_".tr();
    }else if(receivedCode == keyElSalvador) {
    return "counties_iso.sv_".tr();
    }else if(receivedCode == keySintMaarten) {
    return "counties_iso.sx_".tr();
    }else if(receivedCode == keySyrianArabRepublic) {
    return "counties_iso.sy_".tr();
    }else if(receivedCode == keyEswatini) {
    return "counties_iso.sz_".tr();
    }else if(receivedCode == keyTurksCaicosIslands) {
    return "counties_iso.tc_".tr();
    }else if(receivedCode == keyChad) {
    return "counties_iso.td_".tr();
    }else if(receivedCode == keyFrenchSouthernTerritories) {
    return "counties_iso.tf_".tr();
    }else if(receivedCode == keyTogo) {
    return "counties_iso.tg_".tr();
    }else if(receivedCode == keyThailand) {
    return "counties_iso.th_".tr();
    }else if(receivedCode == keyTajikistan) {
    return "counties_iso.tj_".tr();
    }else if(receivedCode == keyTokelau) {
    return "counties_iso.tk_".tr();
    }else if(receivedCode == keyTimorLeste) {
    return "counties_iso.tl_".tr();
    }else if(receivedCode == keyTurkmenistan) {
    return "counties_iso.tm_".tr();
    }else if(receivedCode == keyTunisia) {
    return "counties_iso.tn_".tr();
    }else if(receivedCode == keyTonga) {
    return "counties_iso.to_".tr();
    }else if(receivedCode == keyTurkey) {
    return "counties_iso.tr_".tr();
    }else if(receivedCode == keyTrinidadTobago) {
    return "counties_iso.tt_".tr();
    }else if(receivedCode == keyTuvalu) {
    return "counties_iso.tv_".tr();
    }else if(receivedCode == keyTaiwan) {
    return "counties_iso.tw_".tr();
    }else if(receivedCode == keyTanzania) {
    return "counties_iso.tz_".tr();
    }else if(receivedCode == keyUkraine) {
    return "counties_iso.ua_".tr();
    }else if(receivedCode == keyUganda) {
    return "counties_iso.ug_".tr();
    }else if(receivedCode == keyUnitedStatesAmerica) {
    return "counties_iso.us_".tr();
    }else if(receivedCode == keyUruguay) {
    return "counties_iso.uy_".tr();
    }else if(receivedCode == keyUzbekistan) {
    return "counties_iso.uz_".tr();
    }else if(receivedCode == keyHolySee) {
    return "counties_iso.va_".tr();
    }else if(receivedCode == keySaintVincentGrenadines) {
    return "counties_iso.vc_".tr();
    }else if(receivedCode == keyVenezuela) {
    return "counties_iso.ve_".tr();
    }else if(receivedCode == keyVirginIslandsBritish) {
    return "counties_iso.vg_".tr();
    }else if(receivedCode == keyVirginIslandsUs) {
    return "counties_iso.vi_".tr();
    }else if(receivedCode == keyVietNam) {
    return "counties_iso.vn_".tr();
    }else if(receivedCode == keyVanuatu) {
    return "counties_iso.vu_".tr();
    }else if(receivedCode == keyWallisFutuna) {
    return "counties_iso.wf_".tr();
    }else if(receivedCode == keySamoa) {
    return "counties_iso.ws_".tr();
    }else if(receivedCode == keyKosovo) {
    return "counties_iso.xk_".tr();
    }else if(receivedCode == keyYemen) {
    return "counties_iso.ye_".tr();
    }else if(receivedCode == keyMayotte) {
    return "counties_iso.yt_".tr();
    }else if(receivedCode == keySouthAfrica) {
    return "counties_iso.za_".tr();
    }else if(receivedCode == keyZambia) {
    return "counties_iso.zm_".tr();
    }else if(receivedCode == keyZimbabwe) {
    return "counties_iso.zw_".tr();
    }else if(receivedCode == keyFrance) {
    return "counties_iso.fr_".tr();
    }

    return "counties_iso.tt_".tr();
    }

  static String getUserPersonalizedTopCard(String levelCode) {
    if (levelCode == "VIP1") {
      return "assets/images/vip_bg_cover_occ_1.png";
    } else if (levelCode == "VIP2") {
      return "assets/images/vip_bg_cover_occ_2.png";
    } else if (levelCode == "VIP3") {
      return "assets/images/vip_bg_cover_occ_3.png";
    } else if (levelCode == "VIP4") {
      return "assets/images/vip_bg_cover_occ_4.png";
    } else if (levelCode == "VIP5") {
      return "assets/images/vip_bg_cover_occ_5.png";
    } else if (levelCode == "VIP6") {
      return "assets/images/vip_bg_cover_occ_6.png";
    } else if (levelCode == "VIP7") {
      return "assets/images/vip_bg_cover_occ_7.png";
    } else if (levelCode == "VIP8") {
      return "assets/images/vip_bg_cover_occ_8.png";
    } else if (levelCode == "VIP9") {
      return "assets/images/vip_bg_cover_occ_9.png";
    } else if (levelCode == "VIP10") {
      return "assets/images/vip_bg_cover_occ_10.png";
    } else {
      return "";
    }
  }

  static String getDeviceOsName() {
    if (QuickHelp.isAndroidPlatform()) {
      return "Android";
    } else if (QuickHelp.isIOSPlatform()) {
      return "iOS";
    } else if (QuickHelp.isWebPlatform()) {
      return "Web";
    } else if (QuickHelp.isWindowsPlatform()) {
      return "Windows";
    } else if (QuickHelp.isLinuxPlatform()) {
      return "Linux";
    } else if (QuickHelp.isFuchsiaPlatform()) {
      return "Fuchsia";
    } else if (QuickHelp.isMacOsPlatform()) {
      return "MacOS";
    }

    return "";
  }

  static String getDeviceOsType() {
    if (QuickHelp.isAndroidPlatform()) {
      return "android";
    } else if (QuickHelp.isIOSPlatform()) {
      return "ios";
    } else if (QuickHelp.isWebPlatform()) {
      return "web";
    } else if (QuickHelp.isWindowsPlatform()) {
      return "windows";
    } else if (QuickHelp.isLinuxPlatform()) {
      return "linux";
    } else if (QuickHelp.isFuchsiaPlatform()) {
      return "fuchsia";
    } else if (QuickHelp.isMacOsPlatform()) {
      return "macos";
    }

    return "";
  }

  static getGender(UserModel user) {
    if (user.getGender == UserModel.keyGenderMale) {
      return "male_".tr();
    } else {
      return "female_".tr();
    }
  }

  static List<String> getShowMyPostToList() {
    List<String> list = [UserModel.ANY_USER, UserModel.ONLY_MY_FRIENDS, ""];

    return list;
  }

  static String getShowMyPostToMessage(String code) {
    switch (code) {
      case UserModel.ANY_USER:
        return "privacy_settings.explain_see_my_posts"
            .tr(namedArgs: {"app_name": Config.appName});

      case UserModel.ONLY_MY_FRIENDS:
        return "privacy_settings.explain_see_my_post".tr();

      default:
        return "edit_profile.profile_no_answer".tr();
    }
  }

  static Future<void> launchInWebViewWithJavaScript(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static Widget appLoading() {
    return Center(
      child: Container(
        width: 50,
        height: 50,
        child:
            showLoadingAnimation(), //SvgPicture.asset('assets/svg/ic_icon.svg', width: 50, height: 50,),
      ),
    );
  }

  static Widget appLoadingLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        child: Image.asset(
          QuickHelp.isDarkModeNoContext()
              ? 'assets/images/ic_logo_white.png'
              : 'assets/images/ic_logo.png',
          width: 120,
          height: 120,
        ),
      ),
    );
  }

  static double distanceInKilometersTo(
      ParseGeoPoint point1, ParseGeoPoint point2) {
    return _distanceInRadiansTo(point1, point2) * earthMeanRadiusKm;
  }

  static double distanceInMilesTo(ParseGeoPoint point1, ParseGeoPoint point2) {
    return _distanceInRadiansTo(point1, point2) * earthMeanRadiusMile;
  }

  static double _distanceInRadiansTo(
      ParseGeoPoint point1, ParseGeoPoint point2) {
    double d2r = math.pi / 180.0; // radian conversion factor
    double lat1rad = point1.latitude * d2r;
    double long1rad = point1.longitude * d2r;
    double lat2rad = point2.latitude * d2r;
    double long2rad = point2.longitude * d2r;
    double deltaLat = lat1rad - lat2rad;
    double deltaLong = long1rad - long2rad;
    double sinDeltaLatDiv2 = math.sin(deltaLat / 2);
    double sinDeltaLongDiv2 = math.sin(deltaLong / 2);
    // Square of half the straight line chord distance between both points.
    // [0.0, 1.0]
    double a = sinDeltaLatDiv2 * sinDeltaLatDiv2 +
        math.cos(lat1rad) *
            math.cos(lat2rad) *
            sinDeltaLongDiv2 *
            sinDeltaLongDiv2;
    a = math.min(1.0, a);
    return 2 * math.asin(math.sqrt(a));
  }

  static String isUserOnlineChat(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
            dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return "offline_".tr();
    } else if (DateTime.now().millisecondsSinceEpoch -
            dateTime.millisecondsSinceEpoch >
        timeToSoon) {
      // offline / recently online
      return QuickHelp.timeAgoSinceDate(dateTime);
    } else {
      // online
      return "online_".tr();
    }
  }

  static String isUserOnlineLiveInvite(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
            dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return "offline_".tr();
    } else {
      // online
      return "online_".tr();
    }
  }

  static bool isUserOnline(UserModel user) {
    DateTime? dateTime;

    if (user.getLastOnline != null) {
      dateTime = user.getLastOnline;
    } else {
      dateTime = user.updatedAt;
    }

    if (DateTime.now().millisecondsSinceEpoch -
            dateTime!.millisecondsSinceEpoch >
        timeToOffline) {
      // offline
      return false;
    } else if (DateTime.now().millisecondsSinceEpoch -
            dateTime.millisecondsSinceEpoch >
        timeToSoon) {
      // offline / recently online
      return true;
    } else {
      // online
      return true;
    }
  }

  static DateTime getDateFromAge(int age) {
    var birthday = DateTime.now();

    int currentYear = birthday.year;
    int birthYear = currentYear - age;

    return new DateTime(birthYear, birthday.month, birthday.day);
  }

  static String getDiamondsLeftToRedeem(
      int diamonds ) {
    if (diamonds >= Setup.diamondsNeededToRedeem) {
      return 0.toString();
    } else {
      return (Setup.diamondsNeededToRedeem - diamonds).toString();
    }
  }

  static bool hasSameDate(DateTime first, DateTime second) {
    int dateDiff = DateTime(second.year, second.month, second.day)
        .difference(DateTime(first.year, first.month, first.day))
        .inDays;
    return dateDiff == 0;
  }

  static String getMessageListTime(DateTime utcTime) {
    final dateTime = utcTime.toLocal();

    Duration diff = DateTime.now().difference(dateTime);
    DateTime now = DateTime.now();
    int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    if (dateDiff == -1) {
      // Yesterday
      return "date_time.yesterday_".tr();
    } else if (dateDiff == 0) {
      // today
      return DateFormat(dateFormatTimeOnly).format(dateTime);
    } else if (diff.inDays > 0 && diff.inDays < 6) {
      // Day name
      return getDaysOfWeek(dateTime);
    } else {
      return DateFormat(dateFormatDateOnly).format(dateTime);
    }
  }

  static String getMessageTime(DateTime utcTime, {bool? time}) {
    final dateTime = utcTime.toLocal();

    if (time != null && time == true) {
      return DateFormat(dateFormatTimeOnly).format(dateTime);
    } else {
      Duration diff = DateTime.now().difference(dateTime);
      DateTime now = DateTime.now();
      int dateDiff = DateTime(dateTime.year, dateTime.month, dateTime.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;

      if (dateDiff == -1) {
        // Yesterday
        return "date_time.yesterday_".tr();
      } else if (dateDiff == 0) {
        // today
        return "date_time.today_".tr();
      } else if (diff.inDays > 0 && diff.inDays < 6) {
        // Day name
        return getDaysOfWeek(dateTime);
      } else {
        return DateFormat().add_MMMEd().format(dateTime);
      }
    }
  }

  static String getTimeAndDate(DateTime utcTime, {bool? time}) {
    final dateTime = utcTime.toLocal();

    DateTime date1 = DateTime.now();
    return dateTime.difference(date1).toYearsMonthsDaysString();
  }

  static String getDaysOfWeek(DateTime dateTime) {
    int day = dateTime.weekday;

    if (day == 1) {
      return "date_time.monday_".tr();
    } else if (day == 2) {
      return "date_time.tuesday_".tr();
    } else if (day == 3) {
      return "date_time.wednesday_".tr();
    } else if (day == 4) {
      return "date_time.thursday_".tr();
    } else if (day == 5) {
      return "date_time.friday_".tr();
    } else if (day == 6) {
      return "date_time.saturday_".tr();
    } else if (day == 7) {
      return "date_time.sunday_".tr();
    }

    return "";
  }

  static String timeAgoSinceDate(DateTime utcTime, {bool numericDates = true}) {
    final dateTime = utcTime.toLocal();

    final date2 = DateTime.now();
    final difference = date2.difference(dateTime);

    if (difference.inDays > 8) {
      return DateFormat(dateFormatDateOnly).format(dateTime);
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 minute ago' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  static String getRemainingTime({required DateTime futureDate}) {
    DateTime currentDate = DateTime.now();

    if (futureDate.isBefore(currentDate)) {
      return '0D-0h';
    }

    Duration remainingDuration = futureDate.difference(currentDate);

    if (remainingDuration.inDays > 0) {
      int days = remainingDuration.inDays;
      int hours = remainingDuration.inHours.remainder(24);

      String formattedDays = days.toString();
      String formattedHours = hours.toString();

      return '${formattedDays}D - ${formattedHours}h';
    }

    int hours = remainingDuration.inHours;
    String formattedHours = hours.toString();

    return '${formattedHours}h';
  }

  static String getTimeByDate({required DateTime date}) {

    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    String formattedTime = DateFormat('HH:mm:ss').format(DateTime(0, 1, 1, hours, minutes, seconds));

    return formattedTime;
  }

  static bool isNumericString(String str) {
    if (str.isEmpty) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  static void showAppNotification(
      {required BuildContext context, String? title, bool isError = true}) {
    showTopSnackBar(
      context,
      isError
          ? SnackBarPro.error(
              title: title!,
            )
          : SnackBarPro.success(
              title: title!,
            ),
    );
  }

  static void showAppNotificationAdvanced(
      {required String title,
      required BuildContext context,
      Widget? avatar,
      String? message,
      bool? isError = true,
      VoidCallback? onTap,
      UserModel? user,
      String? avatarUrl}) {
    showTopSnackBar(
      context,
      SnackBarPro.custom(
        title: title,
        message: message,
        icon: user != null
            ? QuickActions.avatarWidget(
                user,
                imageUrl: avatarUrl,
                width: 60,
                height: 60,
              )
            : avatar,
        textStyleTitle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isError != null ? Colors.white : Colors.black,
        ),
        textStyleMessage: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 15,
          color: isError != null ? Colors.white : Colors.black,
        ),
        isError: isError,
      ),
      onTap: onTap,
      overlayState: null,
    );
  }

  static double convertDiamondsToMoney(int diamonds) {
    double totalMoney = (diamonds.toDouble() / 10000) * Setup.withDrawPercent;
    return totalMoney;
  }

  static double convertMoneyToDiamonds(double amount) {
    double diamonds = (amount.toDouble() * 10000) / Setup.withDrawPercent;;
    return diamonds;
  }

  static int getDiamondsForReceiver(int diamonds) {
    double finalDiamonds =
        (diamonds / 100) * Setup.diamondsEarnPercent;
    return int.parse(finalDiamonds.toStringAsFixed(0));
  }

  static int getDiamondsForAgency(int diamonds) {
    double finalDiamonds =
        (diamonds / 100) * Setup.agencyPercent;
    return int.parse(finalDiamonds.toStringAsFixed(0));
  }

  static DateTime getUntilDateFromDays(int days) {
    return DateTime.now().add(Duration(days: days));
  }

  static void showLoadingDialogWithText(BuildContext context,
      {bool? isDismissible,
      bool? useLogo = false,
      required String description,
      Color? backgroundColor}) {
    showDialog(
        context: context,
        barrierDismissible: isDismissible != null ? isDismissible : false,
        builder: (BuildContext context) {
          return Scaffold(
            extendBodyBehindAppBar: false,
            backgroundColor: backgroundColor,
            body: Container(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    useLogo! ? appLoadingLogo() : appLoading(),
                    TextWithTap(
                      description,
                      marginTop: !useLogo ? 10 : 0,
                      marginLeft: 10,
                      marginRight: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static Future<XFile?> compressImage(String path, {int quality = 40}) async {
    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path + '/file.jpg';

    var result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: quality,
      rotate: 0,
    );

    return result;
  }

  static Future<List<File?>> compressImagesList(List<File> images,
      {int quality = 40}) async {
    final tempDir = await getTemporaryDirectory();
    List<File> imagesList = [];
    List<String> savedImagesPaths = [];

    for (int i = 0; i < images.length; i++) {
      String imageName = 'image_$i.jpg';
      final targetPath = tempDir.absolute.path + imageName;

      File tempFile = File('${tempDir.path}/$imageName');
      await tempFile.writeAsBytes(await images[i].readAsBytes());
      savedImagesPaths.add(tempFile.path);

      await tempFile.writeAsBytes(await images[i].readAsBytes());
      savedImagesPaths.add(tempFile.path);

      imagesList.add(await FlutterImageCompress.compressAndGetFile(
        images[i].path,
        targetPath,
        quality: quality,
        rotate: 0,
      ) as File);
    }

    return imagesList;
  }

  static File bytesToFile(Uint8List uint8List) {
    return File.fromRawPath(uint8List);
  }

  static Widget showLoadingAnimation(
      {Color leftDotColor = kPrimaryColor,
      Color rightDotColor = kSecondaryColor,
      double size = 35}) {
    return Center(
        child: LoadingAnimationWidget.twistingDots(
            leftDotColor: leftDotColor,
            rightDotColor: rightDotColor,
            size: size));
  }

  static bool isNormal(UserModel user){

    DateTime now = DateTime.now();

    if(user.getNormalVip != null){
      DateTime to = user.getNormalVip!;

      if(to.isAfter(now)){
        return true;
      }
    }

    return false;
  }

  static List<Locale> getLanguages(List<String> languages){

    List<Locale> availableLanguages = [];

    for(String language in languages){
      availableLanguages.add(Locale(language));
    }

    return availableLanguages;
  }

  static String getLanguageByCode(String code){
    if(code == "en"){
      return "language_screen.en_".tr();
    }else if(code == "fr") {
      return "language_screen.fr_".tr();
    }else if(code == "pt"){
      return "language_screen.pt_".tr();
    }else if(code == "ar"){
      return "language_screen.ar_".tr();
    } else{
      return "language_screen.en_".tr();
    }
  }

  static String convertNumberToK(int number) {
    return NumberFormat.compact().format(number);
  }

  static saveCurrentRoute({required String route}) async {
    final currentRoute = await SharedPreferences.getInstance();
    await currentRoute.setString('currentRoute', route);
    print("route: ${currentRoute.getString('currentRoute')}");
  }

  static removeFocusOnTextField(BuildContext context) {
    FocusScopeNode focusScopeNode = FocusScope.of(context);
    if (!focusScopeNode.hasPrimaryFocus &&
        focusScopeNode.focusedChild != null) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

extension DurationExtensions on Duration {
  String toYearsMonthsDaysString() {
    final years = this.inDays ~/ 365;
    // You will need a custom logic for the months part, since not every month has 30 days
    final months = (this.inDays % 365) ~/ 30;
    final days = (this.inDays % 365) % 30;

    return "$years y - $months m - $days d";
  }
}

