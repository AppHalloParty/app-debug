// Flutter imports:
// ignore_for_file: must_be_immutable, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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
import 'package:trace/app/setup.dart';
import 'package:trace/home/controller/controller.dart';
import 'package:trace/home/live_end/live_end_report_screen.dart';
import 'package:trace/home/prebuild_live/timer_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../../app/constants.dart';
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
import '../live_end/live_end_screen.dart';
import '../pk_battle/pk_widgets/config.dart';
import '../pk_battle/pk_widgets/events.dart';
import '../pk_battle/pk_widgets/surface.dart';
import '../pk_battle/pk_widgets/widgets/mute_button.dart';
import 'gift/components/mp4_player_widget.dart';
import 'gift/components/svga_player_widget.dart';
import 'gift/gift_data.dart';
import 'gift/gift_manager/defines.dart';
import 'gift/gift_manager/gift_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

import 'global_private_live_price_sheet.dart';
import 'global_user_profil_sheet.dart';

class PreBuildLiveScreen extends StatefulWidget {
  UserModel? currentUser;
  LiveStreamingModel? liveStreaming;
  final String liveID;
  final bool isHost;
  final String localUserID;

  PreBuildLiveScreen(
      {Key? key,
      required this.liveID,
      required this.localUserID,
      this.isHost = false,
      this.currentUser,
      this.liveStreaming})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PreBuildLiveScreenState();
}

