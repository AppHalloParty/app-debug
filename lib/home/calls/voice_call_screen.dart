import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/app/navigation_service.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_cloud.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/home_screen.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../app/setup.dart';
import '../../helpers/send_notifications.dart';
import '../../models/CallsModel.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
import '../coins/coins_payment_widget.dart';

// ignore: must_be_immutable
class VoiceCallScreen extends StatefulWidget {

  static const String route = '/call/voice';

  UserModel? currentUser, mUser;
  bool? isCaller;

  String? channel;

  VoiceCallScreen({Key? key, this.currentUser, this.mUser, this.channel, this.isCaller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<VoiceCallScreen> {
  Timer? callPaymentTimer;
  int coinsUsed = 0;
  String callDuration = "00:00";
  String? credits = "0";
  String? diamonds = "0";
  StateSetter? screenState;LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  bool isJoined = false,
      isCallEnded = false,
      isConnected = false,
      previewAvailable = false,
      isCallAccepted = false,
      switchRender = true,
      switchAudio = false;

  List<int> remoteUid = [];

  @override
  void initState() {
    WakelockPlus.enable();

    QuickHelp.saveCurrentRoute(route: VoiceCallScreen.route);

    setState(() {
      credits = widget.currentUser!.getCredits!.toString();
      diamonds = widget.currentUser!.getDiamonds!.toString();
    });

    super.initState();
  }

  @override
  void dispose() async {
    WakelockPlus.disable();

    //context.read<CallsProvider>().setUserBusy(false);

    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }
    await _stopWatchTimer.dispose();
    callPaymentTimer?.cancel();
    super.dispose();
  }

  @override
  didChangeDependencies(){
    //context.dependOnInheritedWidgetOfExactType<ProviderInheritedWidget>();
    super.didChangeDependencies();
  }

  startTimerToEnd(){

    Future.delayed(Duration(seconds: Setup.callWaitingDuration), () {

      if(mounted){

        if(!isConnected) widget.isCaller == true ? endCallBtnCaller(CallsModel.CALL_END_REASON_OFFLINE) : endCallBtnReceiver();
      }

    });
  }

  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
    onChange: (value) => print('onChange $value'),
    onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
    onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
  );



  setupCallObserver(){
    print("AgoraCall setupCallObserver called");
    bool callRefused = 3==4;

    if (callRefused == true) {
      print("AgoraCall isCallRefused == true");

      //endCallRefused();
      if(mounted){
        endCallOffline(CallsModel.CALL_END_REASON_REFUSED);
      }
    }

  }

  initPaidTimer(){

    checkCredits(firstCheck: true);

    callPaymentTimer = Timer.periodic(Duration(seconds: 60), (timer) {

      checkCredits(firstCheck: false);
    });

  }

  checkCredits({bool? firstCheck}){

    print("callPaymentTimer checked $firstCheck");

    if(widget.currentUser!.getCredits! >= Setup.coinsNeededForVoiceCallPerMinute){

      widget.currentUser!.removeCredit = Setup.coinsNeededForVoiceCallPerMinute;
      widget.currentUser!.save().then((value) {

        coinsUsed = coinsUsed+Setup.coinsNeededForVoiceCallPerMinute;

        screenState!(() {
          credits = widget.currentUser!.getCredits.toString();
        });

        QuickCloudCode.sendGift(author: widget.mUser!, credits:  Setup.coinsNeededForVoiceCallPerMinute);
        widget.currentUser = value.results!.first! as UserModel;

        if(widget.currentUser!.getCredits! <= Setup.coinsNeededForVoiceCallPerMinute /2){

          QuickHelp.showAppNotificationAdvanced(
            title: "video_call.coins_run_out".tr(namedArgs: {"coins" : widget.currentUser!.getCredits!.toString()}),
            message: "video_call.coins_run_out_explain".tr(),
            context: context,
            isError: true,
          );
        }
      });


    } else {

      QuickHelp.showAppNotificationAdvanced(
          title: "video_call.no_coins".tr(),
          message: "video_call.coins_out_explain".tr(),
          context: context,
          isError: true
      );

      endCallBtnCaller(CallsModel.CALL_END_REASON_CREDITS);
    }
  }

  saveCallHistory({String? endReason}) async {

    CallsModel callsModel = CallsModel();

    callsModel.setAuthor = widget.currentUser!;
    callsModel.setAuthorId = widget.currentUser!.objectId!;

    callsModel.setReceiver = widget.mUser!;
    callsModel.setReceiverId = widget.mUser!.objectId!;

    callsModel.setAccepted = isCallAccepted;
    callsModel.setDuration = callDuration;

    callsModel.setCallEndReason = endReason!;
    callsModel.setIsVoiceCall = true;
    callsModel.setCoins = coinsUsed;

    await callsModel.save();
    saveMessage(callsModel);

  }

  saveMessage(CallsModel callsModel) async {

    MessageModel message = MessageModel();

    message.setAuthor = widget.currentUser!;
    message.setAuthorId = widget.currentUser!.objectId!;

    message.setReceiver = widget.mUser!;
    message.setReceiverId = widget.mUser!.objectId!;

    message.setDuration = MessageModel.messageTypeCall;
    message.setIsMessageFile = false;
    message.setCall = callsModel;

    message.setMessageType = MessageModel.messageTypeCall;

    message.setIsRead = false;

    await message.save();
    _saveList(message, callsModel);

    if(!isCallAccepted){

      SendNotifications.sendPush(
        widget.currentUser!,
        widget.mUser!,
        SendNotifications.typeMissedCall,
        message: "push_notifications.missed_call".tr(namedArgs: {"name":  widget.currentUser!.getFullName!}),
      );
    }

  }

  _saveList(MessageModel messageModel, CallsModel call) async {
    QueryBuilder<MessageListModel> queryFrom =
    QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyListId, widget.currentUser!.objectId! + widget.mUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
    QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyListId, widget.mUser!.objectId! + widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
    QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = widget.mUser!;
        messageListModel.setReceiverId = widget.mUser!.objectId!;
        messageListModel.setCall= call;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setIsRead = false;
        messageListModel.setListId = widget.currentUser!.objectId! + widget.mUser!.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = widget.mUser!;
        messageListModel.setReceiverId = widget.mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setCall = call;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;

        messageListModel.setListId = widget.currentUser!.objectId! + widget.mUser!.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    screenState = setState;
    setupCallObserver();

    setupCounterLive();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _renderVideo(),
          _topButtons(),
          _timerOnStartConversation(),
          _andOrRefuseCallButton(),
        ],
      ),
    );
  }

  _userInformation() {
    return Align(
      child: Padding(
        padding: EdgeInsets.only(top: 200),
        child: Column(
          children: [
            QuickActions.avatarWidget(widget.mUser!, width: 100, height: 100),
            TextWithTap(
              '${widget.mUser!.getFullName!}',
              textAlign: TextAlign.center,
              marginTop: 10,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            TextWithTap(
              callStatus(),
              textAlign: TextAlign.center,
              marginTop: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }


  String callStatus() {
    if (!previewAvailable) {
      return "video_call.on_call_connecting".tr();
    } else if (previewAvailable && !isCallAccepted) {
      return "video_call.on_calling".tr();
    } else if (isCallAccepted) {
      return "video_call.on_call_connected".tr();
    } else if (isCallEnded) {
      return "video_call.call_end_no_response".tr();
    }

    return "";
  }

  _topButtons() {
    return Padding(
      padding: EdgeInsets.only(top: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerCorner(
            height: 40,
            marginBottom: 10,
            marginTop: 10,
            borderRadius: 20,
            marginLeft: 10,
            color: Colors.black.withOpacity(0.5),
            onTap: widget.isCaller! ? _buyCredits : null,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10,bottom: 10, right: 10),
                  child: SvgPicture.asset(widget.isCaller! ? "assets/svg/coin.svg" : "assets/svg/dolar_diamond.svg" , height: 20, width: 20,),
                ),
                SizedBox(child: TextWithTap(widget.isCaller! ? credits! : diamonds!, color: Colors.white, marginRight: 15, fontSize: 17,)),
                Visibility(
                  visible: widget.isCaller!,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10,bottom: 10, right: 10),
                    child: SvgPicture.asset("assets/svg/ic_coin_with_star.svg", height: 24, width: 24,),
                  ),
                ),
              ],
            ),
          ),
          ContainerCorner(
            width: 40,
            height: 40,
            marginLeft: 10,
            marginRight: 10,
            borderRadius: 50,
            color: Colors.black.withOpacity(0.7),
            child: Icon(
              switchAudio ? Icons.mic : Icons.mic_off,
              size: 30,
              color: Colors.white,
            ),
            onTap: (){},
          ),
        ],
      ),
    );
  }

  _buyCredits(){

    CoinsFlowPayment(
      context: context,
      currentUser: widget.currentUser!,
      showOnlyCoinsPurchase: true,
      onCoinsPurchased: (tickets){
        print("onCoinsPurchased: $tickets new: ${widget.currentUser!.getCredits}");

        setState(() {
          credits = widget.currentUser!.getCredits.toString();
        });
      },
    );
  }

  _andOrRefuseCallButton() {
    return Align(
      child: ContainerCorner(
        width: 60,
        height: 60,
        marginLeft: 10,
        borderRadius: 50,
        color: Colors.red,
        marginBottom: 50,
        child: Icon(
          Icons.call_end,
          size: 45,
          color: Colors.white,
        ),
        onTap: () =>
        widget.isCaller == true ? endCallBtnCaller(CallsModel.CALL_END_REASON_END) : endCallBtnReceiver(),
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  _timerOnStartConversation() {
    return Visibility(
      visible: isConnected,
      child: Align(
        child: ContainerCorner(
          color: kTransparentColor,
          marginBottom: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamBuilder<int>(
                stream: _stopWatchTimer.secondTime,
                initialData: 0,
                builder: (context, snap) {
                  final value = snap.data;
                  callDuration = QuickHelp.formatTime(value!);
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: TextWithTap(
                          QuickHelp.formatTime(value),
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              Visibility(
                visible: isCallEnded,
                child: TextWithTap(
                  "video_call.on_call_end".tr(),
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextWithTap(
                widget.mUser!.getFullName!,
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              )
            ],
          ),
        ),
        alignment: Alignment.bottomCenter,
      ),
    );
  }

  _renderVideo() {
    return Stack(
      children: [
        Visibility(
          visible: true,
          child: ContainerCorner(
            color: kTransparentColor,
            borderWidth: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: QuickActions.photosWidget(widget.currentUser!.getAvatar!.url!,
                borderRadius: 0, fit: BoxFit.cover),
          ),
        ),
        Align(
          //alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _userInformation(),
              ],
            ),
          ),
        )
      ],
    );
  }

  endCallBtnCaller(String endReason) {
    setState(() {
      isCallEnded = true;
    });

    if(widget.isCaller!){
      saveCallHistory(endReason: endReason);
    }

    if (isCallAccepted) {
      if (isJoined) {
        debugPrint("...");
      }
    } else {
      debugPrint("...");
    }

    Future.delayed(Duration(seconds: 1), () {
      QuickHelp.goBackToPreviousPage(context);
    });
  }

  endCallBtnReceiver() {
    setState(() {
      isCallEnded = true;
    });

    if (isJoined) {
      debugPrint("...");
    }

    Future.delayed(Duration(seconds: 1), () {
      QuickHelp.goToNavigatorScreen(
          context,
          HomeScreen(
            currentUser: widget.currentUser,
          ), //route: HomeScreen.route,
      );
    });
  }

  endCallOffline(String reason) {

    debugPrint("...");

    setState(() {
      isCallEnded = true;
    });

    if(widget.isCaller!){
      saveCallHistory(endReason: reason);
    }

    debugPrint("...");

    Future.delayed(Duration(seconds: 1), () {
      if (widget.isCaller == true) {
        QuickHelp.goBackToPreviousPage(context);
      } else {
        QuickHelp.goToNavigatorScreen(
            context,
            HomeScreen(
              currentUser: widget.currentUser,
            ),
            //route: HomeScreen.route,
            finish: true,
            back: false);
      }
    });
  }

  endCallRefused() {
    setState(() {
      isCallEnded = true;
    });

    debugPrint("...");
    if (isCallEnded) {
      QuickHelp.goBackToPreviousPage(NavigationService.navigatorKey.currentState!.context);
    }
  }

  setupCounterLive() async {

    QueryBuilder<UserModel> query = QueryBuilder(UserModel.forQuery());
    query.whereEqualTo(UserModel.keyObjectId, widget.currentUser!.objectId);

    subscription = await liveQuery.client.subscribe(query);

    subscription!.on(LiveQueryEvent.update, (user) async {
      print('*** UPDATE ***');

      widget.currentUser = user as UserModel;

      setState(() {
        credits = widget.currentUser!.getCredits!.toString();
        diamonds = widget.currentUser!.getDiamonds!.toString();
      });

    });

    subscription!.on(LiveQueryEvent.enter, (user) {
      print('*** ENTER ***');

      widget.currentUser = user as UserModel;

      setState(() {
        credits = widget.currentUser!.getCredits!.toString();
        diamonds = widget.currentUser!.getDiamonds!.toString();
      });
    });

  }
}
