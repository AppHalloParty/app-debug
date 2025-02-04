import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/home_screen.dart';
import 'package:trace/home/stories/see_stories_screen.dart';
import 'package:trace/home/stories/story_type_chooser_screen.dart';
import 'package:trace/models/StoriesAuthorsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class StoriesPage extends StatefulWidget {
  final UserModel? currentUser;
  static String route = "/home/all_stories";

  const StoriesPage({Key? key, this.currentUser}) : super(key: key);

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

AnimationController? _animationController;

class _StoriesPageState extends State<StoriesPage>
    with TickerProviderStateMixin {
  List storiesList = [];

  LiveQuery liveQuery = LiveQuery();

  int startIndex = 0;

  @override
  void initState() {
    _getAllAuthors();
    _animationController = AnimationController.unbounded(vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: QuickHelp.isDarkMode(context)
            ? kContentColorLightTheme
            : Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              BackButton(
                color: QuickHelp.isDarkMode(context)
                    ? Colors.white
                    : kContentColorLightTheme,
              ),
              GestureDetector(
                onTap: () => QuickHelp.goToNavigatorScreen(
                    context,
                    HomeScreen(
                      currentUser: widget.currentUser,
                    )),
                child: QuickActions.avatarWidget(widget.currentUser!,
                    width: 40, height: 40),
              ),
            ],
          ),
        ),
        leadingWidth: 200,
        centerTitle: true,
        title: TextWithTap(
          "stories.tab_states".tr(),
          color: QuickHelp.isDarkMode(context)
              ? Colors.white
              : kContentColorLightTheme,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
        actions: [
          IconButton(
            onPressed: () => QuickHelp.goToNavigatorScreen(
                context,
                StoryTypeChooserScreen(
                  currentUser: widget.currentUser,
                )),
            icon: Icon(
              Icons.add,
              color: kPrimaryColor,
              size: size.width / 12,
            ),
          ),
          SizedBox(
            width: size.width / 30,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: _getAllStories(),
      ),
    );
  }

  List<StoriesAuthorsModel> authorsList = [];

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

  _getAllStories() {
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

    return ParseLiveGridWidget<StoriesAuthorsModel>(
      query: query,
      crossAxisCount: 2,
      reverse: false,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      lazyLoading: false,
      childAspectRatio: .7,
      shrinkWrap: true,
      duration: const Duration(milliseconds: 200),
      animationController: _animationController,
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
            child: Stack(children: [
              storyAuthor.getLastStory!.getImage != null
                  ? ContainerCorner(
                      color: kTransparentColor,
                      child: QuickActions.photosWidget(
                          storyAuthor.getLastStory!.getImage!.url!,
                          borderRadius: 10),
                    )
                  : ContainerCorner(
                      borderWidth: 0,
                      borderRadius: 10,
                      color: QuickHelp.stringToColor(
                          storyAuthor.getLastStory!.getTextBgColors!),
                    ),
              if (storyAuthor.getLastStory!.getImage == null)
                Center(
                  child: ContainerCorner(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: AutoSizeText(
                        storyAuthor.getLastStory!.getText!,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          color: QuickHelp.stringToColor(
                              storyAuthor.getLastStory!.getTextColors!),
                        ),
                        minFontSize: 10,
                        stepGranularity: 5,
                        maxLines: 5,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                child: ContainerCorner(
                  width: (MediaQuery.of(context).size.width / 2) - 15,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ContainerCorner(
                        borderRadius: 50,
                        height: 40,
                        width: 40,
                        marginTop: 5,
                        marginLeft: 5,
                        borderWidth: 3,
                        borderColor: storyAuthor.getLastStorySeen!
                            ? Colors.white.withOpacity(0.5)
                            : kFacebookColor,
                        child: Center(
                          child: QuickActions.avatarWidget(
                            storyAuthor.getAuthor!,
                            height: 39,
                            width: 39,
                          ),
                        ),
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        marginRight: 5,
                        marginTop: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Center(
                              child: TextWithTap(
                                storyAuthor.getStoriesList!.length.toString(),
                                //storyAuthor.getStoriesList!.length.toString(),
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: ContainerCorner(
                  borderWidth: 0,
                  width: (MediaQuery.of(context).size.width / 2) - 15,
                  height: 55,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: SizedBox(
                        height: 55,
                        width: (MediaQuery.of(context).size.width / 2) - 15,
                        child: Center(
                            child: TextWithTap(
                          storyAuthor.getAuthor!.getFullName!,
                          marginLeft: 5,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        )),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
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
            height: MediaQuery.sizeOf(context).width / 2,
          )),
      gridLoadingElement: QuickHelp.appLoading(),
    );
  }
}
