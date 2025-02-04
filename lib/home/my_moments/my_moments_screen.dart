// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:like_button/like_button.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_cloud.dart';
import '../../helpers/quick_help.dart';
import '../../models/CommentsModel.dart';
import '../../models/NotificationsModel.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../services/deep_links_service.dart';
import '../feed/comment_post_screen.dart';
import '../feed/create_pictures_post_screen.dart';
import '../feed/edit_pictures_post.dart';
import '../feed/edit_text_post_screen.dart';
import '../feed/edit_video_post.dart';
import '../feed/feed_on_reels_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/user_profile_screen.dart';

class MyMomentsScreen extends StatefulWidget {
  UserModel? currentUser;
  MyMomentsScreen({this.currentUser,  super.key});

  @override
  State<MyMomentsScreen> createState() => _MyMomentsScreenState();
}

class _MyMomentsScreenState extends State<MyMomentsScreen> {

  List<dynamic> postsResults = <dynamic>[];
  var _future;

  int clickedPostIndex = 0;
  int clickedImageIndex = 0;

  List<PostsModel> allPosts = [];

  late FocusNode? commentTextFieldFocusNode;

  TextEditingController commentController = TextEditingController();

  String linkToShare = "";

  shareLink() async {
    Share.share(linkToShare);
  }

