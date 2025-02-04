// Flutter imports:
// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import '../../app/constants.dart';
import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_cloud.dart';
import '../../helpers/quick_help.dart';
import '../../helpers/users_avatars_service.dart';
import '../../models/GiftsModel.dart';
import '../../models/GiftsSentModel.dart';
import '../../models/LeadersModel.dart';
import '../../models/LiveStreamingModel.dart';
import '../../models/LiveViewersModel.dart';
import '../../models/NotificationsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../coins/coins_payment_widget.dart';
import '../controller/controller.dart';
import '../live_end/live_end_report_screen.dart';
import '../live_end/live_end_screen.dart';
import 'gift/components/svga_player_widget.dart';
import 'gift/gift_manager/gift_manager.dart';
import 'global_private_live_price_sheet.dart';
import 'global_user_profil_sheet.dart';

class PrebuildAudioRoomScreen extends StatefulWidget {
  UserModel? currentUser;
  bool? isHost;
  LiveStreamingModel? liveStreaming;

  PrebuildAudioRoomScreen({
    this.currentUser,
    this.isHost,
    this.liveStreaming,
    super.key,
  });

  @override
  State<PrebuildAudioRoomScreen> createState() =>
      _PrebuildAudioRoomScreenState();
}

class _PrebuildAudioRoomScreenState extends State<PrebuildAudioRoomScreen> with TickerProviderStateMixin {
  int numberOfSeats = 0;
  AnimationController? _animationController;

  Subscription? subscription;
  LiveQuery liveQuery = LiveQuery();
  var coHostsList = [];
  bool following = false;

