// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/home/privilege/vip_privilege_details_screen.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../utils/colors.dart';
import '../wallet/wallet_screen.dart';

class VipRules extends StatefulWidget {
  UserModel? currentUser;

  VipRules({this.currentUser, Key? key}) : super(key: key);

  @override
  State<VipRules> createState() => _VipRulesState();
}

class _VipRulesState extends State<VipRules> {
  int? levelIndex;
  int? privilegeIndex;
  int? privilegeIndexRow;

  var tableTitle = [
    "vip_rules_screen.vip_level".tr(),
    "vip_rules_screen.activation_points_required".tr(),
    "vip_rules_screen.maintainence_points_required".tr(),
  ];

  var vipText = [
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "1"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "2"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "3"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "4"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "5"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "6"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "7"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "8"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "9"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "10"}).toUpperCase(),
  ];

  var vipTextTableTwo = [
    "vip_rules_screen.non_vip".tr(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "1"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "2"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "3"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "4"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "5"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "6"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "7"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "8"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "9"}).toUpperCase(),
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "10"}).toUpperCase(),
  ];

  var privilegeTitle = [
    "vip_rules_screen.privilege_".tr(),
    "vip_rules_screen.non_vip".tr(),
  ];

  var actionPoints = [
    "10,000",
    "50,000",
    "100,000",
    "200,000",
    "500,000",
    "1,000,000",
    "2,000,000",
    "5,000,000",
    "1,0000,000",
    "20,000,000",
  ];

  var maintainPoints = [
    "6,000",
    "30,000",
    "60,000",
    "120,000",
    "300,000",
    "600,000",
    "1,200,000",
    "3,000,000",
    "6,0000,000",
    "12,000,000",
  ];

  var memberPrivilegesText = [
    "guardian_and_vip_screen.up_notification".tr(),
    "guardian_and_vip_screen.Special_Special".tr(),
    "guardian_and_vip_screen.vip_badge".tr(),
    "guardian_and_vip_screen.Avatar_Frame".tr(),
    "guardian_and_vip_screen.vip_name_card".tr(),
    "guardian_and_vip_screen.exclusive_customer".tr(),
    "guardian_and_vip_screen.free_private".tr(),
    "guardian_and_vip_screen.vip_seat".tr(),
    "guardian_and_vip_screen.message_background".tr(),
    "guardian_and_vip_screen.Highlighted_private".tr(),
    "guardian_and_vip_screen.status_advantages".tr(),
    "guardian_and_vip_screen.ban_messaging_room".tr(),
    "guardian_and_vip_screen.remove_users_rooms".tr(),
    "guardian_and_vip_screen.exclusive_gifts".tr(),
    "guardian_and_vip_screen.invisible_ranking".tr(),
    "guardian_and_vip_screen.hide_contributors".tr(),
    "guardian_and_vip_screen.invisible_follow".tr(),
    "guardian_and_vip_screen.message_ban_removal_immunity".tr(),
    "guardian_and_vip_screen.bullet_messages".tr(),
    "guardian_and_vip_screen.recommend_".tr(),
  ];


  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kDisabledColor100,
      appBar: AppBar(
        backgroundColor: kContentDarkShadow200,
        surfaceTintColor: kContentDarkShadow200,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () => QuickHelp.goBackToPreviousPage(context),
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.white,
            size: 22,
          ),
        ),
        title: TextWithTap(
          "vip_rules_screen.vip_rule".tr(),
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          Image.asset(
            "assets/images/ic_vip_rule_url.png",
            width: size.width,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17, top: 17, right: 17),
            child: Row(
              children: [
                ContainerCorner(
                  color: Colors.red,
                  height: 5,
                  width: 5,
                  borderRadius: 100,
                ),
                TextWithTap(
                  "vip_rules_screen.how_".tr(),
                  fontWeight: FontWeight.bold,
                  marginLeft: 6,
                  fontSize: 15,
                ),
              ],
            ),
          ),
          TextWithTap(
            "vip_rules_screen.activate_vip_time_zone".tr(),
            marginLeft: 17,
            fontSize: 14,
            marginTop: 8,
            marginRight: 17,
            marginBottom: 17,
          ),
          ContainerCorner(
            color: isDark ? kContentColorLightTheme : kDisabledGrayColor200,
            width: size.width,
            height: 8,
            marginBottom: 17,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17),
            child: Row(
              children: [
                ContainerCorner(
                  color: Colors.red,
                  height: 5,
                  width: 5,
                  borderRadius: 100,
                ),
                TextWithTap(
                  "vip_rules_screen.maintain_increase".tr(),
                  fontWeight: FontWeight.bold,
                  marginLeft: 6,
                  fontSize: 15,
                ),
              ],
            ),
          ),
          TextWithTap(
            "vip_rules_screen.after_become_vip".tr(),
            marginLeft: 17,
            fontSize: 14,
            marginTop: 8,
            marginRight: 17,
            marginBottom: 17,
          ),
          vipLevelTable(),
          ContainerCorner(
            color: isDark ? kContentColorLightTheme : kDisabledGrayColor200,
            width: size.width,
            height: 8,
            marginBottom: 17,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ContainerCorner(
                      color: Colors.red,
                      height: 5,
                      width: 5,
                      borderRadius: 100,
                    ),
                    TextWithTap(
                      "vip_rules_screen.vip_level_privileges".tr(),
                      marginLeft: 6,
                      fontSize: 15,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => QuickHelp.goToNavigatorScreen(
                    context,
                    VipPrivilegeDetailsScreen(
                      currentUser: widget.currentUser,
                      initialIndex: 0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "vip_rules_screen.detailed_privileges".tr(),
                        fontSize: 15,
                        color: Colors.red,
                        marginRight: 6,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: Colors.red,
                        size: 12,
                        weight: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          privilegeTable(),
          TextWithTap(
            "vip_rules_screen.note_more_privilege".tr(),
            color: kSecondaryGrayColor200,
            alignment: Alignment.center,
          ),
          SizedBox(height: 80),
        ],
      ),
      floatingActionButton: buttons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget vipLevelTable() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(left: 17, right: 17, bottom: 17),
      child: ContainerCorner(
        radiusTopLeft: 10,
        radiusTopRight: 10,
        radiusBottomLeft: 10,
        radiusBottomRight: 10,
        borderColor: kRoseVip500,
        child: Column(
          children: [
            Table(
              columnWidths: {
                0: FixedColumnWidth(size.width/4),
                1: FixedColumnWidth(size.width/3),
                2: FixedColumnWidth(size.width/3),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: kGrayWhite100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      topRight: Radius.circular(9),
                    ),
                  ),
                  children: List.generate(
                    3, (index) => TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment.intrinsicHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: TextWithTap(
                              tableTitle[index],
                              color: kColdVip100,
                              alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              marginTop: 10,
                              marginBottom: 10,
                            ),
                          ),
                          Visibility(
                            visible: index == 0 || index == 1,
                            child: ContainerCorner(
                              color: kGreyColor5,
                              width: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: List.generate(vipText.length, (index) {
                setState(() {
                  levelIndex = index;
                });
                return Column(
                  children: [
                    ContainerCorner(
                      color: kGreyColor5,
                      height: 1,
                    ),
                    Table(
                      columnWidths: {
                        0: FixedColumnWidth(size.width/4),
                        1: FixedColumnWidth(size.width/3),
                        2: FixedColumnWidth(size.width/3),
                      },
                      children: [
                        TableRow(
                          children: List.generate(
                            tableTitle.length,
                            (index) => TableCell(
                              verticalAlignment:
                                  TableCellVerticalAlignment.intrinsicHeight,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Visibility(
                                    visible: index == 0,
                                    child: Expanded(
                                      child: TextWithTap(
                                        vipText[levelIndex!],
                                        color: kRoseVip600,
                                        alignment: Alignment.center,
                                        textAlign: TextAlign.center,
                                        marginTop: 8,
                                        marginBottom: 8,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 1,
                                    child: Expanded(
                                      child: TextWithTap(
                                        actionPoints[levelIndex!],
                                        color: isDark ? kGray : kColdVip100,
                                        alignment: Alignment.center,
                                        textAlign: TextAlign.center,
                                        marginTop: 8,
                                        marginBottom: 8,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 2,
                                    child: Expanded(
                                      child: TextWithTap(
                                        maintainPoints[levelIndex!],
                                        color: isDark ? kGray : kColdVip100,
                                        alignment: Alignment.center,
                                        textAlign: TextAlign.center,
                                        marginTop: 8,
                                        marginBottom: 8,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index != 2,
                                    child: ContainerCorner(
                                      color: kGreyColor5,
                                      width: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget privilegeTable() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(left: 17, right: 17, bottom: 17),
      child: ContainerCorner(
        radiusTopLeft: 10,
        radiusTopRight: 10,
        radiusBottomLeft: 10,
        radiusBottomRight: 10,
        borderColor: kRoseVip500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  columnWidths: {
                    0: FixedColumnWidth(size.width/2.4),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: kGrayWhite100,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(9),
                        ),
                      ),
                      children: [
                        TableCell(
                          verticalAlignment:
                              TableCellVerticalAlignment.intrinsicHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: TextWithTap(
                                  privilegeTitle[0],
                                  color: kColdVip100,
                                  alignment: Alignment.topCenter,
                                  marginBottom: 16,
                                  marginTop: 10,
                                ),
                              ),
                              ContainerCorner(
                                color: kGreyColor5,
                                width: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: List.generate(
                    memberPrivilegesText.length,
                    (index) {
                      setState(() {
                        privilegeIndex = index;
                      });
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContainerCorner(
                            color: kGreyColor5,
                            height: 1,
                            width: size.width / 2.40,
                          ),
                          Table(
                            columnWidths: {
                              0: FixedColumnWidth(size.width/2.4),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: index == 19
                                        ? Radius.circular(10)
                                        : Radius.circular(0),
                                  ),
                                ),
                                children: [
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment
                                            .intrinsicHeight,
                                    child: ContainerCorner(
                                      height: 48,
                                      borderWidth: 0,
                                      radiusBottomLeft: privilegeIndex == 19 ? 10: 0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: TextWithTap(
                                              memberPrivilegesText[
                                                  privilegeIndex!],
                                              fontSize: 13,
                                              color: isDark ? kGray : kColdVip100,
                                              alignment: Alignment.topCenter,
                                              marginBottom: 13,
                                              textAlign: TextAlign.center,
                                              marginTop: 7,
                                            ),
                                          ),
                                          ContainerCorner(
                                            color: kGreyColor5,
                                            width: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: ContainerCorner(
                width: size.width,
                height: 1026,
                borderWidth: 0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Row(
                      children: List.generate(vipTextTableTwo.length, (index){
                        setState(() {
                          privilegeIndexRow = index;
                        });
                        return Column(
                          children: [
                            Table(
                              columnWidths: {
                                0: FixedColumnWidth(size.width/4),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: kGrayWhite100,
                                    borderRadius: BorderRadius.only(
                                      topRight: index == 10
                                          ? Radius.circular(9)
                                          : Radius.circular(0),
                                    ),
                                  ),
                                  children: [
                                    TableCell(
                                      verticalAlignment:
                                      TableCellVerticalAlignment.intrinsicHeight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            child: TextWithTap(
                                              vipTextTableTwo[index],
                                              color: kColdVip100,
                                              alignment: Alignment.topCenter,
                                              marginBottom: 16,
                                              marginTop: 10,
                                            ),
                                          ),
                                          Visibility(
                                            visible: privilegeIndexRow != 10,
                                            child: ContainerCorner(
                                              color: kGreyColor5,
                                              width: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],),
                              ],
                            ),
                            Column(
                              children: List.generate(
                                memberPrivilegesText.length, (index) {
                                  setState(() {
                                    privilegeIndex = index;
                                  });
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ContainerCorner(
                                        color: kGreyColor5,
                                        height: 1,
                                        width: size.width / 4,
                                      ),
                                      Table(
                                        columnWidths: {
                                          0: FixedColumnWidth(size.width/4),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              TableCell(
                                                verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
                                                child: ContainerCorner(
                                                  height: 48,
                                                  borderWidth: 0,
                                                  color: privilegeIndexRow == 0 ? kGrayWhite100 : Colors.transparent,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceAround,
                                                    children: [
                                                      Visibility(
                                                        visible: privilegeIndexRow == 0,
                                                        child: Expanded(
                                                          child: TextWithTap(
                                                            "vip_rules_screen.none_".tr(),
                                                            fontSize: 13,
                                                            color: kColdVip100,
                                                            alignment: Alignment.topCenter,
                                                            marginBottom: 10,
                                                            textAlign: TextAlign.center,
                                                            marginTop: 10,
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: privilegeIndexRow != 0,
                                                        child: privilegeEnable(
                                                          indexRow: privilegeIndexRow!,
                                                          indexColumn: index,
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: privilegeIndexRow != 10,
                                                        child: ContainerCorner(
                                                          color: kGreyColor5,
                                                          width: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },),
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

  Widget privilegeEnable({
    required int indexRow,
    required int indexColumn,
  }){
    if(indexRow == 10){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 9){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 8 && indexColumn != 19){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 7 && indexColumn != 19){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 6 && indexColumn != 19 && indexColumn != 18){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 5 && indexColumn != 19 && indexColumn != 18 && indexColumn != 17){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 4 && indexColumn != 19 && indexColumn != 18 && indexColumn != 17&& indexColumn != 16 && indexColumn != 15){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 3 && indexColumn != 19 && indexColumn != 18 && indexColumn != 17&& indexColumn != 16 && indexColumn != 15){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 2 && indexColumn != 19 && indexColumn != 18 && indexColumn != 17&& indexColumn != 16 && indexColumn != 15 && indexColumn != 14){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else if(indexRow == 1 && indexColumn != 19 && indexColumn != 18 && indexColumn != 17&& indexColumn != 16 && indexColumn != 15 && indexColumn != 14 && indexColumn != 13 && indexColumn != 12){
      return Expanded(
        child: Icon(
          Icons.check,
          color: kGreyColor2,
          size: 20,
        ),
      );
    }else{
      return Expanded(child: SizedBox());
    }
  }

  Widget buttons() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          bottom: 30,
          child: ContainerCorner(
            colors: [Colors.white, kRoseVip300],
            height: 45,
            borderRadius: 50,
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            onTap: () {
              QuickHelp.goToNavigatorScreenForResult(
                context,
                WalletScreen(
                  currentUser: widget.currentUser,
                ),
              );
            },
            child: Center(
              child: TextWithTap(
                "guardian_and_vip_screen.recharge_unlock_vip".tr(),
                color: Colors.black,
                marginLeft: 8,
                marginRight: 8,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
