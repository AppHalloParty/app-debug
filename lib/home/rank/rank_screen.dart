// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/LeadersModel.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class RankingScreen extends StatefulWidget {
  UserModel? currentUser;

  RankingScreen({this.currentUser, super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with TickerProviderStateMixin {
  int topLeadersAmount = 50;

  late TabController leaderTypeTabControl;
  int leaderTypeTabsLength = 3;
  int leaderTypeTabIndex = 0;

  late TabController timeTabController;
  int timeTabsLength = 4;
  int timeTabIndex = 0;

  var allStreamLeaders = [];
  var pkLeaders = [];
  var pkLeadersDiamonds = [];
  var allGiftGiver = [];
  var allGiftGiverCredits = [];
  bool loading = true;
  bool giftLoading = true;

  getAllGiftSenders() async {
    QueryBuilder<LeadersModel> query =
    QueryBuilder<LeadersModel>(LeadersModel());

    query.includeObject([LeadersModel.keyAuthor]);
    query.orderByDescending(LeadersModel.keyDiamondsQuantity);
    //query.whereGreaterThan(UserModel.keyDiamondsTotal, 0);

    query.setLimit(50);
    ParseResponse response = await query.query();
    if (response.success && response.results != null) {
      for (LeadersModel leader in response.results!) {
        allGiftGiver.add(leader.getAuthor);
        allGiftGiverCredits.add(leader.getDiamondsQuantity);
      }
      setState(() {
        giftLoading = false;
      });
    } else {
      setState(() {
        giftLoading = false;
      });
    }
  }

  getAllStreamLeaders() async {
    QueryBuilder<UserModel> query =
    QueryBuilder<UserModel>(UserModel.forQuery());

    query.orderByDescending(UserModel.keyDiamondsTotal);
    query.whereGreaterThan(UserModel.keyDiamondsTotal, 0);

    query.setLimit(50);
    ParseResponse response = await query.query();
    if (response.success && response.results != null) {
      for (UserModel user in response.results!) {
        allStreamLeaders.add(user);
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  getAllSPkLeaders() async {
    QueryBuilder<UserModel> query =
    QueryBuilder<UserModel>(UserModel.forQuery());

    query.orderByDescending(UserModel.keyBattlePoints);
    query.whereGreaterThan(UserModel.keyBattlePoints, 0);

    query.setLimit(50);
    ParseResponse response = await query.query();
    if (response.success && response.results != null) {
      for (UserModel user in response.results!) {
        pkLeaders.add(user);
        pkLeadersDiamonds.add(user.getDiamondsTotal);
      }
      setState(() {
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllStreamLeaders();
    getAllGiftSenders();
    getAllSPkLeaders();
    leaderTypeTabControl = TabController(
        vsync: this, length: leaderTypeTabsLength, initialIndex: 0)
      ..addListener(() {
        setState(() {
          leaderTypeTabIndex = leaderTypeTabControl.index;
        });
      });
    timeTabController = TabController(
        vsync: this, length: timeTabsLength, initialIndex: timeTabIndex)
      ..addListener(() {
        setState(() {
          timeTabIndex = timeTabController.index;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    leaderTypeTabControl.dispose();
    timeTabController.dispose();
    allStreamLeaders.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: TextWithTap(
          "leaderboard_screen.leaderboard_".tr(),
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: kIamonDarkerColor,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Column(
            children: [
              TabBar(
                isScrollable: false,
                enableFeedback: false,
                controller: leaderTypeTabControl,
                dividerColor: kTransparentColor,
                unselectedLabelColor: kColorsGrey,
                indicatorWeight: 2.0,
                indicatorColor: kTransparentColor,
                tabAlignment: TabAlignment.fill,
                labelColor: kIamonDarkerColor,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: kIamonDarkerColor),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  insets: EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                ),
                labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    return states.contains(WidgetState.focused)
                        ? null
                        : Colors.transparent;
                  },
                ),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14,
                  color: kIamonDarkerColor,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  TextWithTap(
                    "leaderboard_screen.streamers_".tr(),
                    marginBottom: 3,
                    color: kIamonDarkerColor,
                  ),
                  TextWithTap(
                    "leaderboard_screen.gift_giver".tr(),
                    marginBottom: 3,
                    color: kIamonDarkerColor,
                  ),
                  TextWithTap(
                    "go_live_menu.pk_title".tr(),
                    marginBottom: 3,
                    color: kIamonDarkerColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: ContainerCorner(
        borderWidth: 0,
        imageDecoration: "assets/images/trace_rank_bg.png",
        child: TabBarView(
          controller: leaderTypeTabControl,
          children: [
            getBody(),
            getGifters(),
            getPkLeader(),
          ],
        ),
      ),
    );
  }

  Widget getPkLeader() {
    Size size = MediaQuery.sizeOf(context);
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (pkLeaders.length < 3)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kSilverColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kSilverColor,
                        child: TextWithTap(
                          "3",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (pkLeaders.length >= 3)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: pkLeaders[2],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(pkLeaders[2].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              pkLeaders[2],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kSilverColor,
                              borderWidth: 4,
                            ),
                            if(pkLeaders[2].getIsUserVip! && !pkLeaders[2].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kSilverColor,
                                  child: TextWithTap(
                                    "3",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(pkLeaders[2].getIsUserVip! && !pkLeaders[2].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kSilverColor,
                                child: TextWithTap(
                                  "3",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          pkLeaders[2].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[2].getBattleVictories!)+"victories_".tr(),
                            color: kIamonDarkerColor,
                            marginRight: 5,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[2].getBattlePoints!)+"Pts",
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            marginRight: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -28,
                  child: Image.asset(
                    "assets/images/iamon_third_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (pkLeaders.length < 1)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 4,
                        width: size.width / 4,
                        borderWidth: 5,
                        borderColor: kGoldenColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kGoldenColor,
                        marginRight: 5,
                        marginBottom: 5,
                        child: TextWithTap(
                          "1",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (pkLeaders.length >= 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: pkLeaders[0],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(pkLeaders[0].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              pkLeaders[0],
                              height: size.width / 4,
                              width: size.width / 4,
                              vipFrameWidth: size.width / 3,
                              vipFrameHeight: size.width / 3.5,
                              borderWidth: 5,
                              borderColor: kGoldenColor,
                            ),
                            if(pkLeaders[0].getIsUserVip! && !pkLeaders[0].getCanUseAvatarFrame!)
                              Positioned(
                                right: 25,
                                bottom: 3,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kGoldenColor,
                                  child: TextWithTap(
                                    "1",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(pkLeaders[0].getIsUserVip! && !pkLeaders[0].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kGoldenColor,
                                marginRight: 5,
                                marginBottom: 5,
                                child: TextWithTap(
                                  "1",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          pkLeaders[0].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[0].getBattleVictories!)+"victories_".tr(),
                            color: kIamonDarkerColor,
                            marginRight: 5,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[0].getBattlePoints!)+"Pts",
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            marginRight: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -37,
                  child: Image.asset(
                    "assets/images/iamon_first_leader.png",
                    width: size.width / 8,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (pkLeaders.length < 2)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kBronzeColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kBronzeColor,
                        child: TextWithTap(
                          "2",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 3,
                          marginRight: 3,
                        ),
                      )
                    ],
                  ),
                if (pkLeaders.length >= 2)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: pkLeaders[1],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(pkLeaders[1].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              pkLeaders[1],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kBronzeColor,
                              borderWidth: 4,
                            ),
                            if(pkLeaders[1].getIsUserVip! && !pkLeaders[1].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kBronzeColor,
                                  child: TextWithTap(
                                    "2",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(pkLeaders[1].getIsUserVip! && !pkLeaders[1].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kBronzeColor,
                                child: TextWithTap(
                                  "2",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          pkLeaders[1].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[1].getBattleVictories!)+"victories_".tr(),
                            color: kIamonDarkerColor,
                            marginRight: 5,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(pkLeaders[1].getBattlePoints!)+"Pts",
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            marginRight: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -32,
                  child: Image.asset(
                    "assets/images/iamon_second_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            //if(allStreamLeaders.length < 2)
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Visibility(
          visible: !giftLoading,
          child: ContainerCorner(
            width: size.width,
            height: size.height,
            child: ListView(
              children: List.generate(pkLeaders.length, (index) {
                if (index > 2) {
                  UserModel user = pkLeaders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () => QuickHelp.goToNavigatorScreen(
                        context,
                        UserProfileScreen(
                          currentUser: widget.currentUser,
                          mUser: user,
                          isFollowing: widget.currentUser!.getFollowing!
                              .contains(user.objectId),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWithTap(
                                "${index + 1}",
                                color: kIamonDarkerColor,
                                fontWeight: FontWeight.bold,
                                marginLeft: 15,
                                marginRight: 15,
                              ),
                              QuickActions.avatarBorder(
                                user,
                                height: 45,
                                width: 45,
                                vipFrameWidth: 50,
                                vipFrameHeight: 52,
                                borderWidth: 0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextWithTap(
                                              user.getFullName!.capitalize,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: kIamonDarkerColor,
                                              marginRight: 5,
                                            ),
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              child: Image.asset(
                                                QuickHelp.levelImage(
                                                  pointsInApp: user.getUserPoints!,
                                                ),
                                                width: 37,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextWithTap(
                                          "face_authentication_screen.id_".tr(
                                            namedArgs: {"id": "${user.getUid!}"},
                                          ).toUpperCase(),
                                          fontSize: 13,
                                          marginBottom: 3,
                                          color: kIamonDarkerColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWithTap(
                                QuickHelp.convertToK(user.getBattleVictories!)+"victories_".tr(),
                                color: kIamonDarkerColor,
                                marginRight: 5,
                                fontWeight: FontWeight.w900,
                                fontSize: 7,
                              ),
                              TextWithTap(
                                QuickHelp.convertToK(user.getBattlePoints!)+"Pts",
                                color: kIamonDarkerColor,
                                marginLeft: 5,
                                marginRight: 10,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
            ),
          ),
        ),
        Visibility(
          visible: pkLeaders.isEmpty && !giftLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(47, (index) {
              return TextWithTap(
                "${index + 4}",
                color: kIamonDarkerColor,
                fontWeight: FontWeight.bold,
                marginLeft: 35,
                marginRight: 15,
                marginBottom: 35,
              );
            }),
          ),
        ),
        Visibility(
          visible: giftLoading,
          child: QuickHelp.appLoading(),
        ),
      ],
    );
  }

  Widget getGifters() {
    Size size = MediaQuery.sizeOf(context);
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allGiftGiver.length < 3)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kSilverColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kSilverColor,
                        child: TextWithTap(
                          "3",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (allGiftGiver.length >= 3)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allGiftGiver[2],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allGiftGiver[2].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allGiftGiver[2],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kSilverColor,
                              borderWidth: 4,
                            ),
                            if(allGiftGiver[2].getIsUserVip! && !allGiftGiver[2].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kSilverColor,
                                  child: TextWithTap(
                                    "3",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allGiftGiver[2].getIsUserVip! && !allGiftGiver[2].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kSilverColor,
                                child: TextWithTap(
                                  "3",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allGiftGiver[2].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                              allGiftGiverCredits[2],
                            ),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -28,
                  child: Image.asset(
                    "assets/images/iamon_third_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allGiftGiver.length < 1)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 4,
                        width: size.width / 4,
                        borderWidth: 5,
                        borderColor: kGoldenColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kGoldenColor,
                        marginRight: 5,
                        marginBottom: 5,
                        child: TextWithTap(
                          "1",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (allGiftGiver.length >= 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allGiftGiver[0],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allGiftGiver[0].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allGiftGiver[0],
                              height: size.width / 4,
                              width: size.width / 4,
                              vipFrameWidth: size.width / 3,
                              vipFrameHeight: size.width / 3.2,
                              borderWidth: 5,
                              borderColor: kGoldenColor,
                            ),
                            if(allGiftGiver[0].getIsUserVip! && !allGiftGiver[0].getCanUseAvatarFrame!)
                              Positioned(
                                right: 25,
                                bottom: 3,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kGoldenColor,
                                  child: TextWithTap(
                                    "1",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allGiftGiver[0].getIsUserVip! && !allGiftGiver[0].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kGoldenColor,
                                marginRight: 5,
                                marginBottom: 5,
                                child: TextWithTap(
                                  "1",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allGiftGiver[0].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                                allGiftGiverCredits[0]),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -37,
                  child: Image.asset(
                    "assets/images/iamon_first_leader.png",
                    width: size.width / 8,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allGiftGiver.length < 2)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kBronzeColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kBronzeColor,
                        child: TextWithTap(
                          "2",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 3,
                          marginRight: 3,
                        ),
                      )
                    ],
                  ),
                if (allGiftGiver.length >= 2)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allGiftGiver[1],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allGiftGiver[1].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allGiftGiver[1],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kBronzeColor,
                              borderWidth: 4,
                            ),
                            if(allGiftGiver[1].getIsUserVip! && !allGiftGiver[1].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kBronzeColor,
                                  child: TextWithTap(
                                    "2",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allGiftGiver[1].getIsUserVip! && !allGiftGiver[1].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kBronzeColor,
                                child: TextWithTap(
                                  "2",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allGiftGiver[1].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                                allGiftGiverCredits[1]),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -32,
                  child: Image.asset(
                    "assets/images/iamon_second_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            //if(allStreamLeaders.length < 2)
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Visibility(
          visible: !giftLoading,
          child: ContainerCorner(
            width: size.width,
            height: size.height,
            child: ListView(
              children: List.generate(allGiftGiver.length, (index) {
                if (index > 2) {
                  UserModel? user = allGiftGiver[index];
                  if(user != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: GestureDetector(
                        onTap: () => QuickHelp.goToNavigatorScreen(
                          context,
                          UserProfileScreen(
                            currentUser: widget.currentUser,
                            mUser: user,
                            isFollowing: widget.currentUser!.getFollowing!
                                .contains(user.objectId),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWithTap(
                                  "${index + 1}",
                                  color: kIamonDarkerColor,
                                  fontWeight: FontWeight.bold,
                                  marginLeft: 15,
                                  marginRight: 15,
                                ),
                                QuickActions.avatarBorder(
                                  user,
                                  height: 45,
                                  width: 45,
                                  vipFrameWidth: 50,
                                  vipFrameHeight: 52,
                                  borderWidth: 0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              TextWithTap(
                                                user.getFullName!.capitalize,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: kIamonDarkerColor,
                                                marginRight: 5,
                                              ),
                                              ClipRRect(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                child: Image.asset(
                                                  QuickHelp.levelImage(
                                                    pointsInApp: user.getUserPoints!,
                                                  ),
                                                  width: 37,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TextWithTap(
                                            "face_authentication_screen.id_".tr(
                                              namedArgs: {"id": "${user.getUid!}"},
                                            ).toUpperCase(),
                                            fontSize: 13,
                                            marginBottom: 3,
                                            color: kIamonDarkerColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/icon_jinbi.png",
                                  height: 17,
                                  width: 17,
                                ),
                                TextWithTap(
                                  QuickHelp.convertToK(allGiftGiverCredits[index]),
                                  color: kIamonDarkerColor,
                                  marginLeft: 5,
                                  marginRight: 15,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }else{
                    return SizedBox();
                  }
                } else {
                  return SizedBox();
                }
              }),
            ),
          ),
        ),
        Visibility(
          visible: allGiftGiver.isEmpty && !giftLoading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(47, (index) {
              return TextWithTap(
                "${index + 4}",
                color: kIamonDarkerColor,
                fontWeight: FontWeight.bold,
                marginLeft: 35,
                marginRight: 15,
                marginBottom: 35,
              );
            }),
          ),
        ),
        Visibility(
          visible: giftLoading,
          child: QuickHelp.appLoading(),
        ),
      ],
    );
  }

  Widget getBody() {
    Size size = MediaQuery.sizeOf(context);
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allStreamLeaders.length < 3)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kSilverColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kSilverColor,
                        child: TextWithTap(
                          "3",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (allStreamLeaders.length >= 3)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allStreamLeaders[2],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allStreamLeaders[2].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allStreamLeaders[2],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kSilverColor,
                              borderWidth: 4,
                            ),
                            if(allStreamLeaders[2].getIsUserVip! && !allStreamLeaders[2].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kBronzeColor,
                                  child: TextWithTap(
                                    "3",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allStreamLeaders[2].getIsUserVip! && !allStreamLeaders[2].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kSilverColor,
                                child: TextWithTap(
                                  "3",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allStreamLeaders[2].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/grade_welfare.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                              allStreamLeaders[2].getDiamondsTotal!,
                            ),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -28,
                  child: Image.asset(
                    "assets/images/iamon_third_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allStreamLeaders.length < 1)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 4,
                        width: size.width / 4,
                        borderWidth: 5,
                        borderColor: kGoldenColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kGoldenColor,
                        marginRight: 5,
                        marginBottom: 5,
                        child: TextWithTap(
                          "1",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 4,
                          marginRight: 4,
                        ),
                      ),
                    ],
                  ),
                if (allStreamLeaders.length >= 1)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allStreamLeaders[0],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allStreamLeaders[0].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allStreamLeaders[0],
                              height: size.width / 4,
                              width: size.width / 4,
                              borderWidth: 5,
                              vipFrameWidth: size.width / 3,
                              vipFrameHeight: size.width / 3.2,
                              borderColor: kGoldenColor,
                            ),
                            if(allStreamLeaders[0].getIsUserVip! && !allStreamLeaders[0].getCanUseAvatarFrame!)
                              Positioned(
                                right: 25,
                                bottom: 3,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kGoldenColor,
                                  child: TextWithTap(
                                    "1",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allStreamLeaders[0].getIsUserVip! && !allStreamLeaders[0].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kGoldenColor,
                                marginRight: 5,
                                marginBottom: 5,
                                child: TextWithTap(
                                  "1",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 4,
                                  marginRight: 4,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allStreamLeaders[0].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/grade_welfare.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                                allStreamLeaders[0].getDiamondsTotal!),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -37,
                  child: Image.asset(
                    "assets/images/iamon_first_leader.png",
                    width: size.width / 8,
                  ),
                ),*/
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (allStreamLeaders.length < 2)
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ContainerCorner(
                        height: size.width / 6,
                        width: size.width / 6,
                        borderWidth: 4,
                        borderColor: kBronzeColor,
                        borderRadius: 50,
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        color: kBronzeColor,
                        child: TextWithTap(
                          "2",
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          marginLeft: 3,
                          marginRight: 3,
                        ),
                      )
                    ],
                  ),
                if (allStreamLeaders.length >= 2)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          QuickHelp.goToNavigatorScreen(
                            context,
                            UserProfileScreen(
                              currentUser: widget.currentUser,
                              mUser: allStreamLeaders[1],
                              isFollowing: widget.currentUser!.getFollowing!
                                  .contains(allStreamLeaders[1].objectId),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            QuickActions.avatarBorder(
                              allStreamLeaders[1],
                              height: size.width / 6,
                              width: size.width / 6,
                              vipFrameWidth: size.width / 5,
                              vipFrameHeight: size.width / 5.2,
                              borderColor: kBronzeColor,
                              borderWidth: 4,
                            ),
                            if(allStreamLeaders[1].getIsUserVip! && !allStreamLeaders[1].getCanUseAvatarFrame!)
                              Positioned(
                                right: 8,
                                bottom: 1,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kBronzeColor,
                                  child: TextWithTap(
                                    "2",
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 4,
                                    marginRight: 4,
                                  ),
                                ),
                              ),
                            if(!(allStreamLeaders[1].getIsUserVip! && !allStreamLeaders[1].getCanUseAvatarFrame!))
                              ContainerCorner(
                                borderRadius: 50,
                                color: kBronzeColor,
                                child: TextWithTap(
                                  "2",
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                              )
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width / 4,
                        child: TextWithTap(
                          allStreamLeaders[1].getFullName!,
                          color: kIamonDarkerColor,
                          fontWeight: FontWeight.bold,
                          alignment: Alignment.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/grade_welfare.png",
                            height: 17,
                            width: 17,
                          ),
                          TextWithTap(
                            QuickHelp.convertToK(
                                allStreamLeaders[1].getDiamondsTotal!),
                            color: kIamonDarkerColor,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                /*Positioned(
                  top: -32,
                  child: Image.asset(
                    "assets/images/iamon_second_leader.png",
                    width: size.width / 10,
                  ),
                ),*/
              ],
            ),
            //if(allStreamLeaders.length < 2)
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Visibility(
          visible: !loading,
          child: ContainerCorner(
            width: size.width,
            height: size.height,
            child: ListView(
              children: List.generate(allStreamLeaders.length, (index) {
                if (index > 2) {
                  UserModel user = allStreamLeaders[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: GestureDetector(
                      onTap: () => QuickHelp.goToNavigatorScreen(
                        context,
                        UserProfileScreen(
                          currentUser: widget.currentUser,
                          mUser: user,
                          isFollowing: widget.currentUser!.getFollowing!
                              .contains(user.objectId),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWithTap(
                                "${index + 1}",
                                color: kIamonDarkerColor,
                                fontWeight: FontWeight.bold,
                                marginLeft: 15,
                                marginRight: 15,
                              ),
                              QuickActions.avatarBorder(
                                user,
                                height: 45,
                                width: 45,
                                borderWidth: 0,
                                vipFrameWidth: 50,
                                vipFrameHeight: 52,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextWithTap(
                                              user.getFullName!.capitalize,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: kIamonDarkerColor,
                                              marginRight: 5,
                                            ),
                                            ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(15)),
                                              child: Image.asset(
                                                QuickHelp.levelImage(
                                                  pointsInApp: user.getUserPoints!,
                                                ),
                                                width: 37,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextWithTap(
                                          "face_authentication_screen.id_".tr(
                                            namedArgs: {"id": "${user.getUid!}"},
                                          ).toUpperCase(),
                                          fontSize: 13,
                                          marginBottom: 3,
                                          color: kIamonDarkerColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                "assets/images/grade_welfare.png",
                                height: 17,
                                width: 17,
                              ),
                              TextWithTap(
                                QuickHelp.convertToK(user.getDiamondsTotal!),
                                color: kIamonDarkerColor,
                                marginLeft: 5,
                                marginRight: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return SizedBox();
                }
              }),
            ),
          ),
        ),
        Visibility(
          visible: allStreamLeaders.isEmpty && !loading,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(47, (index) {
              return TextWithTap(
                "${index + 4}",
                color: kIamonDarkerColor,
                fontWeight: FontWeight.bold,
                marginLeft: 35,
                marginRight: 15,
                marginBottom: 35,
              );
            }),
          ),
        ),
        Visibility(
          visible: loading,
          child: QuickHelp.appLoading(),
        ),
      ],
    );
  }
}