  Controller showGiftSendersController = Get.put(Controller());
  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);
  Timer? removeGiftTimer;

  void startRemovingGifts() {
    removeGiftTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (showGiftSendersController.receivedGiftList.isNotEmpty) {
        showGiftSendersController.giftReceiverList.removeAt(0);
        showGiftSendersController.giftSenderList.removeAt(0);
        showGiftSendersController.receivedGiftList.removeAt(0);
      } else {
        timer.cancel();
        removeGiftTimer = null;
      }
    });
  }

  SharedPreferences? preference;

  initSharedPref() async {
    preference = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preference!);
  }

  sendMessage(String msg) {
    ZegoUIKitPrebuiltLiveStreamingController().message.send(msg);
  }

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    initSharedPref();
    showGiftSendersController.isPrivateLive.value = widget.liveStreaming!.getPrivate!;
    Future.delayed(Duration(minutes: 2)).then((value){
      widget.currentUser!.addUserPoints = widget.isHost! ? 350 : 200;
      widget.currentUser!.save();
    });
    following = widget.currentUser!.getFollowing!
        .contains(widget.liveStreaming!.getAuthorId!);
    showGiftSendersController.diamondsCounter.value = widget.liveStreaming!.getDiamonds!.toString();
    showGiftSendersController.shareMediaFiles.value = widget.liveStreaming!.getSharingMedia!;
    if(widget.liveStreaming!.getNumberOfChairs == 20) {
      numberOfSeats = (widget.liveStreaming!.getNumberOfChairs! ~/ 5) + 1;
    }else if(widget.liveStreaming!.getNumberOfChairs == 24) {
      numberOfSeats = (widget.liveStreaming!.getNumberOfChairs! ~/ 6) + 1;
    }else{
      numberOfSeats = (widget.liveStreaming!.getNumberOfChairs! ~/ 4) + 1;
    }
    if (widget.isHost!) {
      addOrUpdateLiveViewers();
    }
    setupLiveGifts();
    setupStreamingLiveQuery();
    _animationController = AnimationController.unbounded(vsync: this);
  }


  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    showGiftSendersController.isPrivateLive.value = false;
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    subscription = null;
  }

  var userAvatar;

  final isSeatClosedNotifier = ValueNotifier<bool>(false);
  final isRequestingNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final AvatarService avatarService = AvatarService();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          ZegoUIKitPrebuiltLiveAudioRoom(
            appID: Setup.zegoLiveStreamAppID,
            appSign: Setup.zegoLiveStreamAppSign,
            userID: widget.currentUser!.objectId!,
            userName: widget.currentUser!.getFullName!,
            roomID: widget.liveStreaming!.getStreamingChannel!,
            events: ZegoUIKitPrebuiltLiveAudioRoomEvents(
                onLeaveConfirmation: (event, defaultAction,) async {
              if (widget.isHost!) {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: QuickHelp.isDarkMode(context)
                          ? kContentColorLightTheme
                          : kContentColorDarkTheme,
                      title: TextWithTap(
                        "account_settings.logout_user_sure".tr(),
                        fontWeight: FontWeight.bold,
                      ),
                      content: Text('live_streaming.finish_live_ask'.tr()),
                      actions: [
                        TextWithTap(
                          "cancel".tr(),
                          fontWeight: FontWeight.bold,
                          marginRight: 10,
                          marginLeft: 10,
                          marginBottom: 10,
                          onTap: () => Navigator.of(context).pop(false),
                        ),
                        TextWithTap(
                          "confirm_".tr(),
                          fontWeight: FontWeight.bold,
                          marginRight: 10,
                          marginLeft: 10,
                          marginBottom: 10,
                          onTap: () async {
                            if (widget.isHost!) {
                              QuickHelp.showLoadingDialog(context);
                              onViewerLeave();
                              widget.liveStreaming!.setStreaming = false;
                              ParseResponse response =
                                  await widget.liveStreaming!.save();
                              if (response.success && response.result != null) {
                                QuickHelp.hideLoadingDialog(context);
                                QuickHelp.goToNavigatorScreen(
                                  context,
                                  LiveEndReportScreen(
                                    currentUser: widget.currentUser,
                                    live: widget.liveStreaming,
                                  ),
                                );
                                //onViewerLeave();
                              } else {
                                QuickHelp.hideLoadingDialog(context);
                                QuickHelp.showAppNotificationAdvanced(
                                  title: "try_again_later".tr(),
                                  message: "not_connected".tr(),
                                  context: context,
                                );
                              }
                            } else {
                              QuickHelp.goBackToPreviousPage(context);
                              QuickHelp.goBackToPreviousPage(context);
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              } else {
                return defaultAction.call();
              }
            },
              user: ZegoLiveAudioRoomUserEvents(
                onEnter: (user){
                  if(user.id != widget.liveStreaming!.getAuthorId) {
                    addOrUpdateLiveViewers();
                    sendMessage("has_entered_the_room".tr());
                  }
                },
                onLeave: (user) {
                  sendMessage("has_left_the_room".tr());
                  onViewerLeave();
                }
              ),
              /*onEnded: (event, defaultAction,) {
              QuickHelp.goToNavigatorScreen(
                  context,
                  LiveEndScreen(
                    currentUser: widget.currentUser,
                    preferences: widget.preferences,
                    liveAuthor: widget.liveStreaming!.getAuthor,
                  ),
              );
            }*/),
            config: widget.isHost!
                ? (ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
                  ..confirmDialogInfo = ZegoLiveAudioRoomDialogInfo(
                    title: "account_settings.logout_user_sure".tr(),
                    message: 'live_streaming.finish_live_ask'.tr(),
                    cancelButtonName: "cancel".tr(),
                    confirmButtonName: "confirm_".tr(),
                  ))
                : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience()
              ..bottomMenuBar.audienceExtendButtons = [giftButton]
              ..bottomMenuBar.speakerExtendButtons = [giftButton]
              ..seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
                if (user == null) return const SizedBox();
                userAvatar = avatarService.fetchUserAvatar(user.id);
                return FutureBuilder<String?>(
                  future: avatarService.fetchUserAvatar(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return FadeShimmer(
                        width: size.width,
                        height: size.width,
                        radius: 200,
                        fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Icon(Icons.account_circle, size: size.width);
                    }
                    final avatarUrl = snapshot.data;
                    return avatarUrl != null
                        ? QuickActions.photosWidget(
                      avatarUrl,
                      width: size.width,
                      height: size.height,
                      borderRadius: 200,
                    ) : const Icon(Icons.account_circle, size: 40);
                  },
                );
              }
            ..seat.layout.rowConfigs = List.generate(numberOfSeats, (index){
              if(index == 0){
                return ZegoLiveAudioRoomLayoutRowConfig(count: 1, alignment: ZegoLiveAudioRoomLayoutAlignment.center);
              }

              if(widget.liveStreaming!.getNumberOfChairs == 20){
                return ZegoLiveAudioRoomLayoutRowConfig(count: 5, alignment: ZegoLiveAudioRoomLayoutAlignment.start);
              }

              if(widget.liveStreaming!.getNumberOfChairs == 24){
                return ZegoLiveAudioRoomLayoutRowConfig(count: 6, alignment: ZegoLiveAudioRoomLayoutAlignment.start);
              }

              return ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceEvenly);
            })
              ..foreground = customUiComponents()
              ..inRoomMessage.visible = true
              ..inRoomMessage.showAvatar = true
              ..bottomMenuBar.hostExtendButtons = [Obx((){
                return ContainerCorner(
                  color: Colors.white,
                  borderRadius: 50,
                  height: 38,
                  width: 38,
                  onTap: () {
                    toggleSharingMedia();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SvgPicture.asset(
                      showGiftSendersController.shareMediaFiles.value ? "assets/svg/stop_sharing_media.svg":
                      "assets/svg/start_sharing_media.svg",
                    ),
                  ),
                );
              }), privateLiveBtn]
              ..background = Image.asset(
                "assets/images/audio_bg_start.png",
                height: size.height,
                width: size.width,
                fit: BoxFit.fill,
              ),
          ),
          Positioned(
            top: 30,
            left: 10,
            child: SizedBox(
              width: size.width / 1.2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContainerCorner(
                        height: 37,
                        borderRadius: 50,
                        onTap: (){
                          if(!widget.isHost!) {
                            showUserProfileBottomSheet(
                              currentUser: widget.currentUser!,
                              userId: widget.liveStreaming!.getAuthorId!,
                              context: context,
                            );
                          }
                        },
                        colors: [kVioletColor, earnCashColor],
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ContainerCorner(
                                  marginRight: 5,
                                  color: Colors.black.withOpacity(0.5),
                                  child: QuickActions.avatarWidget(
                                    widget.liveStreaming!.getAuthor!,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  borderRadius: 50,
                                  height: 30,
                                  width: 30,
                                  borderWidth: 0,
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ContainerCorner(
                                      width: 65,
                                      child: TextScroll(
                                        widget.liveStreaming!.getAuthor!
                                            .getFullName!,
                                        mode: TextScrollMode.endless,
                                        velocity: Velocity(
                                            pixelsPerSecond: Offset(30, 0)),
                                        delayBefore: Duration(seconds: 1),
                                        pauseBetween:
                                        Duration(milliseconds: 150),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.left,
                                        selectable: true,
                                        intervalSpaces: 5,
                                        numberOfReps: 9999,
                                      ),
                                    ),
                                    ContainerCorner(
                                      width: 65,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: Image.asset(
                                              "assets/images/grade_welfare.png",
                                              height: 12,
                                              width: 12,
                                            ),
                                          ),
                                          Obx((){
                                            return TextWithTap(
                                              QuickHelp.checkFundsWithString(
                                                amount: showGiftSendersController.diamondsCounter.value,
                                              ),
                                              marginLeft: 5,
                                              marginRight: 5,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.white,
                                            );
                                          }),

                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            ContainerCorner(
                              marginLeft: 10,
                              marginRight: 6,
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: 50,
                              height: 23,
                              width: 23,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Lottie.asset(
                                    "assets/lotties/ic_live_animation.json"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isHost!)
                      ContainerCorner(
                          marginLeft: 5,
                          height: 30,
                          width: 30,
                        marginTop: 15,
                          color: following ? Colors.blueAccent : kVioletColor,
                          child: ContainerCorner(
                            color: kTransparentColor,
                            height: 30,
                            width: 30,
                            child: Center(
                              child: Icon(
                                following ? Icons.done : Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          borderRadius: 50,
                          onTap: () {
                            if (!following) {
                              followOrUnfollow();
                              //ZegoInRoomMessage.fromBroadcastMessage(ZegoBroadcastMessageInfo())
                            }
                          },
                        ),
                    ],
                  ),
                  ContainerCorner(
                    width: 70,
                    height: 40,
                    marginRight: 5,
                    child: getTopGifters(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ZegoLiveStreamingMenuBarExtendButton get privateLiveBtn =>
      ZegoLiveStreamingMenuBarExtendButton(
        child: IconButton(
          style: IconButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.black26,
          ),
          onPressed: () {
            if(showGiftSendersController.isPrivateLive.value) {
              unPrivatiseLive();
            }else{
              PrivateLivePriceWidget(
                  context: context,
                  onCancel: () => QuickHelp.hideLoadingDialog(context),
                  onGiftSelected: (gift){
                    QuickHelp.hideLoadingDialog(context);
                    privatiseLive(gift);
                  }
              );
            }
          },
          icon: Obx(()=> SvgPicture.asset(
            showGiftSendersController.isPrivateLive.value ?
            "assets/svg/ic_unlocked_live.svg":
            "assets/svg/ic_locked_live.svg",
          ),
          ),
        ),
      );

  privatiseLive(GiftsModel gift) async{
    QuickHelp.showLoadingDialog(context);
    widget.liveStreaming!.setPrivate = true;
    widget.liveStreaming!.setPrivateLivePrice = gift;
    ParseResponse response = await widget.liveStreaming!.save();
    if(response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "privatise_live_title".tr(),
        message: "privatise_live_succeed".tr(),
        context: context,
        isError: false,
      );
      showGiftSendersController.isPrivateLive.value = true;
    }else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "connection_failed".tr(),
        message: "not_connected".tr(),
        context: context,
      );
    }
  }
  unPrivatiseLive() async{
    QuickHelp.showLoadingDialog(context);
    widget.liveStreaming!.setPrivate = false;
    ParseResponse response = await widget.liveStreaming!.save();
    if(response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "public_live_title".tr(),
        message: "public_live_succeed".tr(),
        isError: false,
        context: context,
      );
      showGiftSendersController.isPrivateLive.value = false;
    }else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "connection_failed".tr(),
        message: "not_connected".tr(),
        context: context,
      );
    }
  }

  onViewerLeave() async {
    QueryBuilder<LiveViewersModel> queryLiveViewers =
    QueryBuilder<LiveViewersModel>(LiveViewersModel());

    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyAuthorId, widget.currentUser!.objectId);
    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyLiveAuthorId, widget.liveStreaming!.getAuthorId!);
    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyLiveId, widget.liveStreaming!.objectId!);

    ParseResponse parseResponse = await queryLiveViewers.query();
    if (parseResponse.success) {
      if (parseResponse.result != null) {
        LiveViewersModel liveViewers =
        parseResponse.results!.first! as LiveViewersModel;

        liveViewers.setWatching = false;
        await liveViewers.save();
      }
    }
  }

  addOrUpdateLiveViewers() async {
    QueryBuilder<LiveViewersModel> queryLiveViewers =
    QueryBuilder<LiveViewersModel>(LiveViewersModel());

    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyAuthorId, widget.currentUser!.objectId);
    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyLiveId, widget.liveStreaming!.objectId!);
    queryLiveViewers.whereEqualTo(
        LiveViewersModel.keyLiveAuthorId, widget.liveStreaming!.getAuthorId!);

    ParseResponse parseResponse = await queryLiveViewers.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveViewersModel liveViewers =
        parseResponse.results!.first! as LiveViewersModel;

        liveViewers.setWatching = true;

        await liveViewers.save();
      } else {
        LiveViewersModel liveViewersModel = LiveViewersModel();

        liveViewersModel.setAuthor = widget.currentUser!;
        liveViewersModel.setAuthorId = widget.currentUser!.objectId!;

        liveViewersModel.setWatching = true;

        liveViewersModel.setLiveAuthorId = widget.liveStreaming!.getAuthorId!;
        liveViewersModel.setLiveId = widget.liveStreaming!.objectId!;

        await liveViewersModel.save();
      }
    }
  }

  Widget getTopGifters() {
    QueryBuilder<LiveViewersModel> query =
    QueryBuilder<LiveViewersModel>(LiveViewersModel());

    //query.whereNotEqualTo(LiveViewersModel.keyAuthorId, widget.liveStreaming!.getAuthorId);
    query.whereEqualTo(LiveViewersModel.keyLiveId, widget.liveStreaming!.objectId);
    query.whereEqualTo(LiveViewersModel.keyWatching, true);
    query.orderByDescending(LiveViewersModel.keyUpdatedAt);
    query.includeObject([
      LiveViewersModel.keyAuthor,
    ]);
    //query.setLimit(3);

    return ParseLiveListWidget<LiveViewersModel>(
      query: query,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      duration: const Duration(milliseconds: 200),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<LiveViewersModel> snapshot) {
        if (snapshot.hasData) {
          LiveViewersModel viewer = snapshot.loadedData!;

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ContainerCorner(
                height: 25,
                width: 25,
                borderWidth: 0,
                borderRadius: 50,
                marginRight: 7,
                child: QuickActions.avatarWidget(
                  viewer.getAuthor!,
                  height: 25,
                  width: 25,
                ),
              ),
              ContainerCorner(
                color: Colors.white,
                borderRadius: 2,
                marginRight: 7,
                child: TextWithTap(
                  QuickHelp.convertToK(viewer.getAuthor!.getCreditsSent!),
                  fontSize: 5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
      listLoadingElement: const SizedBox(),
    );
  }

  void followOrUnfollow() async {
    if (following) {
      widget.currentUser!.removeFollowing = widget.liveStreaming!.getAuthorId!;
      widget.liveStreaming!.removeFollower = widget.currentUser!.objectId!;

      setState(() {
        following = false;
      });
    } else {
      widget.currentUser!.setFollowing = widget.liveStreaming!.getAuthorId!;
      widget.liveStreaming!.addFollower = widget.currentUser!.objectId!;

      setState(() {
        following = true;
      });
    }

    await widget.currentUser!.save();
    widget.liveStreaming!.save();

    ParseResponse parseResponse = await QuickCloudCode.followUser(
        author: widget.currentUser!,
        receiver: widget.liveStreaming!.getAuthor!);

    if (parseResponse.success) {
      sendMessage("start_following".tr());
      QuickActions.createOrDeleteNotification(
        widget.currentUser!,
        widget.liveStreaming!.getAuthor!,
        NotificationsModel.notificationTypeFollowers,
      );
    }
  }

  ZegoLiveStreamingMenuBarExtendButton get giftButton =>
      ZegoLiveStreamingMenuBarExtendButton(
        index: 0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.black26,
          ),
          onPressed: () {
            if(coHostsList.isNotEmpty) {
              openUserToReceiveCoins();
              return ;
            }
            CoinsFlowPayment(
              context: context,
              currentUser: widget.currentUser!,
              onCoinsPurchased: (coins) {
                print(
                    "onCoinsPurchased: $coins new: ${widget.currentUser!.getCredits}");
              },
              onGiftSelected: (gift) {
                print("onGiftSelected called ${gift.getCoins}");
                sendGift(gift, widget.liveStreaming!.getAuthor!);

                //QuickHelp.goBackToPreviousPage(context);
                QuickHelp.showAppNotificationAdvanced(
                  context: context,
                  user: widget.currentUser,
                  title: "live_streaming.gift_sent_title".tr(),
                  message:
                  "live_streaming.gift_sent_explain".tr(
                    namedArgs: {
                      "name": widget.liveStreaming!.getAuthor!.getFirstName!
                    },
                  ),
                  isError: false,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Lottie.asset(
              "assets/lotties/ic_gift.json",
              height: 29,
            ),
          ),
        ),
      );


  setupStreamingLiveQuery() async {
    QueryBuilder<LiveStreamingModel> query =
    QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

    query.whereEqualTo(
        LiveStreamingModel.keyObjectId, widget.liveStreaming!.objectId);
    query.includeObject([
      LiveStreamingModel.keyPrivateLiveGift,
      LiveStreamingModel.keyGiftSenders,
      LiveStreamingModel.keyGiftSendersAuthor,
      LiveStreamingModel.keyAuthor,
      LiveStreamingModel.keyInvitedPartyLive,
      LiveStreamingModel.keyInvitedPartyLiveAuthor,
    ]);

    subscription = await liveQuery.client.subscribe(query);

    subscription!.on(LiveQueryEvent.update, (LiveStreamingModel newUpdatedLive) async {
      print('*** UPDATE ***');
      await newUpdatedLive.getAuthor!.fetch();
      widget.liveStreaming = newUpdatedLive;
      widget.liveStreaming = newUpdatedLive;

      if (!mounted) return;

      showGiftSendersController.diamondsCounter.value = newUpdatedLive.getDiamonds.toString();

      if(newUpdatedLive.getSharingMedia != showGiftSendersController.shareMediaFiles.value) {
        showGiftSendersController.shareMediaFiles.value = newUpdatedLive.getSharingMedia!;
      }

      if(!newUpdatedLive.getStreaming! && !widget.isHost!) {
        QuickHelp.goToNavigatorScreen(
            context,
            LiveEndScreen(
              currentUser: widget.currentUser,
              liveAuthor: widget.liveStreaming!.getAuthor,
            ));
        //onViewerLeave();
      }
    });

    subscription!.on(LiveQueryEvent.enter, (LiveStreamingModel updatedLive) async{
      print('*** ENTER ***');
      await updatedLive.getAuthor!.fetch();
      widget.liveStreaming = updatedLive;
      widget.liveStreaming = updatedLive;

      if (!mounted) return;
      showGiftSendersController.diamondsCounter.value = widget.liveStreaming!.getDiamonds.toString();
    });
  }
  sendGift(GiftsModel giftsModel, UserModel mUser) async {

    GiftsSentModel giftsSentModel = new GiftsSentModel();
    giftsSentModel.setAuthor = widget.currentUser!;
    giftsSentModel.setAuthorId = widget.currentUser!.objectId!;

    giftsSentModel.setReceiver = mUser;
    giftsSentModel.setReceiverId = mUser.objectId!;
    giftsSentModel.setLiveId = widget.liveStreaming!.objectId!;

    giftsSentModel.setGift = giftsModel;
    giftsSentModel.setGiftId = giftsModel.objectId!;
    giftsSentModel.setCounterDiamondsQuantity = giftsModel.getCoins!;
    await giftsSentModel.save();

    QuickHelp.saveReceivedGifts(
        receiver: mUser, author: widget.currentUser!, gift: giftsModel);
    QuickHelp.saveCoinTransaction(
      receiver: mUser,
      author: widget.currentUser!,
      amountTransacted: giftsModel.getCoins!,
    );

    QueryBuilder<LeadersModel> queryBuilder =
    QueryBuilder<LeadersModel>(LeadersModel());
    queryBuilder.whereEqualTo(
        LeadersModel.keyAuthorId, widget.currentUser!.objectId!);
    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      updateCurrentUser(giftsSentModel.getDiamondsQuantity!);

      if (parseResponse.results != null) {
        LeadersModel leadersModel =
        parseResponse.results!.first as LeadersModel;
        leadersModel.incrementDiamondsQuantity =
        giftsSentModel.getDiamondsQuantity!;
        leadersModel.setGiftsSent = giftsSentModel;
        await leadersModel.save();
      } else {
        LeadersModel leadersModel = LeadersModel();
        leadersModel.setAuthor = widget.currentUser!;
        leadersModel.setAuthorId = widget.currentUser!.objectId!;
        leadersModel.incrementDiamondsQuantity =
        giftsSentModel.getDiamondsQuantity!;
        leadersModel.setGiftsSent = giftsSentModel;
        await leadersModel.save();
      }

      await QuickCloudCode.sendGift(
        author: mUser,
        credits: giftsModel.getCoins!,
      );

      if(mUser.objectId == widget.liveStreaming!.getAuthorId) {
        widget.liveStreaming!.addDiamonds =
            QuickHelp.getDiamondsForReceiver(
              giftsModel.getCoins!,
            );
        await widget.liveStreaming!.save();
        sendMessage("sent_gift".tr(namedArgs: {"name": "host_".tr()}));
      }else{
        sendMessage("sent_gift".tr(namedArgs: {"name": mUser.getFullName!}));
      }

      /*sendMessage(LiveMessagesModel.messageTypeGift, "", widget.currentUser,
          giftsSent: giftsSentModel);*/
    } else {
      //QuickHelp.goBackToPreviousPage(context);
      debugPrint("gift Navigator pop up");
    }
  }


  Widget advanceMediaPlayer({
    required bool canControl,
  }) {
    Size size = MediaQuery.sizeOf(context);
    const padding = 20;
    final playerSize =
    Size(size.width - padding * 2, size.width * 9 / 16);
    return ZegoUIKitMediaPlayer(
      size: playerSize,
      enableRepeat: true,
      canControl: canControl,
      showSurface: true,
      initPosition: Offset(
        size.width - playerSize.width - padding,
        size.height - playerSize.height - padding - 40,
      ),
    );
  }

  Widget customUiComponents() {
    return Stack(
      children: [
        Obx((){
          return Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                showGiftSendersController.receivedGiftList.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ContainerCorner(
                      colors: [Colors.black26, Colors.transparent],
                      borderRadius: 50,
                      marginLeft: 5,
                      marginRight: 10,
                      marginBottom: 15,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QuickActions.avatarWidget(
                                  showGiftSendersController.giftSenderList[index],
                                  width: 35,
                                  height: 35,
                                ),
                                SizedBox(
                                  width: 45,
                                  child: TextWithTap(
                                    showGiftSendersController.giftSenderList[index].getFullName!,
                                    fontSize: 8,
                                    color: Colors.white,
                                    marginTop: 2,
                                    overflow: TextOverflow.ellipsis,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ],
                            ),
                            TextWithTap(
                              "sent_gift_to".tr(),
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              marginRight: 5,
                              marginLeft: 5,
                              textItalic: true,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                QuickActions.avatarWidget(
                                  showGiftSendersController.giftReceiverList[index],
                                  width: 35,
                                  height: 35,
                                ),
                                SizedBox(
                                  width: 45,
                                  child: TextWithTap(
                                    showGiftSendersController.giftReceiverList[index].getFullName!,
                                    fontSize: 8,
                                    color: Colors.white,
                                    marginTop: 2,
                                    overflow: TextOverflow.ellipsis,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: QuickActions.photosWidget(
                                    showGiftSendersController.receivedGiftList[index].getPreview!.url),
                              ),
                            ),
                            ContainerCorner(
                              color: kTransparentColor,
                              marginTop: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    "assets/svg/ic_coin_with_star.svg",
                                    width: 10,
                                    height: 10,
                                  ),
                                  TextWithTap(
                                    showGiftSendersController.receivedGiftList[index].getCoins.toString(),
                                    color: Colors.white,
                                    fontSize: 10,
                                    marginLeft: 5,
                                    fontWeight: FontWeight.w900,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        TextWithTap(
                          "x1",
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          marginLeft: 10,
                          textItalic: true,
                        ),
                      ],
                    )
                  ],
                ).animate().slideX(
                  duration: Duration(seconds: 2),
                  delay: Duration(seconds: 0),
                  begin: -5,
                  end: 0,
                );
              },
              ),),
          );
        }),
        ValueListenableBuilder<GiftsModel?>(
          valueListenable: ZegoGiftManager().playList.playingDataNotifier,
          builder: (context, playData, _) {
            if (null == playData) {
              return const SizedBox.shrink();
            }
            return svgaWidget(playData);
          },
        ),
        Obx((){
          return Visibility(
            visible: showGiftSendersController.shareMediaFiles.value,
              child: advanceMediaPlayer(
                canControl: widget.isHost!,
              ),);
        }),
      ],
    );
  }

  toggleSharingMedia() async{
    QuickHelp.showLoadingDialog(context);
    if(showGiftSendersController.shareMediaFiles.value) {
      widget.liveStreaming!.setSharingMedia = false;
    }else{
      widget.liveStreaming!.setSharingMedia = true;
    }
    ParseResponse response = await widget.liveStreaming!.save();
    if(response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        message: "not_connected".tr(),
        context: context,
        isError: true,
      );
    }
  }

  updateCurrentUser(int coins) async {
    widget.currentUser!.removeCredit = coins;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      widget.currentUser = response.results!.first as UserModel;
    }
  }

  Widget svgaWidget(GiftsModel giftItem) {

    /// you can define the area and size for displaying your own
    /// animations here
    int level = 1;
    if (giftItem.getCoins! < 10) {
      level = 1;
    } else if (giftItem.getCoins! < 100) {
      level = 2;
    } else {
      level = 3;
    }
    switch (level) {
      case 2:
        return Positioned(
          top: 100,
          bottom: 100,
          left: 1,
          right: 1,
          child: ZegoSvgaPlayerWidget(
            key: UniqueKey(),
            giftItem: giftItem,
            onPlayEnd: () {
              ZegoGiftManager().playList.next();
            }, count: 1,
          ),
        );
      case 3:
        return ZegoSvgaPlayerWidget(
          key: UniqueKey(),
          giftItem: giftItem,
          onPlayEnd: () {
            ZegoGiftManager().playList.next();
          }, count: 1,
        );
    }
    // level 1
    return Positioned(
      bottom: 200,
      child: ZegoSvgaPlayerWidget(
        key: UniqueKey(),
        size: const Size(100, 100),
        giftItem: giftItem,
        onPlayEnd: () {
          /// if there is another gift animation, then play
          ZegoGiftManager().playList.next();
        }, count: 1,
      ),
    );
  }

  setupLiveGifts() async {
    QueryBuilder<GiftsSentModel> queryBuilder =
    QueryBuilder<GiftsSentModel>(GiftsSentModel());
    queryBuilder.whereEqualTo(
        GiftsSentModel.keyLiveId, widget.liveStreaming!.objectId);
    queryBuilder.includeObject(
        [GiftsSentModel.keyGift]);
    subscription = await liveQuery.client.subscribe(queryBuilder);

    subscription!.on(LiveQueryEvent.create,
          (GiftsSentModel giftSent) async {
        await giftSent.getGift!.fetch();
        await giftSent.getReceiver!.fetch();
        await giftSent.getAuthor!.fetch();

        GiftsModel receivedGift = giftSent.getGift!;
        UserModel receiver = giftSent.getReceiver!;
        UserModel sender = giftSent.getAuthor!;

        showGiftSendersController.giftSenderList.add(sender);
        showGiftSendersController.giftReceiverList.add(receiver);
        showGiftSendersController.receivedGiftList.add(receivedGift);

        if (removeGiftTimer == null) {
          startRemovingGifts();
        }

        selectedGiftItemNotifier.value = receivedGift;

        /// local play
        ZegoGiftManager().playList.add(receivedGift);

        ValueListenableBuilder<GiftsModel?>(
          valueListenable: ZegoGiftManager().playList.playingDataNotifier,
          builder: (context, playData, _) {
            if (null == playData) {
              return const SizedBox.shrink();
            }
            return svgaWidget(playData);
          },
        );
      },
    );
  }
  void openUserToReceiveCoins() async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _showUserToReceiveCoins();
      },
    );
  }

  Widget _showUserToReceiveCoins() {
    coHostsList.add(widget.liveStreaming!.getAuthorId);
    Size size = MediaQuery.sizeOf(context);
    QueryBuilder<UserModel> coHostQuery = QueryBuilder<UserModel>(UserModel.forQuery());
    coHostQuery.whereNotEqualTo(UserModel.keyObjectId, widget.currentUser!.objectId);
    coHostQuery.whereContainedIn(UserModel.keyObjectId, coHostsList);

    return ContainerCorner(
      color: kIamonDarkBarColor.withOpacity(.9),
      width: size.width,
      borderColor: Colors.white,
      radiusTopLeft: 10,
      radiusTopRight: 10,
      marginRight: 15,
      marginLeft: 15,
      child: Column(
        children: [
          TextWithTap(
            "choose_gift_receiver".tr(),
            color: Colors.white,
            alignment: Alignment.center,
            textAlign: TextAlign.center,
            marginTop: 15,
            marginBottom: 30,
          ),
          Flexible(child: ParseLiveGridWidget<UserModel>(
            query: coHostQuery,
            crossAxisCount: 4,
            reverse: false,
            crossAxisSpacing: 5,
            mainAxisSpacing: 10,
            lazyLoading: false,
            padding: EdgeInsets.only(left: 15, right: 15),
            childAspectRatio: 0.7,
            shrinkWrap: true,
            listenOnAllSubItems: true,
            duration: Duration(seconds: 0),
            animationController: _animationController,
            childBuilder: (BuildContext context,
                ParseLiveListElementSnapshot<UserModel> snapshot) {
              UserModel user = snapshot.loadedData!;
              return GestureDetector(
                onTap: () {
                  CoinsFlowPayment(
                    context: context,
                    currentUser: widget.currentUser!,
                    onCoinsPurchased: (coins) {
                      print(
                          "onCoinsPurchased: $coins new: ${widget.currentUser!.getCredits}");
                    },
                    onGiftSelected: (gift) {
                      print("onGiftSelected called ${gift.getCoins}");
                      sendGift(gift, user);

                      //QuickHelp.goBackToPreviousPage(context);
                      QuickHelp.showAppNotificationAdvanced(
                        context: context,
                        user: widget.currentUser,
                        title: "live_streaming.gift_sent_title".tr(),
                        message:
                        "live_streaming.gift_sent_explain".tr(
                          namedArgs: {
                            "name": user.getFirstName!
                          },
                        ),
                        isError: false,
                      );
                    },
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    QuickActions.avatarWidget(
                      user,
                      width: size.width / 5.5,
                      height: size.width / 5.5,
                    ),
                    TextWithTap(
                      user.getFullName!,
                      color: Colors.white,
                      marginTop: 5,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 10,
                    ),
                  ],),
              );
            },
            queryEmptyElement: QuickActions.noContentFound(context),
            gridLoadingElement: Container(
              margin: EdgeInsets.only(top: 50),
              alignment: Alignment.topCenter,
              child: CircularProgressIndicator(),
            ),
          ),)
        ],
      ),
    );
  }
}
