// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:trace/models/UserModel.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../app/setup.dart';

class CallPage extends StatefulWidget {
  UserModel? currentUser;
  CallPage({
    this.currentUser,
    Key? key, required this.callID}) : super(key: key);
  final String callID;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltCall(
      appID: Setup.zegoLiveStreamAppID,
      appSign: Setup.zegoLiveStreamAppSign,
      userID: widget.currentUser!.objectId!,
      userName: widget.currentUser!.getFullName!,
      callID: widget.callID,
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      events: ZegoUIKitPrebuiltCallEvents(),
    );
  }
}
