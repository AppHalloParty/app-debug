import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/models/UserModel.dart';

import '../app/Config.dart';

class SendNotifications {

  static final String pushNotificationSendParam = "sendPush";

  static final String pushNotificationInstallation = "installation";
  static final String pushNotificationSender = "senderId";
  static final String pushNotificationSenderName = "senderName";
  static final String pushNotificationReceiver = "receiverId";
  static final String pushNotificationTitle = "title";
  static final String pushNotificationAlert = "alert";
  static final String pushNotificationSenderAvatar = "avatar";
  static final String pushNotificationChat = "chat";
  static final String pushNotificationType = "type";
  static final String pushNotificationObjectId = "objectId";
  static final String pushNotificationViewGroup = "view";
  static final String pushNotificationFollowers = "followers";
  static const String typeStory = "newStory";
  static const String typePost = "newPost";

  static const String pushNotificationBigPicture = "big_picture";
  static const String pushNotificationLargeIcon = "large_icon";

  static final String typeChat = "chat";
  static final String typeProfileVisit = "profileVisit";
  static final String typeMissedCall = "missedCall";
  static final String typeLive = "live";
  static final String typeLiveInvite = "liveInvite";
  static final String typeLike = "postLiked";
  static final String typeComment = "postComment";
  static final String typeReplyComment = "replyPostComment";
  static final String typeFollow = "followers";
  static final String typeGift = "postGift";
  static final String typeLikedReels = "reelsLiked";
  static final String typeCommentReels = "reelsComment";


  static void sendPush(UserModel fromUser, UserModel toUser, String type,
      {String? message, String? objectId, String? pictureURL}) async{


    ParseCloudFunction function = ParseCloudFunction(pushNotificationSendParam);

    Map<String, dynamic> params = <String, dynamic> {
      pushNotificationReceiver: toUser.objectId,
      pushNotificationSender: fromUser.objectId,
      pushNotificationSenderName : fromUser.getFullName,
      pushNotificationSenderAvatar: fromUser.getAvatar != null ? fromUser.getAvatar?.url: "",
      pushNotificationTitle: getTitle(type, name: fromUser.getFullName),
      pushNotificationAlert: getMessage(type, name: fromUser.getFullName, chat: message),
      pushNotificationViewGroup: getViewGroup(type),
      pushNotificationChat: message != null ? message : "",
      pushNotificationType: type,
      pushNotificationObjectId: objectId != null ? objectId : "",
      pushNotificationFollowers: fromUser.getFollowers,
      pushNotificationBigPicture: pictureURL ?? "",
      pushNotificationLargeIcon: fromUser.getAvatar!.url ?? "",
    };

    if(type == typeLive && toUser.getLiveNotification!){
      await function.execute(parameters: params);

    } else {
      await function.execute(parameters: params);
    }
  }

  static String getTitle(String type, {String? name}){

    if(type == typeChat){
      return "push_notifications.new_message".tr(namedArgs: {"name": name!});

    } else if(type == typeLive){
      return "push_notifications.started_new_title".tr(namedArgs: {"name": name!});

    } else if(type == typeLike){
      return "push_notifications.new_like".tr();

    } else if(type == typeComment){
      return "push_notifications.new_comment".tr();

    } else if(type == typeFollow){
      return "push_notifications.new_follow_title".tr();

    } else if(type == typeLiveInvite){
      return "push_notifications.invited_you_title".tr();

    } else if(type == typeMissedCall){
      return "push_notifications.missed_call_title".tr();

    } else if(type == typeLikedReels){
      return "push_notifications.new_like_reels".tr();

    } else if(type == typeCommentReels){
      return "push_notifications.new_comment_reels".tr();

    }else if (type == typeStory) {
      return "push_notifications.story_creation_title"
          .tr(namedArgs: {"name": Config.appName});
    }else if (type == typePost) {
      return "push_notifications.post_creation_title"
          .tr(namedArgs: {"name": Config.appName});
    }else if(type == typeReplyComment) {
      return "push_notifications.comment_reply_title".tr();
    }else if(type == typeProfileVisit){
      return "push_notifications.profile_visit_title".tr();
    }

    return "";
  }

  static String getMessage(String type, {String? name, String? chat}){

    if(type == typeChat){
      return chat!;

    } else if(type == typeLive){
      return "push_notifications.started_live".tr(namedArgs: {"name": name!});

    } else if(type == typeLike){
      return "push_notifications.liked_your_post".tr(namedArgs: {"name": name!});

    } else if(type == typeComment){
      return "push_notifications.commented_post".tr(namedArgs: {"name": name!});

    } else if(type == typeFollow){
      return "push_notifications.started_follow_you".tr(namedArgs: {"name": name!});

    } else if(type == typeLiveInvite){
      return "push_notifications.invited_you".tr(namedArgs: {"name": name!});

    } else if(type == typeMissedCall){
      return "push_notifications.missed_call".tr(namedArgs: {"name": name!});

    } else if(type == typeLikedReels){
      return "push_notifications.liked_your_reels".tr(namedArgs: {"name": name!});

    } else if(type == typeCommentReels){
      return "push_notifications.commented_reels".tr(namedArgs: {"name": name!});

    }else if (type == typeStory) {
      return "push_notifications.story_creation".tr(namedArgs: {"name": name!});
    }else if (type == typePost) {
      return "push_notifications.post_creation".tr(namedArgs: {"name": name!});
    }else if(type == typeReplyComment) {
      return "push_notifications.comment_reply_explain".tr(namedArgs: {"name": name!});
    }else if(type == typeProfileVisit){
      return "push_notifications.profile_visit_explain".tr(namedArgs: {"name": name!});
    }

    return "";
  }

  static String getViewGroup(String type){

    if(type == typeChat){
      return type;

    } else if(type == typeLive){
      return type;

    } else if(type == typeLike){
      return type;

    } else if(type == typeComment){
      return type;

    } else if(type == typeFollow){
      return type;

    } else if(type == typeLiveInvite){
      return type;

    }  else if(type == typeMissedCall){
      return type;

    } else if(type == typeLikedReels){
      return type;

    } else if(type == typeCommentReels){
      return type;

    }else if (type == typeStory) {
      return type;

    }else if (type == typePost) {
      return type;
    }else if (type == typeReplyComment) {
      return type;
    }else if (type == typeProfileVisit) {
      return type;
    }

    return "";
  }
}