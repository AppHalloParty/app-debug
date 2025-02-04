// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';

class LanguagesScreen extends StatefulWidget {
  UserModel? currentUser;

  LanguagesScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _LanguagesScreenState extends State<LanguagesScreen> {
  var systemList = [
    "language_screen.follow_system".tr(),
  ];

  var languages = Setup.languages;

  var selectedLanguages = [
    navigatorKey.currentContext?.locale.languageCode ??
        WidgetsBinding.instance.window.locale.languageCode
  ];

  changeLanguage() async {
    QuickHelp.showLoadingDialog(context);

    if (selectedLanguages[0] == systemList[0]) {
      widget.currentUser!.setRemoveAppLanguage =
          widget.currentUser!.getLanguage!;
      if (context.deviceLocale.toString().startsWith("pt_")) {
        context.setLocale(Locale("pt"));
      } else if (context.deviceLocale.toString().startsWith("fr_")) {
        context.setLocale(Locale("fr"));
      } else if (context.deviceLocale.toString().startsWith("en_")) {
        context.setLocale(Locale("en"));
      } else if(context.deviceLocale.toString().startsWith("ar_")){
        context.setLocale(Locale("ar"));
      }else {
        QuickHelp.showAppNotificationAdvanced(
            title: "language_screen.language_no_found_title".tr(),
            context: context,
            message: "language_screen.language_no_found_explain".tr());
        context.setLocale(Locale("en"));
      }
      setState(() {});
    } else {
      widget.currentUser!.setLanguage = selectedLanguages[0];
      setState(() {
        context.setLocale(Locale(selectedLanguages[0]));
      });
    }
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first!;
      });
      QuickHelp.showAppNotificationAdvanced(
        title: "language_screen.changed_successfully_title".tr(),
        message: "language_screen.changed_successfully_explain".tr(),
        isError: false,
        context: context,
      );
      QuickHelp.goToNavigatorScreen(
          context,
          HomeScreen(
            currentUser: widget.currentUser,
          ));
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "error".tr(),
          context: context,
          message: "report_screen.report_failed_explain".tr());
    }
  }

  @override
  void dispose() {
    super.dispose();
    selectedLanguages.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "language_screen.language_settings".tr(),
        ),
        actions: [
          IconButton(
            onPressed: () => changeLanguage(),
            icon: TextWithTap("language_screen.confirm_".tr()),
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          option(
            contains: selectedLanguages.contains(systemList[0]),
            index: 0,
            system: true,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(languages.length, (index) {
              bool contains = selectedLanguages.contains(languages[index]);
              return option(
                contains: contains,
                index: index,
                system: false,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget option(
      {required bool contains, required int index, required bool system}) {
    bool isDark = QuickHelp.isDarkMode(context);
    return ButtonWidget(
      onTap: () {
        setState(() {
          selectedLanguages.clear();
          if (system) {
            selectedLanguages.add(systemList[0]);
          } else {
            selectedLanguages.add(languages[index]);
          }
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWithTap(
            system
                ? systemList[0]
                : QuickHelp.getLanguageByCode(languages[index]),
            fontSize: 16,
            marginLeft: 10,
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              contains ? Icons.check_circle : Icons.circle_outlined,
              color: contains ? kPrimaryColor : kGrayColor,
            ),
          )
        ],
      ),
    );
  }
}