  @override
  void initState() {
    super.initState();
    _future = _loadFeeds(false);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
            "my_moment_screen.my_moments".tr(),
        ),
      ),
      body: initQuery(false),
      bottomNavigationBar: ContainerCorner(
        height: 45,
        color: kPrimaryColor,
        marginBottom: 20,
        marginRight: 20,
        marginLeft: 20,
        borderWidth: 0,
        marginTop: 10,
        borderRadius: 50,
        onTap: (){
          QuickHelp.goToNavigatorScreen(
              context,
            CreatePicturesPostScreen(
              currentUser: widget.currentUser,
            ),
          );
        },
        child: TextWithTap(
          "my_moment_screen.post_moments".tr(),
          color: Colors.white,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget initQuery(bool isExclusive) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {
            postsResults = snapshot.data! as List<dynamic>;

            if (postsResults.isNotEmpty) {
              return ListView.separated(
                itemCount: postsResults.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final PostsModel post = postsResults[index] as PostsModel;

                  return ContainerCorner(
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
                        if (post.getTargetPeopleID != null &&
                            post.getTargetPeopleID!
                                .contains(widget.currentUser!.objectId))
                          TextWithTap(
                            "feed.you_was_mentioned".tr(
                              namedArgs: {
                                "author_name": post.getAuthor!.getFullName!
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
                                      QuickActions.avatarWidget(post.getAuthor!,
                                          width: 50, height: 50),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            TextWithTap(
                                              post.getAuthor!.getFullName!,
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.width / 20,
                                              marginBottom: 5,
                                            ),
                                            QuickActions.getGender(
                                              currentUser: post.getAuthor!,
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
                                      QuickActions.showUserProfile(context,
                                          widget.currentUser!, post.getAuthor!,);
                                    }
                                  }),
                            ),
                            Visibility(
                              visible: post.getAuthorId ==
                                  widget.currentUser!.objectId,
                              child: IconButton(
                                onPressed: () {
                                  editPostScreen(post);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: kGrayColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => openSheet(post.getAuthor!, post),
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
                          visible: post.getText!.isNotEmpty,
                          child: TextWithTap(
                            post.getText!,
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
                        if (post.getTargetPeople != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Wrap(
                              children: List.generate(
                                post.getTargetPeopleID!.length,
                                    (targetIndex) => TextWithTap(
                                  "@${post.getTargetPeople![targetIndex][UserModel.keyFullName]}",
                                  color: Colors.blueAccent,
                                  marginRight: 5,
                                  marginBottom: 8,
                                  onTap: () {
                                    if (post.getTargetPeople![targetIndex]
                                    [UserModel.keyObjectId] ==
                                        widget.currentUser!.objectId) {
                                      QuickHelp.goToNavigatorScreen(
                                        context,
                                        ProfileScreen(
                                          currentUser: widget.currentUser,
                                        ),
                                      );
                                    } else {
                                      QuickHelp.goToNavigatorScreen(
                                        context,
                                        UserProfileScreen(
                                          currentUser: widget.currentUser,
                                          mUser: post
                                              .getTargetPeople![targetIndex],
                                          isFollowing: widget
                                              .currentUser!.getFollowing!
                                              .contains(post.getTargetPeopleID![
                                          targetIndex]),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        Divider(
                          height: 10,
                          color: kTransparentColor,
                        ),
                        showPost(post)
                            ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.getVideo == null)
                              Wrap(
                                children: List.generate(
                                  post.getNumberOfPictures,
                                      (index) => ContainerCorner(
                                    width: imageWidth(
                                        numberOfPictures:
                                        post.getNumberOfPictures),
                                    height: imageHeight(
                                        numberOfPictures:
                                        post.getNumberOfPictures),
                                    borderWidth: 0,
                                    marginRight: 5,
                                    marginBottom: 5,
                                    borderRadius: 8,
                                    onTap: () {
                                      setState(() {
                                        clickedImageIndex = index;
                                      });
                                      goToFeedOnReels(post: post);
                                    },
                                    child: QuickActions.photosWidget(
                                        post.getImagesList![index].url),
                                  ),
                                ),
                              ),
                            if (post.getVideo != null)
                              ContainerCorner(
                                width: size.width / 1.7,
                                height: 350,
                                borderRadius: 10,
                                borderWidth: 0,
                                onTap: () => goToFeedOnReels(post: post),
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    QuickActions.photosWidget(
                                        post.getVideoThumbnail!.url),
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
                            : GestureDetector(
                          onTap: () => chargeUserAndShowImage(post),
                          child: Stack(
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
                                              "coins": post.getPaidAmount!
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
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.watch_later_outlined,
                                size: 14,
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 220,
                                child: Text(
                                  QuickHelp.getTimeAgoForFeed(post.createdAt!),
                                  style: TextStyle(
                                    //color: isDark ? Colors.white : kContentColorLightTheme,
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showPost(post),
                          child: ContainerCorner(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _likeWidget(post),
                                    ContainerCorner(
                                      marginBottom: 10,
                                      marginTop: 10,
                                      marginLeft: 10,
                                      onTap: () {
                                        QuickHelp.goToNavigatorScreen(
                                          context,
                                          CommentPostScreen(
                                            post: post,
                                            currentUser: widget.currentUser,
                                          ),
                                        );
                                      },
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
                                            post.getComments!.length.toString(),
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
                                            objectID: post.objectId!,
                                            imageURL: QuickHelp.getImageToShare(post) ,
                                            title: QuickHelp.getTitleToShare(post),
                                            description: post.getAuthor!.getFullName,
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
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
              );
            } else {
              return QuickActions.noContentFound(context);
            }
          } else {
            return QuickActions.noContentFound(context);
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

  _deleteLike(PostsModel postsModel) async {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        postsModel.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: postsModel);
  }

  _likePost(PostsModel post) {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: post);
  }

  void chargeUserAndShowImage(PostsModel post) async {
    if (widget.currentUser!.getCredits! >= post.getPaidAmount!) {
      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.removeCredit = post.getPaidAmount!;
      ParseResponse saved = await widget.currentUser!.save();
      if (saved.success) {
        QuickCloudCode.sendGift(
            author: post.getAuthor!,
            credits: post.getPaidAmount!,);

        widget.currentUser = saved.results!.first! as UserModel;

        post.setPaidBy = widget.currentUser!.objectId!;
        ParseResponse savedPost = await post.save();
        if (savedPost.success) {
          QuickHelp.hideLoadingDialog(context);
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotification(
              title: "error".tr(), context: context, isError: true);
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotification(
            title: "error".tr(), context: context, isError: true);
      }
    } else {
      QuickHelp.showAppNotification(
          title: "video_call.no_coins".tr(), context: context, isError: true);
    }
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

  Future<List<dynamic>?> _loadFeeds(bool? isExclusive) async {
    QueryBuilder<PostsModel> queryBuilder =
    QueryBuilder<PostsModel>(PostsModel());
    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);
    queryBuilder.whereEqualTo(PostsModel.keyAuthor, widget.currentUser);
    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    queryBuilder.orderByDescending(keyVarCreatedAt);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      print("Lives count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        for (PostsModel post in apiResponse.results!) {
          if (!allPosts.contains(post)) {
            allPosts.add(post);
          }
        }

        return apiResponse.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return apiResponse.error as dynamic;
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

  showBottomModal(PostsModel post) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return _showComments(post);
        });
  }

  Widget _showComments(PostsModel post) {
    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          QuickHelp.removeFocusOnTextField(context);
        } else {
          QuickHelp.goBackToPreviousPage(context);
        }
      },
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(
              builder: (context, newState) {
                return ContainerCorner(
                  radiusTopRight: 25.0,
                  radiusTopLeft: 25.0,
                  borderWidth: 0,
                  child: ContainerCorner(
                    onTap: () => QuickHelp.removeFocusOnTextField(context),
                    radiusTopRight: 10.0,
                    radiusTopLeft: 10.0,
                    borderWidth: 0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: Scaffold(
                      backgroundColor: kTransparentColor,
                      resizeToAvoidBottomInset: false,
                      appBar: AppBar(
                        backgroundColor: kTransparentColor,
                        automaticallyImplyLeading: false,
                        centerTitle: true,
                        title: TextWithTap(
                          "tab_feed.comments_".tr(namedArgs: {
                            "amount": post.getComments!.length.toString()
                          }),
                          color: QuickHelp.isDarkMode(context)
                              ? Colors.white
                              : kContentColorLightTheme,
                          fontWeight: FontWeight.w700,
                        ),
                        actions: [
                          IconButton(
                              onPressed: () {
                                if (MediaQuery.of(context).viewInsets.bottom >
                                    0) {
                                  QuickHelp.removeFocusOnTextField(context);
                                } else {
                                  QuickHelp.goBackToPreviousPage(context);
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                color: QuickHelp.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                                size: 25,
                              ))
                        ],
                      ),
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: showAllComments(post, newState)),
                          ContainerCorner(
                            child: commentInputField(post),
                            marginBottom:
                            MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget commentInputField(PostsModel post) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * 0.75,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) {},
                      focusNode: commentTextFieldFocusNode,
                      maxLines: null,
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "comment_post.leave_comment".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ContainerCorner(
            marginLeft: 10,
            color: kBlueColor1,
            child: ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                "assets/svg/ic_send_message.svg",
                color: Colors.white,
                height: 10,
                width: 30,
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () {
              if (commentController.text.isNotEmpty) {
                _createComment(post, commentController.text);
                setState(() {
                  commentController.text = "";
                });
              }
            },
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

  Widget showAllComments(PostsModel post, StateSetter newState) {
    QueryBuilder<CommentsModel> queryBuilder =
    QueryBuilder<CommentsModel>(CommentsModel());
    queryBuilder.whereEqualTo(CommentsModel.keyPost, post);

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
                    QuickActions.avatarWidget(commentsModel.getAuthor!,
                        width: 60, height: 60),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            commentsModel.getAuthor!.getFullName!,
                            marginLeft: 10,
                            marginBottom: 5,
                            fontWeight: FontWeight.bold,
                            color: kGrayColor,
                            fontSize: 16,
                          ),
                          TextWithTap(
                            commentsModel.getText!,
                            marginLeft: 10,
                            marginRight: 10,
                            color: kGrayColor,
                          ),
                          TextWithTap(
                            QuickHelp.getTimeAgoForFeed(
                              commentsModel.createdAt!,
                            ),
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
                ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 1,
                  marginLeft: 5,
                  marginRight: 5,
                  marginTop: 20,
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

  void openSheet(UserModel author, PostsModel post) async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _showPostOptionsAndReportAuthor(author, post);
      },
    );
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
            ],
          ),
        ),
      ),
    );
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
    removePostIdOnUser(postsModel.objectId!);
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

  removePostIdOnUser(String postId) async {
    widget.currentUser!.removePostId = postId;
    await widget.currentUser!.save();
  }

}
