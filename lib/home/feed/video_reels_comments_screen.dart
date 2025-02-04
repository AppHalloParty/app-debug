// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/CommentsModel.dart';
import '../../models/NotificationsModel.dart';
import '../../models/PostsModel.dart';
import '../../models/ReplyModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';
import '../profile/user_profile_screen.dart';

class VideoReelsCommentScreen extends StatefulWidget {
  UserModel? currentUser;
  PostsModel? post;
  VideoReelsCommentScreen({this.currentUser, this.post, super.key});

  @override
  State<VideoReelsCommentScreen> createState() => _VideoReelsCommentScreenState();
}

class _VideoReelsCommentScreenState extends State<VideoReelsCommentScreen> {

  TextEditingController replyController = TextEditingController();

  bool showCommentOrReplyTextField = true;
  List commentToReply = [];

  String keyToRefreshCommentsList = "";
  String keyToRefreshRepliesList = "";

  late FocusNode? commentTextFieldFocusNode;

  TextEditingController commentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    commentTextFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: (){
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(color: isDark ? Colors.white : kContentColorLightTheme,),
          centerTitle: true,
          title: TextWithTap(
            "feed.reels_video_comments".tr(),
            fontWeight: FontWeight.w800,
          ),
        ),
        body: showAllComments(),
        bottomNavigationBar:  commentInputField(),
      ),
    );
  }

  Widget commentInputField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10),
      child: Row(
        children: [
          Expanded(
            child: ContainerCorner(
              color: kGrayColor.withOpacity(0.1),
              marginLeft: 10,
              borderRadius: 50,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  onChanged: (text) {},
                  focusNode: commentTextFieldFocusNode,
                  maxLines: 1,
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: "comment_post.leave_comment".tr(),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          ContainerCorner(
            color: kPrimaryColor,
            height: 30,
            marginLeft: 10,
            marginRight: 10,
            borderRadius: 40,
            onTap: () {
              if (commentController.text.isNotEmpty) {
                _createComment(widget.post!, commentController.text);
                setState(() {
                  commentController.text = "";
                });
                QuickHelp.removeFocusOnTextField(context);
              }
            },
            child: TextWithTap(
              "comment_post.send_".tr(),
              color: Colors.white,
              marginLeft: 10,
              marginRight: 10,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }

  _createComment(PostsModel post, String text) async {
    CommentsModel comment = CommentsModel();
    comment.setAuthor = widget.currentUser!;
    comment.setText = text;
    comment.setAuthorId = widget.currentUser!.objectId!;
    comment.setPostId = post.objectId!;
    comment.setPost = post;

    await comment.save();

    post.setComments = comment.objectId!;
    await post.save();

    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeCommentPost,
        post: post);
  }

  Widget showAllComments() {
    var size = MediaQuery.of(context).size;

    QueryBuilder<CommentsModel> queryBuilder =
    QueryBuilder<CommentsModel>(CommentsModel());
    queryBuilder.whereEqualTo(CommentsModel.keyPost, widget.post);
    queryBuilder.whereNotContainedIn(
        CommentsModel.keyObjectId, widget.currentUser!.getReportedCommentID!);

    queryBuilder.includeObject([
      CommentsModel.keyAuthor,
      CommentsModel.keyPost,
    ]);

    return ParseLiveListWidget<CommentsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      primary: false,
      key: Key(keyToRefreshCommentsList),
      scrollPhysics: const NeverScrollableScrollPhysics(),
      duration: const Duration(milliseconds: 200),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<CommentsModel> snapshot) {
        if (snapshot.hasData) {
          CommentsModel commentsModel = snapshot.loadedData! as dynamic;

          return Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if(commentsModel.getAuthorId == widget.currentUser!.objectId) {
                          QuickHelp.goToNavigatorScreen(context,
                              HomeScreen(
                                currentUser: widget.currentUser,
                                initialTabIndex: 4,
                              )
                          );
                        }else{
                          goToUserProfile(commentsModel.getAuthor!);
                        }
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          QuickActions.avatarWidget(
                            commentsModel.getAuthor!,
                            width: 40,
                            height: 40,
                          ),
                          if (commentsModel.getAuthor!.getAvatarFrame !=
                              null &&
                              commentsModel.getAuthor!
                                  .getCanUseAvatarFrame!)
                            ContainerCorner(
                              borderWidth: 0,
                              width: 55,
                              height: 55,
                              child: CachedNetworkImage(
                                imageUrl: commentsModel.getAuthor!
                                    .getAvatarFrame!.url!,
                                imageBuilder:
                                    (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: AlignmentDirectional.center,
                        children: [
                          ContainerCorner(
                            marginLeft: 5,
                            marginRight: 10,
                            marginBottom: 5,
                            borderRadius: 10,
                            color: QuickHelp.isDarkMode(context)
                                ? kContentDarkShadow
                                : kGrayWhite,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        TextWithTap(
                                          commentsModel.getAuthor!.getFullName!,
                                          marginLeft: 10,
                                          marginBottom: 5,
                                          fontWeight: FontWeight.bold,
                                          color: QuickHelp.isDarkMode(context)
                                              ? Colors.white
                                              : kContentColorLightTheme,
                                          fontSize: 16,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: ExpandableText(
                                            commentsModel.getText!,
                                            expandText: 'show_more'.tr(),
                                            collapseText: 'show_less'.tr(),
                                            maxLines: 2,
                                            linkColor: Colors.blue,
                                            style: GoogleFonts.nunito(
                                                color: kGrayColor),
                                          ),
                                        ),
                                        TextWithTap(
                                          QuickHelp.getTimeAgoForFeed(
                                              commentsModel.createdAt!),
                                          marginLeft: 10,
                                          color: kGrayColor,
                                          marginTop: 10,
                                          fontSize: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: size.width / 8, bottom: 15),
                  child: Row(
                    children: [
                      TextWithTap(
                        "reply_".tr(),
                        color: kGrayColor,
                        onTap: () => _showReplyTextField(commentsModel),
                        fontWeight: FontWeight.w900,
                        marginLeft: 7,
                      ),
                      ContainerCorner(
                        marginLeft: 20,
                        onTap: () {
                          openReportComments(
                            author: commentsModel.getAuthor!,
                            commentOrReply: 1,
                            comment: commentsModel,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/svg/ic_report.svg",
                          height: 17,
                          width: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: commentToReply.contains(commentsModel.objectId),
                  child: replyInputField(commentsModel),
                ),
                showAllReplies(commentsModel),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      queryEmptyElement: QuickActions.noContentFound(context),
      listLoadingElement: QuickHelp.appLoading(),
    );
  }

  openReportComments(
      {required UserModel author,
        required int commentOrReply,
        CommentsModel? comment,
        ReplyModel? replyComment}) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportCommentsBottomSheet(
            author: author,
            commentOrReply: commentOrReply,
            comment: comment,
            replyComment: replyComment,
          );
        });
  }

  Widget _showReportCommentsBottomSheet(
      {required UserModel author,
        required int commentOrReply,
        CommentsModel? comment,
        ReplyModel? replyComment}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
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
                        const ContainerCorner(
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

                                    if (commentOrReply == 1) {
                                      _saveReportComment(comment!.objectId!);
                                    } else if (commentOrReply == 2) {
                                      _saveReportReply(replyComment!.objectId!);
                                    }
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
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 18,
                                            color: kGrayColor,
                                          ),
                                        ],
                                      ),
                                      const Divider(
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

  _saveReportComment(String commentID) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setReportedCommentID = commentID;

    ParseResponse response = await widget.currentUser!.save();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "post_comment_screen.reported_succeed_title".tr(),
        message: "post_comment_screen.reported_succeed_explain".tr(),
        context: context,
        isError: false,
      );
      setState(() {
        keyToRefreshCommentsList = commentID;
      });
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "post_comment_screen.reported_failed_title".tr(),
        message: "post_comment_screen.reported_failed_explain".tr(),
        context: context,
      );
    }
  }

  _saveReportReply(String commentID) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setReportedReplyID = commentID;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "post_comment_screen.reported_succeed_title".tr(),
        message: "post_comment_screen.reported_succeed_explain".tr(),
        context: context,
        isError: false,
      );
      setState(() {
        keyToRefreshRepliesList = commentID;
      });
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "post_comment_screen.reported_failed_title".tr(),
        message: "post_comment_screen.reported_failed_explain".tr(),
        context: context,
      );
    }
  }


  Widget showAllReplies(CommentsModel commentsModel) {
    var size = MediaQuery.of(context).size;

    QueryBuilder<ReplyModel> queryBuilder =
    QueryBuilder<ReplyModel>(ReplyModel());

    queryBuilder.whereEqualTo(ReplyModel.keyCommentId, commentsModel.objectId);
    queryBuilder.orderByAscending(ReplyModel.keyCreatedAt);

    queryBuilder.whereNotContainedIn(
        ReplyModel.keyObjectId, widget.currentUser!.getReportedReplyID!);

    queryBuilder.includeObject([
      CommentsModel.keyAuthor,
      CommentsModel.keyPost,
    ]);

    return ParseLiveListWidget<ReplyModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      primary: false,
      key: Key(keyToRefreshRepliesList),
      scrollPhysics: const NeverScrollableScrollPhysics(),
      duration: const Duration(milliseconds: 200),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ReplyModel> snapshot) {
        if (snapshot.hasData) {
          ReplyModel replyModel = snapshot.loadedData! as dynamic;

          return Padding(
            padding: EdgeInsets.only(left: size.width / 8, top: 2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(replyModel.getAuthorId == widget.currentUser!.objectId) {
                          QuickHelp.goToNavigatorScreen(context,
                              HomeScreen(
                                currentUser: widget.currentUser,
                                initialTabIndex: 4,
                              )
                          );
                        }else{
                          goToUserProfile(replyModel.getAuthor!);
                        }
                      },
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          QuickActions.avatarWidget(
                            replyModel.getAuthor!,
                            width: 35,
                            height: 35,
                          ),
                          if (replyModel.getAuthor!.getAvatarFrame !=
                              null &&
                              replyModel.getAuthor!
                                  .getCanUseAvatarFrame!)
                            ContainerCorner(
                              borderWidth: 0,
                              width: 45,
                              height: 45,
                              child: CachedNetworkImage(
                                imageUrl: replyModel.getAuthor!
                                    .getAvatarFrame!.url!,
                                imageBuilder:
                                    (context, imageProvider) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fill),
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: AlignmentDirectional.center,
                        children: [
                          ContainerCorner(
                            marginLeft: 5,
                            marginRight: 10,
                            marginBottom: 5,
                            borderRadius: 10,
                            color: QuickHelp.isDarkMode(context)
                                ? kContentDarkShadow
                                : kGrayWhite,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        TextWithTap(
                                          replyModel.getAuthor!.getFullName!,
                                          marginLeft: 10,
                                          marginBottom: 5,
                                          fontWeight: FontWeight.bold,
                                          color: QuickHelp.isDarkMode(context)
                                              ? Colors.white
                                              : kContentColorLightTheme,
                                          fontSize: 16,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: ExpandableText(
                                            replyModel.getText!,
                                            expandText: 'show_more'.tr().toLowerCase(),
                                            collapseText: 'show_less'.tr().toLowerCase(),
                                            maxLines: 4,
                                            linkColor: Colors.blue,
                                            style: GoogleFonts.nunito(
                                                color: kGrayColor),
                                          ),
                                        ),
                                        TextWithTap(
                                          QuickHelp.getTimeAgoForFeed(
                                              replyModel.createdAt!),
                                          marginLeft: 10,
                                          color: kGrayColor,
                                          marginTop: 10,
                                          fontSize: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: size.width / 8, bottom: 15),
                  child: Row(
                    children: [
                      ContainerCorner(
                        marginLeft: 10,
                        onTap: () {
                          openReportComments(
                            author: replyModel.getAuthor!,
                            commentOrReply: 2,
                            replyComment: replyModel,
                          );
                        },
                        child: SvgPicture.asset(
                          "assets/svg/ic_report.svg",
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
      queryEmptyElement: const SizedBox(),
      listLoadingElement: const SizedBox(),
    );
  }

  goToUserProfile(UserModel user) {
    QuickHelp.goToNavigatorScreen(
      context,
      UserProfileScreen(
        currentUser: widget.currentUser,
        mUser: user,
        isFollowing: widget.currentUser!.getFollowing!.contains(user.objectId),
      ),
    );
  }

  Widget replyInputField(CommentsModel commentModel) {
    var size = MediaQuery.of(context).size;
    return ContainerCorner(
      marginLeft: size.width / 10,
      marginRight: 10,
      marginBottom: 20,
      shadowColor: kGrayColor,
      shadowColorOpacity: 0.3,
      child: Row(
        children: [
          ContainerCorner(
            marginRight: 10,
            color: kContentColorLightTheme,
            child: const ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 20,
              width: 20,
              child: Center(
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () => _clearCommentsToReply(),
          ),
          Expanded(
            child: ContainerCorner(
              color: kContentColorLightTheme,
              borderRadius: 10,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  minLines: 1,
                  controller: replyController,
                  style: GoogleFonts.nunito(color: kGrayColor),
                  decoration: InputDecoration(
                    hintText: "reply_".tr(),
                    hintStyle: GoogleFonts.nunito(color: kGrayColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          ContainerCorner(
            marginLeft: 10,
            color: kContentColorLightTheme,
            child: ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 20,
              width: 20,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SvgPicture.asset(
                  "assets/svg/ic_sent_message.svg",
                  color: Colors.white,
                ),
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () {
              if (replyController.text.isNotEmpty) {
                _replyComment(comment: commentModel);
                setState(() {
                  replyController.text = "";
                  commentToReply.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  _replyComment({required CommentsModel comment}) async {
    ReplyModel replyModel = ReplyModel();

    replyModel.setComment = comment;
    replyModel.setCommentId = comment.objectId!;
    replyModel.setText = replyController.text;
    replyModel.setAuthor = widget.currentUser!;
    replyModel.setAuthorId = widget.currentUser!.objectId!;

    await replyModel.save();

    QuickActions.createOrDeleteNotification(widget.currentUser!,
        comment.getAuthor!, NotificationsModel.notificationTypeReplyCommentPost,
        post: widget.post);
  }

  _showReplyTextField(CommentsModel commentsModel) {
    commentToReply.clear();

    setState(() {
      commentToReply.add(commentsModel.objectId);
    });
  }

  _clearCommentsToReply() {
    setState(() {
      commentToReply.clear();
    });
  }

}
