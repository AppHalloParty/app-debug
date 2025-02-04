// ignore_for_file: must_be_immutable

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:story/story_page_view.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/message/message_screen.dart';
import 'package:trace/models/StoriesModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class SeeOneStory extends StatefulWidget {
   UserModel? currentUser, storyAuthor;
   ParseFileBase? storyImage;
   DateTime? createdDate;

  final StoriesModel? story;
  static String route = "stories/see_one_story";

  SeeOneStory(
      {Key? key,
      this.storyAuthor,
      this.currentUser,
      this.storyImage,
      this.createdDate,
      this.story})
      : super(key: key);

  @override
  State<SeeOneStory> createState() => _SeeOneStoryState();
}

class _SeeOneStoryState extends State<SeeOneStory> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;

  @override
  void initState() {
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.resume);
    super.initState();
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        child: StoryPageView(
          itemBuilder: (context, pageIndex, storyIndex) {
            return Stack(
              children: [
                _background(),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: size.height / 13, left: 10),
                  child: QuickActions.avatarWidget(
                    widget.storyAuthor!,
                    height: 50,
                    width: 50,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: size.height / 13, left: 67),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.storyAuthor!.getFullName!,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextWithTap(
                              QuickHelp.getTimeAgoForFeed(widget.createdDate!),
                              marginTop: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _content(),
              ],
            );
          },
          gestureItemBuilder: (context, pageIndex, storyIndex) {
            return Stack(children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: size.height / 13),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    color: Colors.white,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              if (widget.storyAuthor!.objectId == widget.currentUser!.objectId)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        indicatorAnimationController.value =
                            IndicatorAnimationCommand.pause;

                        await showModalBottomSheet(
                          backgroundColor: kContentColorLightTheme,
                          context: context,
                          builder: (context) {
                            QueryBuilder<UserModel> usersQuery =
                                QueryBuilder<UserModel>(UserModel.forQuery());
                            usersQuery.whereContainedIn(UserModel.keyObjectId,
                                widget.story!.geViewsIDs!);
                            usersQuery.whereNotEqualTo(UserModel.keyObjectId,
                                widget.currentUser!.objectId);

                            return ParseLiveListWidget<UserModel>(
                              query: usersQuery,
                              reverse: false,
                              lazyLoading: false,
                              duration: const Duration(milliseconds: 200),
                              childBuilder: (BuildContext context,
                                  ParseLiveListElementSnapshot<ParseObject>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  UserModel viewer =
                                      snapshot.loadedData! as UserModel;
                                  return ButtonWidget(
                                    height: 50,
                                    onTap: () => QuickHelp.goToNavigatorScreen(
                                      context,
                                      MessageScreen(
                                        currentUser: widget.currentUser,
                                        mUser: viewer,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          QuickActions.avatarWidget(
                                            viewer,
                                            width: 50,
                                            height: 50,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TextWithTap(
                                                viewer.getFullName!,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                marginLeft: 10,
                                                color: Colors.white,
                                                marginTop: 5,
                                                marginRight: 5,
                                              ),
                                              const TextWithTap(
                                                "12/03/2022",
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                marginLeft: 10,
                                                color: Colors.white,
                                                marginTop: 5,
                                                marginRight: 5,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: QuickHelp.appLoading(),
                                  );
                                }
                              },
                              queryEmptyElement: Center(
                                  child: Image.asset(
                                    "assets/images/szy_kong_icon.png",
                                    height: size.width / 2,
                                  )),
                              listLoadingElement: Center(
                                child: QuickHelp.appLoading(),
                              ),
                            );
                          },
                        );

                        indicatorAnimationController.value =
                            IndicatorAnimationCommand.resume;
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset("assets/svg/ic_small_viewers.svg"),
                          const SizedBox(
                            width: 6,
                          ),
                          TextWithTap(
                            widget.story!.geViewsIDs!.length.toString(),
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ]);
          },
          indicatorAnimationController: indicatorAnimationController,
          initialStoryIndex: (pageIndex) {
            return 0;
          },
          pageLength: 1,
          indicatorPadding: EdgeInsets.only(top: size.height / 15),
          storyLength: (int pageIndex) {
            return 1;
          },
          onPageLimitReached: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _background() {
    var size = MediaQuery.of(context).size;
    if (widget.story!.getImage != null) {
      return Positioned.fill(
        child: QuickActions.photosWidget(
          widget.story!.getImage!.url,
          width: size.width,
          height: size.height,
        ),
      );
    } else {
      return Positioned.fill(
        child: ContainerCorner(
          borderWidth: 0,
          width: size.width,
          height: size.height,
          color: QuickHelp.stringToColor(widget.story!.getTextBgColors!),
        ),
      );
    }
  }

  Widget _content() {
    var size = MediaQuery.of(context).size;
    if (widget.story!.getImage != null) {
      return Center(
        child: QuickActions.photosWidget(
          widget.story!.getImage!.url,
          width: size.width,
          height: size.height / 1.5,
          fit: BoxFit.contain,
          borderRadius: 0,
        ),
      );
    } else {
      return Center(
        child: ContainerCorner(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: AutoSizeText(
              widget.story!.getText!,
              style: GoogleFonts.nunito(
                fontSize: 49,
                color: QuickHelp.stringToColor(widget.story!.getTextColors!),
              ),
              minFontSize: 14,
              stepGranularity: 7,
              maxLines: 7,
            ),
          ),
        ),
      );
    }
  }
}
