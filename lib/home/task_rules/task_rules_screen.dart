// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../app/Config.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class TaskRulesScreen extends StatefulWidget {
  UserModel? currentUser;

  TaskRulesScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<TaskRulesScreen> createState() => _TaskRulesScreenState();
}

class _TaskRulesScreenState extends State<TaskRulesScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "new_task_system_screen.new_task_system".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ContainerCorner(
            borderWidth: 0,
            width: size.width,
            child: Image.asset("assets/images/host_task_description.png"),
          ),
          TextWithTap(
            "new_task_system_screen.dear_host"
                .tr(namedArgs: {"app_name": Config.appName}),
            fontWeight: FontWeight.w900,
            textItalic: true,
            fontSize: 16,
            marginLeft: 15,
            marginRight: 10,
            marginTop: 15,
          ),
          stylesTitle(title: "new_task_system_screen.rule_".tr(), width: 80),
          TextWithTap(
            "new_task_system_screen.host_daily_task".tr(),
            fontWeight: FontWeight.w600,
            fontSize: 15,
            marginLeft: 15,
            marginRight: 10,
            marginTop: 15,
          ),
          TextWithTap(
            "new_task_system_screen.daily_income".tr(),
            fontWeight: FontWeight.w800,
            fontSize: 15,
            marginLeft: 15,
            marginRight: 10,
            marginTop: 15,
            marginBottom: 15,
          ),
          stylesTitle(
              title: "new_task_system_screen.level_task".tr(), width: 130),
          levelTaskTable(),
          stylesTitle(
              title: "new_task_system_screen.new_hosts".tr(), width: 130),
          newHosts(),
          stylesTitle(
              title: "new_task_system_screen.ordinary_hosts".tr(), width: 150),
          ordinaryHosts(),
          stylesTitle(
              title: "new_task_system_screen.notice_".tr(), width: 80),
          notices(),
          SizedBox(height: 30,),
        ],
      ),
    );
  }

  Widget notices() {
    var notices = [
      "new_task_system_screen.notice_1".tr(),
      "new_task_system_screen.notice_2".tr(),
      "new_task_system_screen.notice_3".tr(),
      "new_task_system_screen.notice_4".tr(),
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 10, top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(notices.length, (index) => TextWithTap(
          notices[index],
          fontWeight: FontWeight.w600,
          fontSize: 14,
          marginBottom: 8,
        )),
      ),
    );
  }

  Widget ordinaryHosts() {
    bool isDark = QuickHelp.isDarkMode(context);
    int amountPerDay = 2000;
    int hour = 1;
    int money = 15;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 10),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepPurple.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                    text: "new_task_system_screen.not_new_host".tr(),
                  ),
                  WidgetSpan(
                    child: SizedBox(width: 3),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w800,
                    ),
                    text: "< \$$money",
                  ),
                ])),
          ),
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: isDark
                      ? kSecondaryColor.withOpacity(0.2)
                      : kSecondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                children: [
                  TextWithTap(""),
                  TextWithTap(
                    "new_task_system_screen.task_reward_of_day".tr(),
                    alignment: Alignment.center,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    marginTop: 10,
                    marginBottom: 10,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          ),
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                children: [
                  TextWithTap(
                    "new_task_system_screen.ordinary_hosts".tr(),
                    alignment: Alignment.center,
                    marginTop: 10,
                    marginBottom: 5,
                    marginLeft: 5,
                    fontWeight: FontWeight.w700,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                              amount: "$amountPerDay"),
                          alignment: Alignment.center,
                          marginTop: 3,
                          marginBottom: 3,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        Image.asset(
                          "assets/images/ic_jifen_wode.webp",
                          height: 16,
                          width: 16,
                        ),
                        TextWithTap(
                          "/H",
                          marginRight: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        TextWithTap(
                          "new_task_system_screen.hour_per_day"
                              .tr(namedArgs: {"hour": "$hour"}),
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget newHosts() {
    bool isDark = QuickHelp.isDarkMode(context);
    int amountPerDay = 10000;
    int hour = 2;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, bottom: 10),
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepPurple.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                    text: "new_task_system_screen.hosts_within".tr(),
                  ),
                  WidgetSpan(
                    child: SizedBox(width: 3),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w800,
                    ),
                    text: "new_task_system_screen.seven_days".tr(),
                  ),
                  WidgetSpan(
                    child: SizedBox(width: 3),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.deepPurple.withOpacity(0.4),
                      fontWeight: FontWeight.w700,
                    ),
                    text: "new_task_system_screen.registration_policy".tr(),
                  ),
                ])),
          ),
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                  decoration: BoxDecoration(
                    color: isDark
                        ? kSecondaryColor.withOpacity(0.2)
                        : kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  children: [
                    TextWithTap(""),
                    TextWithTap(
                      "new_task_system_screen.task_reward_of_day".tr(),
                      alignment: Alignment.center,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      marginTop: 10,
                      marginBottom: 10,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                  ]),
            ],
          ),
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                children: [
                  TextWithTap(
                    "new_task_system_screen.new_hosts".tr(),
                    alignment: Alignment.center,
                    marginTop: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                              amount: "$amountPerDay"),
                          alignment: Alignment.center,
                          marginTop: 3,
                          marginBottom: 3,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        Image.asset(
                          "assets/images/ic_jifen_wode.webp",
                          height: 16,
                          width: 16,
                        ),
                        TextWithTap(
                          "/H",
                          marginRight: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        TextWithTap(
                            "new_task_system_screen.hour_per_day"
                                .tr(namedArgs: {"hour": "$hour"}),
                            fontWeight: FontWeight.w700,
                            marginRight: 10),
                        TextWithTap(
                          "new_task_system_screen.seven_days".tr(),
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget levelTaskTable() {
    bool isDark = QuickHelp.isDarkMode(context);
    var letters = ["S", "A", "B", "C", "D", "E", "F", "G", "H", "I"];
    var lastSevenDaysAmount = [
      50000000,
      22000000,
      10000000,
      7000000,
      4000000,
      2000000,
      1200000,
      900000,
      300000,
      150000
    ];
    var dayRewardAmount = [
      70000,
      50000,
      40000,
      35000,
      28000,
      18000,
      12000,
      9000,
      5000,
      3000
    ];
    var dayRewardHour = [4, 4, 3, 3, 3, 3, 3, 3, 2, 2];

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
            },
            children: [
              TableRow(
                  decoration: BoxDecoration(
                    color: isDark
                        ? kSecondaryColor.withOpacity(0.2)
                        : kSecondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                  ),
                  children: [
                    TextWithTap(""),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Column(
                              children: [
                                TextWithTap(
                                  "new_task_system_screen.earning_in_last".tr(),
                                  alignment: Alignment.center,
                                  marginTop: 3,
                                  marginBottom: 3,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.7)
                                      : Colors.black.withOpacity(0.7),
                                  fontSize: 11,
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            "assets/images/ic_jifen_wode.webp",
                            height: 17,
                            width: 17,
                          ),
                        ],
                      ),
                    ),
                    TextWithTap(
                      "new_task_system_screen.task_reward_of_day".tr(),
                      alignment: Alignment.center,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      marginTop: 15,
                      color: isDark
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black.withOpacity(0.7),
                    ),
                  ]),
            ],
          ),
          Table(
            border: TableBorder.all(
              color: kGrayColor,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)),
            ),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(3),
            },
            children: List.generate(
              letters.length,
              (index) => TableRow(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                children: [
                  TextWithTap(
                    letters[index],
                    alignment: Alignment.center,
                    marginTop: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  TextWithTap(
                    QuickHelp.checkFundsWithString(
                        amount: "${lastSevenDaysAmount[index]}"),
                    alignment: Alignment.center,
                    fontWeight: FontWeight.w700,
                    marginTop: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                              amount: "${dayRewardAmount[index]}"),
                          alignment: Alignment.center,
                          marginTop: 3,
                          marginBottom: 3,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        Image.asset(
                          "assets/images/ic_jifen_wode.webp",
                          height: 16,
                          width: 16,
                        ),
                        TextWithTap(
                          "/H",
                          marginRight: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        TextWithTap(
                          "new_task_system_screen.hour_per_day".tr(
                              namedArgs: {"hour": "${dayRewardHour[index]}"}),
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget stylesTitle({required String title, required double width}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ContainerCorner(
          color: kSecondaryColor.withOpacity(0.1),
          borderRadius: 50,
          width: width,
          height: 14,
          child: TextWithTap(
            title,
            color: kTransparentColor,
            alignment: Alignment.center,
            marginLeft: 8,
            marginRight: 8,
            marginTop: 4,
            marginBottom: 4,
          ),
        ),
        TextWithTap(
          title,
          color: kPrimaryColor,
          alignment: Alignment.center,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          marginLeft: 8,
          marginRight: 8,
          marginBottom: 10,
        )
      ],
    );
  }
}
