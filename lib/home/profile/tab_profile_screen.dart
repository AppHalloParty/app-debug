// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/home/home_screen.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/home/relations/close_friends.dart';
import 'package:trace/home/settings/settings_screen.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helpers/quick_help.dart';
import '../../models/GroupMessageModel.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../agency/add_host_screen.dart';
import '../agency/agency_group_creation_screen.dart';
import '../agency/agency_screen.dart';
import '../agency/agent_screen.dart';
import '../agency/my_agent_sreen.dart';
import '../agency/official_services_screen.dart';
import '../coins/refill_coins_screen.dart';
import '../coins_and_points/coins_and_points_screen.dart';
import '../coins_and_points/points_screen.dart';
import '../coins_trading/coins_trading_screen.dart';
import '../contact_us/contact_us_screen.dart';
import '../fan_club/fan_club_screen.dart';
import '../feedback/my_feedback_screen.dart';
import '../guardian_vip/guardian_and_vip_store_screen.dart';
import '../guardian_vip/my_guardian_screen.dart';
import '../help/help_screen.dart';
import '../host_center/host_center_screen.dart';
import '../invitation/invitation_screen.dart';
import '../level/level_screen.dart';
import '../mvp/mvp_screen.dart';
import '../my_moments/my_moments_screen.dart';
import '../my_obtained_items/my_obtained_items.dart';
import '../relations/followers_screen.dart';
import '../relations/visits_screen.dart';
import '../report/report_screen.dart';
import '../reward/reward_screen.dart';
import '../store/store_screen.dart';
import '../task_rules/task_rules_screen.dart';
import '../upload_live_photo/upload_live_photo_screen.dart';
import '../wallet/wallet_screen.dart';
import '../withdraw/witthdraw_screen.dart';

class TabProfileScreen extends StatefulWidget {
  UserModel? currentUser;
  static String route = "user/profile";

  TabProfileScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<TabProfileScreen> createState() => _TabProfileScreenState();
}

class _TabProfileScreenState extends State<TabProfileScreen> {
  final CarouselController _controller = CarouselController();
  int current = 0;

  var numbersCaptions = [
    "tab_profile.followings_".tr(),
    "tab_profile.followers_".tr(),
    "profile_list_menu.moments_".tr(),
  ];

  var coinsCaption = [
    "tab_profile.coins_".tr(),
    "tab_profile.p_coin".tr(),
    "tab_profile.points_".tr(),
  ];

  var slideBanner = [
    "assets/images/slide_image_1.png",
    "assets/images/slide_image_2.png",
    "assets/images/slide_image_3.png",
    "assets/images/slide_image_4.png",
  ];

  var firstOptionsCaption = [
    "tab_profile.reward_".tr(),
    "tab_profile.rank_".tr(),
    "tab_profile.store_".tr(),
    "tab_profile.invite_".tr(),
    "tab_profile.medal_".tr(),
    "tab_profile.fans_club".tr(),
    "tab_profile.auth_".tr(),
  ];

  var firstOptionsIcons = [
    "assets/images/ic_tab_profile_reward.png",
    "assets/images/ic_tab_profile_rank.png",
    "assets/images/ic_tab_profile_store.png",
    "assets/images/ic_tab_invite.png",
    "assets/images/ic_tab_profile_medal.png",
    "assets/images/ic_tab_profile_fans.png",
    "assets/images/ic_tab_profile_auth.png",
  ];

  var agentOptionsIcons = [
    "assets/images/ic_tab_profile_agent.png",
    "assets/images/ic_tab_profile_add_host.png",
    "assets/images/ic_tab_profile_coins_trading.png",
    "assets/images/ic_tab_profile_official_services.png",
  ];

  var agentOptionsCaption = [
    "agents_menu.agent_".tr(),
    "agents_menu.add_host".tr(),
    "agents_menu.coins_trading".tr(),
    "agents_menu.official_services".tr(),
  ];

  var secondOptionsCaption = [
    //"tab_profile.guardian_".tr(),
    //"tab_profile.help_".tr(),
    "tab_profile.my_agency".tr(),
    //"tab_profile.level_complete".tr(),
    //"tab_profile.about_".tr(),
    //"tab_profile.settings_".tr(),
    //"tab_profile.follow_us".tr()
  ];

