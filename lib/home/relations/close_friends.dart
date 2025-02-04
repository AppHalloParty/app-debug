// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class CloseFriendsScreen extends StatefulWidget {
  UserModel? currentUser;

  static String route = "/close/friends";

  CloseFriendsScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<CloseFriendsScreen> createState() => _CloseFriendsScreenState();
}

class _CloseFriendsScreenState extends State<CloseFriendsScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TextWithTap("close_friend_screen.close_friend".tr()),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          ContainerCorner(
            width: size.width,
            color: kGrayWhite,
            borderWidth: 0,
            marginTop: 10,
            child: TextWithTap(
              "close_friend_screen.friends_amount".tr(namedArgs: {"amount":widget.currentUser!.getCloseFriends!.length.toString()}),
              fontWeight: FontWeight.bold,
              color: kContentColorLightTheme,
              fontSize: 18,
              marginTop: 10,
              marginLeft: 10,
              marginBottom: 10,
            ),
          ),
          users(),
        ],
      ),
    );
  }

  Widget users() {
    String emptyMessage = "close_friend_screen.no_close_friends".tr();

    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(UserModel.keyId, widget.currentUser!.getCloseFriends!);

    Size size = MediaQuery.of(context).size;

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      scrollPhysics: NeverScrollableScrollPhysics(),
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
          child: TextWithTap(emptyMessage),
        ),
      ),
    );
  }
}
