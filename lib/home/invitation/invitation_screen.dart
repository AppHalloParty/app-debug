// ignore_for_file: must_be_immutable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/HostModel.dart';
import '../../models/InvitedUsersModel.dart';
import '../../models/UserModel.dart';
import '../../services/deep_links_service.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class InvitationScreen extends StatefulWidget {
  UserModel? currentUser;

  InvitationScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen>
    with TickerProviderStateMixin {
  int tabIndex = 0;

  int tabsLength = 2;

  int tabMyRewards = 0;
  int tabIncomeRank = 1;

  late TabController _tabController;
  int amountToEarn = 14;

  @override
  void initState() {
    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(() {
            setState(() {
              tabIndex = _tabController.index;
            });
          });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: TextWithTap(
                  "invitation_gift_screen.invitation_gift".tr(),
                  fontWeight: FontWeight.w700,
                  color: !innerBoxIsScrolled || isDark
                      ? Colors.white
                      : kContentColorLightTheme,
                ),
                backgroundColor: isDark ? kContentColorLightTheme : kGrayWhite,
                floating: false,
                primary: true,
                pinned: true,
                snap: false,
                elevation: 0,
                stretch: true,
                expandedHeight: 350,
                leading: BackButton(
                  color: !innerBoxIsScrolled || isDark
                      ? Colors.white
                      : kContentColorLightTheme,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    children: [
                      Image.asset(
                        "assets/images/bg_header_invitation.png",
                        width: size.width,
                      ),
                      ContainerCorner(
                        width: size.width,
                        height: 350,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextWithTap(
                              "invitation_gift_screen.invite_someone".tr(),
                              color: Colors.white,
                              marginBottom: 20,
                            ),
                            SizedBox(
                              width: 140,
                              child: TextWithTap(
                                "invitation_gift_screen.can_earn_up".tr(
                                    namedArgs: {"amount": "\$$amountToEarn"}),
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: size.width / 15,
                                alignment: Alignment.center,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            TextWithTap(
                              "invitation_gift_screen.the_more_you_invite".tr(),
                              color: Colors.white,
                              marginBottom: 30,
                              marginTop: 50,
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ContainerCorner(
                          height: 35,
                          width: 80,
                          marginBottom: 30,
                          color: Colors.black.withOpacity(0.3),
                          radiusTopLeft: 50,
                          radiusBottomLeft: 50,
                          onTap: () => openRules(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white.withOpacity(0.4),
                                  size: 19,
                                ),
                                TextWithTap(
                                  "invitation_gift_screen.rules_".tr(),
                                  color: Colors.white,
                                  marginLeft: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
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
                        child: Container(
                          height: MediaQuery.of(context).size.height -
                              kToolbarHeight -
                              MediaQuery.of(context).padding.top,
                          child: DefaultTabController(
                            length: tabsLength,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ContainerCorner(
                                    borderRadius: 50,
                                    borderColor: kRoseVip,
                                    marginTop: 5,
                                    child: TabBar(
                                      isScrollable: true,
                                      enableFeedback: false,
                                      controller: _tabController,
                                      indicatorSize: TabBarIndicatorSize.label,
                                      dividerColor: kTransparentColor,
                                      unselectedLabelColor:
                                          kTabIconDefaultColor,
                                      indicatorWeight: 0.0,
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: 0.0,
                                      ),
                                      automaticIndicatorColorAdjustment: false,
                                      labelColor:
                                          isDark ? Colors.white : Colors.black,
                                      indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide.none,
                                      ),
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      unselectedLabelStyle:
                                          TextStyle(fontSize: 14),
                                      tabs: [
                                        ContainerCorner(
                                          height: 30,
                                          borderRadius: 50,
                                          borderWidth: 0,
                                          color: tabIndex == 0
                                              ? kRoseVip
                                              : kTransparentColor,
                                          child: TextWithTap(
                                            "invitation_gift_screen.my_rewards"
                                                .tr(),
                                            color: tabIndex == 0
                                                ? kColorsAmber900
                                                : kRoseVip,
                                            textAlign: TextAlign.center,
                                            alignment: Alignment.center,
                                            marginLeft: 8,
                                            marginRight: 8,
                                          ),
                                        ),
                                        ContainerCorner(
                                          height: 30,
                                          borderRadius: 50,
                                          borderWidth: 0,
                                          color: tabIndex == 1
                                              ? kRoseVip
                                              : kTransparentColor,
                                          child: TextWithTap(
                                            "invitation_gift_screen.income_rank"
                                                .tr(),
                                            color: tabIndex == 1
                                                ? kColorsAmber900
                                                : kRoseVip,
                                            textAlign: TextAlign.center,
                                            alignment: Alignment.center,
                                            marginLeft: 8,
                                            marginRight: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Flexible(
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        myRewards(),
                                        Column(
                                          children: [
                                            ContainerCorner(
                                              color: isDark
                                                  ? kContentColorLightTheme
                                                  : Colors.white,
                                              borderRadius: 10,
                                              height: 300,
                                              child: ListView(
                                                children: [
                                                  topTenHosts(),
                                                  TextWithTap(
                                                    "invitation_gift_screen.only_display_top"
                                                        .tr(namedArgs: {
                                                      "number": "10",
                                                      "days": "30"
                                                    }),
                                                    color: kColorsOrange900,
                                                    alignment: Alignment.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
      bottomNavigationBar: ContainerCorner(
        borderWidth: 0,
        borderRadius: 50,
        height: 45,
        marginLeft: 30,
        marginRight: 30,
        color: kColorsAmber900,
        marginBottom: 20,
        marginTop: 10,
        onTap: () async {
          String linkToShare = await DeepLinksService.createLink(
            branchObject: DeepLinksService.branchObject(
              shareAction: DeepLinksService.keyProfileShare,
              objectID: widget.currentUser!.objectId!,
              imageURL: widget.currentUser!.getAvatar!.url,
              title: widget.currentUser!.getFullName,
              description: widget.currentUser!.getBio,
            ),
            branchProperties: DeepLinksService.linkProperties(
              channel: "link",
            ),
            context: context,
          );
          if (linkToShare.isNotEmpty) {
            Share.share(
              "settings_screen.share_app_url".tr(
                  namedArgs: {"app_name": Setup.appName, "url": linkToShare}),
            );
          }
        },
        child: TextWithTap(
          "invitation_gift_screen.invite_now".tr(),
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget myRewards() {
    bool isDark = QuickHelp.isDarkMode(context);
    return Column(
      children: [
        ContainerCorner(
          height: 100,
          color: isDark ? kContentColorLightTheme : Colors.white,
          borderRadius: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    QuickHelp.checkFundsWithString(
                      amount: "${widget.currentUser!.getDiamonds}",
                    ),
                    color: kColorsAmber900,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    marginBottom: 8,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/ic_jifen_wode.webp",
                        height: 12,
                        width: 12,
                      ),
                      TextWithTap(
                        "invitation_gift_screen.claimed_rewards".tr(),
                        color: kGrayColor,
                        marginLeft: 5,
                      ),
                    ],
                  ),
                ],
              ),
              ContainerCorner(
                color: kGrayColor.withOpacity(0.8),
                width: 1,
                height: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    QuickHelp.checkFundsWithString(
                      amount: "${widget.currentUser!.getInvitedUsers!.length}",
                    ),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    marginBottom: 8,
                  ),
                  TextWithTap(
                    "invitation_gift_screen.number_invitees".tr(),
                    color: kGrayColor,
                  ),
                ],
              )
            ],
          ),
        ),
        ContainerCorner(
          height: 50,
          color: isDark ? kContentColorLightTheme : Colors.white,
          borderRadius: 10,
          marginTop: 15,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/ic_jifen_wode.webp",
                      height: 17,
                      width: 17,
                    ),
                    TextWithTap(
                      "invitation_gift_screen.available_today".tr(),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      marginLeft: 4,
                    ),
                    TextWithTap(
                      QuickHelp.checkFundsWithString(
                        amount: "${widget.currentUser!.getPCoins}",
                      ),
                      color: kColorsAmber900,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      marginLeft: 4,
                    ),
                  ],
                ),
                ContainerCorner(
                  borderRadius: 50,
                  height: 30,
                  color: widget.currentUser!.getPCoins! > 1
                      ? kPrimaryColor
                      : kGrayColor.withOpacity(0.7),
                  child: TextWithTap(
                    "invitation_gift_screen.receive_".tr(),
                    color: Colors.white,
                    alignment: Alignment.center,
                    textAlign: TextAlign.center,
                    marginLeft: 8,
                    marginRight: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
        ContainerCorner(
          height: 200,
          color: isDark ? kContentColorLightTheme : Colors.white,
          borderRadius: 10,
          marginTop: 10,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWithTap(
                      "invitation_gift_screen.invitation_last_days".tr(
                          namedArgs: {
                            "days": "7",
                            "amount":
                                "${widget.currentUser!.getInvitedUsers!.length}"
                          }),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      marginLeft: 4,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "invitation_gift_screen.more_".tr(),
                          color: kGrayColor,
                          marginRight: 2,
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kGrayColor,
                          size: 12,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              invitedUser()
            ],
          ),
        ),
      ],
    );
  }

  Widget topTenHosts() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<HostModel> queryBuilder = QueryBuilder<HostModel>(HostModel());

    queryBuilder.includeObject([
      HostModel.keyHost,
    ]);

    return ParseLiveListWidget<HostModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      scrollPhysics: NeverScrollableScrollPhysics(),
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [
        HostModel.keyHost,
      ],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<HostModel> snapshot) {
        if (snapshot.hasData) {
          HostModel hostUser = snapshot.loadedData!;
          UserModel user = hostUser.getHost!;

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
                  TextWithTap(
                    QuickHelp.getMessageListTime(user.updatedAt!),
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
      queryEmptyElement: Center(
        child: Image.asset(
          "assets/images/szy_kong_icon.png",
          height: size.width / 3,
        ),
      ),
    );
  }

  Widget invitedUser() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<InvitedUsersModel> queryBuilder =
        QueryBuilder<InvitedUsersModel>(InvitedUsersModel());
    queryBuilder.whereEqualTo(
        InvitedUsersModel.keyInvitedById, widget.currentUser!.objectId);

    queryBuilder.includeObject([
      InvitedUsersModel.keyAuthor,
    ]);

    return ParseLiveListWidget<InvitedUsersModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [
        InvitedUsersModel.keyAuthor,
      ],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<InvitedUsersModel> snapshot) {
        if (snapshot.hasData) {
          InvitedUsersModel invitedUser = snapshot.loadedData!;
          UserModel user = invitedUser.getAuthor!;

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
                  TextWithTap(
                    QuickHelp.getMessageListTime(user.updatedAt!),
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
      queryEmptyElement: Center(
        child: Image.asset(
          "assets/images/szy_kong_icon.png",
          height: size.width / 3,
        ),
      ),
    );
  }

  void openRules() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return _showRules();
        });
  }

  Widget _showRules() {
    bool isDark = QuickHelp.isDarkMode(context);
    var hours = [3, 5, 8, 12];
    var coinHours = [10000, 10000, 10000, 30000];
    int daysForHours = 7;

    var incomes = [20, 50, 100, 200];
    var incomesCoins = [10000, 20000, 20000, 30000];
    int incomesForDays = 30;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return ContainerCorner(
                  borderWidth: 0,
                  color: Colors.black.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerCorner(
                        height: 350,
                        width: 250,
                        color: isDark ? kContentColorLightTheme : Colors.white,
                        borderRadius: 20,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 20),
                          child: ListView(
                            children: [
                              TextWithTap(
                                "invitation_gift_screen.how_to_invite".tr(),
                                color: kColorsOrange900,
                                fontWeight: FontWeight.w900,
                              ),
                              TextWithTap(
                                "invitation_gift_screen.how_to_invite_explain"
                                    .tr(),
                                fontWeight: FontWeight.w700,
                                marginTop: 10,
                                fontSize: 11,
                              ),
                              TextWithTap(
                                "invitation_gift_screen.how_to_earn_reward"
                                    .tr(),
                                color: kColorsOrange900,
                                fontWeight: FontWeight.w900,
                                marginTop: 20,
                              ),
                              TextWithTap(
                                "invitation_gift_screen.how_to_earn_reward_explain"
                                    .tr(),
                                fontWeight: FontWeight.w700,
                                marginTop: 10,
                                fontSize: 11,
                                marginBottom: 20,
                              ),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                },
                                children: [
                                  TableRow(
                                      decoration: BoxDecoration(
                                        color: kRoseVip.withOpacity(0.4),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          topLeft: Radius.circular(10),
                                        ),
                                      ),
                                      children: [
                                        TextWithTap(
                                          "invitation_gift_screen.task_".tr(),
                                          alignment: Alignment.center,
                                          textAlign: TextAlign.center,
                                          marginTop: 3,
                                          marginBottom: 3,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        TextWithTap(
                                          "invitation_gift_screen.reward_".tr(),
                                          alignment: Alignment.center,
                                          textAlign: TextAlign.center,
                                          marginTop: 5,
                                          marginBottom: 3,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black.withOpacity(0.7),
                                        ),
                                      ]),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                },
                                children: List.generate(
                                  hours.length,
                                  (index) => TableRow(
                                      decoration: BoxDecoration(
                                        color: (index % 2) != 0
                                            ? isDark
                                                ? kContentDarkShadow
                                                : kGrayColor.withOpacity(0.1)
                                            : kTransparentColor,
                                      ),
                                      children: [
                                        TextWithTap(
                                          "invitation_gift_screen.reward_invited_broadcast"
                                              .tr(namedArgs: {
                                            "hours": "${hours[index]}",
                                            "days": "$daysForHours"
                                          }),
                                          marginTop: 3,
                                          marginBottom: 3,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black.withOpacity(0.7),
                                          fontSize: 11,
                                          marginLeft: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/ic_jifen_wode.webp",
                                              height: 12,
                                              width: 12,
                                            ),
                                            TextWithTap(
                                              QuickHelp.checkFundsWithString(
                                                  amount:
                                                      "${coinHours[index]}"),
                                              alignment: Alignment.center,
                                              textAlign: TextAlign.center,
                                              marginTop: 5,
                                              marginBottom: 3,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: earnCashColor,
                                              marginLeft: 2,
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                              Table(
                                columnWidths: {
                                  0: FlexColumnWidth(3),
                                  1: FlexColumnWidth(2),
                                },
                                children: List.generate(
                                  incomes.length,
                                  (index) => TableRow(
                                      decoration: BoxDecoration(
                                        color: (index % 2) != 0
                                            ? isDark
                                                ? kContentDarkShadow
                                                : kGrayColor.withOpacity(0.1)
                                            : kTransparentColor,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(
                                              (index == incomes.length - 1)
                                                  ? 10
                                                  : 0),
                                          bottomLeft: Radius.circular(
                                              (index == incomes.length - 1)
                                                  ? 10
                                                  : 0),
                                        ),
                                      ),
                                      children: [
                                        TextWithTap(
                                          "invitation_gift_screen.reward_invited_income"
                                              .tr(namedArgs: {
                                            "money": "\$${incomes[index]}",
                                            "days": "$incomesForDays"
                                          }),
                                          marginTop: 3,
                                          marginBottom: 3,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black.withOpacity(0.7),
                                          fontSize: 11,
                                          marginLeft: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              "assets/images/ic_jifen_wode.webp",
                                              height: 12,
                                              width: 12,
                                            ),
                                            TextWithTap(
                                              QuickHelp.checkFundsWithString(
                                                  amount:
                                                      "${incomesCoins[index]}"),
                                              alignment: Alignment.center,
                                              textAlign: TextAlign.center,
                                              marginTop: 5,
                                              marginBottom: 3,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: earnCashColor,
                                              marginLeft: 2,
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ContainerCorner(
                        height: 40,
                        width: 40,
                        borderRadius: 50,
                        marginTop: 15,
                        borderColor: Colors.white.withOpacity(0.5),
                        onTap: () => QuickHelp.hideLoadingDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
