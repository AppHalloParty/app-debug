// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/feed/visualize_multiple_pictures_screen.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_cloud.dart';
import '../../helpers/quick_help.dart';
import '../../models/ReportModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/profile_screen.dart';
import '../reels/reels_home_screen.dart';

class FeedReelsScreen extends StatefulWidget {
  static String route = "feed/reels";
  UserModel? currentUser;
  int? initialIndex, pictureIndex;
  List? preloadsPost;

  FeedReelsScreen({
    this.currentUser,
    this.initialIndex,
    this.preloadsPost,
    this.pictureIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<FeedReelsScreen> createState() => _FeedReelsScreenState();
}

class _FeedReelsScreenState extends State<FeedReelsScreen> {
  PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    pageController = PageController(initialPage: widget.initialIndex!);
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.preloadsPost!.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          PostsModel post = widget.preloadsPost![index];
          if (post.getVideo != null) {
            return ReelsHomeScreen(currentUser: widget.currentUser, post: post,);
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    child: postContent(post),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: size.width / 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            ContainerCorner(
                                marginTop: 10,
                                child: Row(
                                  children: [
                                    QuickActions.avatarWidget(
                                      post.getAuthor!,
                                      width: 50,
                                      height: 50,
                                      vipFrameWidth: 60,
                                      vipFrameHeight: 57,
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          TextWithTap(
                                            post.getAuthor!
                                                .getFullName!,
                                            fontWeight: FontWeight.bold,
                                            fontSize: size.width / 20,
                                            marginBottom: 5,
                                              color: Colors.white
                                          ),
                                          QuickActions.getGender(
                                            currentUser:
                                            post.getAuthor!,
                                            context: context,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                marginLeft: 15,
                                onTap: () {
                                  if (post.getAuthorId ==
                                      widget.currentUser!.objectId!) {
                                    QuickHelp.goToNavigatorScreen(
                                        context,
                                        ProfileScreen(
                                          currentUser: widget.currentUser,
                                        ));
                                  } else {
                                    QuickActions.showUserProfile(
                                        context,
                                        widget.currentUser!,
                                        post.getAuthor!,
                                    );
                                  }
                                }),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 8.0),
                                  Container(
                                    width: 220,
                                    child: Text(
                                      QuickHelp.getTimeAgoForFeed(post.createdAt!),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => openSheet(
                            post.getAuthor!, post),
                        icon: SvgPicture.asset(
                          "assets/svg/ic_post_config.svg",
                          color: kGrayColor,
                          height: 13,
                          width: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
        onPageChanged: (newIndex) {
          setState(() {
            widget.pictureIndex = 0;
          });
        },
      ),
    );
  }

  postContent(PostsModel post) {
    if(post.getImagesList!.isNotEmpty) {
      return VisualizeMultiplePicturesScreen(
        picturesFromDataBase: post.getImagesList,
        initialIndex: widget.pictureIndex ?? 0,
      );
    }else{
      if(post.getText!.isNotEmpty && post.getBackgroundColor == null){
        return TextWithTap(
          post.getText!,
          textAlign: TextAlign.start,
          marginTop: 10,
          marginBottom: 5,
          marginLeft: 10,
          color: Colors.white,
          alignment: Alignment.center,
        );
      }else if(post.getText!.isNotEmpty && post.getBackgroundColor != null) {
        Size size = MediaQuery.sizeOf(context);
        return Center(
          child: ContainerCorner(
            width: size.width,
            marginLeft: 5,
            marginTop: 10,
            borderRadius: 8,
            marginRight: 5,
            color: QuickHelp.stringToColor(post.getBackgroundColor!),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, top: 20, bottom: 20),
              child: AutoSizeText(
                post.getText!,
                style: GoogleFonts.nunito(
                  fontSize: 30,
                  color: QuickHelp.stringToColor(post.getTextColors!),
                ),
                minFontSize: 15,
                stepGranularity: 5,
                maxLines: 10,
              ),
            ),
          ),
        );
      }else{
        return SizedBox();
      }
    }
  }

  void openSheet(UserModel author, PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, post);
        });
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author, PostsModel post) {
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
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: TextWithTap(
                  "feed.report_post"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  onTap: () {
                    openReportMessage(author, post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: TextWithTap(
                  "feed.block_user"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 10,
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
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: TextWithTap(
                  "feed.delete_post".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 10,
                  onTap: () {
                    _deletePost(post);
                  },
                ),
              ),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: Divider(),
              ),
              Visibility(
                visible: widget.currentUser!.isAdmin!,
                child: TextWithTap(
                  "feed.suspend_user".tr(),
                  marginBottom: 10,
                  marginTop: 10,
                  onTap: () {
                    _suspendUser(post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
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

  void openReportMessage(UserModel author, PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportMessageBottomSheet(author, post);
        });
  }

  Widget _showReportMessageBottomSheet(UserModel author, PostsModel post) {
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
                                    _saveReport(
                                        QuickHelp.getReportMessage(code), post);
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

  _saveReport(String reason, PostsModel post) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser?.setReportedPostIDs = post.objectId;
    widget.currentUser?.setReportedPostReason = reason;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {});
    } else {
      QuickHelp.hideLoadingDialog(context);
    }

    ParseResponse parseResponse = await QuickActions.report(
        type: ReportModel.reportTypePost,
        message: reason,
        accuser: widget.currentUser!,
        accused: post.getAuthor!,
        postsModel: post);

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": post.getAuthor!.getFullName!}),
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

  _suspendUser(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(post.getAuthor!),
    );
  }

  _confirmSuspendUser(UserModel userModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    userModel.setActivationStatus = true;
    ParseResponse parseResponse =
    await QuickCloudCode.suspendUSer(objectId: userModel.objectId!);
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "suspended".tr(),
        message: "feed.user_suspended".tr(),
        user: userModel,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.user_not_suspended".tr(),
        user: userModel,
        isError: true,
      );
    }
  }

  _deletePost(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.delete_post_alert".tr(),
      message: "feed.delete_post_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_delete".tr(),
      onPressed: () => _confirmDeletePost(post),
    );
  }

  _confirmDeletePost(PostsModel postsModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await postsModel.delete();
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "deleted".tr(),
        message: "feed.post_deleted".tr(),
        user: postsModel.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.post_not_deleted".tr(),
        user: postsModel.getAuthor,
        isError: true,
      );
    }
  }
}
