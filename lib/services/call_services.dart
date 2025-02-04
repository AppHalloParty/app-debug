import 'package:trace/models/UserModel.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../app/setup.dart';

/// on App's user login
void onUserLogin(UserModel currentUser) {
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: Setup.zegoLiveStreamAppID,
    appSign: Setup.zegoLiveStreamAppSign /*input your AppSign*/,
    userID: currentUser.objectId!,
    userName: currentUser.getFullName!,
    plugins: [ZegoUIKitSignalingPlugin()],
  );
}

/// on App's user logout
void onUserLogout() {
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}