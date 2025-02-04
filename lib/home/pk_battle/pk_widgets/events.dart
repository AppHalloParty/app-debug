// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:flutter/cupertino.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class PKEvents {
  const PKEvents(
      {required this.requestIDNotifier,
      required this.requestingHostsMapRequestIDNotifier,
      required this.liveStreaming,
      required this.onIncomingBattleRequest,
      required this.onUserJoined,
      required this.onOutgoingRequestAccepted});

  final ValueNotifier<String> requestIDNotifier;
  final ValueNotifier<Map<String, List<String>>>
      requestingHostsMapRequestIDNotifier;
  final LiveStreamingModel liveStreaming;

  //final ValueChanged<ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent>? onIncomingBattleRequest;
  //final ValueChanged<void Function()>? onIncomingBattleAction;
  final Function(ZegoLiveStreamingIncomingPKBattleRequestReceivedEvent,
      void Function())? onIncomingBattleRequest;
  final Function(ZegoLiveStreamingOutgoingPKBattleRequestAcceptedEvent,
      void Function())? onOutgoingRequestAccepted;
  final Function(ZegoUIKitUser)? onUserJoined;

  ZegoLiveStreamingPKEvents get event => ZegoLiveStreamingPKEvents(
        onIncomingRequestReceived: (event, defaultAction) {
          debugPrint('custom event, '
              'onIncomingPKBattleRequestReceived, event:$event ${event.fromHost.id}');
          onIncomingBattleRequest!(event, defaultAction);
        },
        onIncomingRequestCancelled: (event, defaultAction) {
          debugPrint(
              'custom event, onIncomingPKBattleRequestCancelled, event:$event');
          defaultAction.call();

          requestIDNotifier.value = '';

          removeRequestingHostsMap(event.requestID);
        },
        onIncomingRequestTimeout: (event, defaultAction) {
          debugPrint(
              'custom event, onIncomingPKBattleRequestTimeout, event:$event');
          defaultAction.call();

          requestIDNotifier.value = '';

          removeRequestingHostsMap(event.requestID);
        },
        onOutgoingRequestAccepted: (event, defaultAction) {
          debugPrint(
              'custom event, onOutgoingPKBattleRequestAccepted, event:$event');
          onOutgoingRequestAccepted!(event, defaultAction);
          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );
        },
        onOutgoingRequestRejected: (event, defaultAction) {
          debugPrint(
              'custom event, onOutgoingPKBattleRequestRejected, event:$event');
          defaultAction.call();

          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );
        },
        onOutgoingRequestTimeout: (event, defaultAction) {
          debugPrint(
              'custom event, onOutgoingPKBattleRequestTimeout, event:$event');

          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );

          defaultAction.call();
        },
        onEnded: (event, defaultAction) {
          debugPrint('custom event, onPKBattleEnded, event:$event');
          defaultAction.call();

          requestIDNotifier.value = '';
          updateBattleToLive();
          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );
        },
        onUserOffline: (event, defaultAction) {
          debugPrint('custom event, onUserOffline, event:$event');
          defaultAction.call();

          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );
        },
        onUserQuited: (event, defaultAction) {
          debugPrint('custom event, onUserQuited, event:$event');
          defaultAction.call();

          if (event.fromHost.id == ZegoUIKit().getLocalUser().id) {
            requestIDNotifier.value = '';
          }
          updateBattleToLive();
          removeRequestingHostsMapWhenRemoteHostDone(
            event.requestID,
            event.fromHost.id,
          );
        },
        onUserJoined: (ZegoUIKitUser user) {
          debugPrint('custom event, onUserJoined:$user');
          onUserJoined!(user);
          //updateLiveToBattle();
        },
        onUserDisconnected: (ZegoUIKitUser user) {
          debugPrint('custom event, onUserDisconnected:$user');
        },
        onUserReconnecting: (ZegoUIKitUser user) {
          debugPrint('custom event, onUserReconnecting:$user');
        },
        onUserReconnected: (ZegoUIKitUser user) {
          debugPrint('custom event, onUserReconnected:$user');
        },
      );

  void updateBattleToLive() {
    liveStreaming.setBattleStatus = LiveStreamingModel.battleEnded;
    liveStreaming.setMyBattlePoints = 0;
    liveStreaming.setHisBattlePoints = 0;
    liveStreaming.setMyBattleVictory = 0;
    liveStreaming.setHisBattleVictory = 0;
    liveStreaming.setRepeatBattleTimes = 0;
    liveStreaming.save();
  }

  void removeRequestingHostsMap(String requestID) {
    requestingHostsMapRequestIDNotifier.value.remove(requestID);

    requestingHostsMapRequestIDNotifier.notifyListeners();
  }

  void removeRequestingHostsMapWhenRemoteHostDone(
    String requestID,
    String fromHostID,
  ) {
    requestingHostsMapRequestIDNotifier.value[requestID]
        ?.removeWhere((requestHostID) => fromHostID == requestHostID);
    if (requestingHostsMapRequestIDNotifier.value[requestID]?.isEmpty ??
        false) {
      removeRequestingHostsMap(requestID);
    }

    requestingHostsMapRequestIDNotifier.notifyListeners();
  }
}