  var secondOptionsLightIcons = [
    //"assets/images/ic_profil_tab_guardian.png",
    //"assets/images/ic_profil_tab_help.png",
    "assets/images/ic_tab_profile_agency.png",
    //"assets/images/ic_tab_profile_level.png",
    //"assets/images/ic_tab_profile_about.png",
    //"assets/images/ic_tab_profile_settings.png",
    //"assets/images/ic_tab_profile_follow.png",
  ];

  var secondOptionsDarkIcons = [
    "assets/svg/ic_guardian_dark.svg",
    "assets/svg/help.svg",
    "assets/svg/ic_agent_dark.svg",
    "assets/svg/ic_level_dark.svg",
    "assets/svg/ic_about_dark.svg",
    "assets/svg/ic_config_dark.svg",
    "assets/svg/ic_facebook_dark.svg"
  ];

  var coinsImageUrls = [
    "assets/images/icon_jinbi.png",
    "assets/images/icon_ppbi_do_task.png",
    "assets/images/ic_jifen_wode.webp",
  ];

  var coinsActionsTexts = [
    "tab_profile.top_up".tr(),
    "tab_profile.receive_".tr(),
    "tab_profile.withdraw_".tr(),
  ];

  bool showTempAlert = false;

  loadAgencyGroup() async {
    QueryBuilder<MessageGroupModel> queryBuilder =
        QueryBuilder<MessageGroupModel>(MessageGroupModel());

    queryBuilder.whereEqualTo(
        MessageGroupModel.keyCreatorID, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(
        MessageGroupModel.keyGroupType, MessageGroupModel.keyAgencyGroupType);
    queryBuilder.includeObject([
      MessageGroupModel.keyCreator,
    ]);

    ParseResponse response = await queryBuilder.query();

    if (response.success && response.result != null) {
      agencyGroup = response.results!.first;
    }
  }

  @override
  void initState() {
    super.initState();
    loadAgencyGroup();
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

  MessageGroupModel? agencyGroup;

  Widget agencyScreen() {
    if (widget.currentUser!.getAgencyRole == UserModel.agencyClientRole) {
      return MyAgentScreen(
        currentUser: widget.currentUser,
      );
    } else if (widget.currentUser!.getAgencyRole == UserModel.agencyAgentRole) {
      return AgentScreen(
        currentUser: widget.currentUser,
      );
    } else {
      return AgencyScreen(
        currentUser: widget.currentUser,
      );
    }
  }

  var coinsActionsButtonsBgColors = [
    kOrangeColor,
    kPrimaryColor,
    earnCashColor,
  ];

  var firstOptionsScreens = [];
  var secondOptionsScreens = [];
  var agentOptionsScreens = [];
  var agencyOptionsScreens = [];
  var listMenuScreens = [];

  var personalIcons = [
    "assets/images/my_icon_message.png",
    "assets/images/my_icon_bag.png",
    "assets/images/my_icon_store.png",
    "assets/images/my_icon_home.png",
    "assets/images/my_icon_lv.png",
    "assets/images/my_icon_check.png",
    "assets/images/my_icon_manor.png",
    "assets/images/icon_medal_default.png",
  ];

  var personalTitle = [
    "personal_menu.messages_".tr(),
    "personal_menu.Backpacks_".tr(),
    "personal_menu.shop_".tr(),
    "personal_menu.family_".tr(),
    "personal_menu.level_".tr(),
    "personal_menu.check_in".tr(),
    "personal_menu.farm_".tr(),
    "personal_menu.badges_".tr(),
  ];

  var privilegesIcons = [
    "assets/images/my_icon_member.png",
    "assets/images/my_icon_vip.png",
    "assets/images/my_icon_guard.png",
    "assets/images/my_icon_love.png",
  ];

  var privilegesTitle = [
    "profile_list_menu.mvp_".tr(),
    "profile_list_menu.vip_".tr(),
    "profile_list_menu.my_guardian".tr(),
    "profile_list_menu.fan_club".tr(),
  ];

  var listMenuTitle = [
    "profile_list_menu.host_center".tr(),
    //"profile_list_menu.batter_of_glory".tr(),
    "profile_list_menu.who_viewed_me".tr(),
    "profile_list_menu.view_record".tr(),
    "profile_list_menu.customer_service".tr(),
    "profile_list_menu.help_center".tr(),
    "profile_list_menu.feed_back".tr(),
    "profile_list_menu.contact_us".tr(),
  ];

  var colors = [Colors.redAccent, Colors.amber, Colors.deepPurpleAccent];

  final Uri url =
      Uri.parse("https://www.facebook.com/profile.php?id=100063582998530");

  Future<void> goToFacebookPage() async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    agencyOptionsScreens = [
      AgentScreen(
        currentUser: widget.currentUser,
      ),
      AddHostScreen(
        currentUser: widget.currentUser,
      ),
      CoinsTradingScreen(
        currentUser: widget.currentUser,
      ),
      OfficialServicesScreen(
        currentUser: widget.currentUser,
        groupModel: agencyGroup,
      ),
    ];

    agentOptionsScreens = [
      MVPScreen(
        currentUser: widget.currentUser,
      ),
      GuardianAndVipStoreScreen(
        currentUser: widget.currentUser,
        initialIndex: 1,
      ),
      MyGuardianScreen(
        currentUser: widget.currentUser,
      ),
      FanClubScreen(
        currentUser: widget.currentUser,
      ),
    ];

    listMenuScreens = [
      HostCenterScreen(
        currentUser: widget.currentUser,
      ),
      /*HostCenterScreen(
        currentUser: widget.currentUser,

      ),*/
      VisitScreen(
        currentUser: widget.currentUser,
        initialIndex: 0,
      ),
      VisitScreen(
        currentUser: widget.currentUser,
        initialIndex: 1,
      ),
      ReportScreen(
        currentUser: widget.currentUser,
      ),
      HelpScreen(
        currentUser: widget.currentUser,
      ),
      ReportScreen(
        currentUser: widget.currentUser,
      ),
      ContactUsScreen(
        currentUser: widget.currentUser,
      ),
    ];

    var numbersCaptionsScreens = [
      FollowersScreen(
        currentUser: widget.currentUser,
        isFollowers: false,
      ),
      FollowersScreen(
        currentUser: widget.currentUser,
        isFollowers: true,
      ),
      MyMomentsScreen(
        currentUser: widget.currentUser,
      ),
      VisitScreen(
        currentUser: widget.currentUser,
      ),
    ];

    firstOptionsScreens = [
      HomeScreen(
        currentUser: widget.currentUser,
        initialTabIndex: 3,
      ),
      MyObtainedItems(
        currentUser: widget.currentUser,
      ),
      StoreScreen(
        currentUser: widget.currentUser,
      ),
      InvitationScreen(
        currentUser: widget.currentUser,
      ),
      LevelScreen(
        currentUser: widget.currentUser,
      ),
      UploadLivePhoto(
        currentUser: widget.currentUser,
      ),
      MyFeedbackScreen(
        currentUser: widget.currentUser,
      ),
      TaskRulesScreen(
        currentUser: widget.currentUser,
      ),
    ];

    secondOptionsScreens = [
      /*GuardianAndVipStoreScreen(
        currentUser: widget.currentUser,

        initialIndex: 0,
      ),
      HelpScreen(
        currentUser: widget.currentUser,

      ),*/
      agencyScreen(),
      /*LevelScreen(
        currentUser: widget.currentUser,

      ),
      AboutUsScreen(
        currentUser: widget.currentUser,

      ),
      SettingsScreen(
        currentUser: widget.currentUser,

      ),
      null*/
    ];

    var numbers = [
      widget.currentUser!.getFollowing!.length,
      widget.currentUser!.getFollowers!.length,
      widget.currentUser!.getPostIdList!.length,
    ];

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 0.1,
            title: ContainerCorner(
              width: size.width / 1.2,
              child: TextWithTap(
                widget.currentUser!.getFullName!,
                fontSize: size.width / 17,
                fontWeight: FontWeight.w900,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  UserModel? user =
                  await QuickHelp.goToNavigatorScreenForResult(
                      context,
                      SettingsScreen(
                        currentUser: widget.currentUser,
                      ));
                  if (user != null) {
                    debugPrint("user: ${user}");
                    setState(() {
                      widget.currentUser = user;
                    });
                  }
                },
                icon: Image.asset(
                  "assets/images/profile_icon_set.png",
                  height: 25,
                  width: 25,
                ),
              )
            ],
          ),
          body: ListView(
            padding: EdgeInsets.only(left: 15, top: 30 ,right: 15),
            children: [
              Stack(
                children: [
                  Visibility(
                    visible: QuickHelp.isMvpUser(widget.currentUser!),
                    child: ContainerCorner(
                      colors: [kColorsLightBlue200, kTransparentColor],
                      height: 300,
                      borderRadius: 8,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      width: size.width,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Image.asset(
                              "assets/images/google_points_mvp_icon.png"),
                          Positioned(
                            top: 0,
                            right: 10,
                            child: Image.asset(
                              "assets/images/vip_member.png",
                              height: 35,
                              width: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          QuickHelp.goToNavigatorScreen(
                            context,
                            ProfileScreen(
                              currentUser: widget.currentUser,
                            ),
                          );
                        },
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            QuickActions.avatarWidget(
                              widget.currentUser!,
                              width: size.width / 3,
                              height: size.width / 3,
                              margin: EdgeInsets.only(top: 15, bottom: 15),
                              hideAvatarFrame: true,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextWithTap(
                            "tab_profile.id_".tr(),
                            fontSize: size.width / 33,
                            fontWeight: FontWeight.w900,
                            color: kGrayColor,
                          ),
                          TextWithTap(
                            widget.currentUser!.getUid!.toString(),
                            fontSize: size.width / 33,
                            marginLeft: 3,
                            marginRight: 3,
                            color: kGrayColor,
                          ),
                          GestureDetector(
                            onTap: () {
                              QuickHelp.copyText(
                                  textToCopy: "${widget.currentUser!.getUid!}");
                              showTemporaryAlert();
                            },
                            child: Icon(
                              Icons.copy,
                              color: kGrayColor,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          numbersCaptions.length,
                              (index) => captionAndNumber(
                            caption: numbersCaptions[index],
                            screenToGo: numbersCaptionsScreens[index],
                            number: numbers[index],
                            visitor: index == 2 ? true : false,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              ContainerCorner(
                color: isDark ? kContentColorLightTheme : Colors.white,
                borderRadius: 10,
                borderWidth: 0,
                shadowColor: kGrayColor,
                shadowColorOpacity: isDark ? 0.3 : 0.1,
                marginTop: 18,
                marginBottom: 18,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () async {
                        UserModel? user =
                        await QuickHelp.goToNavigatorScreenForResult(
                          context,
                          WalletScreen(
                            currentUser: widget.currentUser,
                          ),
                        );
                        if (user != null) {
                          setState(() {
                            widget.currentUser = user;
                          });
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "profile_list_menu.wallet_".tr(),
                            alignment: Alignment.topLeft,
                            marginBottom: 3,
                            fontSize: 13,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/icon_jinbi.png",
                                height: 13,
                                width: 13,
                              ),
                              TextWithTap(
                                QuickHelp.checkFundsWithString(
                                    amount:
                                    "${widget.currentUser!.getCredits}"),
                                marginLeft: 8,
                                fontSize: 13,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    ContainerCorner(
                      height: 30,
                      width: 0.2,
                      color: kGrayColor,
                    ),
                    TextButton(
                      onPressed: () {
                        QuickHelp.goToNavigatorScreen(
                          context,
                          PointsScreen(
                            currentUser: widget.currentUser,
                          ),
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "my_earnings".tr(),
                            marginBottom: 3,
                            fontSize: 13,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/ic_jifen_wode.webp",
                                height: 13,
                                width: 13,
                              ),
                              TextWithTap(
                                QuickHelp.checkFundsWithString(
                                  amount:
                                  "${widget.currentUser!.getDiamonds}",
                                ),
                                marginLeft: 8,
                                fontSize: 13,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextWithTap(
                "personal_".tr(),
                fontSize: size.width / 23,
                fontWeight: FontWeight.w900,
              ),
              ContainerCorner(
                color: isDark ? kContentColorLightTheme : Colors.white,
                borderRadius: 10,
                width: size.width,
                height: 150,
                marginTop: 8,
                child: GridView.count(
                  crossAxisCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    personalTitle.length,
                        (index) {
                      return options(
                        caption: personalTitle[index],
                        screenTogo: firstOptionsScreens[index],
                        iconURL: personalIcons[index],
                        isAgency: false,
                        index: index,
                      );
                    },
                  ),
                ),
              ),
              TextWithTap(
                "privileges_".tr(),
                fontSize: size.width / 23,
                marginTop: 10,
                marginBottom: 12,
                fontWeight: FontWeight.w900,
              ),
              ContainerCorner(
                color: isDark ? kContentColorLightTheme : Colors.white,
                borderRadius: 10,
                width: size.width,
                height: 60,
                padding: EdgeInsets.all(4),
                child: GridView.count(
                  crossAxisCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    privilegesTitle.length,
                        (index) {
                      return options(
                        caption: privilegesTitle[index],
                        screenTogo: agentOptionsScreens[index],
                        iconURL: privilegesIcons[index],
                        width: size.width / 14,
                        height: size.width / 14,
                        isAgency: false,
                        index: index,
                      );
                    },
                  ),
                ),
              ),
              TextWithTap(
                "agency_".tr(),
                fontSize: size.width / 23,
                marginTop: 10,
                fontWeight: FontWeight.w900,
              ),
              ContainerCorner(
                color: isDark ? kContentColorLightTheme : Colors.white,
                borderRadius: 10,
                width: size.width,
                height: 65 ,
                marginTop: 10,
                padding: EdgeInsets.all(4),
                child: GridView.count(
                  crossAxisCount: 4,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    secondOptionsCaption.length,
                        (index) {
                      return secondOptions(
                        caption: secondOptionsCaption[index],
                        screenTogo: secondOptionsScreens[index],
                        iconURL: secondOptionsLightIcons[index],
                      );
                    },
                  ),
                ),
              ),
              Visibility(
                visible: widget.currentUser!.getAgencyRole == UserModel.agencyAgentRole,
                child: ContainerCorner(
                  color: isDark ? kContentColorLightTheme : Colors.white,
                  borderRadius: 10,
                  width: size.width,
                  padding: EdgeInsets.all(4),
                  height: 70,
                  marginTop: 10,
                  child: GridView.count(
                    crossAxisCount: 4,
                    physics: NeverScrollableScrollPhysics(),
                    children: List.generate(
                      agentOptionsCaption.length,
                          (index) {
                        return options(
                          caption: agentOptionsCaption[index],
                          screenTogo: agencyOptionsScreens[index],
                          iconURL: agentOptionsIcons[index],
                          isAgency: true,
                          index: index,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    listMenuTitle.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: ButtonWidget(
                        onTap: () => QuickHelp.goToNavigatorScreen(
                          context, listMenuScreens[index],
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            TextWithTap(
                              listMenuTitle[index],
                              marginBottom: 16,
                              fontSize: size.width / 23,
                              color: isDark
                                  ? Colors.white
                                  : kContentColorLightTheme,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Visibility(
                                  visible: index == 4,
                                  child: Image.asset(
                                    "assets/images/im_service_icon.png",
                                    height: 16,
                                    width: 16,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: kGrayColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          top: kToolbarHeight,
          child: IgnorePointer(
            child: ContainerCorner(
              fit: BoxFit.fill,
              imageDecoration:
             QuickHelp.levelVipCover(
                currentCredit: widget.currentUser!.getCredits!.toDouble(),
               user: widget.currentUser!,
              ),
              width: size.width,
              height: size.height - kToolbarHeight,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Visibility(
            visible: showTempAlert,
            child: Align(
              alignment: Alignment.bottomCenter,
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
          ),
        ),
      ],
    );
  }

  Widget oldBody() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    var coinsNumbers = [
      widget.currentUser!.getCredits,
      widget.currentUser!.getPCoins,
      widget.currentUser!.getDiamonds,
    ];

    var numbers = [
      widget.currentUser!.getFollowing!.length,
      widget.currentUser!.getFollowers!.length,
      widget.currentUser!.getCloseFriends!.length,
      widget.currentUser!.getVisitors!.length,
    ];

    var numbersCaptionsScreens = [
      FollowersScreen(
        currentUser: widget.currentUser,
        isFollowers: false,
      ),
      FollowersScreen(
        currentUser: widget.currentUser,
        isFollowers: true,
      ),
      CloseFriendsScreen(
        currentUser: widget.currentUser,
      ),
      VisitScreen(
        currentUser: widget.currentUser,
      ),
    ];

    var coinsAndPointsScreen = [
      CoinsAndPointsScreen(
        currentUser: widget.currentUser,
        initialIndex: 0,
      ),
      CoinsAndPointsScreen(
        currentUser: widget.currentUser,
        initialIndex: 1,
      ),
      PointsScreen(
        currentUser: widget.currentUser,
      ),
    ];

    var coinsAndPointsScreenOperation = [
      RefillCoinsScreen(
        currentUser: widget.currentUser,
      ),
      RewardScreen(
        currentUser: widget.currentUser,
      ),
      WithDrawScreen(
        currentUser: widget.currentUser,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    title: Visibility(
                      visible: innerBoxIsScrolled,
                      child: TextWithTap(
                        widget.currentUser!.getFullName!,
                      ),
                    ),
                    backgroundColor:
                        isDark ? kContentColorLightTheme : kGrayWhite,
                    floating: false,
                    primary: true,
                    pinned: true,
                    snap: false,
                    elevation: 0,
                    stretch: true,
                    expandedHeight: size.width / 3,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.parallax,
                      background: Padding(
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: size.width / 7),
                        child: header(),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Builder(builder: (BuildContext context) {
              return CustomScrollView(
                slivers: [
                  SliverOverlapInjector(
                    // This is the flip side of the SliverOverlapAbsorber above.
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: List.generate(
                                    numbersCaptions.length,
                                    (index) => captionAndNumber(
                                      caption: numbersCaptions[index],
                                      screenToGo: numbersCaptionsScreens[index],
                                      number: numbers[index],
                                      visitor: index == 3 ? true : false,
                                    ),
                                  ),
                                ),
                                ContainerCorner(
                                  imageDecoration: "assets/images/vip_bar.png",
                                  height: 40,
                                  fit: BoxFit.fill,
                                  radiusTopRight: 10,
                                  radiusTopLeft: 10,
                                  marginTop: 20,
                                  borderWidth: 0,
                                  onTap: () {
                                    QuickHelp.goToNavigatorScreen(
                                        context,
                                        GuardianAndVipStoreScreen(
                                          currentUser: widget.currentUser,
                                        ));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Image.asset(
                                          "assets/images/VIP.png",
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          TextWithTap(
                                            "tab_profile.noble_privileges".tr(),
                                            fontSize: size.width / 40,
                                            color: kRoseVipClair,
                                          ),
                                          ContainerCorner(
                                            borderRadius: 50,
                                            marginRight: 15,
                                            marginLeft: 10,
                                            marginTop: 10,
                                            marginBottom: 10,
                                            colors: [kRoseVip, kRoseVipClair],
                                            child: Center(
                                              child: TextWithTap(
                                                "tab_profile.open_".tr(),
                                                fontSize: size.width / 40,
                                                marginRight: 15,
                                                marginLeft: 15,
                                                color: kColdVip,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                ContainerCorner(
                                  color: isDark
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  radiusBottomRight: 10,
                                  radiusBottomLeft: 10,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: List.generate(
                                      coinsCaption.length,
                                      (index) => coinsAndPoints(
                                        caption: coinsCaption[index],
                                        number: coinsNumbers[index]!,
                                        imageUrl: coinsImageUrls[index],
                                        bgColor:
                                            coinsActionsButtonsBgColors[index],
                                        actionText: coinsActionsTexts[index],
                                        screenToGo: coinsAndPointsScreen[index],
                                        screenOperation:
                                            coinsAndPointsScreenOperation[
                                                index],
                                      ),
                                    ),
                                  ),
                                ),
                                ContainerCorner(
                                  color: isDark
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  borderRadius: 10,
                                  width: size.width,
                                  height: 200,
                                  marginTop: 10,
                                  child: GridView.count(
                                    crossAxisCount: 4,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: List.generate(
                                      firstOptionsCaption.length,
                                      (index) {
                                        return options(
                                          caption: firstOptionsCaption[index],
                                          screenTogo:
                                              firstOptionsScreens[index],
                                          iconURL: firstOptionsIcons[index],
                                          isAgency: false,
                                          index: index,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                sliders(),
                                Visibility(
                                  visible: widget.currentUser!.getAgencyRole ==
                                      UserModel.agencyAgentRole,
                                  child: ContainerCorner(
                                    color: isDark
                                        ? kContentColorLightTheme
                                        : Colors.white,
                                    borderRadius: 10,
                                    width: size.width,
                                    height: 90,
                                    marginTop: 10,
                                    child: GridView.count(
                                      crossAxisCount: 4,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: List.generate(
                                        agentOptionsCaption.length,
                                        (index) {
                                          return options(
                                            caption: agentOptionsCaption[index],
                                            screenTogo:
                                                agentOptionsScreens[index],
                                            iconURL: agentOptionsIcons[index],
                                            isAgency: true,
                                            index: index,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                ContainerCorner(
                                  color: isDark
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  borderRadius: 10,
                                  width: size.width,
                                  height: 200,
                                  marginTop: 10,
                                  child: GridView.count(
                                    crossAxisCount: 4,
                                    physics: NeverScrollableScrollPhysics(),
                                    children: List.generate(
                                      secondOptionsCaption.length,
                                      (index) {
                                        return secondOptions(
                                          caption: secondOptionsCaption[index],
                                          screenTogo:
                                              secondOptionsScreens[index],
                                          iconURL:
                                              secondOptionsLightIcons[index],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
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
      ),
    );
  }

  String vipIconUrl() {
    if (widget.currentUser!.isDiamondVip!) {
      return "assets/images/icon_vip_3.webp";
    } else if (widget.currentUser!.isSuperVip!) {
      return "assets/images/icon_vip_2.webp";
    } else if (widget.currentUser!.isNormalVip!) {
      return "assets/images/icon_vip_1.webp";
    } else {
      return "assets/images/icon_vip_0.png";
    }
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
          vipIconUrl(),
          height: 15,
        ),
      ),
    );
  }

  Widget options({
    required String caption,
    required String iconURL,
    required Widget screenTogo,
    double? width,
    double? height,
    required bool isAgency,
    required int index,
  }) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        UserModel? user;
        if (isAgency && index == 3) {
          if (agencyGroup != null) {
            QuickHelp.goToNavigatorScreenForResult(context, screenTogo);
          } else {
            QuickHelp.showLoadingDialog(context);
            QueryBuilder<MessageGroupModel> queryBuilder =
                QueryBuilder<MessageGroupModel>(MessageGroupModel());

            queryBuilder.whereEqualTo(
                MessageGroupModel.keyCreatorID, widget.currentUser!.objectId);
            queryBuilder.whereEqualTo(MessageGroupModel.keyGroupType,
                MessageGroupModel.keyAgencyGroupType);
            queryBuilder.includeObject([
              MessageGroupModel.keyCreator,
            ]);

            ParseResponse response = await queryBuilder.query();

            if (response.success && response.result != null) {
              QuickHelp.hideLoadingDialog(context);
              agencyGroup = response.results!.first as MessageGroupModel;
              QuickHelp.goToNavigatorScreenForResult(
                context,
                OfficialServicesScreen(
                  currentUser: widget.currentUser,
                  groupModel: agencyGroup,
                ),
              );
            } else {
              QuickHelp.hideLoadingDialog(context);
              QuickHelp.goToNavigatorScreenForResult(
                context,
                AgencyGroupCreationScreen(
                  currentUser: widget.currentUser,
                ),
              );
            }
          }
        } else {
          user =
              await QuickHelp.goToNavigatorScreenForResult(context, screenTogo);
        }
        if (user != null) {
          setState(() {
            widget.currentUser = user;
          });
        }
      },
      child: Column(
        children: [
          Image.asset(
            iconURL,
            width: width ?? size.width / 10,
            height: height ?? size.width / 10,
          ),
          TextWithTap(
            caption,
            marginTop: 6,
            fontSize: size.width / 40,
          ),
        ],
      ),
    );
  }

  Widget secondOptions({
    required String caption,
    required String iconURL,
    Widget? screenTogo,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      onTap: () async {
        if (screenTogo != null) {
          UserModel? user =
              await QuickHelp.goToNavigatorScreenForResult(context, screenTogo);
          if (user != null) {
            setState(() {
              widget.currentUser = user;
            });
          }
        } else {
          goToFacebookPage();
        }
      },
      child: Column(
        children: [
          isDark
              ? Image.asset(
                  iconURL,
                  width: size.width / 14,
                  height: size.width / 14,
                  //color: kTra,
                )
              : Image.asset(
                  iconURL,
                  width: size.width / 14,
                  height: size.width / 14,
                ),
          TextWithTap(
            caption,
            marginTop: 10,
            fontSize: size.width / 38,
          ),
        ],
      ),
    );
  }

  Widget sliders() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      marginTop: 10,
      child: CarouselView(
        itemExtent: double.infinity,
        controller: _controller,
        children: List.generate(slideBanner.length, (index){
          return ContainerCorner(
            width: size.width,
            borderRadius: 8,
            child: Image.asset(
              slideBanner[index],
            ),
          );
        }),
      ),
    );
  }

  Widget coinsAndPoints(
      {required String caption,
      required int number,
      required String imageUrl,
      required Color bgColor,
      required String actionText,
      required Widget screenToGo,
      required Widget screenOperation}) {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      marginTop: 15,
      marginBottom: 15,
      onTap: () {
        QuickHelp.goToNavigatorScreen(context, screenToGo);
      },
      child: Column(
        children: [
          TextWithTap(
            QuickHelp.checkFundsWithString(amount: number.toString()),
            fontWeight: FontWeight.w600,
            marginBottom: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imageUrl,
                width: size.width / 30,
                height: size.width / 30,
                //color: kTra,
              ),
              TextWithTap(
                caption,
                color: kGrayColor,
                fontSize: size.width / 34,
                marginLeft: 2,
              ),
            ],
          ),
          ContainerCorner(
            borderWidth: 0,
            borderRadius: 50,
            marginTop: 10,
            color: bgColor.withOpacity(0.2),
            onTap: () async {
              UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                context,
                screenOperation,
              );
              if (user != null) {
                widget.currentUser = user;
                setState(() {});
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 6),
              child: AutoSizeText(
                actionText,
                maxFontSize: 14.0,
                minFontSize: 5.0,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: bgColor,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget captionAndNumber({
    required String caption,
    required int number,
    bool? visitor,
    required Widget screenToGo,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isVisitor = visitor ?? false;
    return ContainerCorner(
      onTap: () => QuickHelp.goToNavigatorScreen(context, screenToGo),
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            clipBehavior: Clip.none,
            children: [
              TextWithTap(
                number.toString(),
                fontWeight: FontWeight.w600,
                marginBottom: 4,
                fontSize: 14,
              ),
              Visibility(
                visible: isVisitor,
                child: Positioned(
                  top: 0,
                  right: -5,
                  child: ContainerCorner(
                    height: 5,
                    width: 5,
                    color: Colors.red,
                    borderRadius: 50,
                  ),
                ),
              )
            ],
          ),
          TextWithTap(
            caption,
            color: kGrayColor,
            fontSize: size.width / 38,
          ),
        ],
      ),
    );
  }

  Widget header() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      marginBottom: 25,
      onTap: () => QuickHelp.goToNavigatorScreen(
        context,
        ProfileScreen(
          currentUser: widget.currentUser,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuickActions.avatarWidget(widget.currentUser!,
                  width: size.width / 6, height: size.width / 6),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          widget.currentUser!.getFullName!,
                          fontSize: size.width / 23,
                          fontWeight: FontWeight.w600,
                          marginBottom: 4,
                          marginRight: 4,
                        ),
                        vipIconType(),
                      ],
                    ),
                    Row(
                      children: [
                        QuickActions.getGender(
                          currentUser: widget.currentUser!,
                          context: context,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        QuickActions.giftReceivedLevel(
                          receivedGifts: widget.currentUser!.getDiamondsTotal!,
                          width: 35,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        QuickActions.wealthLevel(
                          credit: widget.currentUser!.getCreditsSent!,
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
                        GestureDetector(
                          onTap: () {
                            QuickHelp.copyText(
                                textToCopy: "${widget.currentUser!.getUid!}");
                            showTemporaryAlert();
                          },
                          child: Icon(
                            Icons.copy,
                            color: kGrayColor,
                            size: 20,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: kGrayColor,
            size: size.width / 30,
          ),
        ],
      ),
    );
  }
}
