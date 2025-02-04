// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_cloud.dart';
import '../../helpers/quick_help.dart';
import '../../models/NotificationsModel.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  UserModel? currentUser;
  bool? isFollowers;

  FollowersScreen({this.currentUser, this.isFollowers, Key? key})
      : super(key: key);

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  String keyUpdate = "connect";
  List<String> followersIds = [];
  List<String> followingIds = [];

  @override
  void initState() {
    super.initState();
    populateUserIdsList();
  }

  @override
  void dispose() {
    super.dispose();
    followersIds.clear();
    followingIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    int followersAmount = widget.currentUser!.getFollowers!.length;
    int followingAmount = widget.currentUser!.getFollowing!.length;

    String title = widget.isFollowers!
        ? "followers_screen.follower_".tr()
        : "followers_screen.following_".tr();

    String amountCaption = widget.isFollowers!
        ? "followers_screen.followers_amount"
            .tr(namedArgs: {"amount": "$followersAmount"})
        : "followers_screen.following_amount"
            .tr(namedArgs: {"amount": "$followingAmount"});

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TextWithTap(title),
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
              amountCaption,
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

  populateUserIdsList() {
    for (String userId in widget.currentUser!.getFollowers!) {
      followersIds.add(userId);
    }

    for (String userId in widget.currentUser!.getFollowing!) {
      followingIds.add(userId);
    }
  }

  Widget users() {
    String emptyMessage = "";

    if (widget.isFollowers!) {
      emptyMessage = "followers_screen.no_followers".tr();
    } else {
      emptyMessage = "followers_screen.no_followings".tr();
    }

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());

    if (widget.isFollowers!) {
      queryBuilder.whereContainedIn(UserModel.keyId, followersIds);
    } else {
      queryBuilder.whereContainedIn(UserModel.keyId, followingIds);
    }

    Size size = MediaQuery.of(context).size;

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      key: Key(keyUpdate),
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      scrollPhysics: NeverScrollableScrollPhysics(),
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
                      if(widget.isFollowers! && widget.currentUser!.getLevelUserVip! > 4 && widget.currentUser!.getMysteryMan!)
                        ContainerCorner(
                          width: size.width / 6,
                          height: size.width / 6,
                          borderRadius: 50,
                          child: Image.asset(
                            "assets/images/ic_avatar_invisible_user.png",
                          ),
                        ),
                      if(widget.currentUser!.getMysteryMan! == false || widget.currentUser!.getLevelUserVip! < 5)
                        QuickActions.avatarWidget(
                          user,
                          width: size.width / 6,
                          height: size.width / 6,
                        ),
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
                  button(user),
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

  follow(String objectId) async {
    widget.currentUser!.removeFollowers = objectId;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      widget.currentUser = response.results!.first;
      setState(() {
        keyUpdate = QuickHelp.generateUId().toString();
      });
    } else {
      QuickHelp.showAppNotificationAdvanced(
        title: "edit_data_screen.error_".tr(),
        message: "edit_data_screen.updated_failed_explain".tr(),
        context: context,
      );
    }
  }

  Widget button(UserModel user) {
    if (widget.isFollowers!) {

      if (followersIds.contains(user.objectId) &&
          followingIds.contains(user.objectId)) {
        return ContainerCorner(
          imageDecoration: "assets/images/icon_has_fav_with_bg.png",
          height: 35,
          width: 60,
        );
      }else if (followersIds.contains(user.objectId)) {
        return ContainerCorner(
          imageDecoration: "assets/images/icon_unfav_with_bg.png",
          height: 35,
          width: 60,
          onTap: () => followOrUnfollow(follow: true, mUser: user),
        );
      } else {
        return ContainerCorner(
          imageDecoration: "assets/images/icon_fav_with_bg.png",
          borderWidth: 0,
          height: 35,
          width: 60,
          onTap: () => followOrUnfollow(follow: false, mUser: user),
        );
      }
    } else {
      return ContainerCorner(
        imageDecoration: "assets/images/icon_unfav_with_bg.png",
        borderWidth: 0,
        height: 35,
        width: 60,
        onTap: () => followOrUnfollow(follow: true, mUser: user),
      );
    }
  }

  void followOrUnfollow(
      {required bool follow, required UserModel mUser}) async {


    if (widget.currentUser!.getFollowing!.contains(mUser.objectId)) {

      widget.currentUser!.removeFollowing = mUser.objectId!;
      ParseResponse response = await widget.currentUser!.save();

      if (response.success && response.results != null) {
        widget.currentUser = response.results!.first;
        setState(() {
          keyUpdate = QuickHelp.generateUId().toString();
        });
      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "edit_data_screen.error_".tr(),
          message: "edit_data_screen.updated_failed_explain".tr(),
          context: context,
        );
      }

    } else {
      widget.currentUser!.setFollowing = mUser.objectId!;
      ParseResponse response = await widget.currentUser!.save();

      if (response.success && response.results != null) {
        widget.currentUser = response.results!.first;
        setState(() {
          keyUpdate = QuickHelp.generateUId().toString();
        });
      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "edit_data_screen.error_".tr(),
          message: "edit_data_screen.updated_failed_explain".tr(),
          context: context,
        );
      }
    }

    ParseResponse parseResponse;

    if (follow) {
      parseResponse = await QuickCloudCode.unFollowUser(
        author: widget.currentUser!,
        receiver: mUser,
      );
    } else {
      parseResponse = await QuickCloudCode.followUser(
        author: widget.currentUser!,
        receiver: mUser,
      );
    }

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!, mUser,
          NotificationsModel.notificationTypeFollowers);
    }
  }
}
