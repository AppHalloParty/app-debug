import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/home/reels/reels_saved_videos_screen.dart';
import 'package:trace/home/reels/reels_single_screen.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/ui/button_with_svg.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';
import '../../helpers/quick_cloud.dart';
import '../../models/NotificationsModel.dart';
import '../../models/ReportModel.dart';
import '../../models/UserModel.dart';
import '../../ui/button_with_icon.dart';
import '../../ui/text_with_tap.dart';
import '../feed/create_video_post_screen.dart';
import '../message/message_screen.dart';


// ignore: must_be_immutable
class ReelsVideosScreen extends StatefulWidget {
  static String route = "/home/reels/videos";

  UserModel? currentUser, mUser;

  ReelsVideosScreen({this.currentUser, this.mUser});

  @override
  _ReelsVideosScreenState createState() => _ReelsVideosScreenState();
}

class _ReelsVideosScreenState extends State<ReelsVideosScreen>
    with TickerProviderStateMixin {
  UserModel? user;
  int? videoCount = 0;
  bool following = false;
  AnimationController? _animationController;
  TextEditingController postContent = TextEditingController();

  String? uploadPhoto;
  ParseFileBase? parseFile;
  ParseFileBase? parseFileThumbnail;
  bool? isVideo = false;
  File? videoFile;

  @override
  void initState() {
    if (widget.mUser != null) {
      user = widget.mUser;

      if (widget.currentUser!.getFollowing!.contains(user!.objectId!)) {
        setState(() {
          following = true;
        });
      } else {
        following = false;
      }
    } else {
      user = widget.currentUser;
    }

    countVideos();
    _animationController = AnimationController.unbounded(vsync: this);
    super.initState();
  }

  countVideos() async {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
    queryBuilder.whereEqualTo(PostsModel.keyAuthorId, user!.objectId!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, true);

    ParseResponse response = await queryBuilder.count();
    if (response.success) {
      setState(() {
        videoCount = response.count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.reels_videos_title"
          .tr(namedArgs: {"name": user!.getFullName!}),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: QuickHelp.isAndroidPlatform() ? Icons.arrow_back_outlined : Icons.arrow_back_ios,
      rightButtonTwoPress:
          widget.mUser != null ? () => openSheet(widget.mUser!) : null,
      rightButtonTwoIcon: widget.mUser != null
          ? Icons.more_vert
          : null,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: reelsScreen(),
      elevation: 1,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: Visibility(
        visible: widget.mUser == null,
        child: FloatingActionButton.extended(
          //materialTapTargetSize: MaterialTapTargetSize.padded,
          isExtended: true,
          backgroundColor: kPrimaryColor,
          onPressed: () => goToPostVideoScreen(),
          label: TextWithTap(
            "feed.reels_new_video".tr(),
            marginLeft: 5,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
            fontSize: 16,
            color: Colors.white,
          ),
          icon: Icon(
            Icons.video_library_outlined,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  goToPostVideoScreen() {
    QuickHelp.goToNavigatorScreen(
      context,
      CreateVideoPostScreen(
        currentUser: widget.currentUser,
      ),
    );
  }

  Widget reelsScreen() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          margin: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  QuickActions.avatarWidget(user!, width: 60, height: 60),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        user!.getFullName!,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        marginLeft: 10,
                      ),
                      TextWithTap(
                        "feed.reels_profile_video_followers".tr(
                          namedArgs: {
                            "video_count":
                                QuickHelp.convertNumberToK(videoCount!),
                            "followers_count": QuickHelp.convertNumberToK(
                                user!.getFollowers!.length)
                          },
                        ),
                        fontSize: 15,
                        color: kGrayColor,
                        marginLeft: 10,
                      ),
                    ],
                  ),
                ],
              ),
              widget.mUser != null
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: ButtonWithSvg(
                              text: following
                                  ? "feed.reels_unfollow_user".tr()
                                  : "feed.reels_follow_user".tr(),
                              color: following ? kPrimaryColor : kPrimacyGrayColor,
                              svgName: 'ic_menu_followers',
                              borderRadius: 5,
                              fontSize: 16,
                              svgHeight: 22,
                              svgWidth: 22,
                              svgColor: following ? Colors.white : Colors.white,
                              textColor:
                                  following ? Colors.white : Colors.white,
                              fontWeight: FontWeight.bold,
                              press: () => followOrUnfollow(),
                            ),
                          ),
                          Visibility(
                            visible: widget.currentUser!.objectId != widget.mUser!.objectId,
                            child: Flexible(
                              child: ButtonWithSvg(
                                text: "feed.reels_send_message".tr(),
                                marginLeft: 10,
                                borderRadius: 5,
                                fontSize: 16,
                                svgHeight: 26,
                                svgWidth: 26,
                                svgName: 'ic_tab_chat_default',
                                color: kBlueColor1,
                                svgColor: Colors.white,
                                textColor: Colors.white,
                                fontWeight: FontWeight.bold,
                                press: () {
                                  QuickHelp.goToNavigatorScreen(
                                      context, MessageScreen(
                                    currentUser: widget.currentUser,
                                    mUser: widget.mUser,
                                  ));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: ButtonWithIcon(
                              text: "feed.reels_saved_videos".tr(),
                              backgroundColor: Colors.black12,
                              borderRadius: 5,
                              fontSize: 16,
                              textColor: Colors.black,
                              fontWeight: FontWeight.bold,
                              onTap: ()=> QuickHelp.goToNavigatorScreenForResult(context, ReelsSavedVideosScreen(currentUser: widget.currentUser)),
                            ),
                          ),
                          ButtonWithIcon(
                            text: null,
                            marginLeft: 10,
                            borderRadius: 5,
                            icon: Icons.more_horiz_outlined,
                            backgroundColor: Colors.black12,
                            iconColor: Colors.black,
                            onTap: () => widget.mUser == null
                                ? QuickHelp.goToNavigatorScreen(
                                    context,
                                    ProfileScreen(
                                      currentUser: widget.currentUser,
                                    ),
                                  )
                                : QuickActions.showUserProfile(context,
                                    widget.currentUser!, widget.mUser!),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        Expanded(
          child: loadVideosList(),
        ),
      ],
    );
  }

  Widget loadVideosList() {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
    queryBuilder.whereEqualTo(PostsModel.keyAuthorId, user!.objectId!);
    queryBuilder.whereValueExists(PostsModel.keyVideo, true);
    queryBuilder.orderByDescending(keyVarCreatedAt);

    return ParseLiveGridWidget<PostsModel>(
      query: queryBuilder,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      lazyLoading: false,
      childAspectRatio: 1 / 1.8,
      shrinkWrap: true,
      listenOnAllSubItems: true,
      animationController: _animationController,
      childBuilder: (ctx, snapshot) {
        PostsModel post = snapshot.loadedData as PostsModel;

        return GestureDetector(
          onTap: (){
            QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: widget.currentUser, post: post,));
          },
          child: Stack(
            children: [
              QuickActions.photosWidget(
                post.getVideoThumbnail!.url,
                fit: BoxFit.fitWidth,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ContainerCorner(
                  height: 35,
                  colors: [Colors.black, Colors.black.withOpacity(0.1)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      TextWithTap(
                        QuickHelp.convertNumberToK(post.getViews),
                        marginLeft: 2,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      gridLoadingElement: Center(child: QuickHelp.showLoadingAnimation()),
      queryEmptyElement: QuickActions.noContentFound(context),
    );
  }

  void openSheet(UserModel author) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author);
        });
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: true,
                child: ButtonWithIcon(
                  text: "feed.reels_user_report"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  //iconURL: "assets/svg/ic_blocked_menu.svg",
                  icon: Icons.report_problem_outlined,
                  iconColor: kPrimaryColor,
                  iconSize: 26,
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    openReportUserMessage(author);
                  },
                ),
              ),
              Divider(),
              Visibility(
                visible: true,
                child: ButtonWithIcon(
                  text: "feed.block_user"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  textColor: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  //iconURL: "assets/images/ic_block_user.png",
                  icon: Icons.block,
                  iconColor: kPrimaryColor,
                  iconSize: 26,
                  onTap: () {
                    Navigator.of(context).pop();
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "feed.post_block_title".tr(),
                      message: "feed.post_block_message"
                          .tr(namedArgs: {"name": author.getFullName!}),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText: "feed.post_block_confirm".tr(),
                      onPressed: () => _blockUser(author),
                    );
                  },
                  height: 60,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                ),
              ),
              Divider(),
              Visibility(
                visible: true,
                child: ButtonWithIcon(
                  text: "feed.reels_goto_profile".tr(),
                  //iconURL: "assets/svg/ic_blocked_menu.svg",
                  icon: Icons.account_circle_outlined,
                  iconColor: kPrimaryColor,
                  iconSize: 26,
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    QuickHelp.goBackToPreviousPage(context);
                    QuickActions.showUserProfile(
                        context, widget.currentUser!, widget.mUser!);
                  },
                ),
              ),
              Divider(),
              Visibility(
                visible: widget.currentUser!.isAdmin!,
                child: ButtonWithIcon(
                  text: "feed.suspend_user".tr(),
                  iconURL: "assets/svg/config.svg",
                  height: 60,
                  radiusTopLeft: 25.0,
                  radiusTopRight: 25.0,
                  backgroundColor: Colors.white,
                  mainAxisAlignment: MainAxisAlignment.start,
                  textColor: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  onTap: () {
                    //_suspendUser(post!.getAuthor!);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _blockUser(UserModel author) async {
    Navigator.of(context).pop();
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setBlockedUser = author;
    widget.currentUser!.setBlockedUserIds = author.objectId!;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      widget.currentUser = response.results!.first as UserModel;

      QuickHelp.hideLoadingDialog(context);
      //QuickHelp.goToNavigator(context, BlockedUsersScreen.route);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_block_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
        message: "feed.post_block_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  void openReportUserMessage(UserModel author) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportUserMessageBottomSheet(author);
        });
  }

  Widget _showReportUserMessageBottomSheet(UserModel author) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    radiusTopRight: 20.0,
                    radiusTopLeft: 20.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: Column(
                      children: [
                        ContainerCorner(
                          color: kGreyColor1,
                          width: 50,
                          marginTop: 5,
                          borderRadius: 50,
                          marginBottom: 10,
                        ),
                        TextWithTap(
                          "feed.report_".tr(),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          marginBottom: 50,
                        ),
                        Column(
                          children: List.generate(
                              QuickHelp.getReportCodeMessageList().length,
                              (index) {
                            String code =
                                QuickHelp.getReportCodeMessageList()[index];

                            return TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                print("Message: " +
                                    QuickHelp.getReportMessage(code));
                                Navigator.of(context).pop();
                                _saveUserReport(
                                    QuickHelp.getReportMessage(code), author);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWithTap(
                                        QuickHelp.getReportMessage(code),
                                        color: kGrayColor,
                                        fontSize: 15,
                                        marginBottom: 5,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 1.0,
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                        ContainerCorner(
                          marginTop: 30,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: TextWithTap(
                              "cancel".tr().toUpperCase(),
                              color: kGrayColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  _saveUserReport(String reason, UserModel author) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await QuickActions.report(
      type: ReportModel.reportTypeProfile,
      message: reason,
      accuser: widget.currentUser!,
      accused: author,
    );

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
        message: "feed.post_report_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  void followOrUnfollow() async {
    if (widget.currentUser!.getFollowing!.contains(widget.mUser!.objectId)) {
      widget.currentUser!.removeFollowing = widget.mUser!.objectId!;

      setState(() {
        following = false;
      });
    } else {
      widget.currentUser!.setFollowing = widget.mUser!.objectId!;

      setState(() {
        following = true;
      });
    }

    await widget.currentUser!
        .save()
        .then((value) => widget.currentUser = value.result as UserModel);

    ParseResponse parseResponse = await QuickCloudCode.followUser(
        author: widget.currentUser!,
        receiver: widget.mUser!);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          widget.mUser!, NotificationsModel.notificationTypeFollowers);
    }
  }
}
