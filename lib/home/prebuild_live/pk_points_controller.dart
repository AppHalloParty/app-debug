import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import '../controller/controller.dart';
Controller controller = Get.put(Controller());

class PointsController {
  static late StreamSubscription _subscription;

  static void initialize(String roomID, Function(int, int) onPointsUpdate) {
    _subscribeToCommands(roomID, onPointsUpdate);
  }

  static void dispose() {
    _subscription.cancel();
  }

  static void _subscribeToCommands(String roomID, Function(int, int) onPointsUpdate) {
    _subscription = ZegoUIKitPrebuiltLiveStreamingController().room.commandReceivedStream().listen((event) {
      for (var message in event.messages) {
        final commandString = utf8.decode(message.message);
        print('Raw command received: $commandString');
        try {
          final command = jsonDecode(commandString);
          if (command is Map<String, dynamic> && command.containsKey('hisBattlePoints') && command.containsKey('myPoints')) {
            final hisPoints = command['hisBattlePoints'];
            final myPoints = command['myPoints'];
            print('Command received: $commandString');
            if(hisPoints > 0){
              _updateHisPoints(hisPoints, onPointsUpdate);
            }

            if(myPoints > 0) {
              _updateMyPoints(myPoints, onPointsUpdate);
            }

          } else {
            print('Invalid command format');
          }
        } catch (e) {
          print('Error decoding command: $e');
        }
      }
    });
  }

  static void _updateHisPoints(int points, Function(int, int) onPointsUpdate) {
    controller.hisBattlePoints.value += points;
    onPointsUpdate(controller.myBattlePoints.value, controller.hisBattlePoints.value);
  }
  static void _updateMyPoints(int points, Function(int, int) onPointsUpdate) {
    controller.myBattlePoints.value += points;
    onPointsUpdate(controller.myBattlePoints.value, controller.hisBattlePoints.value);
  }

  static void sendPointsUpdate({required String roomID, required int hisPoints, required int myPoints}) async {
    final command = jsonEncode({'hisBattlePoints': hisPoints, 'myPoints': myPoints});
    final commandSent = await ZegoUIKitPrebuiltLiveStreamingController().room.sendCommand(
      roomID: roomID,
      command: Uint8List.fromList(utf8.encode(command)),
    );

    if (commandSent) {
      debugPrint('Points update sent: $command');
    } else {
      debugPrint('Failed to send points update');
    }
  }

  static void updateLocalPoints(int points, Function(int, int) onPointsUpdate) {
    controller.myBattlePoints.value += points;
    onPointsUpdate(controller.myBattlePoints.value, controller.hisBattlePoints.value);
  }
}