class PreBuildLiveScreenState extends State<PreBuildLiveScreen>
    with TickerProviderStateMixin {
  bool following = false;
  late TabController generalTabControl;
  int tabsLength = 2;
  int tabIndex = 0;
  int pagesIndex = 0;

  Subscription? subscription;
  LiveQuery liveQuery = LiveQuery();
  var coHostsList = [];

  TextEditingController searchTextController = TextEditingController();
  String searchText = "";
  String keyUpdate = "";
  bool isSearching = false;
  bool imLiveInviter = false;

  final requestingHostsMapRequestIDNotifier =
      ValueNotifier<Map<String, List<String>>>({});
  final requestIDNotifier = ValueNotifier<String>('');
  PKEvents? pkEvents;
  var invitedUsers = [];
  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);
  AnimationController? _animationController;

  Map<String, dynamic> giftSendersSowerList = {};

  Controller showGiftSendersController = Get.put(Controller());

  Timer? removeGiftTimer;
  int repeatPkTimes = 0;

  var numbersCaptions = [
    "tab_profile.followings_".tr(),
    "tab_profile.followers_".tr(),
    "agent_screen.earnings_".tr(),
  ];

  int myBattlePoint = 0;
  int hisBattlePoint = 0;

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
    Future.delayed(Duration(minutes: 2)).then((value){
      widget.currentUser!.addUserPoints = widget.isHost ? 350 : 200;
      widget.currentUser!.save();
    });
    pkEvents = PKEvents(
        requestIDNotifier: requestIDNotifier,
        requestingHostsMapRequestIDNotifier:
            requestingHostsMapRequestIDNotifier,
        liveStreaming: widget.liveStreaming!,
        onIncomingBattleRequest: (event, defaultAction) async {
          QueryBuilder queryUser = QueryBuilder(UserModel.forQuery());
          queryUser.whereEqualTo(UserModel.keyObjectId, event.fromHost.id);
          queryUser.setLimit(1);
          ParseResponse response = await queryUser.query();
          if (response.success && response.results != null) {
            UserModel battleRequestHost = response.results!.first;
            openBattleRequestInvitation(user: battleRequestHost, event: event);
          } else {
            defaultAction.call();
          }
        },
        onOutgoingRequestAccepted: (event, defaultAction) {
          defaultAction.call();
          updateLiveToBattle(event.fromLiveID);
          initiateBattleTimer();
        },
        onUserJoined: (user) {
          updateLiveToBattle(user.streamID);
          initiateBattleTimer();
        },
    );

    following = widget.currentUser!.getFollowing!
        .contains(widget.liveStreaming!.getAuthorId);
    showGiftSendersController.diamondsCounter.value =
        widget.liveStreaming!.getDiamonds!.toString();
    showGiftSendersController.isBattleLive.value =
        widget.liveStreaming!.getBattle!;
    if (showGiftSendersController.isBattleLive.value) {}
    ZegoGiftManager().cache.cacheAllFiles(giftItemList);

    ZegoGiftManager().service.recvNotifier.addListener(onGiftReceived);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ZegoGiftManager().service.init(
            appID: Setup.zegoLiveStreamAppID,
            liveID: widget.liveID,
            localUserID: widget.currentUser!.objectId!,
            localUserName: widget.currentUser!.getFullName!,
          );
    });

    generalTabControl =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(() {
            setState(() {
              tabIndex = generalTabControl.index;
            });
          });
    setupStreamingLiveQuery();
    setupLiveGifts();
    if (widget.isHost) {
      addOrUpdateLiveViewers();
    }
    _animationController = AnimationController.unbounded(vsync: this);
  }

  void openBattleRequestInvitation(
      {required UserModel user,
      required ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent
          event}) async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _showInComingBattleRequest(user: user, event: event);
      },
    );
  }

  Widget _showInComingBattleRequest(
      {required UserModel user,
      required ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent event}) {
    Size size = MediaQuery.sizeOf(context);
    var numbers = [
      user.getFollowing!.length,
      user.getFollowers!.length,
      user.getDiamondsTotal!,
    ];
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
        color: kWhitenDark,
        width: size.width,
        borderWidth: 0,
        child: Scaffold(
          backgroundColor: kTransparentColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: kTransparentColor,
            backgroundColor: kTransparentColor,
            title: Row(
              children: [
                TextWithTap(
                  "pk_invitation_title".tr(),
                  fontSize: 18,
                  color: Colors.black,
                  alignment: Alignment.center,
                  fontWeight: FontWeight.w900,
                  marginRight: 10,
                ),
                Image.asset(
                  "assets/images/live_pk_icon_vs.png",
                  width: 45,
                  height: 45,
                ),
              ],
            ),
            toolbarHeight: 80,
          ),
          body: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return ContainerCorner(
                width: size.width,
                borderWidth: 0,
                child: ListView(
                  children: [
                    QuickActions.avatarWidget(
                      user,
                      height: size.width / 3,
                      width: size.width / 3,
                    ),
                    TextWithTap(
                      user.getFullName!,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        numbersCaptions.length,
                        (index) => captionAndNumber(
                          caption: numbersCaptions[index],
                          number: numbers[index],
                          visitor: index == 2 ? true : false,
                        ),
                      ),
                    ),
                    TextWithTap(
                      "pk_invitation_explain".tr(),
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                      marginRight: 15,
                      marginLeft: 15,
                      marginTop: 20,
                      fontSize: 18,
                    ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ContainerCorner(
                colors: [kProfileStarsColorSecondary, earnCashColor],
                borderRadius: 10,
                borderWidth: 0,
                marginBottom: 20,
                marginTop: 10,
                width: size.width / 2.7,
                height: 50,
                onTap: () {
                  ZegoUIKitPrebuiltLiveStreamingController().pk.rejectRequest(
                        requestID: event.requestID,
                        targetHostID: event.fromHost.id,
                      );
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "cancel".tr(),
                  color: Colors.white,
                  alignment: Alignment.center,
                  fontWeight: FontWeight.w900,
                ),
              ),
              ContainerCorner(
                colors: [kPrimaryColor, kVioletColor],
                borderRadius: 10,
                borderWidth: 0,
                marginBottom: 20,
                marginTop: 10,
                width: size.width / 2.7,
                height: 50,
                onTap: () {
                  showGiftSendersController.showBattleWinner.value = false;
                  ZegoUIKitPrebuiltLiveStreamingController().pk.acceptRequest(
                        requestID: event.requestID,
                        targetHost: ZegoUIKitPrebuiltLiveStreamingPKUser(
                          userInfo: event.fromHost,
                          liveID: event.fromLiveID,
                        ),
                      );
                  updateLiveToBattle(event.fromLiveID);
                  initiateBattleTimer();
                  updateBattleInvitee();
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "accept_".tr(),
                  color: Colors.white,
                  alignment: Alignment.center,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  restartPkBattle() async{
    widget.liveStreaming!.setMyBattlePoints = 0;
    widget.liveStreaming!.setHisBattlePoints = 0;
    repeatPkTimes++;
    await widget.liveStreaming!.save();
    QuickCloudCode.restartPKBattle(liveChannel: widget.liveStreaming!.getBattleLiveId!, times: repeatPkTimes);
    initiateBattleTimer();
  }

  void updateLiveToBattle(String liveId) {
    widget.liveStreaming!.setBattleStatus = LiveStreamingModel.battleAlive;
    widget.liveStreaming!.setBattleLiveId = liveId;
    widget.liveStreaming!.save();
  }

  initiateBattleTimer() {
    Future.delayed(Duration(seconds: 3)).then((value) {
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      sendSyncCommand(startTime: currentTime, duration: 120);
      TimerController.startLocalTimer(onTimerUpdate:(remainingTimer) {
        showGiftSendersController.battleTimer.value = remainingTimer;
        if(showGiftSendersController.battleTimer.value == 0) {
          showGiftSendersController.showBattleWinner.value = true;
          Future.delayed(Duration(seconds: 10)).then((value){
            showGiftSendersController.showBattleWinner.value = false;
          });
          if(widget.isHost){
            updateVictories();
            updateUserBattleData();
          }
        }
      }, duration: 120);
    });
  }

  updateVictories() {
    int myPoints = showGiftSendersController.myBattlePoints.value;
    int hisPoints = showGiftSendersController.hisBattlePoints.value;
    if(myPoints != hisPoints) {
      if(myPoints > hisPoints) {
        widget.liveStreaming!.addMyBattleVictory = 1;
      }else if(hisPoints > myPoints){
        widget.liveStreaming!.addHisBattleVictory = 1;
      }
      widget.liveStreaming!.save();
    }
  }

  updateUserBattleData() {
    int myPoints = showGiftSendersController.myBattlePoints.value;
    int hisPoints = showGiftSendersController.hisBattlePoints.value;
    widget.currentUser!.addBattlePoints = myPoints;
    if(myPoints > hisPoints) {
      widget.currentUser!.addBattleVictories = 1;
    }else if(hisPoints > myPoints){
      widget.currentUser!.addBattleLost = 1;
    }
    widget.currentUser!.save();
  }

  Future<void> sendSyncCommand({required int startTime, required int duration}) async {
    final command = jsonEncode({'startTime': startTime, 'duration': duration});
    try {
      final commandSent =
          await ZegoUIKitPrebuiltLiveStreamingController().room.sendCommand(
                roomID: widget.liveID,
                command: Uint8List.fromList(utf8.encode(command)),
              );

      if (commandSent) {
        debugPrint('Command sent successfully: $command');
      } else {
        debugPrint('Failed to send command');
      }
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  Widget captionAndNumber({
    required String caption,
    required int number,
    bool? visitor,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isVisitor = visitor ?? false;
    return ContainerCorner(
      child: Column(
        children: [
          Stack(
            alignment: AlignmentDirectional.center,
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (visitor!)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Image.asset(
                        "assets/images/grade_welfare.png",
                        height: 15,
                        width: 15,
                      ),
                    ),
                  TextWithTap(
                    QuickHelp.convertToK(number),
                    fontWeight: FontWeight.w600,
                    marginBottom: 4,
                    marginLeft: 4,
                    fontSize: 15,
                  ),
                ],
              ),
              Visibility(
                visible: isVisitor,
                child: Positioned(
                  top: 0,
                  right: -5,
                  child: ContainerCorner(
                    height: 5,
                    width: 5,
                    color: Colors.red,
                    borderRadius: 50,
                  ),
                ),
              )
            ],
          ),
          TextWithTap(
            caption,
            color: kGrayColor,
            fontSize: size.width / 35,
          ),
        ],
      ),
    );
  }

  Widget pointsWidget() {
    Size size = MediaQuery.sizeOf(context);
    var pkColors = [kOrangedColor, kPurpleColor];
    return Obx((){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(2,
              (index) {
            return ContainerCorner(
              width: size.width / 2,
              height: 15,
              color: pkColors[index],
              borderWidth: 0,
              child: TextWithTap(
                "${index == 0 ? showGiftSendersController.myBattlePoints.value : showGiftSendersController.hisBattlePoints.value} "+"coins_and_points_screen.points_".tr(),
                color: Colors.white,
                alignment: index == 1 ? Alignment.centerRight : Alignment.centerLeft,
                fontSize: 12,
                marginRight: index == 1 ? 10 : 0,
                marginLeft: index == 0 ? 10 : 0,
                fontWeight: FontWeight.w900,
              ),
            );
          },
        ),
      );
    });
  }

  Widget victoryWidget() {
    Size size = MediaQuery.sizeOf(context);
    return Obx((){
      return SizedBox(
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(2,
                (index) {
              return ContainerCorner(
                color: Colors.black38,
                borderWidth: 0,
                //height: 25,
                borderRadius: 4,
                //width: 80,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "WIN",
                        color: kOrangeColor100,
                        fontWeight: FontWeight.w900,
                        marginRight: 1,
                        fontSize: 12,
                      ),
                      TextWithTap(
                        "x ${index == 0 ? showGiftSendersController.myBattleVictories.value : showGiftSendersController.hisBattleVictories.value}",
                        color: Colors.white,
                        alignment: index == 1 ? Alignment.centerRight : Alignment.centerLeft,
                        //marginRight: index == 1 ? 10 : 0,
                        //marginLeft: index == 0 ? 10 : 0,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget winnerWidget() {
    Size size = MediaQuery.sizeOf(context);
    int myPoints = showGiftSendersController.myBattlePoints.value;
    int hisPoints = showGiftSendersController.hisBattlePoints.value;
    if(showGiftSendersController.showBattleWinner.value) {
      if(myPoints > hisPoints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Lottie.asset(
                "assets/lotties/battle_winner.json",
                height: size.width / 2.3,
                width: size.width / 2.3
            ),
            Lottie.asset(
                "assets/lotties/battle_lost.json",
                height: size.width / 3,
                width: size.width / 3
            ),
          ],);
      }else if(hisPoints > myPoints){
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Lottie.asset(
                "assets/lotties/battle_lost.json",
                height: size.width / 3,
                width: size.width / 3
            ),
            Lottie.asset(
                "assets/lotties/battle_winner.json",
                height: size.width / 2.3,
                width: size.width / 2.3
            ),
          ],);
      }else{
        return Lottie.asset(
            "assets/lotties/no_winner.json",
            height: size.width / 2.3,
            width: size.width / 2.3
        );
      }
    }else{
      return SizedBox();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    generalTabControl.dispose();
    showGiftSendersController.isPrivateLive.value = false;
    showGiftSendersController.isPrivateLive.value = widget.liveStreaming!.getPrivate!;
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    subscription = null;

    following = widget.currentUser!.getFollowing!
        .contains(widget.liveStreaming!.getAuthorId!);

    ZegoGiftManager().service.recvNotifier.removeListener(onGiftReceived);
    ZegoGiftManager().service.uninit();
  }

  final liveStateNotifier =
      ValueNotifier<ZegoLiveStreamingState>(ZegoLiveStreamingState.idle);

  @override
  Widget build(BuildContext context) {
    final AvatarService avatarService = AvatarService();
    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host(
      plugins: [
        ZegoUIKitSignalingPlugin(),
      ],
    )

      /// on host can control pk
      //..foreground =
      ..preview.showPreviewForHost = false
      ..bottomMenuBar.hostExtendButtons = [privateLiveBtn]
      ..avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user,
          Map extraInfo) {
        return user != null
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: NetworkImage(
                      widget.liveStreaming!.getAuthor!.getAvatar!.url!,
                    ),
                  ),
                ),
              )
            : const SizedBox();
      };

    final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience(
      plugins: [ZegoUIKitSignalingPlugin()],
    )
      ..audioVideoView.foregroundBuilder = hostAudioVideoViewForegroundBuilder
      ..bottomMenuBar.coHostExtendButtons = [giftButton]
      ..bottomMenuBar.audienceExtendButtons = [giftButton];

    final audienceEvents = ZegoUIKitPrebuiltLiveStreamingEvents(
      inRoomMessage: ZegoLiveStreamingInRoomMessageEvents(
        onClicked: (message){
          if(message.user.id != widget.currentUser!.objectId) {
            showUserProfileBottomSheet(
              currentUser: widget.currentUser!,
              userId: message.user.id,
              context: context,
            );
          }
        },
      ),
      memberList: ZegoLiveStreamingMemberListEvents(
          onClicked: (user) {
            if(user.id != widget.currentUser!.objectId) {
              QuickHelp.hideLoadingDialog(context);
              showUserProfileBottomSheet(
                currentUser: widget.currentUser!,
                userId: user.id,
                context: context,
              );
            }
          }
      ),
      onError: (ZegoUIKitError error) {
        debugPrint('onError:$error');
      },
      user: ZegoLiveStreamingUserEvents(onEnter: (zegoUser) {
        Future.delayed(Duration(seconds: 1)).then((value){
          showGiftSendersController.hisBattlePoints.value = widget.liveStreaming!.getHisBattlePoints!;
          showGiftSendersController.myBattlePoints.value = widget.liveStreaming!.getMyBattlePoints!;
          showGiftSendersController.hisBattleVictories.value = widget.liveStreaming!.getHisBattleVictory!;
          showGiftSendersController.myBattleVictories.value = widget.liveStreaming!.getMyBattleVictory!;
        });
        addOrUpdateLiveViewers();
      }, onLeave: (zegoUser) {
        onViewerLeave();
      }),
      onEnded: (
        ZegoLiveStreamingEndEvent event,
        VoidCallback defaultAction,
      ) {
        if (ZegoLiveStreamingEndReason.hostEnd == event.reason) {
          if (event.isFromMinimizing) {
            /// now is minimizing state, not need to navigate, just switch to idle
            ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
            onViewerLeave();
          } else {
            QuickHelp.goToNavigatorScreen(
              context,
              LiveEndScreen(
                currentUser: widget.currentUser,
                liveAuthor: widget.liveStreaming!.getAuthor,
              ),
            );
            onViewerLeave();
          }
        } else {
          defaultAction.call();
          onViewerLeave();
        }
      },
      coHost: ZegoLiveStreamingCoHostEvents(
        onUpdated: (co_hosts_ids) {
          for (ZegoUIKitUser coHost in co_hosts_ids) {
            if (!coHostsList.contains(coHost.id)) {
              coHostsList.add(coHost.id);
            }
          }
          coHostsList.removeWhere(
              (id) => !co_hosts_ids.any((coHost) => coHost.id == id));
          setState(() {});
        },
      ),
      audioVideo: ZegoLiveStreamingAudioVideoEvents(
        onCameraTurnOnByOthersConfirmation: (BuildContext context) {
          return onTurnOnAudienceDeviceConfirmation(
            context,
            isCameraOrMicrophone: true,
          );
        },
        onMicrophoneTurnOnByOthersConfirmation: (BuildContext context) {
          return onTurnOnAudienceDeviceConfirmation(
            context,
            isCameraOrMicrophone: false,
          );
        },
      ),
    );

    final hostEvents = ZegoUIKitPrebuiltLiveStreamingEvents(
      inRoomMessage: ZegoLiveStreamingInRoomMessageEvents(
        onClicked: (message) {
          if(message.user.id != widget.currentUser!.objectId) {
            showUserProfileBottomSheet(
              currentUser: widget.currentUser!,
              userId: message.user.id,
              context: context,
            );
          }
        },
      ),
      memberList: ZegoLiveStreamingMemberListEvents(
          onClicked: (user) {
            if(user.id != widget.currentUser!.objectId) {
              QuickHelp.hideLoadingDialog(context);
              showUserProfileBottomSheet(
                currentUser: widget.currentUser!,
                userId: user.id,
                context: context,
              );
            }
          }
      ),
      pk: pkEvents!.event,
      onError: (ZegoUIKitError error) {
        debugPrint('onError:$error');
      },
      user: ZegoLiveStreamingUserEvents(
        onEnter: (user) {
          if (ZegoLiveStreamingState.inPKBattle == liveStateNotifier.value) {
            Future.delayed(Duration(seconds: 3)).then((value){
              final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              sendSyncCommand(startTime: currentTime, duration: showGiftSendersController.battleTimer.value);
            });
          }
        },
      ),
      onEnded: (
        ZegoLiveStreamingEndEvent event,
        VoidCallback defaultAction,
      ) {
        if (ZegoLiveStreamingEndReason.hostEnd == event.reason) {
          if (event.isFromMinimizing) {
            /// now is minimizing state, not need to navigate, just switch to idle
            ZegoUIKitPrebuiltLiveStreamingController().minimize.hide();
          } else {
            Navigator.pop(context);
            QuickHelp.goBackToPreviousPage(context);
          }
        } else {
          defaultAction.call();
          QuickHelp.goBackToPreviousPage(context);
        }
      },
      onStateUpdated: (state) {
        liveStateNotifier.value = state;
        if (ZegoLiveStreamingState.idle == state) {
          ZegoGiftManager().playList.clear();
        }
      },
    );

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
          appID: Setup.zegoLiveStreamAppID,
          appSign: Setup.zegoLiveStreamAppSign,
          userID: widget.currentUser!.objectId!,
          userName: widget.currentUser!.getFullName!,
          liveID: widget.liveID,
          events: widget.isHost ? hostEvents : audienceEvents,
          config: (widget.isHost ? hostConfig : audienceConfig)
            ..audioVideoView.useVideoViewAspectFill = true
            ..mediaPlayer.supportTransparent = true
            ..pkBattle = pkConfig(
                liveId: widget.liveID,
              pointsWidget: pointsWidget(),
              showWinnerAndLoser: Obx((){
                return Visibility(
                  visible: showGiftSendersController.showBattleWinner.value,
                    child: winnerWidget(),
                );
              }),
              victoryWidget: victoryWidget(),
            )
            ..audioVideoView.backgroundBuilder = (BuildContext context,
                Size size, ZegoUIKitUser? user, Map extraInfo) {
              return user != null
                  ? Image.asset(
                      "assets/images/audio_bg_start.png",
                      height: size.height,
                      width: size.width,
                      fit: BoxFit.fill,
                    )
                  : const SizedBox();
            }
            ..topMenuBar.hostAvatarBuilder = (ZegoUIKitUser? user) {
              return user != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ContainerCorner(
                          height: 37,
                          borderRadius: 50,
                          colors: [kVioletColor, earnCashColor],
                          onTap: (){
                            if(user.id != widget.currentUser!.objectId) {
                              showUserProfileBottomSheet(
                                currentUser: widget.currentUser!,
                                userId: user.id,
                                context: context,
                              );
                            }
                          },
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
                                              padding: const EdgeInsets.only(
                                                  left: 5),
                                              child: Image.asset(
                                                "assets/images/grade_welfare.png",
                                                height: 12,
                                                width: 12,
                                              ),
                                            ),
                                            Obx(() {
                                              return TextWithTap(
                                                QuickHelp.checkFundsWithString(
                                                  amount:
                                                      showGiftSendersController
                                                          .diamondsCounter
                                                          .value,
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
                        if (!widget.isHost)
                          ContainerCorner(
                            marginLeft: 5,
                            height: 30,
                            width: 30,
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
                                //ZegoInRoomMessage.fromBroadcastMessage("")
                              }
                            },
                          ),
                      ],
                    )
                  : const SizedBox();
            }
            ..memberButton.builder = (number) {
              return ContainerCorner(
                width: 70,
                height: 40,
                marginRight: 5,
                child: Stack(
                  alignment: Alignment.centerRight,
                  clipBehavior: Clip.none,
                  children: [
                    getTopGifters(),
                    Positioned(
                      right: -7,
                      child: ContainerCorner(
                        color: Colors.black38,
                        borderRadius: 50,
                        child: TextWithTap(
                          QuickHelp.convertToK(number),
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          marginLeft: 3,
                          marginRight: 3,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            ..topMenuBar.showCloseButton = !widget.isHost
            ..topMenuBar.margin = EdgeInsets.only(right: widget.isHost ? 30 : 0)

            /// support minimizing
            ..topMenuBar.buttons = [
              ZegoLiveStreamingMenuBarButtonName.minimizingButton,
            ]

            /// custom avatar
            ..avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
              if (user == null) return const SizedBox();

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
                    return const Icon(Icons.account_circle, size: 40);
                  }

                  final avatarUrl = snapshot.data;
                  return avatarUrl != null
                      ? QuickActions.photosWidget(
                    avatarUrl,
                    width: size.width,
                    height: size.height,
                    borderRadius: 200,
                  )
                      : const Icon(Icons.account_circle, size: 40);
                },
              );
            }
            ..audioVideoView.showUserNameOnView = true
            ..inRoomMessage.notifyUserJoin = true
            ..inRoomMessage.notifyUserLeave = true
            ..inRoomMessage.showAvatar = true

            //Add your UI component here
            ..foreground = customUiComponents()
            ..background = Image.asset(
              "assets/images/audio_room_background.png",
              fit: BoxFit.fill,
            )

          /// message attributes example
          //..inRoomMessage.attributes = userLevelsAttributes
          //..inRoomMessage.avatarLeadingBuilder = userLevelBuilder,
          ),
    );
  }

  Widget getTopGifters() {
    QueryBuilder<LiveViewersModel> query =
        QueryBuilder<LiveViewersModel>(LiveViewersModel());

    //query.whereNotEqualTo(LiveViewersModel.keyAuthorId, widget.liveStreaming!.getAuthorId);
    query.whereEqualTo(
        LiveViewersModel.keyLiveId, widget.liveStreaming!.objectId);
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

  Widget customUiComponents() {
    return Stack(
      children: [
        ValueListenableBuilder<ZegoLiveStreamingState>(
          valueListenable: liveStateNotifier,
          builder: (context, liveState, _) {
            if (ZegoLiveStreamingState.ended == liveState) {
              return SizedBox();
            }
            return Stack(
              children: [
                Visibility(
                  visible: widget.isHost,
                  child: Positioned(
                    right: 15,
                    top: 37,
                    child: ContainerCorner(
                      borderRadius: 50,
                      marginRight: 5,
                      color: earnCashColor,
                      height: 30,
                      width: 30,
                      marginLeft: 5,
                      child: IconButton(
                        onPressed: () {
                          showDialog(
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
                                content:
                                    Text('live_streaming.finish_live_ask'.tr()),
                                actions: [
                                  TextWithTap(
                                    "cancel".tr(),
                                    fontWeight: FontWeight.bold,
                                    marginRight: 10,
                                    marginLeft: 10,
                                    marginBottom: 10,
                                    onTap: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextWithTap(
                                    "confirm_".tr(),
                                    fontWeight: FontWeight.bold,
                                    marginRight: 10,
                                    marginLeft: 10,
                                    marginBottom: 10,
                                    onTap: () async {
                                      if (widget.isHost) {
                                        QuickHelp.showLoadingDialog(context);
                                        widget.liveStreaming!.setStreaming =
                                            false;
                                        ParseResponse response =
                                            await widget.liveStreaming!.save();
                                        if (response.success &&
                                            response.result != null) {
                                          QuickHelp.hideLoadingDialog(context);
                                          QuickHelp.goToNavigatorScreen(
                                            context,
                                            LiveEndReportScreen(
                                              currentUser: widget.currentUser,
                                              live: widget.liveStreaming,
                                            ),
                                          );
                                          onViewerLeave();
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
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          weight: 900,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: liveStateNotifier,
                  builder: (context, state, _) {
                    if (ZegoLiveStreamingState.inPKBattle != state) {
                      return Visibility(
                        visible: widget.isHost,
                        child: Positioned(
                          right: 15,
                          bottom: 50,
                          child: IconButton(
                            onPressed: () => openVsSheet(),
                            icon: Image.asset(
                              "assets/images/live_pk_multi_vs_icon.png",
                              height: 40,
                            ),
                          ),
                        ),
                      );
                    }else if(ZegoLiveStreamingState.inPKBattle == state && imLiveInviter){
                      return Obx((){
                        return Visibility(
                          visible: widget.isHost && showGiftSendersController.battleTimer.value == 0,
                          child: Positioned(
                            right: 15,
                            bottom: 50,
                            child: IconButton(
                              onPressed: () => restartPkBattle(),
                              icon: Lottie.asset(
                                "assets/lotties/pk_restart.json",
                                height: 40,
                              ),
                            ),
                          ),
                        );
                      });
                    }
                    return SizedBox();
                  },
                ),
                PKV2Surface(
                  requestIDNotifier: requestIDNotifier,
                  liveStateNotifier: liveStateNotifier,
                  requestingHostsMapRequestIDNotifier:
                      requestingHostsMapRequestIDNotifier,
                ),
              ],
            );
          },
        ),
        Obx(() {
          return Positioned(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                showGiftSendersController.receivedGiftList.length,
                (index) {
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
                                    showGiftSendersController
                                        .giftSenderList[index],
                                    width: 35,
                                    height: 35,
                                  ),
                                  SizedBox(
                                    width: 45,
                                    child: TextWithTap(
                                      showGiftSendersController
                                          .giftSenderList[index].getFullName!,
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
                                    showGiftSendersController
                                        .giftReceiverList[index],
                                    width: 35,
                                    height: 35,
                                  ),
                                  SizedBox(
                                    width: 45,
                                    child: TextWithTap(
                                      showGiftSendersController
                                          .giftReceiverList[index].getFullName!,
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
                                      showGiftSendersController
                                          .receivedGiftList[index]
                                          .getPreview!
                                          .url),
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
                                      showGiftSendersController
                                          .receivedGiftList[index].getCoins
                                          .toString(),
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
              ),
            ),
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
      ],
    );
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
            },
            count: 1,
          ),
        );
      case 3:
        return ZegoSvgaPlayerWidget(
          key: UniqueKey(),
          giftItem: giftItem,
          onPlayEnd: () {
            ZegoGiftManager().playList.next();
          },
          count: 1,
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
        },
        count: 1,
      ),
    );
  }

  Widget mp4Widget(PlayData playData) {
    /// you can define the area and size for displaying your own
    /// animations here
    int level = 1;
    if (playData.giftItem.getCoins! < 10) {
      level = 1;
    } else if (playData.giftItem.getCoins! < 100) {
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
          child: ZegoMp4PlayerWidget(
            key: UniqueKey(),
            playData: playData,
            onPlayEnd: () {
              ZegoGiftManager().playList.next();
            },
          ),
        );
      case 3:
        return ZegoMp4PlayerWidget(
          key: UniqueKey(),
          playData: playData,
          onPlayEnd: () {
            ZegoGiftManager().playList.next();
          },
        );
    }
    // level 1
    return Positioned(
      bottom: 200,
      left: 1,
      child: ZegoMp4PlayerWidget(
        key: UniqueKey(),
        size: const Size(100, 100),
        playData: playData,
        onPlayEnd: () {
          /// if there is another gift animation, then play
          ZegoGiftManager().playList.next();
        },
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

  ZegoLiveStreamingMenuBarExtendButton get giftButton =>
      ZegoLiveStreamingMenuBarExtendButton(
        index: 0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.black26,
          ),
          onPressed: () {
            if (coHostsList.isNotEmpty) {
              openUserToReceiveCoins();
              return;
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
                  message: "live_streaming.gift_sent_explain".tr(
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

      if (mUser.objectId == widget.liveStreaming!.getAuthorId) {
        widget.liveStreaming!.addDiamonds = QuickHelp.getDiamondsForReceiver(
          giftsModel.getCoins!,
        );
        if(showGiftSendersController.battleTimer.value > 0 && widget.liveStreaming!.getBattleStatus == LiveStreamingModel.battleAlive) {
          widget.liveStreaming!.addMyBattlePoints = QuickHelp.getDiamondsForReceiver(giftsModel.getCoins!);
          QuickCloudCode.saveHisBattlePoints(
            points: QuickHelp.getDiamondsForReceiver(giftsModel.getCoins!),
            liveChannel: widget.liveStreaming!.getBattleLiveId!,
          );
        }
        await widget.liveStreaming!.save();
        sendMessage("sent_gift".tr(namedArgs: {"name": "host_".tr()}));
        
      } else {
        sendMessage("sent_gift".tr(namedArgs: {"name": mUser.getFullName!}));
      }

    } else {
      //QuickHelp.goBackToPreviousPage(context);
      debugPrint("gift Navigator pop up");
    }
  }

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

    subscription!.on(LiveQueryEvent.update,
        (LiveStreamingModel newUpdatedLive) async {
      print('*** UPDATE ***');
      await newUpdatedLive.getAuthor!.fetch();
      widget.liveStreaming = newUpdatedLive;
      widget.liveStreaming = newUpdatedLive;

      if (!mounted) return;

      showGiftSendersController.diamondsCounter.value =
          newUpdatedLive.getDiamonds.toString();

      showGiftSendersController.hisBattlePoints.value = newUpdatedLive.getHisBattlePoints!;
      showGiftSendersController.myBattlePoints.value = newUpdatedLive.getMyBattlePoints!;

      showGiftSendersController.myBattleVictories.value = newUpdatedLive.getMyBattleVictory!;
      showGiftSendersController.hisBattleVictories.value = newUpdatedLive.getHisBattleVictory!;

      /*if(widget.isHost) {
        widget.currentUser!.addBattlePoints = QuickHelp.getDiamondsForReceiver(giftsModel.getCoins!, widget.preferences!);
        widget.currentUser!.save();
      }
      */
      if(newUpdatedLive.getRepeatBattleTimes! > 0 && newUpdatedLive.getRepeatBattleTimes! > repeatPkTimes) {
        repeatPkTimes = newUpdatedLive.getRepeatBattleTimes!;
        initiateBattleTimer();
      }
      showGiftSendersController.isBattleLive.value = newUpdatedLive.getBattle!;
      if (!newUpdatedLive.getStreaming! && !widget.isHost) {
        QuickHelp.goToNavigatorScreen(
            context,
            LiveEndScreen(
              currentUser: widget.currentUser,
              liveAuthor: widget.liveStreaming!.getAuthor,
            ));
        //onViewerLeave();
      }
    });

    subscription!.on(LiveQueryEvent.enter,
        (LiveStreamingModel updatedLive) async {
      print('*** ENTER ***');
      await updatedLive.getAuthor!.fetch();
      widget.liveStreaming = updatedLive;
      widget.liveStreaming = updatedLive;

      if (!mounted) return;
      showGiftSendersController.diamondsCounter.value =
          widget.liveStreaming!.getDiamonds.toString();
      showGiftSendersController.hisBattlePoints.value = updatedLive.getHisBattlePoints!;
      showGiftSendersController.myBattlePoints.value = updatedLive.getMyBattlePoints!;
    });
  }

  updateCurrentUser(int coins) async {
    widget.currentUser!.removeCredit = coins;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      widget.currentUser = response.results!.first as UserModel;
    }
  }

  setupLiveGifts() async {
    QueryBuilder<GiftsSentModel> queryBuilder =
        QueryBuilder<GiftsSentModel>(GiftsSentModel());
    queryBuilder.whereEqualTo(
        GiftsSentModel.keyLiveId, widget.liveStreaming!.objectId);
    queryBuilder.includeObject([GiftsSentModel.keyGift]);
    subscription = await liveQuery.client.subscribe(queryBuilder);

    subscription!.on(
      LiveQueryEvent.create,
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
    QueryBuilder<UserModel> coHostQuery =
        QueryBuilder<UserModel>(UserModel.forQuery());
    coHostQuery.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);
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
          Flexible(
            child: ParseLiveGridWidget<UserModel>(
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
                          message: "live_streaming.gift_sent_explain".tr(
                            namedArgs: {"name": user.getFirstName!},
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
                    ],
                  ),
                );
              },
              queryEmptyElement: QuickActions.noContentFound(context),
              gridLoadingElement: Container(
                margin: EdgeInsets.only(top: 50),
                alignment: Alignment.topCenter,
                child: CircularProgressIndicator(),
              ),
            ),
          )
        ],
      ),
    );
  }

  void onGiftReceived() {
    final receivedGift = ZegoGiftManager().service.recvNotifier.value ??
        ZegoGiftProtocolItem.empty();
    final giftData = queryGiftInItemList(receivedGift.name);
    if (null == giftData) {
      debugPrint('not ${receivedGift.name} exist');
      return;
    }

    //Uncomment to play on receive

    //ZegoGiftManager().playList.add(giftData,);

    QuickHelp.showAppNotificationAdvanced(
      title: "Gift Recebido",
      context: context,
      isError: false,
    );
  }

  Widget userLevelBuilder(
    BuildContext context,
    ZegoInRoomMessage message,
    Map<String, dynamic> extraInfo,
  ) {
    return Container(
      alignment: Alignment.center,
      height: 15,
      width: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple.shade300, Colors.purple.shade400],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(
        "LV ${message.attributes['lv']}",
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10,
        ),
      ),
    );
  }

  Image prebuiltImage(String name) {
    return Image.asset(name);
  }

  Widget foregroundBuilder(context, size, ZegoUIKitUser? user, _) {
    if (user == null) {
      return Container();
    }

    final hostWidgets = [
      /// mute pk user
      Positioned(
        top: 5,
        left: 5,
        child: SizedBox(
          width: 40,
          height: 40,
          child: PKMuteButton(userID: user.id),
        ),
      ),
    ];

    return Stack(
      children: [
        ...((widget.isHost && user.id != widget.localUserID)
            ? hostWidgets
            : []),

        /// camera state
        Positioned(
          top: 5,
          right: 35,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.6),
              child: Icon(
                user.camera.value ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),

        /// microphone state
        Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.6),
              child: Icon(
                user.microphone.value ? Icons.mic : Icons.mic_off,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),

        /// name
        Positioned(
          top: 25,
          right: 5,
          child: Container(
            // width: 30,
            height: 18,
            color: Colors.purple,
            child: Text(user.name),
          ),
        ),
      ],
    );
  }

  Widget hostAudioVideoViewForegroundBuilder(
    BuildContext context,
    Size size,
    ZegoUIKitUser? user,
    Map<String, dynamic> extraInfo,
  ) {
    if (user == null || widget.currentUser!.objectId == widget.localUserID) {
      return Container();
    }

    final hostWidgets = [
      /// mute pk user
      Positioned(
        top: 5,
        left: 5,
        child: SizedBox(
          width: 40,
          height: 40,
          child: PKMuteButton(userID: user.id),
        ),
      ),
    ];

    const toolbarCameraNormal = 'assets/icons/toolbar_camera_normal.png';
    const toolbarCameraOff = 'assets/icons/toolbar_camera_off.png';
    const toolbarMicNormal = 'assets/icons/toolbar_mic_normal.png';
    const toolbarMicOff = 'assets/icons/toolbar_mic_off.png';
    return Stack(
      children: [
        ...((widget.isHost && user.id != widget.localUserID)
            ? hostWidgets
            : []),

        /// camera state
        Positioned(
          top: 5,
          right: 35,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.6),
              child: Icon(
                user.camera.value ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),

        /// microphone state
        Positioned(
          top: 5,
          right: 5,
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.6),
              child: Icon(
                user.microphone.value ? Icons.mic : Icons.mic_off,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),

        /// name
        Positioned(
          top: 25,
          right: 5,
          child: Container(
            // width: 30,
            height: 18,
            color: Colors.purple,
            child: Text(user.name),
          ),
        ),

        Positioned(
          top: 15,
          right: 0,
          child: Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit()
                    .getCameraStateNotifier(widget.currentUser!.objectId!),
                builder: (context, isCameraEnabled, _) {
                  return GestureDetector(
                    onTap: () {
                      ZegoUIKit().turnCameraOn(!isCameraEnabled,
                          userID: widget.currentUser!.objectId!);
                    },
                    child: SizedBox(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      child: prebuiltImage(
                        isCameraEnabled
                            ? toolbarCameraNormal
                            : toolbarCameraOff,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: size.width * 0.1),
              ValueListenableBuilder<bool>(
                valueListenable: ZegoUIKit()
                    .getMicrophoneStateNotifier(widget.currentUser!.objectId!),
                builder: (context, isMicrophoneEnabled, _) {
                  return GestureDetector(
                    onTap: () {
                      ZegoUIKit().turnMicrophoneOn(
                        !isMicrophoneEnabled,
                        userID: widget.currentUser!.objectId!,

                        ///  if you don't want to stop co-hosting automatically when both camera and microphone are off,
                        ///  set the [muteMode] parameter to true.
                        ///
                        ///  However, in this case, your [ZegoUIKitPrebuiltLiveStreamingConfig.stopCoHostingWhenMicCameraOff]
                        ///  should also be set to false.
                        muteMode: true,
                      );
                    },
                    child: SizedBox(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      child: prebuiltImage(
                        isMicrophoneEnabled ? toolbarMicNormal : toolbarMicOff,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> onTurnOnAudienceDeviceConfirmation(
    BuildContext context, {
    required bool isCameraOrMicrophone,
  }) async {
    const textStyle = TextStyle(
      fontSize: 10,
      color: Colors.white70,
    );
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue[900]!.withOpacity(0.9),
          title: Text(
              "You have a request to turn on your ${isCameraOrMicrophone ? "camera" : "microphone"}",
              style: textStyle),
          content: Text(
              "Do you agree to turn on the ${isCameraOrMicrophone ? "camera" : "microphone"}?",
              style: textStyle),
          actions: [
            ElevatedButton(
              child: const Text('Cancel', style: textStyle),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('OK', style: textStyle),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void openVsSheet() async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _showBattleOptions();
      },
    );
  }

  Widget _showBattleOptions() {
    Size size = MediaQuery.sizeOf(context);
    bool isDark = QuickHelp.isDarkMode(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: StatefulBuilder(
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return ContainerCorner(
            radiusTopRight: 20.0,
            radiusTopLeft: 20.0,
            color: isDark ? kContentColorLightTheme : kWhitenDark,
            width: size.width,
            borderWidth: 0,
            onTap: () => QuickHelp.removeFocusOnTextField(context),
            child: IndexedStack(
              index: pagesIndex,
              children: [
                Scaffold(
                  backgroundColor: kTransparentColor,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    surfaceTintColor: kTransparentColor,
                    backgroundColor: kTransparentColor,
                    leadingWidth: 0.1,
                    title: TabBar(
                      isScrollable: true,
                      enableFeedback: false,
                      controller: generalTabControl,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: kTransparentColor,
                      unselectedLabelColor: kTabIconDefaultColor,
                      indicatorWeight: 2.0,
                      tabAlignment: TabAlignment.start,
                      overlayColor: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                        return states.contains(WidgetState.focused)
                            ? null
                            : Colors.transparent;
                      }),
                      labelPadding: EdgeInsets.symmetric(horizontal: 20),
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 3.0,
                          color:
                              isDark ? Colors.white : kContentColorLightTheme,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        insets: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: -8),
                      ),
                      automaticIndicatorColorAdjustment: false,
                      onTap: (index) {
                        setState(() {
                          tabIndex = index;
                        });
                      },
                      labelColor: isDark ? Colors.white : Colors.black,
                      labelStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      tabs: [
                        TextWithTap("pk_stuff.1v1_pk".tr()),
                        TextWithTap("pk_stuff.multi_pk".tr()),
                      ],
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(tabIndex == 5 ? 45 : 1),
                      child: Visibility(
                        visible: tabIndex == 5,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 5),
                          child: Row(
                            children: [
                              Flexible(
                                child: ContainerCorner(
                                  borderRadius: 10,
                                  height: 45,
                                  marginTop: 10,
                                  color: kGrayColor.withOpacity(0.15),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Center(
                                      child: TextFormField(
                                        controller: searchTextController,
                                        keyboardType: TextInputType.text,
                                        cursorColor: kGrayColor,
                                        autocorrect: false,
                                        onChanged: (text) {
                                          setState(() {
                                            searchText = text;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          errorMaxLines: 1,
                                          border: InputBorder.none,
                                          hintText: "pk_stuff.search_hint".tr(),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: SvgPicture.asset(
                                                "assets/svg/iamon_search.svg"),
                                          ),
                                          suffix: Visibility(
                                            visible: searchText.isNotEmpty,
                                            child: GestureDetector(
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.black,
                                                size: 20,
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  searchTextController.text =
                                                      "";
                                                  searchText = "";
                                                  keyUpdate = "dope";
                                                });
                                              },
                                            ),
                                          ),
                                          hintStyle: TextStyle(
                                            color:
                                                Colors.black.withOpacity(0.49),
                                            fontSize: 14,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: Colors.black,
                                          decorationStyle:
                                              TextDecorationStyle.solid,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: searchText.isNotEmpty,
                                child: ContainerCorner(
                                  height: 45,
                                  width: 45,
                                  color: kVioletColor,
                                  borderRadius: 50,
                                  marginTop: 10,
                                  marginLeft: 15,
                                  onTap: () {
                                    QuickHelp.removeFocusOnTextField(context);
                                    setState(() {
                                      isSearching = true;
                                      keyUpdate = searchTextController.text;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SvgPicture.asset(
                                      "assets/svg/iamon_search.svg",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    controller: generalTabControl,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      ListView(
                        children: [
                          ContainerCorner(
                            colors: [earnPointColor, earnCashColor],
                            height: 120,
                            width: size.width,
                            borderWidth: 0,
                            marginLeft: 10,
                            marginRight: 10,
                            borderRadius: 8,
                            marginTop: 15,
                            onTap: () {
                              setState(() {
                                pagesIndex = 1;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width / 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWithTap(
                                        "pk_stuff.matching_pattern".tr(),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        marginLeft: 10,
                                      ),
                                      TextWithTap(
                                        "pk_stuff.matching_pattern_explain"
                                            .tr(),
                                        color: Colors.white,
                                        marginLeft: 10,
                                        fontSize: 10,
                                        marginTop: 8,
                                        marginBottom: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      ContainerCorner(
                                        color: Colors.white,
                                        borderWidth: 0,
                                        borderRadius: 50,
                                        marginLeft: 10,
                                        child: TextWithTap(
                                          "pk_stuff.start_matching".tr(),
                                          color: kContentColorLightTheme,
                                          fontWeight: FontWeight.w400,
                                          marginLeft: 15,
                                          marginTop: 3,
                                          marginBottom: 3,
                                          marginRight: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Image.asset("assets/images/live_pk_blue.png")
                              ],
                            ),
                          ),
                          ContainerCorner(
                            colors: [kVioletColor, kPrimaryColor],
                            height: 120,
                            width: size.width,
                            borderWidth: 0,
                            marginLeft: 10,
                            marginRight: 10,
                            borderRadius: 8,
                            marginTop: 10,
                            onTap: () {
                              setState(() {
                                pagesIndex = 2;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width / 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWithTap(
                                        "pk_stuff.invitation_mode".tr(),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        marginLeft: 10,
                                      ),
                                      TextWithTap(
                                        "pk_stuff.invitation_mode_explain".tr(),
                                        color: Colors.white,
                                        marginLeft: 10,
                                        fontSize: 10,
                                        marginTop: 8,
                                        marginBottom: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      ContainerCorner(
                                        color: Colors.white,
                                        borderWidth: 0,
                                        borderRadius: 50,
                                        marginLeft: 10,
                                        child: TextWithTap(
                                          "pk_stuff.challenge_friends".tr(),
                                          color: kContentColorLightTheme,
                                          fontWeight: FontWeight.w400,
                                          marginLeft: 15,
                                          marginTop: 3,
                                          marginBottom: 3,
                                          marginRight: 15,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Image.asset(
                                      "assets/images/live_pk_invite.png"),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      getLives(),
                    ],
                  ),
                ),
                Scaffold(
                  backgroundColor: kTransparentColor,
                  appBar: AppBar(
                    surfaceTintColor: kTransparentColor,
                    backgroundColor: kTransparentColor,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    leading: BackButton(
                      onPressed: () {
                        setState(() {
                          pagesIndex = 0;
                        });
                      },
                    ),
                    title: TextWithTap(
                      "pk_stuff.system_match".tr(),
                    ),
                  ),
                  body: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40,
                          right: 40,
                          top: 30,
                          bottom: 30,
                        ),
                        child: Image.asset(
                          "assets/images/live_pk_search.png",
                        ),
                      ),
                      TextWithTap(
                        "pk_stuff.system_match_explain".tr(),
                        fontWeight: FontWeight.w600,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                        fontSize: size.width / 20,
                        marginRight: 20,
                        marginLeft: 20,
                      ),
                    ],
                  ),
                  bottomNavigationBar: ContainerCorner(
                    borderRadius: 50,
                    height: 45,
                    marginLeft: 15,
                    marginRight: 15,
                    borderWidth: 0,
                    marginBottom: 20,
                    marginTop: 10,
                    onTap: () {
                      QuickHelp.hideLoadingDialog(context);
                      startMatchingForPk();
                    },
                    colors: [kVioletColor, kSecondaryColor],
                    child: TextWithTap(
                      "pk_stuff.start_matching".tr(),
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Scaffold(
                  backgroundColor: kTransparentColor,
                  appBar: AppBar(
                    surfaceTintColor: kTransparentColor,
                    backgroundColor: kTransparentColor,
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    leading: BackButton(
                      onPressed: () {
                        setState(() {
                          pagesIndex = 0;
                        });
                      },
                    ),
                    title: TextWithTap(
                      "pk_stuff.challenge_friends".tr(),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(25),
                      child: TextWithTap(
                        "pk_stuff.challenge_friends_explain".tr(),
                        color: kGrayColor,
                        marginLeft: 15,
                        marginRight: 15,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  body: SizedBox(
                    width: size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/error_empty.png",
                          width: size.width / 4,
                        ),
                        TextWithTap(
                          "no_data".tr(),
                          marginTop: 10,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  startMatchingForPk() async {
    List<String> targetLivesId = [];
    QuickHelp.showLoadingDialog(context);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

    queryBuilder.whereNotEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId!);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyLiveType, LiveStreamingModel.liveVideo);
    queryBuilder.whereNotContainedIn(
        LiveStreamingModel.keyAuthorId, invitedUsers);
    queryBuilder.whereNotEqualTo(
        LiveStreamingModel.keyBattleStatus, LiveStreamingModel.battleAlive);
    queryBuilder.includeObject([LiveStreamingModel.keyAuthor]);

    ParseResponse response = await queryBuilder.query();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      for (LiveStreamingModel live in response.results!) {
        targetLivesId.add(live.getAuthorId!);
      }
      ZegoUIKitPrebuiltLiveStreamingController().pk.sendRequest(
            targetHostIDs: targetLivesId,
          );
      QuickHelp.showAppNotificationAdvanced(
        title: "matching_started_title".tr(),
        context: context,
        message: "matching_started_explain".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "no_result".tr(),
        context: context,
        message: "pk_stuff.no_lives".tr(),
      );
    }
  }

  Widget getLives() {
    Size size = MediaQuery.sizeOf(context);
    String emptyMessage = "pk_stuff.no_lives".tr();

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

    queryBuilder.whereNotEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId!);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyLiveType, LiveStreamingModel.liveVideo);
    queryBuilder.whereNotContainedIn(
        LiveStreamingModel.keyAuthorId, invitedUsers);
    queryBuilder.whereNotEqualTo(
        LiveStreamingModel.keyBattleStatus, LiveStreamingModel.battleAlive);
    queryBuilder.includeObject([LiveStreamingModel.keyAuthor]);
    if (searchText.isNotEmpty) {
      final intValue = int.tryParse(searchText);

      if (intValue != null) {
        queryBuilder.whereContains(
            LiveStreamingModel.keyAuthorUid, searchTextController.text);
      } else {
        queryBuilder.whereContains(LiveStreamingModel.keyAuthorUserName,
            searchTextController.text.trim());
      }
    }
    return ParseLiveListWidget<LiveStreamingModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      key: Key(keyUpdate),
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<LiveStreamingModel> snapshot) {
        if (snapshot.hasData) {
          LiveStreamingModel live = snapshot.loadedData!;

          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ContainerCorner(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickActions.avatarWidget(live.getAuthor!,
                          width: 45, height: 45),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ContainerCorner(
                              width: size.width / 3,
                              child: TextWithTap(
                                live.getAuthor!.getUsername!.capitalize,
                                fontSize: size.width / 23,
                                fontWeight: FontWeight.w700,
                                marginBottom: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWithTap(
                                  "tab_profile.id_".tr(),
                                  fontSize: 10,
                                ),
                                TextWithTap(
                                  live.getAuthorUid!.toString(),
                                  fontSize: 10,
                                  marginLeft: 3,
                                  marginRight: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ContainerCorner(
                    borderRadius: 8,
                    color: kVioletColor,
                    marginLeft: 10,
                    onTap: () {
                      QuickHelp.showLoadingDialog(context);
                      Future.delayed(Duration(seconds: 1)).then((value) {
                        QuickHelp.hideLoadingDialog(context);
                        ZegoUIKitPrebuiltLiveStreamingController()
                            .pk
                            .sendRequest(
                          targetHostIDs: [live.getAuthorId!],
                        );
                        updateBattleInviter();
                        QuickHelp.showAppNotificationAdvanced(
                            title: "battle_invitation".tr(),
                            message: "matching_started_explain".tr(),
                            context: context,
                            isError: false);
                        QuickHelp.hideLoadingDialog(context);
                      });
                      /*if (!invitedUsers.contains(live.getAuthorId!)) {
                        ZegoUIKitPrebuiltLiveStreamingController()
                            .pk
                            .sendRequest(
                          targetHostIDs: [live.getAuthorId!],
                        );
                        invitedUsers.add(live.getAuthorId!);
                        setState(() {});
                      }*/
                    },
                    child: TextWithTap(
                      invitedUsers.contains(live.getAuthorId!)
                          ? "..."
                          : "pk_stuff.invite_".tr(),
                      color: Colors.white,
                      marginLeft: 20,
                      marginRight: 20,
                      marginTop: 8,
                      marginBottom: 8,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        child: TextWithTap(
          emptyMessage,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  updateBattleInviter() {
    setState(() {
      imLiveInviter = true;
    });
  }

  updateBattleInvitee() {
    setState(() {
      imLiveInviter = false;
    });
  }
}
