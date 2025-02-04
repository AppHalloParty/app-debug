// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:story/story_page_view.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/helpers/send_notifications.dart';
import 'package:trace/home/message/message_screen.dart';
import 'package:trace/models/MessageListModel.dart';
import 'package:trace/models/MessageModel.dart';
import 'package:trace/models/StoriesAuthorsModel.dart';
import 'package:trace/models/StoriesModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class SeeStoriesScreen extends StatefulWidget {
  final UserModel? currentUser;
  final StoriesAuthorsModel? storyAuthorPre;
  final List<StoriesAuthorsModel>? authorsList;
  final int? firstUserIndex;

  static String route = "stories/see_stories";

  const SeeStoriesScreen(
      {Key? key,
      this.currentUser,
      this.storyAuthorPre,
      this.authorsList,
      this.firstUserIndex})
      : super(key: key);

  @override
  State<SeeStoriesScreen> createState() => _SeeStoriesScreenState();
}

class _SeeStoriesScreenState extends State<SeeStoriesScreen> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  TextEditingController storyMessageTextEditing = TextEditingController();
  List<StoriesModel> storiesList = [];
  late int initialStoryIndex = 0;
  bool storyDownloaded = false;
  StoriesAuthorsModel? selectedUserStory;
  int firstStoryAuthor = 0;
  bool isKeyBoardVisible = true;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    firstStoryAuthor = widget.firstUserIndex!;

    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
        IndicatorAnimationCommand.pause);

    selectedUserStory = widget.authorsList![firstStoryAuthor];

    removeOldStories(selectedUserStory!.getAuthorId!);

    indicatorAnimationController.value = IndicatorAnimationCommand.pause;
    allStories(selectedUserStory!.getAuthorId!).then((value) {
      setState(() {
        storyDownloaded = true;
        storiesList = value;
        //firstStoryToBeSeen();
      });
      indicatorAnimationController.value = IndicatorAnimationCommand.resume;
    });

    super.initState();
  }

  @override
  void dispose() {
    storiesList.clear();
    indicatorAnimationController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  firstStoryToBeSeen() {
    if (selectedUserStory!.getAuthor!.objectId !=
        widget.currentUser!.objectId) {
      bool find = false;
      for (var story in storiesList) {
        if (story['views'] == null && !find) {
          initialStoryIndex = storiesList.indexOf(story);
          find = true;
        } else if (!story['views'].contains(widget.currentUser!.objectId) &&
            !find) {
          initialStoryIndex = storiesList.indexOf(story);
          find = true;
        }
      }
    }
  }

  Future<List<StoriesModel>> allStories(String storyAuthorId) async {
    List<StoriesModel> currentList = [];

    QueryBuilder<StoriesModel> storiesQueries =
        QueryBuilder<StoriesModel>(StoriesModel());

    storiesQueries.whereEqualTo(StoriesModel.keyAuthorId, storyAuthorId);
    storiesQueries.whereGreaterThan(StoriesModel.keyExpiration, DateTime.now());

    ParseResponse parseResponse = await storiesQueries.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (StoriesModel storiesModel in parseResponse.results!) {
          if (!currentList.contains(storiesModel)) {
            currentList.add(storiesModel);
          }
        }

        setState(() {
          storiesList = currentList;
        });

        //firstStoryToBeSeen();
      }
    }

    return currentList;
  }

  Future<List<StoriesModel>> removeOldStories(String storyAuthorId) async {
    List<StoriesModel> currentList = [];

    QueryBuilder<StoriesModel> storiesQueries =
        QueryBuilder<StoriesModel>(StoriesModel());

    storiesQueries.whereEqualTo(StoriesModel.keyAuthorId, storyAuthorId);

    ParseResponse parseResponse = await storiesQueries.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (StoriesModel storiesModel in parseResponse.results!) {
          if (!QuickHelp.isAvailable(storiesModel.getExpireDate!)) {
            widget.storyAuthorPre!.setRemoveStory = storiesModel.objectId!;
            widget.storyAuthorPre!.save();
          }
        }
      }
    }
    return currentList;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: StoryPageView(
          itemBuilder: (context, pageIndex, storyIndex) {
            selectedUserStory = widget.authorsList![pageIndex];

            return Stack(
              children: [
                _background(storyDownloaded, storyIndex),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                    ),
                  ),
                ),
                _content(storyDownloaded, storyIndex),
                Padding(
                  padding: EdgeInsets.only(top: size.height / 13, left: 10),
                  child: QuickActions.avatarWidget(
                    selectedUserStory!.getAuthor!,
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
                              selectedUserStory!.getAuthor!.getFullName!,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (storyDownloaded)
                              TextWithTap(
                                QuickHelp.getTimeAgoForFeed(
                                    storiesList[storyIndex].createdAt!),
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
              ],
            );
          },
          onPageChanged: (pageIndex) {
            storyDownloaded = false;
            indicatorAnimationController.value =
                IndicatorAnimationCommand.pause;

            allStories(widget.authorsList![pageIndex].getAuthorId!)
                .then((value) {
              storiesList = value;
              storyDownloaded = true;
              //firstStoryToBeSeen();
              indicatorAnimationController.value =
                  IndicatorAnimationCommand.resume;
            });
          },
          gestureItemBuilder: (context, pageIndex, storyIndex) {
            if (storyDownloaded) {
              addViewOnSeenPicture(storiesList[storyIndex]);
            }
            if (storyIndex == storiesList.length - 1 &&
                widget.currentUser!.objectId !=
                    widget.storyAuthorPre!.objectId) {
              selectedUserStory!.setLastStorySeen = true;
              selectedUserStory!.save();
            }
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
              if (selectedUserStory!.getAuthor!.objectId ==
                  widget.currentUser!.objectId)
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
                        if (storyDownloaded) {
                          await showModalBottomSheet(
                            backgroundColor: kContentColorLightTheme,
                            context: context,
                            builder: (context) {
                              QueryBuilder<UserModel> usersQuery =
                                  QueryBuilder<UserModel>(UserModel.forQuery());
                              usersQuery.whereContainedIn(UserModel.keyObjectId,
                                  storiesList[storyIndex].geViewsIDs!);
                              usersQuery.whereNotEqualTo(UserModel.keyObjectId,
                                  widget.currentUser!.objectId);
                              return ParseLiveListWidget<UserModel>(
                                query: usersQuery,
                                reverse: false,
                                lazyLoading: false,
                                duration: const Duration(milliseconds: 200),
                                childBuilder: (BuildContext context,
                                    ParseLiveListElementSnapshot<UserModel>
                                        snapshot) {
                                  if (snapshot.hasData) {
                                    UserModel viewer = snapshot.loadedData!;
                                    return ButtonWidget(
                                      height: 50,
                                      onTap: () =>
                                          QuickHelp.goToNavigatorScreen(
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
                        }
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
                          if (storyDownloaded)
                            TextWithTap(
                              storiesList[storyIndex]
                                  .geViewsIDs!
                                  .length
                                  .toString(),
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              if (selectedUserStory!.getAuthor!.objectId!.isEmpty)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: StatefulBuilder(
                      builder: (BuildContext lowerContext, innerState) {
                    return TextButton(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                            size: 35,
                          ),
                          TextWithTap(
                            "stories.reply_".tr(),
                            color: Colors.white,
                            marginBottom: 10,
                          )
                        ],
                      ),
                      onPressed: () {
                        focusNode.requestFocus();
                        openBottomSheet(storyIndex);

                        Future.delayed(const Duration(seconds: 1), () {
                          indicatorAnimationController.value =
                              IndicatorAnimationCommand.pause;
                        });
                      },
                    );
                  }),
                ),
            ]);
          },
          indicatorAnimationController: indicatorAnimationController,
          initialStoryIndex: (pageIndex) {
            return initialStoryIndex;
          },
          initialPage: firstStoryAuthor,
          pageLength: widget.authorsList!.length,
          storyLength: (storyIndex) {
            return widget.authorsList![storyIndex].getStoriesList!.length;
          },
          indicatorPadding: EdgeInsets.only(top: size.height / 15),
          onPageLimitReached: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void openBottomSheet(int storyIndex) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: false,
        builder: (context) {
          return _showTextField(storyIndex);
        });
  }

  Widget _showTextField(int storyIndex) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        width: size.width,
        height: size.height,
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                  onTap: () {
                    focusNode.unfocus(
                        disposition: UnfocusDisposition.previouslyFocusedChild);
                    Navigator.of(context).pop();
                    indicatorAnimationController.value =
                        IndicatorAnimationCommand.resume;
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  )),
            ),
            StatefulBuilder(builder: (context, setState) {
              return Row(
                children: [
                  Expanded(
                    child: ContainerCorner(
                      color: kTransparentColor,
                      borderColor: Colors.white,
                      marginBottom:
                          MediaQuery.of(context).viewInsets.bottom + 10,
                      borderRadius: 50,
                      marginRight: 10,
                      height: 50,
                      marginLeft: 20,
                      width: 300,
                      child: TextFormField(
                        focusNode: focusNode,
                        minLines: 1,
                        maxLines: 100,
                        controller: storyMessageTextEditing,
                        autovalidateMode: AutovalidateMode.disabled,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: "stories.story_text_hint".tr(),
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(left: 10),
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ContainerCorner(
                    marginRight: 10,
                    marginBottom: MediaQuery.of(context).viewInsets.bottom + 10,
                    color: kFacebookColor,
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
                      if (storyMessageTextEditing.text.isEmpty) {
                        QuickHelp.showAppNotificationAdvanced(
                          title: "stories.make_sure_title".tr(),
                          message: "stories.make_sure_explain".tr(),
                          isError: true,
                          context: context,
                        );
                      } else {
                        indicatorAnimationController.value =
                            IndicatorAnimationCommand.resume;
                        replyStory(storiesList[storyIndex]);
                      }
                    },
                  )
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _background(bool downloaded, int storyIndex) {
    var size = MediaQuery.of(context).size;

    if (downloaded) {
      return Stack(
        children: [
          storiesList[storyIndex].getImage != null
              ? Positioned.fill(
                  child: QuickActions.photosWidget(
                    storiesList[storyIndex].getImage!.url,
                    width: size.width,
                    height: size.height,
                  ),
                )
              : ContainerCorner(
                  borderWidth: 0,
                  borderRadius: 10,
                  color: QuickHelp.stringToColor(
                      storiesList[storyIndex].getTextBgColors!),
                ),
        ],
      );
    } else {
      return Stack(
        children: [
          Positioned.fill(
            child: QuickActions.photosWidget(
              selectedUserStory!.getAuthor!.getAvatar!.url!,
              width: size.width,
              height: size.height,
            ),
          ),
        ],
      );
    }
  }

  Widget _content(bool downloaded, int storyIndex) {
    var size = MediaQuery.of(context).size;
    if (downloaded) {
      return Stack(
        children: [
          storiesList[storyIndex].getImage != null
              ? Center(
                  child: QuickActions.photosWidget(
                    storiesList[storyIndex].getImage!.url,
                    width: size.width,
                    height: size.height / 1.5,
                    fit: BoxFit.contain,
                    borderRadius: 0,
                  ),
                )
              : Center(
                  child: ContainerCorner(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: AutoSizeText(
                        storiesList[storyIndex].getText!,
                        style: GoogleFonts.nunito(
                          fontSize: 49,
                          color: QuickHelp.stringToColor(
                              storiesList[storyIndex].getTextColors!),
                        ),
                        minFontSize: 14,
                        stepGranularity: 7,
                        maxLines: 7,
                      ),
                    ),
                  ),
                ),
        ],
      );
    } else {
      return Stack(
        children: [
          Center(
            child: QuickHelp.appLoading(),
          )
        ],
      );
    }
  }

  addViewOnSeenPicture(StoriesModel story) {
    if (!story.geViewsIDs!.contains(widget.currentUser!.objectId)) {
      if (story.getAuthorId != widget.currentUser!.objectId) {
        story.setViewersId = widget.currentUser!.objectId!;
        story.save();
      }
    }
  }

  replyStory(StoriesModel repliedStory) async {
    MessageModel messageModel = MessageModel();
    messageModel.setAuthorId = widget.currentUser!.objectId!;
    messageModel.setAuthor = widget.currentUser!;
    messageModel.setReceiver = selectedUserStory!.getAuthor!;
    messageModel.setReceiverId = selectedUserStory!.getAuthor!.objectId!;
    messageModel.setMessageType = MessageModel.messageStoryReply;
    messageModel.setDuration = storyMessageTextEditing.text;
    messageModel.setStoryReplied = repliedStory;
    messageModel.setIsRead = false;
    storyMessageTextEditing.text = "";
    ParseResponse parseResponse = await messageModel.save();
    if (parseResponse.success) {
      final snackBar = SnackBar(
        content: TextWithTap(
          "stories.story_sent".tr(),
          color: Colors.white,
        ),
        backgroundColor: (Colors.black12),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _saveList(messageModel);
    }
    SendNotifications.sendPush(widget.currentUser!,
        selectedUserStory!.getAuthor!, SendNotifications.typeChat,
        message: "push_notifications.story_replied".tr(
            namedArgs: {"name": selectedUserStory!.getAuthor!.getFullName!}));
  }

  // Update or Create message list
  _saveList(MessageModel messageModel) async {
    QueryBuilder<MessageListModel> queryFrom =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyListId,
        widget.currentUser!.objectId! +
            selectedUserStory!.getAuthor!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyListId,
        selectedUserStory!.getAuthor!.objectId! +
            widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
        QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = selectedUserStory!.getAuthor!;
        messageListModel.setReceiverId =
            selectedUserStory!.getAuthor!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setIsRead = false;
        messageListModel.setListId = widget.currentUser!.objectId! +
            selectedUserStory!.getAuthor!.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = selectedUserStory!.getAuthor!;
        messageListModel.setReceiverId =
            selectedUserStory!.getAuthor!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setListId = widget.currentUser!.objectId! +
            selectedUserStory!.getAuthor!.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }
}
