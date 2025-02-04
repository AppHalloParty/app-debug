// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_version_checker/flutter_app_version_checker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../auth/welcome_screen.dart';
import '../../helpers/quick_help.dart';
import '../../ui/button_widget.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../about/about_us_screen.dart';
import '../account_and_security/account_and_security_screen.dart';
import '../blacklist/black_list_screen.dart';
import '../language_setting/languages_screen.dart';
import '../message_notification/new_messages_notifications_screen.dart';
import '../privacy/privacy_screen.dart';
import '../privilege/privilege_setting_screen.dart';
import '../profile/profile_edit.dart';
import 'package:trace/app/config.dart' as conf;

class SettingsScreen extends StatefulWidget {
  UserModel? currentUser;

  SettingsScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  var privilegeGroupTitle = [
    "setting_screen.privilege_settings".tr(),
    "setting_screen.new_message_push".tr(),
    "setting_screen.privacy_".tr(),
  ];

  var versionGroupTitles = [
    "setting_screen.version_".tr(),
    "setting_screen.about_app".tr(namedArgs: {"app_name": conf.Config.appName}),
    "setting_screen.rate_app".tr(namedArgs: {"app_name": conf.Config.appName}),
    "setting_screen.clear_cache".tr(),
  ];

  var settingsTitles = [
    "setting_screen.log_out".tr(),
    "cancel".tr(),
  ];

  String appVersion = "0.0.0";

  bool showTempAlert = false;

  final InAppReview inAppReview = InAppReview.instance;
  String appStoreId = conf.Config.packageNameAndroid;

