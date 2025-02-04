import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/reels/reels_single_screen.dart';
import 'package:trace/ui/app_bar.dart';

import '../../helpers/quick_actions.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

// ignore: must_be_immutable
class ReelsSavedVideosScreen extends StatefulWidget {

  static String route = "/home/reels/videos/saved";

  UserModel? currentUser;

  ReelsSavedVideosScreen({this.currentUser});

  @override
  _ReelsSavedVideosScreenState createState() => _ReelsSavedVideosScreenState();
}

class _ReelsSavedVideosScreenState extends State<ReelsSavedVideosScreen> with SingleTickerProviderStateMixin {

  AnimationController? _animationController;


  @override
  void initState() {
    _animationController = AnimationController.unbounded(vsync: this);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
        title: "page_title.reels_saved_videos_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: loadVideosList(),
    );
  }

  Widget loadVideosList() {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder(PostsModel());
    queryBuilder.whereContains(PostsModel.keySaves, widget.currentUser!.objectId!);
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
              Center(child: QuickActions.getImageFeed(context, post)),
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
}
