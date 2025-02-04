// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trace/app/constants.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_cloud.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/feed/feed_on_reels_screen.dart';
import 'package:trace/home/feed/post_type_chooser.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/models/CommentsModel.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/PostReactionsModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/ReportModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/StoriesAuthorsModel.dart';
import '../../utils/utilsConstants.dart';

import '../profile/user_profile_screen.dart';
import '../stories/see_stories_screen.dart';
import 'comment_post_screen.dart';
import 'edit_pictures_post.dart';
import 'edit_text_post_screen.dart';
import 'edit_video_post.dart';

// ignore: must_be_immutable
class ResponsiveFeedScreen extends StatefulWidget {
  UserModel? currentUser;
  double? size;
  ResponsiveFeedScreen({
    this.currentUser,
    this.size,
  });

  @override
  _ResponsiveFeedScreenState createState() => _ResponsiveFeedScreenState();
}

class _ResponsiveFeedScreenState extends State<ResponsiveFeedScreen>
    with TickerProviderStateMixin {
  var _future;
  NativeAd? nativeAd;

  // Ads
  static final _kAdIndex = 2;

  late QueryBuilder<PostsModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> postsResults = <dynamic>[];

  int clickedPostIndex = 0;
  int clickedImageIndex = 0;

  String uploadPhoto = "";
  ParseFileBase? parseFile;
  ParseFileBase? parseFileThumbnail;
  bool? isVideo = false;
  File? videoFile;
  List<PostsModel> allPosts = [];
  bool shufflePosts = true;

  late FocusNode? commentTextFieldFocusNode;

  TextEditingController commentController = TextEditingController();

  ScrollController _notificationsScrollController = new ScrollController();
  var notifications = [];

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

  String linkToShare = "";

  shareLink() async {
    Share.share(linkToShare);
  }

  @override
  void initState() {
    super.initState();
    _getAllAuthors();
    commentTextFieldFocusNode = FocusNode();

    _future = _loadFeeds();
  }

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

  @override
  void dispose() {
    disposeLiveQuery();

    if (nativeAd != null) {
      nativeAd!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      floatingActionButton: floating(),
      body: initQuery(false),
    );
  }

  Widget interactiveMessagesCount() {
    QueryBuilder<NotificationsModel> query =
    QueryBuilder<NotificationsModel>(NotificationsModel());

    query.whereEqualTo(NotificationsModel.keyReceiver, widget.currentUser!);
    query.whereEqualTo(NotificationsModel.keyRead, false);

    query.orderByDescending(NotificationsModel.keyCreatedAt);

    query.includeObject([
      NotificationsModel.keyAuthor,
      NotificationsModel.keyReceiver,
      NotificationsModel.keyPost,
      NotificationsModel.keyLive,
      NotificationsModel.keyLiveAuthor,
      NotificationsModel.keyPostAuthor,
    ]);

    query.whereNotEqualTo(NotificationsModel.keyAuthor, widget.currentUser!);

    int? indexToRemove;

    return ParseLiveListWidget<NotificationsModel>(
      query: query,
      scrollController: _notificationsScrollController,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<NotificationsModel> snapshot) {
        if (snapshot.failed) {
          return showViewersCount(amountText: "${notifications.length}");
        }

        if (snapshot.hasData) {
          NotificationsModel notification = snapshot.loadedData!;

          if (!notifications.contains(notification.objectId)) {
            if (!notification.isRead!) {
              notifications.add(notification.objectId);

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                return await _notificationsScrollController.animateTo(
                    _notificationsScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 5),
                    curve: Curves.easeInOut);
              });
            }
          } else {
            if (notification.isRead!) {
              for (int i = 0; i < notifications.length; i++) {
                if (notifications[i] == notification.objectId) {
                  indexToRemove = i;
                }
              }

              notifications.removeAt(indexToRemove!);
            }
          }

          return showViewersCount(
              amountText: "${QuickHelp.convertToK(notifications.length)}");
        } else {
          return showViewersCount(amountText: "${notifications.length}");
        }
      },
      listLoadingElement:
      showViewersCount(amountText: "${notifications.length}"),
      queryEmptyElement:
      showViewersCount(amountText: "${notifications.length}"),
    );
  }

  Widget showViewersCount({required String amountText}) {
    return TextWithTap(
      QuickHelp.convertNumberToK(int.parse(amountText)),
      color: Colors.white,
      fontSize: 5,
      marginTop: 3,
      marginLeft: 3,
      marginBottom: 3,
    );
  }

  List<StoriesAuthorsModel> authorsList = [];
  int startIndex = 0;

  _getAllAuthors() async {
    QueryBuilder<StoriesAuthorsModel> query =
    QueryBuilder<StoriesAuthorsModel>(StoriesAuthorsModel());

    query.includeObject([
      StoriesAuthorsModel.keyAuthor,
      StoriesAuthorsModel.keyLastStory,
      StoriesAuthorsModel.keyStoriesList,
    ]);

    query.whereGreaterThan(
        StoriesAuthorsModel.keyLastStoryExpiration, DateTime.now());
    query.orderByAscending(StoriesAuthorsModel.keyLastStorySeen);
    query.whereNotContainedIn(StoriesAuthorsModel.keyAuthorId,
        widget.currentUser!.getBlockedUsersIDs!);

    ParseResponse parseResponse = await query.query();

    if (parseResponse.success) {
      if (parseResponse.result != null) {
        for (StoriesAuthorsModel storyAuthorModel in parseResponse.results!) {
          if (!authorsList.contains(storyAuthorModel)) {
            authorsList.add(storyAuthorModel);
          }
        }
      }
    }
  }

  getAllStories() {
    QueryBuilder<StoriesAuthorsModel> query =
    QueryBuilder<StoriesAuthorsModel>(StoriesAuthorsModel());

    query.whereGreaterThan(
      StoriesAuthorsModel.keyLastStoryExpiration,
      DateTime.now(),
    );
    query.orderByAscending(StoriesAuthorsModel.keyLastStorySeen);
    query.whereNotContainedIn(StoriesAuthorsModel.keyAuthorId,
        widget.currentUser!.getBlockedUsersIDs!);

    query.includeObject([
      StoriesAuthorsModel.keyAuthor,
      StoriesAuthorsModel.keyLastStory,
      StoriesAuthorsModel.keyStoriesList,
    ]);

    return ParseLiveListWidget<StoriesAuthorsModel>(
      query: query,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      duration: const Duration(milliseconds: 400),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<StoriesAuthorsModel> snapshot) {
        if (snapshot.hasData) {
          StoriesAuthorsModel storyAuthor = snapshot.loadedData!;

          return GestureDetector(
            onTap: () {
              for (int i = 0; i < authorsList.length; i++) {
                if (authorsList[i].objectId == storyAuthor.objectId) {
                  startIndex = i;
                }
              }

              QuickHelp.goToNavigatorScreen(
                context,
                SeeStoriesScreen(
                  currentUser: widget.currentUser,
                  storyAuthorPre: storyAuthor,
                  authorsList: authorsList,
                  firstUserIndex: startIndex,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ContainerCorner(
                  borderWidth: 2.0,
                  marginLeft: 10,
                  marginTop: 15,
                  borderRadius: 50,
                  height: 60,
                  width: 60,
                  borderColor: kPrimaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: QuickActions.avatarWidget(
                      storyAuthor.getAuthor!,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
                TextWithTap(
                  storyAuthor.getAuthor!.getFirstName!,
                  overflow: TextOverflow.ellipsis,
                  fontSize: 9,
                  alignment: Alignment.center,
                  marginLeft: 10,
                )
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
      listLoadingElement: const SizedBox(),
    );
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

  Widget floating() {
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      borderRadius: 9,
      color: isDark ? Colors.white : kContentDarkShadow,
      shadowColor: kGrayColor,
      shadowColorOpacity: 0.3,
      onTap: () => QuickHelp.goToNavigatorScreen(
        context,
        PostTypeChooserScreen(
          currentUser: widget.currentUser,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Icon(
          Icons.add,
          color: isDark ? kContentDarkShadow : Colors.white,
        ),
      ),
    );
  }

  Future<void> _objectUpdated(PostsModel object) async {
    for (int i = 0; i < postsResults.length; i++) {
      if (postsResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.afterPosts(postsResults[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            postsResults[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  Future<void> _objectDeleted(PostsModel object) async {
    for (int i = 0; i < postsResults.length; i++) {
      if (postsResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        setState(() {
          // ignore: invalid_use_of_protected_member
          postsResults.removeAt(i);
        });

        break;
      }
    }
  }

  setupLiveQuery() async {
    QueryBuilder<PostsModel> queryBuilderLive =
    QueryBuilder<PostsModel>(PostsModel());

    queryBuilderLive.whereEqualTo(PostsModel.keyExclusive, false);

    queryBuilderLive.whereNotContainedIn(
        PostsModel.keyAuthorId, widget.currentUser!.getBlockedUsersIDs!);
    queryBuilderLive.whereNotContainedIn(
        PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);

    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilderLive);
    }

    subscription!.on(LiveQueryEvent.create, (PostsModel post) async {
      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      if (!mounted) return;
      setState(() {
        postsResults.add(post);
      });
    });

    subscription!.on(LiveQueryEvent.enter, (PostsModel post) async {
      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      if (!mounted) return;
      setState(() {
        postsResults.add(post);
      });
    });

    subscription!.on(LiveQueryEvent.update, (PostsModel post) async {
      if (!mounted) return;

      await post.getAuthor!.fetch();
      if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }

      _objectUpdated(post);
    });

    subscription!.on(LiveQueryEvent.delete, (PostsModel post) {
      if (!mounted) return;

      _objectDeleted(post);
    });
  }

  Future<dynamic> _loadFeeds() async {
    disposeLiveQuery();

    QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
    queryUsers.whereValueExists(UserModel.keyUserStatus, true);
    queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

    queryBuilder = QueryBuilder<PostsModel>(PostsModel());

    queryBuilder.whereNotContainedIn(
        PostsModel.keyAuthorId, widget.currentUser!.getBlockedUsersIDs!);
    queryBuilder.whereNotContainedIn(
        PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);

    queryBuilder.whereDoesNotMatchQuery(PostsModel.keyAuthor, queryUsers);

    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyAuthorName,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor,
      PostsModel.keyTargetPeople
    ]);

    //queryBuilder.setLimit(50);
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

        setupLiveQuery();
        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
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
          if (shufflePosts) {
            postsResults.shuffle();
            shufflePosts = false;
          }
          if (postsResults.isNotEmpty) {
            return ListView.separated(
              itemCount: postsResults.length,
              itemBuilder: (context, index) {
                final PostsModel post = postsResults[index] as PostsModel;
                return ContainerCorner(
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
                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      children: [
                                        QuickActions.avatarWidget(
                                          post.getAuthor!,
                                          width: 60,
                                          height: 60,
                                        ),
                                        if (post.getAuthor!.getAvatarFrame !=
                                            null &&
                                            post.getAuthor!
                                                .getCanUseAvatarFrame!)
                                          ContainerCorner(
                                            borderWidth: 0,
                                            width: 55,
                                            height: 55,
                                            child: CachedNetworkImage(
                                              imageUrl: post.getAuthor!
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
                                    TextWithTap(
                                      post.getAuthor!.getFullName!,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 25,
                                      marginLeft: 10,
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
                                        widget.currentUser!, post.getAuthor!,
                                    );
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
                          )
                        ],
                      ),
                      Divider(
                        height: 10,
                        color: kTransparentColor,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.getBackgroundColor != null)
                            ContainerCorner(
                              width: size.width,
                              marginLeft: 5,
                              marginTop: 10,
                              borderRadius: 8,
                              marginRight: 5,
                              color: QuickHelp.stringToColor(
                                  post.getBackgroundColor!),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 20, bottom: 20),
                                child: AutoSizeText(
                                  post.getText!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 30,
                                    color: QuickHelp.stringToColor(
                                        post.getTextColors!),
                                  ),
                                  minFontSize: 15,
                                  stepGranularity: 5,
                                  maxLines: 10,
                                ),
                              ),
                            ),
                          if (post.getImagesList != null)
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
                                  borderRadius: 4,
                                  onTap: () {
                                    setState(() {
                                      clickedImageIndex = index;
                                    });
                                    goToFeedOnReels(post: post);
                                  },
                                  child: QuickActions.photosWidget(
                                      post.getImagesList![index].url,
                                  ),
                                ),
                              ),
                            ),
                          if (post.getVideo != null)
                            ContainerCorner(
                              width: size.width,
                              height: 700,
                              borderRadius: 10,
                              borderWidth: 0,
                              onTap: () => goToFeedOnReels(post: post),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  QuickActions.photosWidget(
                                    post.getVideoThumbnail!.url,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  ContainerCorner(
                                    height: 40,
                                    width: 40,
                                    borderRadius: 50,
                                    borderWidth: 0,
                                    color: Colors.black.withOpacity(0.7),
                                    child: Center(
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                        )),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      Visibility(
                        visible: post.getText!.isNotEmpty &&
                            post.getBackgroundColor == null,
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
                      if (post.getTargetPeople!.isNotEmpty)
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
                                        mUser:
                                        post.getTargetPeople![targetIndex],
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
                      Divider(
                        height: 10,
                        color: kTransparentColor,
                      ),
                      ContainerCorner(
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
                                  marginLeft: 10,
                                  marginTop: 10,
                                  //onTap: () => showBottomModal(post),
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
                                        marginLeft: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                ContainerCorner(
                                  marginBottom: 10,
                                  marginLeft: 10,
                                  marginTop: 10,
                                  onTap: () {
                                    debugPrint("dynamic links removed");
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
                            RotatedBox(
                              quarterTurns: -1,
                              child: IconButton(
                                onPressed: () =>
                                    openSheet(post.getAuthor!, post),
                                icon: SvgPicture.asset(
                                  "assets/svg/ic_post_config.svg",
                                  color: isDark ? Colors.white : Colors.black,
                                  height: 13,
                                  width: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index % _kAdIndex == 0 && Setup.isAdsOnFeedEnabled) {
                  //futureAds = loadAds();
                  //return getAdsFuture();
                  //return getBannerAd();
                  return SizedBox();
                } else {
                  return SizedBox();
                }
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

  likePost(PostsModel postModel) {
    PostReactionsModel postReactions = PostReactionsModel();
    postReactions.setPost = postModel;
    postReactions.setPostId = postModel.objectId!;
    postReactions.setAuthorId = widget.currentUser!.objectId!;
    postReactions.setAuthor = widget.currentUser!;
    postReactions.setLikes = widget.currentUser!.objectId!;
    postReactions.setLikes = widget.currentUser!.objectId!;
    postReactions.save();
  }

  removeLike(PostsModel postModel) {
    PostReactionsModel postReactions = PostReactionsModel();
    postReactions.setPost = postModel;
    postReactions.setPostId = postModel.objectId!;
    postReactions.setAuthorId = widget.currentUser!.objectId!;
    postReactions.setAuthor = widget.currentUser!;
    postReactions.setLikes = widget.currentUser!.objectId!;
    postReactions.setLikes = widget.currentUser!.objectId!;
    postReactions.save();
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
    if (numberOfPictures == 1) {
      return widget.size!;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return widget.size! / 2.2;
    } else {
      return widget.size! / 3.4;
    }
  }

  double imageHeight({required int numberOfPictures}) {
    if (numberOfPictures == 1) {
      return 700;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return 250;
    } else {
      return widget.size! / 3.4;
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

  Widget getAdsFuture() {
    return FutureBuilder(
        future: loadAds(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {
            AdWithView ad = snapshot.data as AdWithView;

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              color: QuickHelp.isDarkMode(context)
                  ? kContentColorLightTheme
                  : Colors.white,
              margin: EdgeInsets.only(top: 7),
              child: AdWidget(ad: ad),
            );
          } else {
            return Container();
          }
        });
  }

  Future<dynamic> loadAds() async {
    BannerAdListener bannerAdListener = BannerAdListener(
      onAdWillDismissScreen: (ad) {
        debugPrint("Ad Got onAdWillDismissScreen");
        ad.dispose();
      },
      onAdClosed: (ad) {
        debugPrint("Ad Got Closeed");
        ad.dispose();
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint("Ad Got onAdFailedToLoad");
        ad.dispose();
      },
      onAdLoaded: (ad) {
        debugPrint("Ad Got onAdLoaded");
      },
    );

    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Constants.getAdmobFeedNativeUnit(),
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    return bannerAd..load();
  }

  void openVideo(PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showFeedVideoBottomSheet(post);
        });
  }

  _showFeedVideoBottomSheet(PostsModel post) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: ContainerCorner(
                color: kTransparentColor,
                height: MediaQuery.of(context).size.height - 200,
                /*child: AspectRatio(
                  aspectRatio: 1 / 1,
                  child: BetterPlayer.network(
                    post.getVideo!.url!,
                    betterPlayerConfiguration: BetterPlayerConfiguration(
                      aspectRatio: 1 / 1,
                    ),
                  ),
                ),*/
              ),
            );
          }),
        ),
      ),
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
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: TextWithTap(
                  "feed.report_post"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  alignment: Alignment.center,
                  color: Colors.black,
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
                  color: Colors.black,
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
                  color: Colors.black,
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
                  color: Colors.black,
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
      _future = _loadFeeds();

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

  void chargeUserAndShowImage(PostsModel post) async {
    if (widget.currentUser!.getCredits! >= post.getPaidAmount!) {
      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.removeCredit = post.getPaidAmount!;
      ParseResponse saved = await widget.currentUser!.save();
      if (saved.success) {
        QuickCloudCode.sendGift(
            author: post.getAuthor!,
            credits: post.getPaidAmount!,
        );

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
}
