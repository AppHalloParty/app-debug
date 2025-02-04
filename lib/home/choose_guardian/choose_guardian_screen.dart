// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class ChooseGuardianScreen extends StatefulWidget {
  UserModel? currentUser;
  bool? isSending = false;

  ChooseGuardianScreen({this.isSending, this.currentUser, Key? key})
      : super(key: key);

  @override
  State<ChooseGuardianScreen> createState() => _ChooseGuardianScreenState();
}

class _ChooseGuardianScreenState extends State<ChooseGuardianScreen>
    with TickerProviderStateMixin {
  UserModel? selectedUser;

  int tabsLength = 2;

  int tabTypeFollowing = 0;
  int tabTypeFollowers = 1;

  int tabIndex = 0;

  late TabController _tabController;

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
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 100,
        leading: TextButton(
          onPressed: () => QuickHelp.goBackToPreviousPage(context),
          child: TextWithTap(
            "cancel".tr(),
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
        ),
        centerTitle: true,
        title: TextWithTap(widget.isSending! ? "store_screen.select_object".tr():
          "choose_guardian_screen.choose_guardian".tr(),
          fontWeight: FontWeight.w900,
        ),
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
                borderSide: BorderSide(width: 3.0, color: kPrimaryColor),
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
                TextWithTap(
                  "choose_guardian_screen.following_".tr(),
                  marginBottom: 7,
                ),
                TextWithTap(
                  "choose_guardian_screen.followers_".tr(),
                  marginBottom: 7,
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          following(),
          followers(),
        ],
      ),
    );
  }

  selectUser(UserModel selectedUser) {
    QuickHelp.goBackToPreviousPage(context, result: selectedUser);
  }

  Widget following() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(
        UserModel.keyObjectId, widget.currentUser!.getFollowing!);

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
                  ContainerCorner(
                    height: 30,
                    borderRadius: 50,
                    marginRight: 10,
                    color: kPrimaryColor.withOpacity(0.3),
                    child: ButtonWidget(
                      onTap: () => selectUser(user),
                      child: TextWithTap(widget.isSending! ? "store_screen.sending_".tr():
                      "choose_guardian_screen.go_guardian".tr(),
                        color: kPrimaryColor,
                        marginLeft: 5,
                        marginRight: 5,
                        fontSize: 11,
                      ),
                    ),
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
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(child: Image.asset("assets/images/szy_kong_icon.png")),
      ),
    );
  }

  Widget followers() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(
        UserModel.keyObjectId, widget.currentUser!.getFollowers!);

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
                  ContainerCorner(
                    height: 30,
                    borderRadius: 50,
                    marginRight: 10,
                    color: kPrimaryColor.withOpacity(0.3),
                    child: ButtonWidget(
                      onTap: () => selectUser(user),
                      child: TextWithTap(widget.isSending! ? "store_screen.sending_".tr():
                        "choose_guardian_screen.go_guardian".tr(),
                        color: kPrimaryColor,
                        marginLeft: 5,
                        marginRight: 5,
                        fontSize: 11,
                      ),
                    ),
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
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(child: Image.asset("assets/images/szy_kong_icon.png")),
      ),
    );
  }
}
