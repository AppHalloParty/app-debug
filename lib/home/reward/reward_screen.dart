// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../guardian_vip/guardian_and_vip_store_screen.dart';
import '../home_screen.dart';
import '../host_rules/host_rules_screen.dart';
import '../task_rules/task_rules_screen.dart';

class RewardScreen extends StatefulWidget {
  UserModel? currentUser;

  RewardScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with TickerProviderStateMixin {
  int tabsLength = 2;

  int tabTypeMyVisitor = 0;
  int tabTypeWhoIVisited = 1;

  int tabIndex = 0;

  late TabController _tabController;

  final CarouselController _controller = CarouselController();

  var slideBanner = [
    "assets/images/img_host_rules.png",
    "assets/images/img_live_task.png"
  ];

  var screensToGo = [];

  int current = 0;
  int vipRewardAmount = 35000;
  int partyRewardAmount = 200;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(() {
            setState(() {
              tabIndex = _tabController.index;
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    screensToGo = [
      HostRulesScreen(
        currentUser: widget.currentUser,
      ),
      TaskRulesScreen(
        currentUser: widget.currentUser,
      ),
    ];

    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "reward_screen.reward_".tr(),
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () => confirmToRedeem(),
            icon: Icon(
              Icons.help_outline,
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ContainerCorner(
            color: isDark ? kContentColorLightTheme : Colors.white,
            borderWidth: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sliders(),
                ContainerCorner(
                  height: 30,
                  width: size.width,
                  marginBottom: 10,
                  marginLeft: 15,
                  marginTop: 5,
                  child: TabBar(
                    isScrollable: true,
                    enableFeedback: false,
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: kTransparentColor,
                    unselectedLabelColor: kTabIconDefaultColor,
                    indicatorWeight: 2.0,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          width: 3.0,
                          color:
                              isDark ? Colors.white : kContentColorLightTheme),
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      insets: EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    automaticIndicatorColorAdjustment: false,
                    onTap: (index) {
                      setState(() {
                        tabIndex = index;
                      });
                    },
                    labelColor: isDark ? Colors.white : Colors.black,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelStyle: TextStyle(fontSize: 14),
                    tabs: [
                      TextWithTap("reward_screen.live_".tr()),
                      TextWithTap("reward_screen.daily_".tr()),
                    ],
                  ),
                )
              ],
            ),
          ),
          ContainerCorner(
            borderWidth: 0,
            marginLeft: 15,
            marginRight: 15,
            color: isDark ? kContentColorLightTheme : Colors.white,
            borderRadius: 10,
            marginTop: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                              "assets/images/img_bg_reward_vip.png",
                            ),
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: size.width/3.4,
                                    child: AutoSizeText(
                                      "reward_screen.VIP_daily_rewards".tr(),
                                      maxFontSize: 14.0,
                                      minFontSize: 10.0,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : kContentDarkShadow,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                  vipIconType(),
                                ],
                              ),
                              ContainerCorner(
                                color: earnPointColor.withOpacity(0.2),
                                borderRadius: 50,
                                marginTop: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 2,),
                                      Image.asset(
                                        "assets/images/icon_jinbi.png",
                                        height: 13,
                                        width: 13,
                                      ),
                                      TextWithTap(
                                        "+$vipRewardAmount",
                                        color: earnPointColor,
                                        marginRight: 3,
                                        marginLeft: 3,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      ContainerCorner(
                        colors: [kPrimaryColor, kSecondaryColor],
                        borderRadius: 50,
                        onTap: () {
                          QuickHelp.goToNavigatorScreen(
                              context,
                              GuardianAndVipStoreScreen(
                                currentUser: widget.currentUser,
                              ));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 5,),
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                            size: 20,
                          ),
                          TextWithTap(
                            "reward_screen.vip_".tr(),
                            color: Colors.white,
                            marginLeft: 3,
                            fontWeight: FontWeight.w900,
                            marginRight: 5,
                          ),
                        ],),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Divider(),
                ),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ContainerCorner(
                            height: 45,
                            width: 45,
                            borderWidth: 0,
                            borderRadius: 50,
                            color: kSecondaryColor.withOpacity(0.1),
                            marginRight: 10,
                            child: Icon(Icons.mic, color: kSecondaryColor, size: 20,),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: size.width/2,
                                child: AutoSizeText(
                                  "reward_screen.party_reward".tr(),
                                  maxFontSize: 14.0,
                                  minFontSize: 10.0,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : kContentDarkShadow,
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                              ContainerCorner(
                                color: earnPointColor.withOpacity(0.2),
                                borderRadius: 50,
                                marginTop: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 2,),
                                      Image.asset(
                                        "assets/images/icon_jinbi.png",
                                        height: 13,
                                        width: 13,
                                      ),
                                      TextWithTap(
                                        "+$partyRewardAmount",
                                        color: earnPointColor,
                                        marginRight: 3,
                                        marginLeft: 3,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      ContainerCorner(
                        color: kPrimaryColor.withOpacity(0.2),
                        borderRadius: 50,
                        onTap: () {
                          QuickHelp.goToNavigatorScreen(
                              context,
                              HomeScreen(
                                currentUser: widget.currentUser,
                                initialTabIndex: 1,
                              ));
                        },
                        child: TextWithTap(
                          "reward_screen.go_".tr(),
                          color: kPrimaryColor,
                          marginLeft: 15,
                          fontWeight: FontWeight.w900,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          marginRight: 15,
                          marginTop: 5,
                          marginBottom: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget vipIconType() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: GestureDetector(
        onTap: () {
          QuickHelp.goToNavigatorScreen(
              context,
              GuardianAndVipStoreScreen(
                currentUser: widget.currentUser,
              ));
        },
        child: Image.asset(
          "assets/images/icon_vip_3.webp",
          height: 15,
        ),
      ),
    );
  }

  confirmToRedeem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "reward_screen.reward_rule".tr(),
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                    marginBottom: 20,
                  ),
                  TextWithTap(
                    "reward_screen.reward_rule_explain".tr(),
                    textAlign: TextAlign.center,
                    alignment: Alignment.center,
                    marginTop: 10,
                    marginBottom: 8,
                  ),
                  const Divider(
                    height: 2,
                  ),
                  TextButton(
                    child: TextWithTap(
                      "confirm_".tr(),
                      color: kPrimaryColor,
                      marginRight: 20,
                      marginLeft: 20,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                      alignment: Alignment.center,
                    ),
                    onPressed: () {
                      QuickHelp.hideLoadingDialog(context);
                    },
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget sliders() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      marginTop: 10,
      child: CarouselView(
        controller: _controller,
        itemExtent: double.infinity,
        children: List.generate(slideBanner.length, (index){
          return ContainerCorner(
            width: size.width,
            borderRadius: 8,
            onTap: () {
              QuickHelp.goToNavigatorScreen(context, screensToGo[index]);
            },
            child: Image.asset(
              slideBanner[index],
            ),
          );
        }),
      ),
    );
  }
}
