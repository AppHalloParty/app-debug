// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../ui/container_with_corner.dart';
import '../privilege/vip_exp_ranking_screen.dart';
import '../privilege/vip_privilege_details_screen.dart';
import '../profile/user_profile_screen.dart';
import '../vip_rules/vip_rules.dart';
import '../wallet/wallet_screen.dart';

class GuardianAndVipStoreScreen extends StatefulWidget {
  UserModel? currentUser;
  int? initialIndex;

  GuardianAndVipStoreScreen(
      {this.initialIndex, this.currentUser, Key? key})
      : super(key: key);

  @override
  State<GuardianAndVipStoreScreen> createState() =>
      _GuardianAndVipStoreScreenState();
}

class _GuardianAndVipStoreScreenState extends State<GuardianAndVipStoreScreen>
    with TickerProviderStateMixin {

  final ScrollController memberSystemController = ScrollController();

  /* int selectedVipTypeAmount() {
    if (vipTabsIndex == 0) {
      return normalVipPricePerMonth;
    } else if (vipTabsIndex == 1) {
      return superVipPricePerMonth;
    } else if (vipTabsIndex == 2) {
      return diamondVipPricePerMonth;
    }
    return 0;
  }*/

  UserModel? userToGuard;

  var privilegesUrlsDisable = [
    "assets/images/ic_privilege_desable1.png",
    "assets/images/ic_privilege_desable2.png",
    "assets/images/ic_privilege_desable3.png",
    "assets/images/ic_privilege_desable4.png",
    "assets/images/ic_privilege_desable5.png",
    "assets/images/ic_privilege_desable6.png",
    "assets/images/ic_privilege_desable7.png",
    "assets/images/ic_privilege_desable8.png",
    "assets/images/ic_privilege_desable9.png",
    "assets/images/ic_privilege_desable10.png",
    "assets/images/ic_privilege_desable11.png",
    "assets/images/ic_privilege_desable12.png",
    "assets/images/ic_privilege_desable13.png",
    "assets/images/ic_privilege_desable14.png",
    "assets/images/ic_privilege_desable15.png",
    "assets/images/ic_privilege_desable16.png",
    "assets/images/ic_privilege_desable17.png",
    "assets/images/ic_privilege_desable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsEnable = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_enable15.png",
    "assets/images/ic_privilege_enable16.png",
    "assets/images/ic_privilege_enable17.png",
    "assets/images/ic_privilege_enable18.png",
    "assets/images/ic_privilege_enable19.png",
    "assets/images/ic_privilege_enable20.png",
  ];

  var privilegesUrlsUnable12 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_desable13.png",
    "assets/images/ic_privilege_desable14.png",
    "assets/images/ic_privilege_desable15.png",
    "assets/images/ic_privilege_desable16.png",
    "assets/images/ic_privilege_desable17.png",
    "assets/images/ic_privilege_desable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsUnable14 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_desable15.png",
    "assets/images/ic_privilege_desable16.png",
    "assets/images/ic_privilege_desable17.png",
    "assets/images/ic_privilege_desable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsUnable15 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_enable15.png",
    "assets/images/ic_privilege_desable16.png",
    "assets/images/ic_privilege_desable17.png",
    "assets/images/ic_privilege_desable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsUnable17 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_enable15.png",
    "assets/images/ic_privilege_enable16.png",
    "assets/images/ic_privilege_enable17.png",
    "assets/images/ic_privilege_desable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsUnable18 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_enable15.png",
    "assets/images/ic_privilege_enable16.png",
    "assets/images/ic_privilege_enable17.png",
    "assets/images/ic_privilege_enable18.png",
    "assets/images/ic_privilege_desable19.png",
    "assets/images/ic_privilege_desable20.png",
  ];

  var privilegesUrlsUnable19 = [
    "assets/images/ic_privilege_enable1.png",
    "assets/images/ic_privilege_enable2.png",
    "assets/images/ic_privilege_enable3.png",
    "assets/images/ic_privilege_enable4.png",
    "assets/images/ic_privilege_enable5.png",
    "assets/images/ic_privilege_enable6.png",
    "assets/images/ic_privilege_enable7.png",
    "assets/images/ic_privilege_enable8.png",
    "assets/images/ic_privilege_enable9.png",
    "assets/images/ic_privilege_enable10.png",
    "assets/images/ic_privilege_enable11.png",
    "assets/images/ic_privilege_enable12.png",
    "assets/images/ic_privilege_enable13.png",
    "assets/images/ic_privilege_enable14.png",
    "assets/images/ic_privilege_enable15.png",
    "assets/images/ic_privilege_enable16.png",
    "assets/images/ic_privilege_enable17.png",
    "assets/images/ic_privilege_enable18.png",
    "assets/images/ic_privilege_enable19.png",
    "assets/images/ic_privilege_desable20.png",
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
  
  var vipText = [
    "guardian_and_vip_screen.vip_"
        .tr(namedArgs: {"vip_number": "0"}).toUpperCase(),
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

  var selectedGuardianType = [0];
  var guardianPeriod = [1, 3, 6, 12];
  var selectedGuardianPeriod = [1];

  int vipUpgrade = 0;
  int receivingAmount = 0;

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.95);

  int numRanking = 42;
  int change = 0;
  //double currentCredit = 0;
  double getMaxCredit = 10000;
  double rankUp = 0;

  Color _appBarColor = Colors.transparent;
  int showPrivilege = 0;
  int privilege = 20;
  int initialLevel = 0;
  int level = 0;
  int points = 0;
  String pointsAmount = "";

  void _onPageChanged(int _currentPage) {
    setState(() {
      if (_currentPage == 0) {
        showPrivilege = 0;
      } else if (_currentPage == 1) {
        showPrivilege = 12;
      } else if (_currentPage == 2) {
        showPrivilege = 14;
      } else if (_currentPage == 3 || _currentPage == 4) {
        showPrivilege = 15;
      } else if (_currentPage == 5) {
        showPrivilege = 17;
      } else if (_currentPage == 6) {
        showPrivilege = 18;
      } else if (_currentPage == 7 || _currentPage == 8) {
        showPrivilege = 19;
      } else if (_currentPage == 9 || _currentPage == 10) {
        showPrivilege = 20;
      } else {
        showPrivilege = 20;
      }
    });
  }

  void _maxCredit(int changeMaxCredit) {
    setState(() {
      if (changeMaxCredit == 0 || changeMaxCredit == 1) {
        getMaxCredit = 10000;
      } else if (changeMaxCredit == 2) {
        getMaxCredit = 50000;
      } else if (changeMaxCredit == 3) {
        getMaxCredit = 100000;
      } else if (changeMaxCredit == 4) {
        getMaxCredit = 200000;
      }else if (changeMaxCredit == 5) {
        getMaxCredit = 500000;
      } else if (changeMaxCredit == 6) {
        getMaxCredit = 1000000;
      } else if (changeMaxCredit == 7) {
        getMaxCredit = 2000000;
      }else if (changeMaxCredit == 8) {
        getMaxCredit = 5000000;
      } else if (changeMaxCredit == 9) {
        getMaxCredit = 10000000;
      }else if (changeMaxCredit == 10) {
        getMaxCredit = 20000000;
      } else {
        getMaxCredit = 10000;
      }
    });
  }

  void rankUpCalc(){
    setState(() {
      if( widget.currentUser!.getCredits! <= 20000000){
        rankUp = getMaxCredit -  widget.currentUser!.getCredits! + 0.0;;
      }else{
        rankUp = 0;
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.offset >= 85) {
      setState(() {
        _appBarColor = QuickHelp.isDarkMode(context) ? kContentDarkShadow : Colors.white;
      });
    } else {
      setState(() {
        _appBarColor = Colors.transparent;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _maxCredit(QuickHelp.levelUserPage(widget.currentUser!.getCredits! + 0.0));
    rankUpCalc();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Column(
      children: [
        ContainerCorner(
          color: isDark ? kContentColorLightTheme : Colors.white,
          height: size.height / 17.3,
          width: size.width,
          borderWidth: 0,
        ),
        Flexible(
          child: Scaffold(
            backgroundColor: isDark ? kContentColorLightTheme : kDisabledColor100,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(35),
              child: AppBar(
                backgroundColor: _appBarColor,
                automaticallyImplyLeading: false,
                leading: GestureDetector(
                  onTap: () => QuickHelp.goBackToPreviousPage(context),
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    color: isDark ? Colors.white : Colors.black,
                    size: 20,
                  ),
                ),
                centerTitle: true,
                title: TextWithTap(
                  "guardian_and_vip_screen.vip_privileges".tr(),
                  fontSize: 16,
                ),
                actions: [
                  ContainerCorner(
                    onTap: ()=> QuickHelp.goToNavigatorScreen(context, VipRules(
                      currentUser: widget.currentUser,
                    ),),
                    alignment: Alignment.center,
                    borderWidth: 2,
                    borderColor: isDark ? Colors.white : Colors.black,
                    borderRadius: 100,
                    height: 24,
                    width: 24,
                    marginRight: 20,
                    child: TextWithTap(
                      "?",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            body: ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(vertical: 0),
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    ContainerCorner(
                      height: size.height / 4.2,
                      width: size.width,
                      radiusBottomRight: 40,
                      radiusBottomLeft: 40,
                      color: kRoseVip100,
                    ),
                    Positioned(
                      top: 85,
                      child: ContainerCorner(
                        onTap: ()=> QuickHelp.goToNavigatorScreen(context,
                          VipExpRankinScreen(
                            currentUser: widget.currentUser,
                          ),
                        ),
                        width: size.width / 1.1,
                        borderRadius: 15,
                        color: isDark ? kContentDarkShadow : Colors.white,
                        shadowColor: isDark ? Colors.transparent : kRoseVip200,
                        setShadowToBottom: true,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  QuickActions.avatarWidget(
                                    widget.currentUser!,
                                    width: 55,
                                    height: 55,
                                    hideAvatarFrame: true,
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextWithTap(
                                        widget.currentUser!.getFullName!,
                                        fontSize: 15,
                                        marginBottom: 4,
                                      ),
                                      Visibility(
                                        visible: !widget.currentUser!.getIsUserVip!,
                                        child: TextWithTap(
                                          "guardian_and_vip_screen.you_arent_vip".tr(),
                                          color: isDark ? Colors.white: kGray,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(left: 15, top: 8, right: 15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextWithTap(
                                          "guardian_and_vip_screen.current_ranking".tr(),
                                          color: isDark ? Colors.white: kGray,
                                          fontSize: 11,
                                          marginBottom: 4,
                                        ),
                                        Row(
                                          children: [
                                            TextWithTap(
                                              "guardian_and_vip_screen.none_currently"
                                                  .tr(),
                                              fontSize: 15,
                                              marginRight: 6,
                                            ),
                                            Icon(
                                              Icons.arrow_upward,
                                              color: Colors.orange,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: size.width / 3.5,
                                            child: TextWithTap(
                                              "guardian_and_vip_screen.exp_required".tr(),
                                              color: isDark ? Colors.white: kGray,
                                              fontSize: 11,
                                              marginBottom: 4,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          TextWithTap(
                                            "guardian_and_vip_screen.num_ranking".tr(namedArgs: {
                                              "num_ranking": "${rankUp.toInt()}"
                                            }),
                                            fontSize: 15,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                TextWithTap(
                  "guardian_and_vip_screen.member_system".tr(),
                  fontSize: 16,
                  marginTop: 95,
                  marginBottom: 15,
                  marginLeft: 15,
                ),
                ContainerCorner(
                  height: size.height / 4.5,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: vipText.length,
                    onPageChanged: (onChange){
                      _onPageChanged(onChange);
                      _maxCredit(onChange);
                    },
                    itemBuilder: (context, index) {
                      return ContainerCorner(
                        color: kMemberSystemColor,
                        height: 180,
                        width: size.width / 1.2,
                        borderRadius: 15,
                        marginLeft: 4,
                        marginRight: 4,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextWithTap(
                                  vipText[index],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                  color: Colors.white,
                                  marginTop: 22,
                                  marginLeft: 15,
                                ),
                                IntrinsicWidth(
                                  child: IntrinsicHeight(
                                    child: ContainerCorner(
                                      color: kGreyColor3,
                                      radiusBottomLeft: 25,
                                      radiusTopLeft: 25,
                                      marginTop: 6,
                                      child: TextWithTap(
                                        QuickHelp.levelUser(index, currentCredit:  widget.currentUser!.getCredits! + 0.0),
                                        fontSize: 12,
                                        color: Colors.white,
                                        marginLeft: 17,
                                        marginBottom: 2,
                                        marginTop: 2,
                                        marginRight: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TextWithTap(
                              "guardian_and_vip_screen.upgrade_vip"
                                  .tr(namedArgs: {
                                "vip_upgrade": "${numVipUpgrade(index)}",
                                "amount_receive": "${numReceivingAmount(index)}"
                              }),
                              fontSize: 12,
                              color: Colors.white,
                              marginTop: 6,
                              marginLeft: 15,
                              marginRight: 15,
                              marginBottom: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWithTap(
                                  "guardian_and_vip_screen.level_".tr(
                                      namedArgs: {"level": "$initialLevel"}),
                                  color: Colors.white,
                                  marginRight: 6,
                                  fontSize: 12,
                                ),
                                ContainerCorner(
                                  borderRadius: 50,
                                  height: 11,
                                  width: size.width / 2,
                                  borderWidth: 0,
                                  colors: [Colors.deepPurple, Colors.green],
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: FAProgressBar(
                                      currentValue:  widget.currentUser!.getCredits! + 0.0,
                                      size: 5,
                                      maxValue: getMaxCredit,
                                      changeColorValue: 0,
                                      changeProgressColor: Colors.white,
                                      backgroundColor: kGreyColor4,
                                      progressColor: Colors.transparent,
                                      animatedDuration: const Duration(seconds: 2),
                                      direction: Axis.horizontal,
                                      border: Border.all(
                                        color: kTransparentColor,
                                        width: 0.0,
                                      ),
                                      verticalDirection: VerticalDirection.up,
                                      displayText: '%',
                                      displayTextStyle: GoogleFonts.roboto(
                                        color: kTransparentColor,
                                        fontSize: 1,
                                      ),
                                      formatValueFixed: 0,
                                    ),
                                  ),
                                ),
                                TextWithTap(
                                  "guardian_and_vip_screen.level_".tr(
                                      namedArgs: {
                                        "level": "${numVipUpgrade(index)}"
                                      }),
                                  color: Colors.white,
                                  marginLeft: 6,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                            TextWithTap(
                              "guardian_and_vip_screen.points_".tr(namedArgs: {
                                "points": "${ widget.currentUser!.getCredits! + 0.0.toInt()}",
                                "points_amount": showPointsAmount(index)
                              }),
                              fontSize: 13,
                              color: Colors.white,
                              marginTop: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                TextWithTap(
                  "guardian_and_vip_screen.member_privileges".tr(namedArgs: {
                    "privileges_show": "$showPrivilege",
                    "privileges": "$privilege"
                  }),
                  fontSize: 16,
                  marginTop: 15,
                  marginBottom: 16,
                  marginLeft: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 18),
                  child: GridView.count(
                    padding: EdgeInsets.all(0.0),
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    crossAxisSpacing: 13,
                    childAspectRatio: .90,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      privilegesUrlsDisable.length,
                      (index) => ButtonWidget(
                        paddingTop: 6,
                        marginBottom: 4,
                        onTap: () => QuickHelp.goToNavigatorScreen(
                          context,
                          VipPrivilegeDetailsScreen(
                            currentUser: widget.currentUser,
                            initialIndex: index,
                          ),
                        ),
                        child: Column(
                          children: [
                            IntrinsicHeight(
                              child: IntrinsicWidth(
                                child: ContainerCorner(
                                  alignment: Alignment.center,
                                  borderRadius: 50,
                                  color: kOrangeColorDisable.withOpacity(0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      listMembersPrivileges(index),
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: TextWithTap(
                                memberPrivilegesText[index],
                                color: kDisabledGrayColor100,
                                fontSize: 10,
                                textAlign: TextAlign.center,
                                marginTop: 5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                ContainerCorner(
                  onTap: () => QuickHelp.goToNavigatorScreen(
                    context,
                    VipPrivilegeDetailsScreen(
                      currentUser: widget.currentUser,
                      initialIndex: 0,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  marginLeft: 8,
                  child: Column(
                    children: [
                      IntrinsicHeight(
                        child: IntrinsicWidth(
                          child: ContainerCorner(
                            alignment: Alignment.center,
                            borderRadius: 50,
                            color: kOrangeColorDisable.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "assets/images/ic_privilege.png",
                                width: 22,
                                height: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextWithTap(
                        "guardian_and_vip_screen.coming_soon".tr(),
                        color: kDisabledGrayColor100,
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        marginTop: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: buttons(),
          ),
        ),
      ],
    );
  }

  int numVipUpgrade(int index) {
    if (index == 0 || index == 1) {
      return vipUpgrade = 1;
    } else if (index == 2) {
      return vipUpgrade = 2;
    } else if (index == 3) {
      return vipUpgrade = 3;
    } else if (index == 4) {
      return vipUpgrade = 4;
    } else if (index == 5) {
      return vipUpgrade = 5;
    } else if (index == 6) {
      return vipUpgrade = 6;
    } else if (index == 7) {
      return vipUpgrade = 7;
    } else if (index == 8) {
      return vipUpgrade = 8;
    } else if (index == 9) {
      return vipUpgrade = 9;
    } else if (index == 10) {
      return vipUpgrade = 10;
    }
    return 0;
  }

  String showPointsAmount(int index) {
    if (index == 0 || index == 1) {
      return pointsAmount = "10,000";
    } else if (index == 2) {
      return pointsAmount = "50,000";
    } else if (index == 3) {
      return pointsAmount = "100,000";
    } else if (index == 4) {
      return pointsAmount = "200,000";
    } else if (index == 5) {
      return pointsAmount = "500,0000";
    } else if (index == 6) {
      return pointsAmount = "1,000,000";
    } else if (index == 7) {
      return pointsAmount = "2,000,000";
    } else if (index == 8) {
      return pointsAmount = "5,000,000";
    } else if (index == 9) {
      return pointsAmount = "10,000,000";
    } else if (index == 10) {
      return pointsAmount = "20,000,000";
    }
    return "0,0";
  }

  int numReceivingAmount(int index) {
    if (index == 0 || index == 1) {
      return receivingAmount = 10000;
    } else if (index == 2) {
      return receivingAmount = 50000;
    } else if (index == 3) {
      return receivingAmount = 100000;
    } else if (index == 4) {
      return receivingAmount = 200000;
    } else if (index == 5) {
      return receivingAmount = 500000;
    } else if (index == 6) {
      return receivingAmount = 1000000;
    } else if (index == 7) {
      return receivingAmount = 2000000;
    } else if (index == 8) {
      return receivingAmount = 5000000;
    } else if (index == 9) {
      return receivingAmount = 10000000;
    } else if (index == 10) {
      return receivingAmount = 20000000;
    }
    return 0;
  }

  int showLevel(int index) {
    if (index == 0 || index == 1) {
      return level = 1;
    } else if (index == 2) {
      return level = 2;
    } else if (index == 3) {
      return level = 3;
    } else if (index == 4) {
      return level = 4;
    } else if (index == 5) {
      return level = 5;
    } else if (index == 6) {
      return level = 6;
    } else if (index == 7) {
      return level = 7;
    } else if (index == 8) {
      return level = 8;
    } else if (index == 9) {
      return level = 9;
    } else if (index == 10) {
      return level = 10;
    }
    return 0;
  }

  String listMembersPrivileges(int index) {
    if (showPrivilege == 0) {
      return privilegesUrlsDisable[index];
    } else if (showPrivilege == 12) {
      return privilegesUrlsUnable12[index];
    } else if (showPrivilege == 14) {
      return privilegesUrlsUnable14[index];
    } else if (showPrivilege == 15) {
      return privilegesUrlsUnable15[index];
    } else if (showPrivilege == 17) {
      return privilegesUrlsUnable17[index];
    } else if (showPrivilege == 18) {
      return privilegesUrlsUnable18[index];
    } else if (showPrivilege == 19) {
      return privilegesUrlsUnable19[index];
    }
    return privilegesUrlsEnable[index];
  }

  Widget membersSystems() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: kMemberSystemColor,
      height: 180,
      width: size.width / 1.1,
      borderRadius: 15,
      marginLeft: 4,
      marginRight: 4,
    );
  }

  int funcChange() {
    if (memberSystemController == 1) {
      return change = 1;
    } else {
      return change = 2;
    }
  }

  Widget peopleGuardingMe() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(
        UserModel.keyObjectId, widget.currentUser!.getPeopleGuardingMe!);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          UserModel user = snapshot.loadedData!;

          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ContainerCorner(
              onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  UserProfileScreen(
                    currentUser: widget.currentUser,
                    mUser: user,
                    isFollowing: false,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickActions.avatarWidget(user,
                          width: size.width / 6, height: size.width / 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWithTap(
                              user.getFullName!,
                              fontSize: size.width / 23,
                              fontWeight: FontWeight.w600,
                              marginBottom: 4,
                            ),
                            Row(
                              children: [
                                QuickActions.getGender(
                                    currentUser: user, context: context),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.giftReceivedLevel(
                                  receivedGifts: user.getDiamondsTotal!,
                                  width: 35,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.wealthLevel(
                                  credit: user.getCreditsSent!,
                                  width: 35,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWithTap(
                                  "tab_profile.id_".tr(),
                                  fontSize: size.width / 33,
                                  fontWeight: FontWeight.w900,
                                ),
                                TextWithTap(
                                  widget.currentUser!.getUid!.toString(),
                                  fontSize: size.width / 33,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                                Icon(
                                  Icons.copy,
                                  color: kGrayColor,
                                  size: size.width / 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        borderWidth: 0,
        width: size.width,
        height: size.height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/szy_kong_icon.png",
              height: size.width / 2,
              width: size.width / 2,
            ),
            TextWithTap(
              "guardian_and_vip_screen.no_one_guard_you_title".tr(),
            ),
            TextWithTap(
              "guardian_and_vip_screen.no_one_guard_you_explain".tr(),
              color: kGrayColor,
              fontSize: 12,
              marginTop: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget peopleIGuard() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(
        UserModel.keyObjectId, widget.currentUser!.getMyGuardians!);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          UserModel user = snapshot.loadedData!;

          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ContainerCorner(
              onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  UserProfileScreen(
                    currentUser: widget.currentUser,
                    mUser: user,
                    isFollowing: false,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickActions.avatarWidget(user,
                          width: size.width / 6, height: size.width / 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWithTap(
                              user.getFullName!,
                              fontSize: size.width / 23,
                              fontWeight: FontWeight.w600,
                              marginBottom: 4,
                            ),
                            Row(
                              children: [
                                QuickActions.getGender(
                                    currentUser: user, context: context),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.giftReceivedLevel(
                                  receivedGifts: user.getDiamondsTotal!,
                                  width: 35,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.wealthLevel(
                                  credit: user.getCreditsSent!,
                                  width: 35,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWithTap(
                                  "tab_profile.id_".tr(),
                                  fontSize: size.width / 33,
                                  fontWeight: FontWeight.w900,
                                ),
                                TextWithTap(
                                  widget.currentUser!.getUid!.toString(),
                                  fontSize: size.width / 33,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                                Icon(
                                  Icons.copy,
                                  color: kGrayColor,
                                  size: size.width / 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        borderWidth: 0,
        width: size.width,
        height: size.height / 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/szy_kong_icon.png",
              height: size.width / 2,
              width: size.width / 2,
            ),
            TextWithTap(
              "guardian_and_vip_screen.you_have_no_guard_title".tr(),
            ),
            TextWithTap(
              "guardian_and_vip_screen.you_have_no_guard_explain".tr(),
              color: kGrayColor,
              fontSize: 12,
              marginTop: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget buttons() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      width: size.width,
      marginBottom: 20,
      marginTop: 5,
      colors: [kRoseVip400, kRoseVip300],
      height: 45,
      marginLeft: 30,
      marginRight: 30,
      borderRadius: 50,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      onTap: () {
        QuickHelp.goToNavigatorScreenForResult(
          context,
          WalletScreen(
            currentUser: widget.currentUser,
          ),
        );
        /*if (userToGuard == null) {
          QuickHelp.showAppNotificationAdvanced(
            title: "error".tr(),
            message: "choose_guardian_screen.choose_guardian".tr(),
            context: context,
          );
        } else if (widget.currentUser!.getCredits! <
            selectedGuardianPeriod[0] * selectedGuardianPrice()) {
          QuickHelp.showAppNotificationAdvanced(
            title: "error".tr(),
            message: "guardian_and_vip_screen.coins_not_enough".tr(),
            context: context,
          );
        } else {
          activateGuardian();
        }*/
      },
      child: Center(
        child: TextWithTap(
          "guardian_and_vip_screen.recharge_unlock_vip".tr(),
          color: Colors.black,
        ),
      ),
    );
  }

  Widget showUserToGuard() {
    if (userToGuard != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuickActions.avatarWidget(
            userToGuard!,
            height: 30,
            width: 30,
            margin: EdgeInsets.only(left: 15),
          ),
          TextWithTap(
            userToGuard!.getUsername!,
            fontSize: 16,
            marginLeft: 5,
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget guardianPeriods() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(guardianPeriod.length, (index) {
        bool contains = selectedGuardianPeriod.contains(guardianPeriod[index]);
        return ContainerCorner(
          borderRadius: 8,
          borderColor: contains ? Colors.white : kGrayColor,
          height: 35,
          borderWidth: contains ? 2 : 1,
          marginLeft: index == 0 ? 10 : 0,
          marginRight: index == 3 ? 10 : 0,
          marginTop: 20,
          onTap: () {
            setState(() {
              selectedGuardianPeriod.clear();
              selectedGuardianPeriod.add(guardianPeriod[index]);
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 5, left: 5),
            child: Center(
              child: AutoSizeText(
                "guardian_and_vip_screen.amount_mouths"
                    .tr(namedArgs: {"amount": "${guardianPeriod[index]}"}),
                maxFontSize: 15,
                minFontSize: 13,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: kGrayColor,
                ),
                maxLines: 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget guardianTypes({
    required String imageUrl,
    required String text,
    required Color color,
    required int index,
  }) {
    Size size = MediaQuery.of(context).size;
    bool contains = selectedGuardianType.contains(index);
    return ContainerCorner(
      borderColor: contains ? Colors.white : kGrayColor,
      borderRadius: 10,
      borderWidth: contains ? 2 : 1,
      width: size.width / 3.5,
      marginRight: index == 2 ? 15 : 0,
      marginLeft: index == 0 ? 15 : 0,
      onTap: () {
        setState(() {
          selectedGuardianType.clear();
          selectedGuardianType.add(index);
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 5,
          ),
          Image.asset(
            imageUrl,
            height: size.width / 5.5,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3, top: 5),
            child: AutoSizeText(
              text,
              maxFontSize: 16,
              minFontSize: 14,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: color,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

/* confirmVipTypeJoining() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "guardian_and_vip_screen.spend_amount_to_join_vip"
                        .tr(namedArgs: {
                      "amount": selectedVipTypeAmount().toString(),
                      "vip_type": selectedVipTypeText(),
                    }),
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: TextWithTap(
                          "cancel".tr(),
                          color: kGrayColor,
                          marginRight: 15,
                          marginLeft: 15,
                        ),
                        onPressed: () =>
                            QuickHelp.goBackToPreviousPage(context),
                      ),
                      TextButton(
                        child: TextWithTap(
                          "confirm_".tr(),
                          color: kPrimaryColor,
                          marginRight: 20,
                          marginLeft: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () {
                          if (widget.currentUser!.getCredits! <
                              selectedVipTypeAmount()) {
                            CoinsFlowPayment(
                              context: context,
                              showOnlyCoinsPurchase: true,
                              currentUser: widget.currentUser!,
                              onCoinsPurchased: (coins) {},
                            );
                          } else {
                            activateVipPlan();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }*/

/*activateVipPlan() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeCredit = selectedVipTypeAmount();
    if (vipTabsIndex == 0) {
      widget.currentUser!.setNormalVip = QuickHelp.getUntilDateFromDays(30);
    } else if (vipTabsIndex == 1) {
      widget.currentUser!.setSuperVip = QuickHelp.getUntilDateFromDays(30);
    } else if (vipTabsIndex == 2) {
      widget.currentUser!.setDiamondVip = QuickHelp.getUntilDateFromDays(30);
    }
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "done".tr(),
        context: context,
        isError: false,
        message: "main_activated".tr(),
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }*/

/*activateGuardian() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeCredit =
        selectedGuardianPeriod[0] * selectedGuardianPrice();
    widget.currentUser!.removeMyGuardians = userToGuard!.objectId!;
    widget.currentUser!.removeMyGuardians = userToGuard!.objectId!;

    if (guardianTextIndex == 0) {
      widget.currentUser!.setGuardianOfSilver =
          QuickHelp.getUntilDateFromDays(selectedGuardianPeriod[0] * 30);
    } else if (guardianTextIndex == 1) {
      widget.currentUser!.setGuardianOfGold =
          QuickHelp.getUntilDateFromDays(selectedGuardianPeriod[0] * 30);
    } else if (guardianTextIndex == 2) {
      widget.currentUser!.setGuardianOfKing =
          QuickHelp.getUntilDateFromDays(selectedGuardianPeriod[0] * 30);
    }

    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "done".tr(),
        context: context,
        isError: false,
        message: "main_activated".tr(),
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }*/
}
