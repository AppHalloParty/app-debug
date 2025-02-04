// Flutter imports:
// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/utils/colors.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import '../../models/UserModel.dart';
UserModel? onlineUser;
Widget customAvatarBuilder(
  BuildContext context,
  Size size,
  ZegoUIKitUser? user,
  Map<String, dynamic> extraInfo,
) {
  debugPrint("User_veios id: ${user?.id} user $user extra ${extraInfo}");
  QueryBuilder userQuery = QueryBuilder(UserModel.forQuery());
  userQuery.whereEqualTo(UserModel.keyObjectId, user?.id);
  userQuery.setLimit(1);
  userQuery.query().then((response){
    if(response.success && response.results != null)
      onlineUser = response.results!.first;
  });

  if(onlineUser != null) {
    debugPrint("User_veios entrou: ${onlineUser}");
    return Stack(
      children: [
        QuickActions.avatarWidget(
            onlineUser!,
          width: size.width,
          height: size.height,
        ),
        ZegoAvatar(
          user: user, avatarSize: size,
          soundLevelColor: kPrimaryColor,
        )
      ],
    );
  }

  return Stack(children: [
    CachedNetworkImage(
      imageUrl: 'https://robohash.org/${user?.id}.png',
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.fill,
          ),
        ),
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      errorWidget: (context, url, error) {
        ZegoLoggerService.logInfo(
          '$user avatar url is invalid',
          tag: 'live audio',
          subTag: 'live page',
        );
        return ZegoAvatar(
            user: user, avatarSize: size,
          soundLevelColor: kPrimaryColor,
        );
      },
    ),
    // Lottie.asset('assets/avatars/4338 400-320.json'),
    // const SVGASimpleImage(assetsName: 'assets/avatars/1746.svga'),
  ]);
}
