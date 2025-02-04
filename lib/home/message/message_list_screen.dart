// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/MessageListModel.dart';
import 'package:trace/models/MessageModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../app/constants.dart';
import '../../app/setup.dart';
import '../../models/NotificationsModel.dart';
import '../../models/OfficialAnnouncementModel.dart';
import '../../utils/utilsConstants.dart';
import '../greetings/greetings_from_new_friend_screen.dart';
import '../notifications/notifications_screen.dart';
import '../official_announcement/official_announcement_screen.dart';
import '../report/report_screen.dart';

// ignore_for_file: must_be_immutable
class MessagesListScreen extends StatefulWidget {
  static const String route = '/home/messages';

  MessagesListScreen({Key? key, this.currentUser})
      : super(key: key);
  final UserModel? currentUser;

  @override
  State<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends State<MessagesListScreen> {
  late QueryBuilder<MessageListModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> messagesResults = <dynamic>[];

  var _future;

  // Ads
  static final _kAdIndex = 4;

  AnchoredAdaptiveBannerAdSize? _size;

  var notifications = [];
  var officialAnnouncements = [];
  List<MessageModel> messages = [];
  List<NotificationsModel> interactives = [];
  List<OfficialAnnouncementModel> announcements = [];

  var settingsTitles = [
    "message_screen.empty_message".tr(),
    "message_screen.mark_as_read".tr(),
    "message_screen.delete_history".tr(),
    "cancel".tr(),
  ];

  var officialMessagesIcons = [
    "assets/images/official_service.png",
    "assets/images/official_helper.png",
    "assets/images/guardian_information.png",
    "assets/images/official_greeting.png",
  ];

  var officialMessagesCaption = [
    "message_screen.customer_service".tr(),
    "message_screen.official_assistant".tr(),
    "message_screen.interactive_messages".tr(),
    "message_screen.greetings_".tr(),
  ];

  var officialMessagesScreen = [];

  var settingsCallBacks = [];

  ScrollController _announcementScrollController = new ScrollController();
  ScrollController _notificationsScrollController = new ScrollController();

  @override
  void initState() {
    QuickHelp.saveCurrentRoute(route: MessagesListScreen.route);

    super.initState();
    _future = _loadMessagesList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initAdsSize();
  }

  @override
  void dispose() {
    notifications.clear();
    officialAnnouncements.clear();
    super.dispose();
  }

  initAdsSize() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    } else {
      setState(() {
        _size = size;
      });
      print('Got to get height of anchored banner.');
    }
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

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

  /*clearChatHistory() async {
    for (MessageModel message in messages) {
      await message.delete();
      messageKey = QuickHelp.generateUId().toString();
    }

    setState(() {
      this.results.clear();
      messages.clear();
    });
  }*/


