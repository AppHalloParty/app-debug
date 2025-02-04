

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/profile/user_profile_screen.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../app/Config.dart';
import '../app/setup.dart';
import '../home/feed/comment_post_screen.dart';
import '../home/profile/profile_edit.dart';
import '../home/profile/profile_screen.dart';
import '../models/InvitedUsersModel.dart';
import '../models/LiveStreamingModel.dart';
import '../models/PostsModel.dart';
import '../models/UserModel.dart';

class DeepLinksService {
  static StreamSubscription<Map>? streamSubscription;
  static String keyPostShare = "post_share";
  static String keyProfileShare = "profile_share";
  static String keyEventShare = "event_share";
  static String keyShareAction = "share_action";
  static String keyObjectID = "object_id";
  static String keyObject = "object";
  static String keyFeature = "sharing";
  static String keyStage = "new share";

  static String keyIdentifier = Setup.appName;
  static String keyCanonicalUrl = Config.appOrCompanyUrl;
  static String keyTitle = "Your journey starts now..";
  static String keyLogoURL = "https://moj.jclpclaudio.com/demo/challenge/trace_icon.png";


  static listenToDeepLinks({
    required UserModel currentUser,
    required BuildContext context}) {
    String receivedAction = "";
    String receivedID = "";

    debugPrint("deep_links started..."
        "}");
    streamSubscription = FlutterBranchSdk.listSession().listen((data)  async{

      debugPrint("deep_links listening... data: ${data}");

      if(data[keyShareAction] != null) {
        receivedAction = data[keyShareAction];
      }

      if(data[keyShareAction] != null) {
        receivedID = data[keyObjectID];
      }

      if(receivedAction == keyPostShare) {
        QuickHelp.showLoadingDialog(context);

        QueryBuilder queryBuilder = QueryBuilder<PostsModel>(PostsModel());

        queryBuilder.whereEqualTo(PostsModel.keyObjectId, receivedID);
        queryBuilder.setLimit(1);
        queryBuilder.includeObject([
          PostsModel.keyAuthor,
          PostsModel.keyAuthorName,
          PostsModel.keyLastLikeAuthor,
          PostsModel.keyLastDiamondAuthor,
          PostsModel.keyTargetPeople
        ]);
        ParseResponse response = await queryBuilder.query();

        if (response.success && response.results != null) {
          QuickHelp.hideLoadingDialog(context);
          PostsModel post = response.results!.first;
          QuickHelp.goToNavigatorScreen(
            context,
            CommentPostScreen(
              post: post,
              currentUser: currentUser,
            ),
          );
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              title: "error".tr(),
              message: "not_connected".tr(),
              context: context);
        }
      }else if(receivedAction == keyProfileShare) {
        if(currentUser.objectId == receivedID) {
          QuickHelp.goToNavigatorScreen(
            context,
            ProfileScreen(
              currentUser: currentUser,
            ),
          );
        }else {
          QuickHelp.showLoadingDialog(context);

          QueryBuilder queryBuilder = QueryBuilder<UserModel>(UserModel.forQuery());

          queryBuilder.whereEqualTo(UserModel.keyObjectId, receivedID);
          queryBuilder.setLimit(1);
          ParseResponse response = await queryBuilder.query();

          if (response.success && response.results != null) {
            QuickHelp.hideLoadingDialog(context);
            UserModel user = response.results!.first;
            QuickHelp.goToNavigatorScreen(
              context,
              UserProfileScreen(
                mUser: user,
                currentUser: currentUser,
                isFollowing: currentUser.getFollowing!.contains(receivedID),
              ),
            );
          } else {
            QuickHelp.hideLoadingDialog(context);
            QuickHelp.showAppNotificationAdvanced(
                title: "error".tr(),
                message: "not_connected".tr(),
                context: context);
          }
        }

      }



      else if (keyStage == keyFeature) {
        QuickHelp.showLoadingDialog(context);

        QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

        queryBuilder.whereEqualTo(LiveStreamingModel.keyObjectId, "id");

        queryBuilder.includeObject([
          LiveStreamingModel.keyAuthor,
          LiveStreamingModel.keyAuthorInvited,
          LiveStreamingModel.keyPrivateLiveGift,
          LiveStreamingModel.keyAudioHostsList,
        ]);

        queryBuilder.whereNotEqualTo(
            LiveStreamingModel.keyAuthorUid, currentUser.getUid);

        queryBuilder.whereValueExists(LiveStreamingModel.keyAuthor, true);

        ParseResponse response = await queryBuilder.query();

        if (response.success && response.results != null) {
          QuickHelp.hideLoadingDialog(context);
          LiveStreamingModel liveStreamingModel = response.results!.first;

          if (currentUser.getAvatar == null) {
            QuickHelp.showDialogLivEend(
              context: context,
              dismiss: true,
              title: 'live_streaming.photo_needed'.tr(),
              confirmButtonText: 'live_streaming.add_photo'.tr(),
              message: 'live_streaming.photo_needed_explain'.tr(),
              onPressed: () {
                QuickHelp.goBackToPreviousPage(context);
                QuickHelp.goToNavigatorScreen(
                  context,
                  ProfileEdit(
                    currentUser: currentUser,
                  ),
                );
              },
            );
          } else if (liveStreamingModel.getPartyType == null) {
            debugPrint("Live go...");
          } else if (liveStreamingModel.getPartyType ==
              LiveStreamingModel.liveVideo) {
            debugPrint("Live go...");
          } else {
            debugPrint("Live go...");
          }
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              title: "error".tr(),
              message: "not_connected".tr(),
              context: context);
        }
      }







      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
        //Link clicked. Add logic to get link data
        print('Custom string: ${data["custom_string"]}');
      }
    }, onError: (error) {
      print('listSession error: ${error.toString()}');
    },
      onDone: () {
        print('listSession done');
      },
    );
  }

  getFirstInstall() async{
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getFirstReferringParams();
    debugPrint("telefone: ${params}");
  }

  getOpenOrInstall() async{
    Map<dynamic, dynamic> params = await FlutterBranchSdk.getLatestReferringParams();
    debugPrint("telefone: ${params}");
  }

  static BranchUniversalObject branchObject({
    required String shareAction,
    required String objectID,
    String? imageURL,
    String? title,
    String? description,
}) {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: keyIdentifier,
      canonicalUrl: keyCanonicalUrl,
      title: title ?? keyTitle,
      imageUrl: imageURL ?? keyLogoURL,
      contentDescription: description ?? shareAction,
      keywords: [keyIdentifier, shareAction, keyTitle],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata(keyShareAction, shareAction)
        ..addCustomMetadata(keyObjectID, objectID)
    );
    return buo;
  }

  static BranchLinkProperties linkProperties({required String channel}) {
    BranchLinkProperties lp = BranchLinkProperties(
      //alias: 'iamon_chancilson', //define link url,
        channel: channel,
        feature: keyFeature,
        stage: keyStage,
        tags: [keyIdentifier, channel, keyTitle]
    );
    return lp;
  }

  static Future<String> createLink({required BranchUniversalObject branchObject,
    required BranchLinkProperties branchProperties, required BuildContext context}) async{
    QuickHelp.showLoadingDialog(context);

    BranchResponse response =
        await FlutterBranchSdk.getShortUrl(
            buo: branchObject,
            linkProperties: branchProperties,
        );
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      debugPrint('Link_generated: ${response.result}');
      return "${response.result}";
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "error".tr(),
          context: context,
        message: "settings_screen.app_could_not_gen_uri".tr()
      );
      debugPrint('Link_generated Error : ${response.errorCode} - ${response.errorMessage}');
      return "";
    }
  }

  static shareLink() async{
    BranchResponse response = await FlutterBranchSdk.showShareSheet(
        buo: branchObject(shareAction: keyProfileShare, objectID: "dxrFmumi5k",),
        linkProperties: linkProperties(channel: "facebook"),
        messageText: 'My Share text',
        androidMessageTitle: 'My Message Title',
        androidSharingTitle: 'My Share with');

    if (response.success) {
      print('showShareSheet Sucess');
    } else {
      print('Error : ${response.errorCode} - ${response.errorMessage}');
    }
  }

  registerInviteBy(
      UserModel currentUser, String inviteeId, BuildContext context) async {
    QuickHelp.showLoadingDialog(context);

    QueryBuilder<UserModel> queryFrom =
    QueryBuilder<UserModel>(UserModel.forQuery());

    queryFrom.whereEqualTo(UserModel.keyId, inviteeId);

    ParseResponse apiResponse = await queryFrom.query();

    if (apiResponse.success) {
      if (apiResponse.results != null) {
        InvitedUsersModel invitedUsersModel = InvitedUsersModel();

        invitedUsersModel.setAuthor = currentUser;
        invitedUsersModel.setAuthorId = currentUser.objectId!;

        invitedUsersModel.setInvitedBy =
        apiResponse.results!.first! as UserModel;
        invitedUsersModel.setInvitedById = inviteeId;

        invitedUsersModel.setValidUntil =
            DateTime.now().add(Duration(days: 730));
        ParseResponse response = await invitedUsersModel.save();

        if (response.success) {
          currentUser.setInvitedByAnswer = true;
          currentUser.setInvitedByUser = inviteeId;

          ParseResponse user = await currentUser.save();
          if (user.success) {
            currentUser = user.results!.first! as UserModel;
          }
        }
      }
    }
  }

}


