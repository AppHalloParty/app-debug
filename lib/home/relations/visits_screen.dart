// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../models/VisitsModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class VisitScreen extends StatefulWidget {
  UserModel? currentUser;
  int? initialIndex;

  VisitScreen({this.initialIndex, this.currentUser, Key? key}) : super(key: key);

  @override
  State<VisitScreen> createState() => _VisitScreenState();
}

class _VisitScreenState extends State<VisitScreen>
    with TickerProviderStateMixin {
  int tabsLength = 2;

  int tabTypeMyVisitor = 0;
  int tabTypeWhoIVisited = 1;

  int tabIndex = 0;

  late TabController _tabController;

  @override
  void initState() {
    tabIndex = widget.initialIndex ?? 0;
    super.initState();
    _tabController = TabController(
        vsync: this, length: tabsLength, initialIndex: tabIndex)
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
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
        elevation: 1.5,
        centerTitle: true,
        title: TextWithTap("visit_screen.visitors_".tr()),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              isDark
                  ? "assets/svg/ic_search_for_dark_mode.svg"
                  : "assets/svg/ic_search_for_light_mode.svg",
              height: 25,
              width: 25,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: ContainerCorner(
            height: 30,
            width: size.width,
            child: TabBar(
              isScrollable: true,
              enableFeedback: false,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: kTransparentColor,
              unselectedLabelColor: kTabIconDefaultColor,
              indicatorWeight: 2.0,
              labelPadding: EdgeInsets.symmetric(horizontal: size.width / 8),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                    width: 3.0,
                    color: isDark ? Colors.white : kContentColorLightTheme,
                ),
                borderRadius: BorderRadius.all(Radius.circular(50)),
                insets: EdgeInsets.symmetric(horizontal: 30.0),
              ),
              automaticIndicatorColorAdjustment: false,
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              labelColor: isDark ? Colors.white : Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: [
                TextWithTap("visit_screen.my_visitors".tr()),
                TextWithTap("visit_screen.who_visited".tr()),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          visit(),
          visited(),
        ],
      ),
    );
  }

  Widget visit() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<VisitsModel> queryBuilder =
        QueryBuilder<VisitsModel>(VisitsModel());
    queryBuilder.whereEqualTo(VisitsModel.keyVisitedId, widget.currentUser!.objectId);

    queryBuilder.includeObject([
      VisitsModel.keyVisitor,
      VisitsModel.keyVisited,
    ]);

    return ParseLiveListWidget<VisitsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [
        VisitsModel.keyVisitor,
        VisitsModel.keyVisited,
      ],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<VisitsModel> snapshot) {
        if (snapshot.hasData) {
          VisitsModel visitsModel = snapshot.loadedData!;
          UserModel user;

          if (tabIndex == tabTypeMyVisitor) {
            user = visitsModel.getVisitor!;
          } else {
            user = visitsModel.getVisited!;
          }

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
                                  currentUser: user,
                                  context: context,
                                ),
                                const SizedBox(width: 10,),
                                Image.asset(
                                  QuickHelp.levelImageWithBanner(
                                    pointsInApp: user.getUserPoints!,
                                  ),
                                  width: 20,
                                ),
                                const SizedBox(width: 10,),
                                Visibility(
                                  visible: QuickHelp.isMvpUser(user),
                                  child: Image.asset(
                                    "assets/images/vip_member.png",
                                    height: 35,
                                    width: 35,
                                  ),
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
      listLoadingElement: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: FadeShimmer(
              height: 80,
              width: 60,
              radius: 4,
              highlightColor: Color(0xffF9F9FB),
              baseColor: Color(0xffE6E8EB),
            ),
          );
        },
      ),
      queryEmptyElement: ContainerCorner(
        child: Center(
          child: TextWithTap("visit_screen.no_visitor".tr()),
        ),
      ),
    );
  }

  Widget visited() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<VisitsModel> queryBuilder =
        QueryBuilder<VisitsModel>(VisitsModel());
    queryBuilder.whereEqualTo(VisitsModel.keyVisitorId, widget.currentUser!.objectId);

    queryBuilder.includeObject([
      VisitsModel.keyVisitor,
      VisitsModel.keyVisited,
    ]);

    return ParseLiveListWidget<VisitsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [
        VisitsModel.keyVisitor,
        VisitsModel.keyVisited,
      ],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<VisitsModel> snapshot) {
        if (snapshot.hasData) {
          VisitsModel visitsModel = snapshot.loadedData!;
          UserModel user;

          if (tabIndex == tabTypeMyVisitor) {
            user = visitsModel.getVisitor!;
          } else {
            user = visitsModel.getVisited!;
          }

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
                                  currentUser: user,
                                  context: context,
                                ),
                                const SizedBox(width: 10,),
                                Image.asset(
                                  QuickHelp.levelImageWithBanner(
                                    pointsInApp: user.getUserPoints!,
                                  ),
                                  width: 20,
                                ),
                                const SizedBox(width: 10,),
                                Visibility(
                                  visible: QuickHelp.isMvpUser(user),
                                  child: Image.asset(
                                    "assets/images/vip_member.png",
                                    height: 35,
                                    width: 35,
                                  ),
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
      listLoadingElement: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: FadeShimmer(
              height: 80,
              width: 60,
              radius: 4,
              highlightColor: Color(0xffF9F9FB),
              baseColor: Color(0xffE6E8EB),
            ),
          );
        },
      ),
      queryEmptyElement: ContainerCorner(
        child: Center(
          child: TextWithTap("visit_screen.no_visits".tr()),
        ),
      ),
    );
  }
}