  getUnreadMessages() async{
    QueryBuilder<MessageModel> query =
    QueryBuilder<MessageModel>(MessageModel());

    query.whereEqualTo(MessageModel.keyReceiver, widget.currentUser!);
    query.whereEqualTo(MessageModel.keyRead, false);

    ParseResponse parseResponse = await query.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (MessageModel message in parseResponse.results!) {
          if (!messages.contains(message)) {
            messages.add(message);
          }
        }
      }
    }
  }

  getUnreadNotification() async{

    QueryBuilder<NotificationsModel> queryBuilder =
    QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyReceiver, widget.currentUser!);
    queryBuilder.whereEqualTo(NotificationsModel.keyRead, false);

    queryBuilder.includeObject([
      NotificationsModel.keyAuthor,
      NotificationsModel.keyReceiver,
      NotificationsModel.keyPost,
      NotificationsModel.keyLive,
      NotificationsModel.keyLiveAuthor,
      NotificationsModel.keyPostAuthor,
    ]);

    queryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (NotificationsModel notification in parseResponse.results!) {
          if (!interactives.contains(notification)) {
            interactives.add(notification);
          }
        }
      }
    }
  }

  getUnreadAnnouncement() async{
    QueryBuilder<OfficialAnnouncementModel> query =
    QueryBuilder<OfficialAnnouncementModel>(OfficialAnnouncementModel());

    ParseResponse parseResponse = await query.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        for (OfficialAnnouncementModel announcement in parseResponse.results!) {


          if (!announcement.getViewedBy!
              .contains(widget.currentUser!.objectId!)) {

            officialAnnouncements.add(announcement);

          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    officialMessagesScreen = [
      ReportScreen(
        currentUser: widget.currentUser,
      ),
      OfficialAnnouncementScreen(
        currentUser: widget.currentUser,
      ),
      NotificationsScreen(
        currentUser: widget.currentUser,
      ),
      GreetingsFromNewFriendScreen(
        currentUser: widget.currentUser,
      )
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 0.0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        title: TextWithTap(
          "message_screen.message_".tr(),
          fontWeight: FontWeight.w900,
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
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ContainerCorner(
            width: size.width,
            height: 110,
            marginTop: 10,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: .7,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                officialMessagesIcons.length,
                    (index) {
                  return option(
                    caption: officialMessagesCaption[index],
                    screenTogo: officialMessagesScreen[index],
                    iconURL: officialMessagesIcons[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
          ContainerCorner(
            height: size.height,
            width: size.width,
            child: loadMessages(),
          ),
        ],
      ),
    );
  }

  Widget option({
    required String caption,
    required String iconURL,
    required Widget screenTogo,
    required int index,
  }) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        ContainerCorner(
          onTap: () async {
            QuickHelp.goToNavigatorScreen(context, screenTogo);
          },
          child: Column(
            children: [
              Image.asset(
                iconURL,
                width: size.width / 7,
                height: size.width / 7,
                //color: kTra,
              ),
              TextWithTap(
                caption,
                marginTop: 5,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Visibility(
          visible: index == 1,
          child: ContainerCorner(
            width: 22,
            height: 22,
            borderRadius: 50,
            borderWidth: 0,
            marginRight: 15,
            marginBottom: 1,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: officialAnnouncementsCount(),
            ),
          ),
        ),
        Visibility(
          visible: index == 2,
          child: ContainerCorner(
            width: 22,
            height: 22,
            borderRadius: 50,
            borderWidth: 0,
            marginRight: 15,
            marginBottom: 1,
            color: Colors.red,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: interactiveMessagesCount(),
            ),
          ),
        )
      ],
    );
  }

  Widget officialAnnouncementsCount() {
    QueryBuilder<OfficialAnnouncementModel> query =
        QueryBuilder<OfficialAnnouncementModel>(OfficialAnnouncementModel());

    int? indexToRemove;

    return ParseLiveListWidget<OfficialAnnouncementModel>(
      query: query,
      scrollController: _announcementScrollController,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<OfficialAnnouncementModel> snapshot) {
        if (snapshot.failed) {
          return showViewersCount(
              amountText: "${officialAnnouncements.length}");
        }

        if (snapshot.hasData) {
          OfficialAnnouncementModel officialAnnouncement = snapshot.loadedData!;

          if (!officialAnnouncements.contains(officialAnnouncement.objectId)) {

            if (!officialAnnouncement.getViewedBy!
                .contains(widget.currentUser!.objectId!)) {
              officialAnnouncements.add(officialAnnouncement.objectId);

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                return await _announcementScrollController.animateTo(
                    _announcementScrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 5),
                    curve: Curves.easeInOut);
              });
            }

          } else {
            if (officialAnnouncement.getViewedBy!
                .contains(widget.currentUser!.objectId!)) {
              for (int i = 0; i < officialAnnouncements.length; i++) {
                if (notifications[i] == officialAnnouncement.objectId) {
                  indexToRemove = i;
                }
              }

              officialAnnouncements.removeAt(indexToRemove!);
            }
          }

          return showViewersCount(
              amountText:
                  "${QuickHelp.convertToK(officialAnnouncements.length)}");
        } else {
          return showViewersCount(
              amountText: "${officialAnnouncements.length}");
        }
      },
      listLoadingElement:
          showViewersCount(amountText: "${officialAnnouncements.length}"),
      queryEmptyElement:
          showViewersCount(amountText: "${officialAnnouncements.length}"),
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
      amountText,
      color: Colors.white,
      fontSize: 9,
      marginLeft: 2,
      marginTop: 2,
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
          initialChildSize: 0.3,
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

  Widget getAd() {
    BannerAdListener bannerAdListener =
        BannerAdListener(onAdWillDismissScreen: (ad) {
      ad.dispose();
    }, onAdClosed: (ad) {
      ad.dispose();
      debugPrint("Ad Got Closeed");
    }, onAdFailedToLoad: (ad, error) {
      ad.dispose();
    });

    BannerAd bannerAd = BannerAd(
      //size: AdSize.banner,
      size: _size!,
      adUnitId: Constants.getAdmobChatListBannerUnit(),
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    bannerAd..load();

    return Container(
      height: _size != null ? _size!.height.roundToDouble() : 0,
      width: _size != null ? _size!.width.toDouble() : 0,
      key: UniqueKey(),
      alignment: Alignment.center,
      child: AdWidget(ad: bannerAd),
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

  Widget loadMessages() {
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

                  //print("CHAT MESSAGE: ${chatUser.objectId} and ${widget.currentUser!.objectId}");

                  return ButtonWidget(
                    height: 50,
                    onTap: () => QuickHelp.gotoChat(context,
                        currentUser: widget.currentUser,
                        mUser: chatUser,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    QuickActions.avatarWidget(
                                      chatUser,
                                      width: 50,
                                      height: 50,
                                      vipFrameWidth: 60,
                                      vipFrameHeight: 57,
                                    ),
                                    if(chatUser.getAvatarFrame != null && chatUser.getCanUseAvatarFrame!)
                                      ContainerCorner(
                                        borderWidth: 0,
                                        width: 65,
                                        height: 65,
                                        child: CachedNetworkImage(
                                          imageUrl: chatUser.getAvatarFrame!.url!,
                                          imageBuilder: (context, imageProvider) => Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Column(
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
                                            MessageModel.messageTypeLeaveAgencyApplication)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 5, left: 5),
                                                  child: Icon(
                                                    Icons.telegram_sharp,
                                                    color: !chatMessage.isRead! && !isMe
                                                        ? Colors.greenAccent
                                                        : kGrayColor,
                                                    size: 15,
                                                  ),
                                                ),
                                                TextWithTap(
                                                  "agent_screen.quit_agency_application".tr(),
                                                  marginTop: 5,
                                                  marginLeft: 5,
                                                  color: !chatMessage.isRead! && !isMe
                                                      ? Colors.redAccent
                                                      : kGrayColor,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontSize: 13,
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
                                            MessageModel.messageTypeAgencyInvitation)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 5, left: 5),
                                                  child: Icon(
                                                    Icons.telegram_sharp,
                                                    color: !chatMessage.isRead! && !isMe
                                                        ? Colors.greenAccent
                                                        : kGrayColor,
                                                    size: 15,
                                                  ),
                                                ),
                                                TextWithTap(
                                                  "agent_screen.agency_invitation".tr(),
                                                  marginTop: 5,
                                                  marginLeft: 5,
                                                  color: !chatMessage.isRead! && !isMe
                                                      ? Colors.redAccent
                                                      : kGrayColor,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontSize: 13,
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
                                            MessageModel.messageTypeVoice)
                                          ContainerCorner(
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      top: 5, left: 5),
                                                  child: SvgPicture.asset(
                                                    "assets/svg/ic_microphone.svg",
                                                    height: 14,
                                                    color: kGrayColor,
                                                  ),
                                                ),
                                                TextWithTap(
                                                  "voice_".tr(),
                                                  //chatMessage.getMessage!.getVoiceDuration!,
                                                  marginTop: 5,
                                                  marginLeft: 5,
                                                  color: !chatMessage.isRead! &&
                                                      !isMe
                                                      ? Colors.greenAccent
                                                      : kGrayColor,
                                                  overflow: TextOverflow.ellipsis,
                                                  fontSize: 15,
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
                                            MessageModel.messageTypeText)
                                          ContainerCorner(
                                            width: 150,
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
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWithTap(
                                QuickHelp.getMessageListTime(
                                    chatMessage.updatedAt!),
                                marginLeft: 5,
                                marginRight: 5,
                                marginBottom: 5,
                                color: kGrayColor,
                              ),
                              Visibility(
                                visible: !chatMessage.isRead! && !isMe,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  color: kRedColor1,
                                  marginRight: 5,
                                  child: TextWithTap(
                                    chatMessage.getCounter.toString(),
                                    color: Colors.white,
                                    marginRight: 5,
                                    marginTop: 2,
                                    marginLeft: 5,
                                    marginBottom: 2,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  if (index % _kAdIndex == 0 &&
                      Setup.isAdsOnMessageListEnabled) {
                    if (_size != null) {
                      return getAd();
                    } else {
                      return Container();
                    }
                  }
                  return Container();
                },
              );
            } else {
              return QuickActions.noContentFound(context);
            }
          } else {
            return QuickActions.noContentFound(context);
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
}
