import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trace/home/controller/controller.dart';
import '../../helpers/quick_help.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import 'timer_controller.dart';

class BattleTimer extends StatefulWidget {
  final String roomID;

  BattleTimer({required this.roomID});

  @override
  _BattleTimerState createState() => _BattleTimerState();
}
Controller controller = Get.put(Controller());
class _BattleTimerState extends State<BattleTimer> {

  @override
  void initState() {
    super.initState();
    TimerController.initialize(roomID: widget.roomID, onTimerUpdate: _updateRemainingTime);
  }

  @override
  void dispose() {
    TimerController.dispose();
    super.dispose();
  }

  void _updateRemainingTime(int remainingTime) {
    controller.battleTimer.value = remainingTime;
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ContainerCorner(
            borderWidth: 0,
            borderRadius: 4,
            color: Colors.black38,
            child: TextWithTap(
              QuickHelp.formatTime(controller.battleTimer.value),
              color: Colors.white,
              fontWeight: FontWeight.w900,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
              fontSize: 15,
              marginLeft: 5,
              marginRight: 5,
              marginTop: 2,
              marginBottom: 2,
            ),
          ),
        ],
      );
    });
  }
}



/*
import 'package:flutter/material.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'dart:async';
import 'dart:convert';

import '../../helpers/quick_help.dart';
import '../../ui/text_with_tap.dart';

class BattleTimer extends StatefulWidget {
  final String roomID;

  BattleTimer({required this.roomID});

  @override
  _BattleTimerState createState() => _BattleTimerState();
}

class _BattleTimerState extends State<BattleTimer> {
  int _battleStartTime = 0;
  late StreamSubscription _subscription;
  Timer? _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _subscribeToCommands();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _timer?.cancel(); // Use ?. to avoid null errors
    super.dispose();
  }

  void _subscribeToCommands() {
    _subscription = ZegoUIKitPrebuiltLiveStreamingController().room.commandReceivedStream().listen((event) {
      for (var message in event.messages) {
        final commandString = utf8.decode(message.message);
        final command = jsonDecode(commandString);
        final startTime = command['startTime'];
        print('Command received: $commandString');
        _startTimer(startTime);
      }
    });
  }

  void _startTimer(int startTime) {
    setState(() {
      _battleStartTime = startTime;
      _remainingTime = _calculateRemainingTime();
      print('Timer started with start time: $_battleStartTime');
    });

    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _calculateRemainingTime();
        print('Remaining Time: $_remainingTime seconds');
        if (_remainingTime <= 0) {
          timer.cancel();
          print('Timer finished');
        }
      });
    });
  }

  int _calculateRemainingTime() {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final elapsedTime = currentTime - _battleStartTime;
    const battleDuration = 120;
    return battleDuration - elapsedTime;
  }

  void startLocalTimer() {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _startTimer(currentTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ContainerCorner(
          borderWidth: 0,
          borderRadius: 4,
          color: Colors.black38,
          child: TextWithTap(
            QuickHelp.formatTime(_remainingTime),
            color: Colors.white,
            fontWeight: FontWeight.w900,
            alignment: Alignment.center,
            textAlign: TextAlign.center,
            fontSize: 15,
            marginLeft: 5,
            marginRight: 5,
            marginTop: 2,
            marginBottom: 2,
          ),
        ),
      ],
    );
  }
}
*/
