// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/home_screen.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/home/profile/user_profile_screen.dart';
import 'package:trace/models/CommentsModel.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../app/setup.dart';
import '../../helpers/quick_cloud.dart';
import '../../models/ReplyModel.dart';
import '../../models/ReportModel.dart';
import '../../services/deep_links_service.dart';
import 'edit_pictures_post.dart';
import 'edit_text_post_screen.dart';
import 'edit_video_post.dart';
import 'feed_on_reels_screen.dart';

class CommentPostScreen extends StatefulWidget {
  static String route = "/post/comment";
  UserModel? currentUser;
  PostsModel? post;

  CommentPostScreen({this.currentUser, this.post, Key? key});

  @override
  _CommentPostScreenState createState() => _CommentPostScreenState();
}

class _CommentPostScreenState extends State<CommentPostScreen> {
  int clickedPostIndex = 0;
  int clickedImageIndex = 0;

  List<PostsModel> allPosts = [];

  TextEditingController replyController = TextEditingController();

  bool showCommentOrReplyTextField = true;
  List commentToReply = [];

  String keyToRefreshCommentsList = "";
  String keyToRefreshRepliesList = "";

  getAllUserPost() async{
    QueryBuilder queryBuilder = QueryBuilder<PostsModel>(PostsModel());

    queryBuilder.whereEqualTo(PostsModel.keyAuthorId, widget.post!.getAuthorId!);
    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyAuthorName,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor,
      PostsModel.keyTargetPeople
    ]);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        for (PostsModel post in apiResponse.results!) {
          if (!allPosts.contains(post)) {
            setState(() {
              allPosts.add(post);
            });
          }
        }
      }
    }
  }

  late FocusNode? commentTextFieldFocusNode;

  TextEditingController commentController = TextEditingController();

  _deleteLike(PostsModel postsModel) async {
    QueryBuilder<NotificationsModel> queryBuilder =
        QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyAuthor, widget.currentUser);
    queryBuilder.whereEqualTo(NotificationsModel.keyPost, postsModel);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success && parseResponse.results != null) {
      NotificationsModel notification = parseResponse.results!.first;
      await notification.delete();
    }
  }

  _likePost(PostsModel post) {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: post);
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

  @override
  void initState() {
    super.initState();
    getAllUserPost();
    commentTextFieldFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return GestureDetector(
      onTap: () {
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          physics: ScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                elevation: 2,
                automaticallyImplyLeading: false,
                leading: BackButton(
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorDarkTheme
                      : kContentColorLightTheme,
                ),
                backgroundColor: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : kContentColorDarkTheme,
                title: TextWithTap(
                  "comment_post.post_comments".tr(),
                  fontSize: 20,
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorDarkTheme
                      : kContentColorLightTheme,
                  fontWeight: FontWeight.bold,
                ),
                centerTitle: true,
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    ContainerCorner(
                      //height: 450,
                      color: QuickHelp.isDarkMode(context)
                          ? kContentColorLightTheme
                          : Colors.white,
                      marginTop: 7,
                      marginBottom: 0,
                      marginLeft: 10,
                      marginRight: 10,
                      borderRadius: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.post!.getTargetPeopleID != null &&
                              widget.post!.getTargetPeopleID!
                                  .contains(widget.currentUser!.objectId))
                            TextWithTap(
                              "feed.you_was_mentioned".tr(
                                namedArgs: {
                                  "author_name":
                                      widget.post!.getAuthor!.getFullName!
                                },
                              ),
                              marginLeft: 10,
                              color: kGrayColor.withOpacity(0.7),
                              fontSize: 7,
                              alignment: Alignment.center,
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: ContainerCorner(
                                    marginTop: 10,
                                    color: QuickHelp.isDarkMode(context)
                                        ? kContentColorLightTheme
                                        : Colors.white,
                                    child: Row(
                                      children: [
                                        QuickActions.avatarWidget(
                                          widget.post!.getAuthor!,
                                          width: 50,
                                          height: 50,
                                          vipFrameWidth: 60,
                                          vipFrameHeight: 57,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWithTap(
                                                    widget.post!.getAuthor!
                                                        .getFullName!,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: size.width / 20,
                                                    marginBottom: 5,
                                                    marginRight: 5,
                                                  ),
                                                  if(widget.post!.getAuthor!.getCountryCode!.isNotEmpty)
                                                    Image.asset(
                                                      QuickHelp.getCountryFlag(code: widget.post!.getAuthor!.getCountryCode!),
                                                      height: 12,
                                                    )
                                                ],
                                              ),
                                              QuickHelp.usersMoreInfo(
                                                context,
                                                widget.post!.getAuthor!,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    marginLeft: 10,
                                    onTap: () {
                                      if (widget.post!.getAuthorId ==
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
                                            widget.post!.getAuthor!,
                                        );
                                      }
                                    }),
                              ),
                              Visibility(
                                visible: widget.post!.getAuthorId ==
                                    widget.currentUser!.objectId,
                                child: IconButton(
                                  onPressed: () {
                                    editPostScreen(widget.post!);
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: kGrayColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => openSheet(
                                    widget.post!.getAuthor!, widget.post!),
                                icon: SvgPicture.asset(
                                  "assets/svg/ic_post_config.svg",
                                  color: kGrayColor,
                                  height: 13,
                                  width: 13,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: widget.post!.getText!.isNotEmpty &&
                                widget.post!.getBackgroundColor == null,
                            child: TextWithTap(
                              widget.post!.getText!,
                              textAlign: TextAlign.start,
                              marginTop: 10,
                              marginBottom: 5,
                              marginLeft: 10,
                            ),
                          ),
                          Divider(
                            height: 6,
                            color: kTransparentColor,
                          ),
                          showPost(widget.post!)
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.post!.getBackgroundColor != null)
                                      ContainerCorner(
                                        width: size.width,
                                        marginLeft: 5,
                                        marginTop: 10,
                                        borderRadius: 8,
                                        marginRight: 5,
                                        color: QuickHelp.stringToColor(
                                            widget.post!.getBackgroundColor!),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10, top: 20, bottom: 20),
                                          child: AutoSizeText(
                                            widget.post!.getText!,
                                            style: GoogleFonts.nunito(
                                              fontSize: 30,
                                              color: QuickHelp.stringToColor(
                                                  widget.post!.getTextColors!),
                                            ),
                                            minFontSize: 15,
                                            stepGranularity: 5,
                                            maxLines: 10,
                                          ),
                                        ),
                                      ),
                                    if (widget.post!.getVideo == null)
                                      Wrap(
                                        children: List.generate(
                                          widget.post!.getNumberOfPictures,
                                          (index) => ContainerCorner(
                                            width: imageWidth(
                                                numberOfPictures: widget
                                                    .post!.getNumberOfPictures),
                                            height: imageHeight(
                                                numberOfPictures: widget
                                                    .post!.getNumberOfPictures),
                                            borderWidth: 0,
                                            marginRight: 5,
                                            marginBottom: 5,
                                            borderRadius: 8,
                                            onTap: () {
                                              setState(() {
                                                clickedImageIndex = index;
                                              });
                                              goToFeedOnReels(
                                                  post: widget.post!);
                                            },
                                            child: QuickActions.photosWidget(
                                                widget.post!
                                                    .getImagesList![index].url),
                                          ),
                                        ),
                                      ),
                                    if (widget.post!.getVideo != null)
                                      ContainerCorner(
                                        width: size.width / 1.7,
                                        height: 350,
                                        borderRadius: 10,
                                        borderWidth: 0,
                                        onTap: () =>
                                            goToFeedOnReels(post: widget.post!),
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional.center,
                                          children: [
                                            QuickActions.photosWidget(widget
                                                .post!.getVideoThumbnail!.url),
                                            ContainerCorner(
                                              height: 40,
                                              width: 40,
                                              borderRadius: 50,
                                              borderWidth: 0,
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              child: Center(
                                                  child: Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white,
                                              )),
                                            ),
                                          ],
                                        ),
                                      )
                                  ],
                                )
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Image.asset(
                                          "assets/images/blurred_image.jpg"),
                                    ),
                                    ContainerCorner(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/ic_coin_with_star.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            TextWithTap(
                                              "feed.post_cost_exclusive".tr(
                                                  namedArgs: {
                                                    "coins": widget
                                                        .post!.getPaidAmount!
                                                        .toString()
                                                  }),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              marginLeft: 6,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          Visibility(
                            visible: showPost(widget.post!),
                            child: ContainerCorner(
                              color: QuickHelp.isDarkMode(context)
                                  ? kContentColorLightTheme
                                  : Colors.white,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _likeWidget(widget.post!),
                                      ContainerCorner(
                                        marginBottom: 10,
                                        marginTop: 10,
                                        marginLeft: 10,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/uil_comment.svg",
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                              height: 20,
                                              width: 20,
                                            ),
                                            TextWithTap(
                                              widget.post!.getComments!.length
                                                  .toString(),
                                              color: kGrayColor,
                                              marginLeft: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      ContainerCorner(
                                        marginBottom: 10,
                                        marginLeft: 10,
                                        marginTop: 10,
                                        onTap: () async {
                                          String linkToShare =
                                          await DeepLinksService.createLink(
                                            branchObject: DeepLinksService.branchObject(
                                              shareAction: DeepLinksService.keyPostShare,
                                              objectID: widget.post!.objectId!,
                                              imageURL: QuickHelp.getImageToShare(widget.post!) ,
                                              title: QuickHelp.getTitleToShare(widget.post!),
                                              description: widget.post!.getAuthor!.getFullName,
                                            ),
                                            branchProperties:
                                            DeepLinksService.linkProperties(
                                              channel: "link",
                                            ),
                                            context: context,
                                          );
                                          if (linkToShare.isNotEmpty) {
                                            Share.share(
                                              "share_post".tr(namedArgs: {
                                                "link": linkToShare,
                                                "app_name": Setup.appName
                                              }),
                                            );
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/images/feed_icon_details_share_new.png",
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          height: 20,
                                          width: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    ContainerCorner(
                      borderRadius: 10,
                      marginRight: 15,
                      marginLeft: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "comment_post.comment_amount".tr(
                              namedArgs: {
                                "amount":
                                    widget.post!.getComments!.length.toString()
                              },),
                            marginLeft: 10,
                            marginTop: 10,
                            marginBottom: 25,
                            fontWeight: FontWeight.bold,
                            ),
                          showAllComments(),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              commentInputField(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _likeWidget(PostsModel postModel) {
    bool isDark = QuickHelp.isDarkMode(context);
    return LikeButton(
      size: 30,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      countPostion: CountPostion.right,
      circleColor: CircleColor(start: kPrimaryColor, end: kPrimaryColor),
      bubblesColor: BubblesColor(
        dotPrimaryColor: kPrimaryColor,
        dotSecondaryColor: kPrimaryColor,
      ),
      isLiked: postModel.getLikes!.contains(widget.currentUser!.objectId),
      likeCountAnimationType: LikeCountAnimationType.all,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
          color: isLiked
              ? kPrimaryColor
              : isDark
              ? Colors.white
              : kContentColorLightTheme,
          size: 20,
        );
      },
      likeCount: postModel.getLikes!.length,
      countBuilder: (count, bool isLiked, String text) {
        Widget result;
        if (count == 0) {
          result = TextWithTap(
            "",
          );
        } else
          result = TextWithTap(
            QuickHelp.convertNumberToK(count!),
          );
        return result;
      },
      onTap: (isLiked) {
        print("Liked: $isLiked");

        if (isLiked) {
          postModel.removeLike = widget.currentUser!.objectId!;

          postModel.save().then((value) {
            postModel = value.results!.first as PostsModel;
          });

          _deleteLike(postModel);

          return Future.value(false);
        } else {
          postModel.setLikes = widget.currentUser!.objectId!;
          postModel.setLastLikeAuthor = widget.currentUser!;

          postModel.save().then((value) {
            postModel = value.results!.first as PostsModel;
          });

          _likePost(postModel);

          return Future.value(true);
        }
      },
    );
  }

  editPostScreen(PostsModel post) {
    if (post.getVideo != null) {
      QuickHelp.goToNavigatorScreen(
        context,
        EditVideoPostScreen(
          currentUser: widget.currentUser,
          postsModel: post,
        ),
      );
    } else if (post.getBackgroundColor != null) {
      QuickHelp.goToNavigatorScreen(
        context,
        EditTextPostScreen(
          currentUser: widget.currentUser,
          postsModel: post,
        ),
      );
    } else {
      QuickHelp.goToNavigatorScreen(
        context,
        EditPicturesPost(
          currentUser: widget.currentUser,
          postsModel: post,
        ),
      );
    }
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
                            vipFrameWidth: 50,
                            vipFrameHeight: 47,
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
                                        Row(
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
                                              marginRight: 5,
                                            ),
                                            if(commentsModel.getAuthor!.getCountryCode!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Image.asset(
                                                  QuickHelp.getCountryFlag(code: commentsModel.getAuthor!.getCountryCode!),
                                                  height: 10,
                                                ),
                                              )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6.0),
                                          child: QuickHelp.usersMoreInfo(
                                            context,
                                            commentsModel.getAuthor!,
                                          ),
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
                            vipFrameWidth: 45,
                            vipFrameHeight: 32,
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
                                        Row(
                                          children: [
                                            TextWithTap(
                                              replyModel.getAuthor!.getFullName!,
                                              marginLeft: 10,
                                              marginBottom: 5,
                                              marginRight: 5,
                                              fontWeight: FontWeight.bold,
                                              color: QuickHelp.isDarkMode(context)
                                                  ? Colors.white
                                                  : kContentColorLightTheme,
                                              fontSize: 16,
                                            ),
                                            if(replyModel.getAuthor!.getCountryCode!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Image.asset(
                                                  QuickHelp.getCountryFlag(code: replyModel.getAuthor!.getCountryCode!),
                                                  height: 10,
                                                ),
                                              )
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6.0),
                                          child: QuickHelp.usersMoreInfo(
                                            context,
                                            replyModel.getAuthor!,
                                          ),
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

  bool showPost(PostsModel post) {
    if (post.getExclusive!) {
      if (post.getAuthorId == widget.currentUser!.objectId) {
        return true;
      } else if (post.getPaidBy!.contains(widget.currentUser!.objectId)) {
        return true;
      } else if (widget.currentUser!.isAdmin!) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  goToFeedOnReels({required PostsModel post}) {
    for (int i = 0; i < allPosts.length; i++) {
      if (allPosts[i].objectId == post.objectId) {
        clickedPostIndex = i;
      }
    }

    QuickHelp.goToNavigatorScreen(
      context,
      FeedReelsScreen(
        currentUser: widget.currentUser,
        preloadsPost: allPosts,
        initialIndex: clickedPostIndex,
        pictureIndex: clickedImageIndex,
      ),
    );
  }

  double imageWidth({required int numberOfPictures}) {
    Size size = MediaQuery.of(context).size;
    if (numberOfPictures == 1) {
      return size.width / 1.7;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return size.width / 2.2;
    } else {
      return size.width / 3.4;
    }
  }

  double imageHeight({required int numberOfPictures}) {
    Size size = MediaQuery.of(context).size;
    if (numberOfPictures == 1) {
      return 350;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return 170;
    } else {
      return size.width / 3.4;
    }
  }

  Widget initQuery() {
    bool isDark = QuickHelp.isDarkMode(context);
    QueryBuilder<CommentsModel> queryBuilder =
        QueryBuilder<CommentsModel>(CommentsModel());
    queryBuilder.whereEqualTo(CommentsModel.keyPost, widget.post);

    queryBuilder.includeObject([
      CommentsModel.keyAuthor,
      CommentsModel.keyPost,
    ]);

    return ParseLiveListWidget<CommentsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.hasData) {
          CommentsModel commentsModel = snapshot.loadedData as CommentsModel;

          return Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    QuickActions.avatarWidget(
                      commentsModel.getAuthor!,
                      width: 40,
                      height: 40,
                      vipFrameWidth: 40,
                      vipFrameHeight: 37,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            commentsModel.getAuthor!.getFullName!,
                            marginLeft: 10,
                            marginBottom: 2,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6),
                          ),
                          TextWithTap(
                            commentsModel.getText!,
                            marginLeft: 10,
                            marginRight: 10,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      queryEmptyElement: QuickActions.noContentFound(context),
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
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
