// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import '../../helpers/quick_actions.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/utilsConstants.dart';

class GreetingsFromNewFriendScreen extends StatefulWidget {
  static String route = "/greetings/from/new/friend";
  UserModel? currentUser;

  GreetingsFromNewFriendScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<GreetingsFromNewFriendScreen> createState() =>
      _GreetingsFromNewFriendScreenState();
}

class _GreetingsFromNewFriendScreenState
    extends State<GreetingsFromNewFriendScreen> {
  var settingsTitles = [
    "message_screen.empty_message".tr(),
    "message_screen.mark_as_read".tr(),
    "cancel".tr(),
  ];

  var settingsCallBacks = [];

  late QueryBuilder<MessageListModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> messagesResults = <dynamic>[];

  var _future;

  Future<void> _objectUpdated(MessageListModel object) async {
    for (int i = 0; i < messagesResults.length; i++) {
      if (messagesResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.afterMessages(messagesResults[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            messagesResults[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  Future<void> _objectDeleted(MessageListModel object) async {
    for (int i = 0; i < messagesResults.length; i++) {
      if (messagesResults[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        setState(() {
          // ignore: invalid_use_of_protected_member
          messagesResults.removeAt(i);
        });

        break;
      }
    }
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

  setupLiveQuery() async {
    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilder);
    }

    subscription!.on(LiveQueryEvent.create,
        (MessageListModel messageListModel) async {
      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();
      /*if (post.getLastLikeAuthor != null) {
        await post.getLastLikeAuthor!.fetch();
      }*/

      if (!mounted) return;
      setState(() {
        messagesResults.add(messageListModel);
      });
    });

    subscription!.on(LiveQueryEvent.enter,
        (MessageListModel messageListModel) async {
      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();

      if (!mounted) return;
      setState(() {
        messagesResults.add(messageListModel);
      });
    });

    subscription!.on(LiveQueryEvent.update,
        (MessageListModel messageListModel) async {
      if (!mounted) return;

      await messageListModel.getAuthor!.fetch();
      await messageListModel.getReceiver!.fetch();

      _objectUpdated(messageListModel);
    });

    subscription!.on(LiveQueryEvent.delete, (MessageListModel post) {
      if (!mounted) return;

      _objectDeleted(post);
    });
  }

  @override
  void initState() {
    QuickHelp.saveCurrentRoute(route: GreetingsFromNewFriendScreen.route);

    super.initState();
    _future = _loadMessagesList();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:
          isDarkMode ? kContentDarkShadow : Colors.white.withOpacity(0.96),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? kContentColorLightTheme : Colors.white,
        leading: BackButton(
          color: kGrayColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () => openSettingsSheet(),
              icon: RotatedBox(
                quarterTurns: 1,
                child: SvgPicture.asset(
                  "assets/svg/ic_post_config.svg",
                  color: isDarkMode ? Colors.white : kGrayColor,
                  height: 15,
                  width: 15,
                ),
              ),
            ),
          ),
        ],
        centerTitle: true,
        title: TextWithTap(
          "greetingS_from_new_friend_screen.greetingS_from_new_friend".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: loadGreetings(),
      ),
    );
  }

  Future<dynamic> _loadMessagesList() async {
    disposeLiveQuery();

    QueryBuilder<MessageListModel> queryFrom =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyAuthorId, widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyReceiverId, widget.currentUser!.objectId!);

    queryBuilder = QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);
    queryBuilder.whereEqualTo(
        MessageListModel.keyMessageCategory, MessageListModel.greetingsMessage);
    queryBuilder.orderByDescending(keyVarUpdatedAt);

    queryBuilder.includeObject([
      MessageListModel.keyAuthor,
      MessageListModel.keyReceiver,
      MessageListModel.keyMessage,
      MessageListModel.keyCall
    ]);

    queryBuilder.setLimit(50);
    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        setupLiveQuery();

        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  Widget loadGreetings() {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final delay = (index * 300);

                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        FadeShimmer.round(
                          size: 60,
                          fadeTheme: QuickHelp.isDarkMode(context)
                              ? FadeTheme.dark
                              : FadeTheme.light,
                          millisecondsDelay: delay,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeShimmer(
                              height: 8,
                              width: size.width / 2,
                              radius: 4,
                              millisecondsDelay: delay,
                              fadeTheme: QuickHelp.isDarkMode(context)
                                  ? FadeTheme.dark
                                  : FadeTheme.light,
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            FadeShimmer(
                              height: 8,
                              millisecondsDelay: delay,
                              width: size.width / 1.5,
                              radius: 4,
                              fadeTheme: QuickHelp.isDarkMode(context)
                                  ? FadeTheme.dark
                                  : FadeTheme.light,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                });
          } else if (snapshot.hasData) {
            messagesResults = snapshot.data! as List<dynamic>;

            if (messagesResults.isNotEmpty) {
              return ListView.separated(
                itemCount: messagesResults.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  MessageListModel chatMessage = messagesResults[index];

                  UserModel chatUser =
                      chatMessage.getAuthorId! == widget.currentUser!.objectId!
                          ? chatMessage.getReceiver!
                          : chatMessage.getAuthor!;
                  bool isMe =
                      chatMessage.getAuthorId! == widget.currentUser!.objectId!
                          ? true
                          : false;

                  return ButtonWidget(
                    height: 50,
                    onTap: () => QuickHelp.gotoChat(context,
                        currentUser: widget.currentUser,
                        mUser: chatUser,),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuickActions.avatarWidget(
                            chatUser,
                            width: 50,
                            height: 50,
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWithTap(
                                      chatUser.getFullName!,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      marginLeft: 10,
                                      color: QuickHelp.isDarkMode(context)
                                          ? Colors.white
                                          : Colors.black,
                                      marginTop: 5,
                                      marginRight: 5,
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.only(left: 10, top: 5),
                                          child: getTextIcon(chatMessage),
                                        ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeText)
                                          ContainerCorner(
                                            width: 230,
                                            child: TextWithTap(
                                              chatMessage.getText!,
                                              marginTop: 5,
                                              marginLeft: 10,
                                              maxLines: 1,
                                              color:
                                                  !chatMessage.isRead! && !isMe
                                                      ? Colors.redAccent
                                                      : kGrayColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontWeight:
                                                  !chatMessage.isRead! && !isMe
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeGif)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Icon(
                                                    Icons.wallet_giftcard_sharp,
                                                    size: 20,
                                                    color: kGrayColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypePicture)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8, left: 5),
                                                  child: Icon(
                                                    Icons.photo_camera,
                                                    size: 20,
                                                    color: kGrayColor,
                                                  ),
                                                ),
                                                TextWithTap(
                                                  MessageModel
                                                      .messageTypePicture,
                                                  marginTop: 5,
                                                  marginLeft: 5,
                                                  color: !chatMessage.isRead! &&
                                                          !isMe
                                                      ? Colors.redAccent
                                                      : kGrayColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 17,
                                                  fontWeight:
                                                      !chatMessage.isRead! &&
                                                              !isMe
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeCall)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8, left: 5),
                                                  child: Icon(
                                                    chatMessage.getCall!
                                                                .getAuthorId ==
                                                            widget.currentUser!
                                                                .objectId!
                                                        ? Icons.call_made
                                                        : Icons.call_received,
                                                    size: 20,
                                                    color: kGrayColor,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 8, left: 5),
                                                  child: Icon(
                                                    chatMessage.getCall!
                                                            .getIsVoiceCall!
                                                        ? Icons.call
                                                        : Icons.videocam,
                                                    size: 24,
                                                    color: kGrayColor,
                                                  ),
                                                ),
                                                TextWithTap(
                                                  chatMessage
                                                          .getCall!.getAccepted!
                                                      ? chatMessage
                                                          .getCall!.getDuration!
                                                      : "push_notifications.missed_call_title"
                                                          .tr(),
                                                  marginTop: 5,
                                                  marginLeft: 5,
                                                  color: !chatMessage.isRead! &&
                                                          !isMe
                                                      ? Colors.redAccent
                                                      : kGrayColor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 17,
                                                  fontWeight:
                                                      !chatMessage.isRead! &&
                                                              !isMe
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ],
                                )),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWithTap(
                                    QuickHelp.getMessageListTime(
                                        chatMessage.updatedAt!),
                                    marginLeft: 5,
                                    marginRight: 5,
                                    marginBottom: 5,
                                    color: kGrayColor,
                                  ),
                                ],
                              ),
                              !chatMessage.isRead! && !isMe
                                  ? ContainerCorner(
                                      borderRadius: 100,
                                      color: kRedColor1,
                                      marginRight: 5,
                                      child: TextWithTap(
                                        chatMessage.getCounter.toString(),
                                        color: Colors.white,
                                        marginRight: 5,
                                        marginTop: 2,
                                        marginLeft: 5,
                                        marginBottom: 2,
                                        fontSize: 11,
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container();
                },
              );
            } else {
              return Center(
                  child: TextWithTap(
                      "greetingS_from_new_friend_screen.empty_greetings_message"
                          .tr()));
            }
          } else {
            return Center(
                child: TextWithTap(
                    "greetingS_from_new_friend_screen.empty_greetings_message"
                        .tr()));
          }
        });
  }

  Widget getTextIcon(MessageListModel chatMessage) {
    if (chatMessage.getAuthorId == widget.currentUser!.objectId) {
      return Icon(
        Icons.done_all_outlined,
        color: chatMessage.isRead! ? Colors.blue : kGrayColor,
        size: 20,
      );
    } else {
      return Visibility(
        visible: false,
        child: Container(),
      );
    }
  }

  Widget options({required String caption, required int index}) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerCorner(
          height: 55,
          width: size.width,
          marginTop: index == (settingsTitles.length - 1) ? 6 : 0,
          radiusTopRight: index == 0 ? 25 : 0,
          radiusTopLeft: index == 0 ? 25 : 0,
          color: isDarkMode ? kContentDarkShadow : Colors.white,
          onTap: () {
            if (index == (settingsTitles.length - 1)) {
              QuickHelp.goBackToPreviousPage(context);
            } else {
              QuickHelp.showAppNotificationAdvanced(
                  title: "Clichou", context: context);
            }
          },
          child: Center(
            child: TextWithTap(
              caption,
              fontSize: size.width / 23,
            ),
          ),
        ),
        Visibility(
            visible: index < (settingsTitles.length - 2),
            child: ContainerCorner(
              height: 0.5,
              color: kGrayColor.withOpacity(0.5),
              width: size.width,
            ))
      ],
    );
  }

  void openSettingsSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showSettingsSheet();
        });
  }

  Widget showSettingsSheet() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.27,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setState) {
              return ContainerCorner(
                radiusTopLeft: 25,
                radiusTopRight: 25,
                color:
                    isDarkMode ? Colors.black : Colors.white.withOpacity(0.9),
                borderWidth: 0,
                child: Scaffold(
                  backgroundColor: kTransparentColor,
                  body: Column(
                    children: List.generate(
                      settingsTitles.length,
                      (index) => options(
                        caption: settingsTitles[index],
                        index: index,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
