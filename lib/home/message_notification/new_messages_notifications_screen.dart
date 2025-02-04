// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class NewMessageNotificationScreen extends StatefulWidget {
  UserModel? currentUser;

  NewMessageNotificationScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<NewMessageNotificationScreen> createState() =>
      _NewMessageNotificationScreenState();
}

class _NewMessageNotificationScreenState
    extends State<NewMessageNotificationScreen> {
  var messageNotificationTitles = [
    "new_message_notification_screen.live_opening_alert".tr(),
    "new_message_notification_screen.message_notification_switch".tr(),
    "new_message_notification_screen.accept_calls".tr(),
  ];

  var messageAlertSettingsTitles = [
    "new_message_notification_screen.sound_".tr(),
    "new_message_notification_screen.vibrate_".tr(),
  ];

  bool isLiveOpening = true;
  bool isMessageNotificationSwitch = true;
  bool isAcceptCalls = true;
  bool isSound = true;
  bool isVibrate = true;

  initiateSwitchValues() {
    setState(() {
      isLiveOpening = widget.currentUser!.getLiveOpeningAlert!;
      isMessageNotificationSwitch =
          widget.currentUser!.getMessageNotificationSwitch!;
      isAcceptCalls = widget.currentUser!.getAcceptCalls!;
      isSound = widget.currentUser!.getSound!;
      isVibrate = widget.currentUser!.getVibrate!;
    });
  }

  @override
  void initState() {
    super.initState();
    initiateSwitchValues();
  }

  @override
  void dispose() {
    super.dispose();
    updateUserMessageNotificationSettings();
  }

  @override
  Widget build(BuildContext context) {
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
            "new_message_notification_screen.new_message_notification".tr()),
      ),
      body: ListView(
        children: [
          TextWithTap(
            "new_message_notification_screen.message_notification".tr(),
            marginTop: 15,
            marginBottom: 5,
            marginLeft: 10,
            color: kGrayColor,
            fontSize: 11,
          ),
          Column(
            children: List.generate(messageNotificationTitles.length, (index) {
              return option(
                title: messageNotificationTitles[index],
                liveOpening: index == 0,
                messagePush: index == 1,
                acceptCalls: index == 2,
              );
            }),
          ),
          TextWithTap(
            "new_message_notification_screen.message_alert_setting".tr(),
            marginTop: 15,
            marginBottom: 5,
            marginLeft: 10,
            color: kGrayColor,
            fontSize: 11,
          ),
          Column(
            children: List.generate(messageAlertSettingsTitles.length, (index) {
              return option(
                title: messageAlertSettingsTitles[index],
                sound: index == 0,
                vibrate: index == 1,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget option({
    required String title,
    bool liveOpening = false,
    bool messagePush = false,
    bool acceptCalls = false,
    bool sound = false,
    bool vibrate = false,
  }) {
    return ContainerCorner(
      borderWidth: 0,
      marginTop: 2,
      color: QuickHelp.getColorStandard(inverse: true),
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWithTap(
              title,
              fontSize: 15,
            ),
            cupertino.CupertinoSwitch(
              value: liveOpening
                  ? isLiveOpening
                  : messagePush
                      ? isMessageNotificationSwitch
                      : acceptCalls
                          ? isAcceptCalls
                          : sound
                              ? isSound
                              : vibrate
                                  ? isVibrate
                                  : false,
              onChanged: (value) {
                if (sound) {
                  isSound = value;
                } else if (vibrate) {
                  isVibrate = value;
                } else if (liveOpening) {
                  if (isLiveOpening) {
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "",
                      message:
                          "new_message_notification_screen.live_opening_alert_explain"
                              .tr(),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText:
                          "new_message_notification_screen.confirm_close".tr(),
                      onPressed: () {
                        setState(() {
                          isLiveOpening = value;
                        });
                        QuickHelp.goBackToPreviousPage(context);
                      },
                    );
                  } else {
                    isLiveOpening = value;
                  }
                } else if (messagePush) {
                  if (isMessageNotificationSwitch) {
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "",
                      message:
                          "new_message_notification_screen.message_alert_setting_explains"
                              .tr(),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText:
                          "new_message_notification_screen.confirm_close".tr(),
                      onPressed: () {
                        setState(() {
                          isMessageNotificationSwitch = value;
                        });
                        QuickHelp.goBackToPreviousPage(context);
                      },
                    );
                  } else {
                    isMessageNotificationSwitch = value;
                  }
                } else if (acceptCalls) {
                  if (isAcceptCalls) {
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "",
                      message:
                          "new_message_notification_screen.accept_calls_explain"
                              .tr(),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText:
                          "new_message_notification_screen.confirm_close".tr(),
                      onPressed: () {
                        setState(() {
                          isAcceptCalls = value;
                        });
                        QuickHelp.goBackToPreviousPage(context);
                      },
                    );
                  } else {
                    isAcceptCalls = value;
                  }
                }
                setState(() {});
              },
              activeColor: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  updateUserMessageNotificationSettings() async {
    if (isLiveOpening != widget.currentUser!.getLiveOpeningAlert ||
        !isMessageNotificationSwitch !=
            widget.currentUser!.getMessageNotificationSwitch ||
        isAcceptCalls != widget.currentUser!.getAcceptCalls ||
        isSound != widget.currentUser!.getSound ||
        isVibrate != widget.currentUser!.getVibrate) {

      widget.currentUser!.setVibrated = isVibrate;
      widget.currentUser!.setSound = isSound;
      widget.currentUser!.setAcceptCalls = isAcceptCalls;
      widget.currentUser!.setMessageNotificationSwitch =
          isMessageNotificationSwitch;
      widget.currentUser!.setLiveOpeningAlert = isLiveOpening;

      await widget.currentUser!.save();
    }
  }
}
