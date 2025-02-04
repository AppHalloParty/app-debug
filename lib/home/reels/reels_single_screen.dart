import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:trace/home/feed/videoutils/api.dart';
import 'package:trace/home/feed/videoutils/screen_config.dart';
import 'package:trace/home/feed/videoutils/video.dart';
import 'package:trace/home/feed/videoutils/video_item_config.dart';
import 'package:trace/home/feed/videoutils/video_newfeed_screen.dart';
import 'package:trace/ui/app_bar_reels.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';

// ignore: must_be_immutable
class ReelsSingleScreen extends StatefulWidget {
  static String route = "/home/reels/video";

  UserModel? currentUser;
  PostsModel? post;

  ReelsSingleScreen({this.currentUser, this.post});

  @override
  _ReelsSingleScreenState createState() => _ReelsSingleScreenState();
}

class _ReelsSingleScreenState extends State<ReelsSingleScreen>
    with SingleTickerProviderStateMixin
    implements VideoNewFeedApi<VideoInfo> {
  bool hasNotification = false;

  late QueryBuilder<PostsModel> queryBuilder;

  late PreloadPageController _pageController;
  late TabController _tabController;

  @override
  void initState() {

    QuickHelp.saveCurrentRoute(route: ReelsSingleScreen.route);

    _tabController = TabController(length: 2, vsync: this);
    _pageController = PreloadPageController(keepPage: true);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBarReels(
      extendBodyBehindAppBar: true,
      showAppBar: true,
      leftButtonIcon: Icons.arrow_back,
      iconColor: Colors.white,
      onLeftWidgetTap: () => QuickHelp.goBackToPreviousPage(context),
      backgroundColor: kTransparentColor,
      centerTitle: true,
      child: reelsVideoWidget(),
    );
  }

  Widget initTabs() {
    return PreloadPageView.builder(
      scrollDirection: Axis.horizontal,
      controller: _pageController,
      itemCount: 2,
      preloadPagesCount: 2,
      onPageChanged: (page) {
        setState(() {
          _tabController.animateTo(page);
        });
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return reelsVideoWidget(exclusive: false);
        } else {
          return reelsVideoWidget(exclusive: true);
        }
      },
    );
  }

  Widget reelsVideoWidget({bool? exclusive}) {
    return Container(
      color: kContentColorLightTheme,
      child: VideoNewFeedScreen<VideoInfo>(
        api: this,
        keepPage: true,
        screenConfig: ScreenConfig(
            backgroundColor: kContentColorLightTheme,
            loadingWidget: CircularProgressIndicator.adaptive(),
            emptyWidget: Center(
              child: GestureDetector(
                onTap: () {
                  getListVideo(exclusive: exclusive);
                },
                child: QuickActions.noContentFoundReels(
                  "feed.no_reels_title".tr(),
                  "feed.no_reels_explain".tr(),
                ),
              ),
            )),
        config: VideoItemConfig(
          itemLoadingWidget: CircularProgressIndicator(),
          loop: true,
          autoPlayNextVideo: false,
        ),
        videoEnded: () {},
        pageChanged: (page, user, post) {
          print("Page changed $page, ${user.objectId}, ${post.objectId}");

            setViewer(post);
        },
      ),
    );
  }

  setViewer(PostsModel post) async{

    if(widget.currentUser!.objectId! != post.getAuthor!.objectId!){
      post.setViewer = widget.currentUser!.objectId!;
      post.addView = 1;
      await post.save();
    }

  }

  @override
  Future<List<VideoInfo>> getListVideo({bool? exclusive}) {
    return _loadFeedsVideos(false, isVideo: true);
  }

  @override
  Future<List<VideoInfo>> loadMore(List<VideoInfo> currentList) {
    // TODO: implement loadMore

    print("implement loadMore ${currentList.length}");

    return _loadFeedsVideos(false, skip: currentList.length, isVideo: true);
    //throw UnimplementedError();
  }

  Future<List<VideoInfo>> _loadFeedsVideos(bool? isExclusive,
      {bool? isVideo, int? skip = 0}) async {
    List<VideoInfo> videos = [];

    QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
    queryUsers.whereValueExists(UserModel.keyUserStatus, true);
    queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

    queryBuilder = QueryBuilder<PostsModel>(PostsModel());

    queryBuilder.whereValueExists(PostsModel.keyVideo, true);
    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    if(widget.post != null){
      queryBuilder.whereEqualTo(PostsModel.keyObjectId, widget.post!.objectId);

    } else {

      queryBuilder.whereEqualTo(PostsModel.keyExclusive, isExclusive);
      queryBuilder.whereNotContainedIn(
          PostsModel.keyAuthor, widget.currentUser!.getBlockedUsers!);
      queryBuilder.whereNotContainedIn(
          PostsModel.keyObjectId, widget.currentUser!.getReportedPostIDs!);

      queryBuilder.whereDoesNotMatchQuery(PostsModel.keyAuthor, queryUsers);
      queryBuilder.setAmountToSkip(skip!);
    }

    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyAuthorName,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);

    //queryBuilder.setLimit(2);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        for (PostsModel postsModel in apiResponse.results!) {
          VideoInfo videoInfo = VideoInfo(
              /*userName: postsModel.getAuthor!.getFullName!,
              liked: postsModel.getLikes!.contains(widget.currentUser!.objectId),
              dateTime: postsModel.createdAt!,
              songName: postsModel.getText,
              likes: postsModel.getLikes,*/
              postModel: postsModel,
              currentUser: widget.currentUser,
              url: postsModel.getVideo!
                  .url); //"https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"); //postsModel.getVideo!.url);

          videos.add(videoInfo);
        }

        return videos;
      } else {
        return [];
      }
    } else {
      return []; //apiResponse.error as dynamic;
    }
  }
}