  requestRate() async {
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

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

  final _checker = AppVersionChecker();

  void checkVersion() async {
    _checker.checkUpdate().then((value) {
      setState(() {
        appVersion = value.currentVersion;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkVersion();

    (<T>(T? o) => o!)(WidgetsBinding.instance).addPostFrameCallback((_) async {
      try {
        await inAppReview.isAvailable();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: BackButton(
              color: isDark ? Colors.white : kContentColorLightTheme,
              onPressed: (){
                QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);
              },
            ),
            centerTitle: true,
            title: TextWithTap(
              "setting_screen.setting_".tr(),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  UserModel? user =
                      await QuickHelp.goToNavigatorScreenForResult(
                    context,
                    ProfileEdit(
                      currentUser: widget.currentUser,
                    ),
                  );
                  if (user != null) {
                    widget.currentUser = user;
                  }
                },
                icon: Icon(
                  Icons.edit,
                  color: isDark ? Colors.white : kContentColorLightTheme,
                ),
              )
            ],
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(
                height: 10,
              ),
              option(
                  title: "setting_screen.account_security".tr(),
                  showSecurityInfo: true,
                goToAccountAndSecurityScreen: true,
              ),
              option(
                title: "setting_screen.language_settings".tr(),
                goToLanguagesScreen: true,
              ),
              const SizedBox(
                height: 10,
              ),
              option(
                title: "setting_screen.blacklist_".tr(),
                goToBlackListScreen: true,
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: List.generate(privilegeGroupTitle.length, (index) {
                  return option(
                    title: privilegeGroupTitle[index],
                    goToPrivilegeSettingScreen: index == 0,
                    goToMessageNotificationScreen: index == 1,
                    goToPrivacyScreen: index == 2,
                  );
                }),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: List.generate(versionGroupTitles.length, (index) {
                  return option(
                    title: versionGroupTitles[index],
                    showAppVersion: index == 0,
                    goToAboutScreen: index == 1,
                    rateApp: index == 2,
                    cleanCache: index == 3,
                  );
                }),
              ),
              ContainerCorner(
                width: size.width,
                marginTop: 10,
                height: 50,
                color: isDark ? kContentColorLightTheme : Colors.white,
                child: ButtonWidget(
                  onTap: () => openLogoutSheet(),
                  child: TextWithTap(
                    "setting_screen.log_out".tr(),
                    color: Colors.red,
                    alignment: Alignment.center,
                  ),
                ),
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
              "setting_screen.cache_cleaned".tr(),
              color: Colors.white,
              marginBottom: 5,
              marginTop: 5,
              marginLeft: 15,
              marginRight: 15,
              fontSize: 12,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget option({
    required String title,
    bool showAppVersion = false,
    bool showSecurityInfo = false,
    bool goToAboutScreen = false,
    bool goToBlackListScreen = false,
    bool goToLanguagesScreen = false,
    bool goToPrivilegeSettingScreen = false,
    bool goToMessageNotificationScreen = false,
    bool goToAccountAndSecurityScreen = false,
    bool goToPrivacyScreen = false,
    bool rateApp = false,
    bool cleanCache = false,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return ContainerCorner(
      width: size.width,
      color: isDark ? kContentColorLightTheme : Colors.white,
      marginTop: 1,
      child: ButtonWidget(
        onTap: () {
          if (goToAboutScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              AboutUsScreen(
                currentUser: widget.currentUser,
              ),
            );
          } else if (cleanCache) {
            emptyCache();
          } else if (rateApp) {
            requestRate();
          } else if (goToBlackListScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              BlacklistScreen(
                currentUser: widget.currentUser,
              ),
            );
          } else if (goToLanguagesScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              LanguagesScreen(
                currentUser: widget.currentUser,
              ),
            );
          } else if (goToPrivilegeSettingScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              PrivilegeSettingScreen(
                currentUser: widget.currentUser,
              ),
            );
          } else if (goToMessageNotificationScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              NewMessageNotificationScreen(
                currentUser: widget.currentUser,
              ),
            );
          } else if (goToPrivacyScreen) {
            QuickHelp.goToNavigatorScreen(
              context,
              PrivacyScreen(
                currentUser: widget.currentUser,
              ),
            );
          }else if(goToAccountAndSecurityScreen){
            QuickHelp.goToNavigatorScreen(
              context,
              AccountAndSecurityScreen(
                currentUser: widget.currentUser,
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWithTap(
                  title,
                  alignment: Alignment.center,
                  fontSize: 16,
                  marginLeft: 10,
                  marginTop: showSecurityInfo ? 5 : 0,
                  color: isDark ? Colors.white : kContentColorLightTheme,
                ),
                Visibility(
                  visible: showSecurityInfo,
                  child: TextWithTap(
                    "setting_screen.security_level"
                        .tr(namedArgs: {"level": "low"}),
                    alignment: Alignment.center,
                    //fontSize: 12,
                    marginLeft: 10,
                    marginTop: 10,
                    marginBottom: 5,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                children: [
                  Visibility(
                      visible: showAppVersion,
                      child: TextWithTap(
                        appVersion,
                        fontSize: 16,
                        color: kGrayColor,
                      )),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: kGrayColor,
                    size: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openLogoutSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showLogoutSheet();
        });
  }

  Widget showLogoutSheet() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setState) {
              return ContainerCorner(
                radiusTopLeft: 25,
                radiusTopRight: 25,
                color:
                    isDarkMode ? Colors.black : Colors.white.withOpacity(0.9),
                borderWidth: 0,
                child: Scaffold(
                  backgroundColor: kTransparentColor,
                  body: Column(
                    children: List.generate(
                      settingsTitles.length,
                      (index) => logoutOptions(
                        caption: settingsTitles[index],
                        index: index,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget logoutOptions({required String caption, required int index}) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerCorner(
          height: 55,
          width: size.width,
          marginTop: index == (settingsTitles.length - 1) ? 6 : 0,
          radiusTopRight: index == 0 ? 25 : 0,
          radiusTopLeft: index == 0 ? 25 : 0,
          color: isDarkMode ? kContentDarkShadow : Colors.white,
          onTap: () {
            if (index == (settingsTitles.length - 1)) {
              QuickHelp.goBackToPreviousPage(context);
            } else if (index == 0) {
              logout();
            }
          },
          child: Center(
            child: TextWithTap(
              caption,
              fontSize: size.width / 23,
            ),
          ),
        ),
        Visibility(
          visible: index < (settingsTitles.length - 2),
          child: ContainerCorner(
            height: 0.5,
            color: kGrayColor.withOpacity(0.5),
            width: size.width,
          ),
        ),
      ],
    );
  }

  logout() {
    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "account_settings.logout_user_sure".tr(),
      message: "account_settings.logout_user_details".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "account_settings.logout_user".tr(),
      onPressed: () {
        QuickHelp.showLoadingDialog(context);

        widget.currentUser!.logout(deleteLocalUserData: true).then((value) {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.goToPageWithClear(
            context, WelcomeScreen(),
          );
        }).onError(
          (error, stackTrace) {
            QuickHelp.hideLoadingDialog(context);
          },
        );

      },
    );
  }

  Future<void> emptyCache() async {
    QuickHelp.showLoadingDialog(context);
    await DefaultCacheManager().emptyCache();
    QuickHelp.hideLoadingDialog(context);
    showTemporaryAlert();
  }
}
