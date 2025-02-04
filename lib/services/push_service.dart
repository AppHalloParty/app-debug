import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../app/config.dart';
import '../helpers/quick_actions.dart';
import '../helpers/quick_help.dart';
import '../helpers/send_notifications.dart';
import '../home/feed/comment_post_screen.dart';
import '../home/message/message_screen.dart';
import '../home/prebuild_live/multi_users_live_screen.dart';
import '../home/prebuild_live/prebuild_audio_room_screen.dart';
import '../home/prebuild_live/prebuild_live_screen.dart';
import '../home/profile/user_profile_screen.dart';
import '../home/reels/reels_single_screen.dart';
import '../models/LiveStreamingModel.dart';
import '../models/PostsModel.dart';
import '../models/UserModel.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushService {
  UserModel? currentUser;
  BuildContext? context;

  PushService({
    required this.currentUser,
    required this.context,
  });

  Future initialise() async {

    //Remove this method to stop OneSignal Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(Config.oneSignalAppId);
    OneSignal.Notifications.requestPermission(true);

    int clicked = 0;
    // When you click in push
    OneSignal.Notifications.addClickListener((event){
      //debugPrint("Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}");
      if(clicked == 0) {
        clicked = 1;
        _decodePushMessage(event.notification.additionalData!, context!);
        Future.delayed(Duration(seconds: 5)).then((value){
          clicked = 0;
        });
      }

    });

    OneSignal.Notifications.clearAll();

    OneSignal.User.addObserver((state) {
      var userState = state.jsonRepresentation();
      print('OneSignal user changed: $userState');
    });

    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');

      /// Display Notification, preventDefault to not display
      event.preventDefault();

      /// Do async work

      /// notification.display() to display after preventing default
      event.notification.display();
      debugPrint("Clicked notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}");

    });

  }

  _decodePushMessage(Map<String, dynamic> message, BuildContext context) async {
    UserModel? mUser;
    PostsModel? mPost;
    LiveStreamingModel? mLive;

    //var data = message["data"];
    //Map notification = json.decode(data);

    print("Push Notification: onBackgroundMessage $message");

    var type = message[SendNotifications.pushNotificationType];
    var senderId = message[SendNotifications.pushNotificationSender];
    var objectId = message[SendNotifications.pushNotificationObjectId];

    if (type == SendNotifications.typeChat) {
      QueryBuilder<UserModel> queryUser =
          QueryBuilder<UserModel>(UserModel.forQuery());
      queryUser.whereEqualTo(UserModel.keyObjectId, senderId);

      ParseResponse parseResponse = await queryUser.query();
      if (parseResponse.success && parseResponse.results != null) {
        mUser = parseResponse.results!.first! as UserModel;
      }

      if (currentUser != null && mUser != null) {
        _gotToChat(currentUser!, mUser, context);
      }
    } else if (type == SendNotifications.typeLive ||
        type == SendNotifications.typeLiveInvite) {
      QueryBuilder<LiveStreamingModel> queryPost =
          QueryBuilder<LiveStreamingModel>(LiveStreamingModel());
      queryPost.whereEqualTo(LiveStreamingModel.keyObjectId, objectId);
      queryPost.includeObject([LiveStreamingModel.keyAuthor]);

      ParseResponse parseResponse = await queryPost.query();
      if (parseResponse.success && parseResponse.results != null) {
        mLive = parseResponse.results!.first! as LiveStreamingModel;
      }

      if (currentUser != null && mLive != null) {
        _goToLive(currentUser!, mLive, context);
      }
    } else if (type == SendNotifications.typeFollow ||
        type == SendNotifications.typeMissedCall ||
        type == SendNotifications.typeProfileVisit ||
        type == SendNotifications.typeLike) {

      QuickHelp.showLoadingDialog(context);
      QueryBuilder<UserModel> queryUser =
      QueryBuilder<UserModel>(UserModel.forQuery());
      queryUser.whereEqualTo(UserModel.keyObjectId, senderId);
      queryUser.setLimit(1);

      ParseResponse parseResponse = await queryUser.query();
      if (parseResponse.success && parseResponse.results != null) {
        QuickHelp.hideLoadingDialog(context);
        mUser = parseResponse.results!.first! as UserModel;
      }else{
        QuickHelp.hideLoadingDialog(context);
      }

      if (currentUser != null && mUser != null) {
        QuickHelp.goToNavigatorScreen(
          context,
          UserProfileScreen(
            currentUser: currentUser,
            isFollowing: currentUser!.getFollowing!.contains(mUser.objectId),
            mUser: mUser,
          ),
        );
      }
    } else if (type == SendNotifications.typeLike ||
        type == SendNotifications.typeComment || type == SendNotifications.typeReplyComment) {
      QueryBuilder<PostsModel> queryPost =
          QueryBuilder<PostsModel>(PostsModel());
      queryPost.whereEqualTo(PostsModel.keyObjectId, objectId);
      queryPost.includeObject([PostsModel.keyAuthor]);

      ParseResponse parseResponse = await queryPost.query();
      if (parseResponse.success && parseResponse.results != null) {
        mPost = parseResponse.results!.first! as PostsModel;
      }

      if (currentUser != null && mPost != null) {
       if(mPost.isVideo!){
         _goToReels(currentUser!, mPost, context);
       } else {
         _goToPost(currentUser!, mPost, context);
       }
      }

    } else if (type == SendNotifications.typeFollow ||
        type == SendNotifications.typeMissedCall) {
      QueryBuilder<UserModel> queryUser =
          QueryBuilder<UserModel>(UserModel.forQuery());
      queryUser.whereEqualTo(UserModel.keyObjectId, senderId);

      ParseResponse parseResponse = await queryUser.query();
      if (parseResponse.success && parseResponse.results != null) {
        mUser = parseResponse.results!.first! as UserModel;
      }

      if (currentUser != null && mUser != null) {
        QuickActions.showUserProfile(
            context,
            currentUser!,
            mUser);
      }
    }

    print("Push Notification data: $message");
  }

  _gotToChat(UserModel currentUser, UserModel mUser, BuildContext context) {
    QuickHelp.goToNavigatorScreen(
      context,
      MessageScreen(
        currentUser: currentUser,
        mUser: mUser,
      ),
    );
  }

  _goToPost(UserModel currentUser, PostsModel mPost, BuildContext context) {
    QuickHelp.goToNavigatorScreen(
      context,
      CommentPostScreen(
        currentUser: currentUser,
        post: mPost,
      ),
    );
  }

  _goToReels(UserModel currentUser, PostsModel mPost, BuildContext context) {
    QuickHelp.goToNavigatorScreen(context, ReelsSingleScreen(currentUser: currentUser, post: mPost,));
  }

  _goToLive(UserModel currentUser, LiveStreamingModel liveStreaming, BuildContext context) {
    if (ZegoUIKitPrebuiltLiveStreamingController()
        .minimize
        .isMinimizing) {
      return;
    }
    if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveVideo) {
      QuickHelp.goToNavigatorScreen(
        context,
        PreBuildLiveScreen(
          isHost: false,
          currentUser: currentUser,
          liveStreaming: liveStreaming,
          liveID:
          liveStreaming.getStreamingChannel!,
          localUserID: currentUser.objectId!,
        ),
      );
    } else if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveAudio) {
      QuickHelp.goToNavigatorScreen(
          context,
          PrebuildAudioRoomScreen(
            currentUser: currentUser,
            isHost: false,
            liveStreaming: liveStreaming,
          ));
    } else if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveTypeParty) {
      QuickHelp.goToNavigatorScreen(
        context,
        MultiUsersLiveScreen(
          isHost: false,
          currentUser: currentUser,
          liveStreaming: liveStreaming,
          liveID:
          liveStreaming.getStreamingChannel!,
          localUserID: currentUser.objectId!,
        ),
      );
    }
  }
}
