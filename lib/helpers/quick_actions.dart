import 'package:cached_network_image/cached_network_image.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/helpers/send_notifications.dart';
import 'package:trace/home/profile/user_profile_screen.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/ReportModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/widgets/AvatarInitials.dart';
import 'package:trace/widgets/need_resume.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class QuickActions {


  static Widget avatarWidgetNotification({double? width, double? height, EdgeInsets? margin, String? imageUrl, UserModel? currentUser, }) {

    if(imageUrl != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          //placeholder: (context, url) => _avatarInitials(currentUser),
          //errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    } else if (currentUser != null && currentUser.getAvatar != null) {
      return Container(
        margin: margin,
        width: width,
        height: height,
        child: CachedNetworkImage(
          imageUrl: currentUser.getAvatar!.url!,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          placeholder: (context, url) => _avatarInitials(currentUser),
          errorWidget: (context, url, error) => _avatarInitials(currentUser),
        ),
      );
    }  else {
      return Container();
    }
  }

  static Widget eventBgImage(String? imageUrl,
      {double? borderRadius = 8,
        BoxFit? fit = BoxFit.cover,
        double? width,
        double? height,
        EdgeInsets? margin}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl != null ? imageUrl : "",
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            //shape: boxShape!,
            borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => ContainerCorner(
            imageDecoration: "assets/images/rating_bg.png",
            width: width,
            height: height,
            borderRadius: borderRadius),
        errorWidget: (context, url, error) => ContainerCorner(
            imageDecoration: "assets/images/rating_bg.png",
            width: width,
            height: height,
            borderRadius: borderRadius),
      ),
    );
  }

  static Widget userState({required String state}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
            QuickHelp.getUserStatesIcon(state),
          height: state == UserModel.userLiving ? 35 :  13,
          width: state == UserModel.userLiving ? 35 :  13,
        ),
        TextWithTap(
            QuickHelp.getUserStatesByCode(state),
          fontSize: 9,
          marginLeft: 3,
        ),
      ],
    );
  }

  static Widget avatarWidget(UserModel currentUser, {
    double? width,
    double? height,
    EdgeInsets? margin,
    String? imageUrl,
    bool hideAvatarFrame = false,
    double frameWidth = 0.0,
    double frameHeight = 0.0,
    double? vipFrameWidth = 43,
    double? vipFrameHeight = 40,
  }) {
    if (currentUser.getAvatar != null) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            margin: margin,
            width: width,
            height: height,
            child: CachedNetworkImage(
              imageUrl: currentUser.getAvatar!.url!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => _avatarInitials(currentUser),
              errorWidget: (context, url, error) => _avatarInitials(currentUser),
            ),
          ),
          if (currentUser.getAvatarFrame != null &&
              !hideAvatarFrame &&
              currentUser.getCanUseAvatarFrame! &&
              currentUser.getAvatarFrame!.url!.toLowerCase().endsWith('.png'))
            ContainerCorner(
              borderWidth: 0,
              width: frameWidth,
              height: frameHeight,
              child: CachedNetworkImage(
                imageUrl: currentUser.getAvatarFrame!.url!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          if(!hideAvatarFrame && currentUser.getIsUserVip! && !currentUser.getCanUseAvatarFrame!)
            Container(
              margin: margin,
              child: Image.asset(
                QuickHelp.levelVipFrame(
                  currentCredit: currentUser.getCredits!.toDouble(),
                ),
                width: vipFrameWidth,
                height: vipFrameHeight,
              ),
            ),
        ],
      );
    } else if(imageUrl != null) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            margin: margin,
            width: width,
            height: height,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              //placeholder: (context, url) => _avatarInitials(currentUser),
              //errorWidget: (context, url, error) => _avatarInitials(currentUser),
            ),
          ),
          if(currentUser.getAvatarFrame != null && !hideAvatarFrame)
            Container(
              margin: margin,
              width: width! + 15,
              height: height! + 15,
              child: CachedNetworkImage(
                imageUrl: currentUser.getAvatarFrame!.url!,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      return _avatarInitials(currentUser);
    }
  }

  static Widget _avatarInitials(UserModel currentUser) {
    return AvatarInitials(
      name: '${currentUser.getFirstName}',
      textSize: 18,
      avatarRadius: 10,
      backgroundColor:
      QuickHelp.isDarkModeNoContext() ? Colors.white : kPrimaryColor,
      textColor: QuickHelp.isDarkModeNoContext()
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
    );
  }

  static Widget photosWidget(String? imageUrl, {
    double? borderRadius = 8, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl != null ? imageUrl : "",
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            //shape: boxShape!,
            borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => _loadingWidget(width: width, height: height, radius: borderRadius),
      ),
    );
  }

  static Widget pictureWithDifferentRadius(
      String? imageUrl, {
        BoxFit? fit = BoxFit.cover,
        double? width,
        double? height,
        EdgeInsets? margin,
        double? radiusTopRight = 0,
        double? radiusBottomRight = 0,
        double? radiusTopLeft = 0,
        double? radiusBottomLeft = 0,
        double? borderRadius = 0,
      }) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl != null ? imageUrl : "",
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(
                  borderRadius != null ? borderRadius : radiusTopRight!),
              bottomRight: Radius.circular(
                  borderRadius != null ? borderRadius : radiusBottomRight!),
              topLeft: Radius.circular(
                  borderRadius != null ? borderRadius : radiusTopLeft!),
              bottomLeft: Radius.circular(
                  borderRadius != null ? borderRadius : radiusBottomLeft!),
            ),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => _loadingWidget(width: width, height: height, radius: borderRadius),
      ),
    );
  }

  static Widget getGender({required UserModel currentUser, required BuildContext context}) {
    bool isMale = currentUser.getGender == UserModel.keyGenderMale;
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: isMale ? Colors.lightBlue : Colors.redAccent,
      borderRadius: 50,
      borderWidth: 0,
      marginBottom: 4,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMale ? Icons.male : Icons.female,
              color: Colors.white,
              size: size.width / 40,
            ),
            TextWithTap(
              QuickHelp.getAgeFromDate(currentUser.getBirthday!)
                  .toString(),
              color: Colors.white,
              fontSize: size.width / 40,
              marginLeft: 2,
              marginRight: 2,
            ),
          ],
        ),
      ),
    );
  }

  static Widget photosWidgetCircle(String imageUrl, {double? borderRadius = 8, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin, BoxShape? boxShape = BoxShape.rectangle, Widget? errorWidget}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: boxShape!,
            //borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => _loadingWidget(width: width, height: height, radius: borderRadius),
      ),
    );
  }

  static Widget profileAvatar(String imageUrl, {double? borderRadius = 0, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin, BoxShape? boxShape = BoxShape.rectangle}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            shape: boxShape!,
            //borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => SvgPicture.asset("assets/svg/ic_avatar.svg"),
      ),
    );
  }

  static Widget profileCover(String imageUrl, {double? borderRadius = 0, BoxFit? fit = BoxFit.cover, double? width, double? height, EdgeInsets? margin}) {
    return Container(
      margin: margin,
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            //shape: boxShape!,
            borderRadius: BorderRadius.circular(borderRadius!),
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => _loadingWidget(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) => Center(child: SvgPicture.asset("assets/svg/ic_avatar.svg"),),
      ),
    );
  }

  static Widget gifWidget(String imageUrl, {double? borderRadius = 8, BoxFit? fit = BoxFit.cover}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          //shape: BoxShape.circle,
          borderRadius: BorderRadius.circular(borderRadius!),
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
      placeholder: (context, url) => FadeShimmer(
        height: 80,
        width: 80,
        fadeTheme: QuickHelp.isDarkMode(context)
            ? FadeTheme.dark
            : FadeTheme.light,
        millisecondsDelay: 0,
      ),
      errorWidget: (context, url, error) => FadeShimmer(
        height: 80,
        width: 80,
        fadeTheme: QuickHelp.isDarkMode(context)
            ? FadeTheme.dark
            : FadeTheme.light,
        millisecondsDelay: 0,
      ),
    );
  }

  static Widget _loadingWidget({double? width, double? height, double? radius}){

   return FadeShimmer(
      width: width != null ? width : 60,
      height: height != null ? height : 60,
      radius: radius != null ? radius : 0,
      fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
    );
    //return Center(child: CircularProgressIndicator.adaptive());
  }

  static showUserProfile(
      BuildContext context,
      UserModel currentUser,
      UserModel user, {ResumableState? resumeState}
      ){
    QuickHelp.goToNavigatorScreen(context, UserProfileScreen(
        currentUser: currentUser, mUser: user,
        isFollowing: currentUser.getFollowing!.contains(user.objectId)));
  }

  static wealthLevel({required int credit, double? width, double? height}) {
    return Image.asset(
        QuickHelp.wealthLevel(creditSent: credit),
      height: height ?? 25,
      width: width ?? 50,
    );
  }

  static giftReceivedLevel({required int receivedGifts, double? width, double? height}) {
    return Image.asset(
      QuickHelp.receivedGiftsLevelIcon(receivedGift: receivedGifts),
      height: height ?? 25,
      width: width ?? 50,
    );
  }

  static Widget noContentFound(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return ContainerCorner(
      width: size.width,
      height: size.height,
      borderWidth: 0,
      child: Center(
          child: Image.asset(
            "assets/images/szy_kong_icon.png",
            height: size.width / 2,
          )),
    );
  }

  static Widget noContentFoundReels(String title, String explain,
      {MainAxisAlignment? mainAxisAlignment = MainAxisAlignment.center,
        CrossAxisAlignment? crossAxisAlignment = CrossAxisAlignment.center,
        double? imageWidth = 91,
        double? imageHeight = 91}) {
    return Column(
      mainAxisAlignment: mainAxisAlignment!,
      crossAxisAlignment: crossAxisAlignment!,
      children: [
        ContainerCorner(
          height: imageHeight,
          width: imageWidth,
          marginBottom: 20,
          color: kTransparentColor,
          child: Icon(Icons.refresh_rounded, size: 90, color: Colors.white,),
        ),
        TextWithTap(
          title,
          marginBottom: 0,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        TextWithTap(
          explain,
          marginLeft: 10,
          marginRight: 10,
          marginBottom: 17,
          marginTop: 5,
          fontSize: 14,
          textAlign: TextAlign.center,
          color: Colors.white,
        )
      ],
    );
  }

  static Widget avatarBorder(
    UserModel user, {
      double? width,
      double? height,
      EdgeInsets? avatarMargin,
      EdgeInsets? borderMargin,
      Color? borderColor = kPrimacyGrayColor,
      double? borderWidth = 1,
      double? vipFrameWidth = 43,
      double? vipFrameHeight = 40,
      bool hideAvatarFrame = false,
      }){

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        QuickActions.avatarWidget(
          user,
          width: width,
          height: height,
          margin: avatarMargin,
          vipFrameWidth: vipFrameWidth,
          vipFrameHeight: vipFrameHeight,
          hideAvatarFrame: hideAvatarFrame,
        ),
        if(!(user.getIsUserVip! && !user.getCanUseAvatarFrame!))
          Container(
            width: width, //160,
            height: height, //160,
            margin: borderMargin, //EdgeInsets.only(top: 10, bottom: 20, left: 30, right: 30),
            decoration: BoxDecoration(
              border: Border.all(
                width: borderWidth!,
                color: borderColor!,
              ),
              shape: BoxShape.circle,
            ),
            /*child: QuickActions.avatarWidget(
              user,
              width: width,
              height: height,
              margin: avatarMargin,
              vipFrameWidth: vipFrameWidth,
              vipFrameHeight: vipFrameHeight,
              hideAvatarFrame: hideAvatarFrame,
            ),*/
          ),
      ],
    );
  }

  static createOrDeleteNotification(UserModel currentUser, UserModel toUser, String type, {PostsModel? post, LiveStreamingModel? live}) async {

    QueryBuilder<NotificationsModel> queryBuilder = QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(NotificationsModel.keyAuthor, currentUser);
    queryBuilder.whereEqualTo(NotificationsModel.keyNotificationType, type);
    if(post != null){
      queryBuilder.whereEqualTo(NotificationsModel.keyPost, post);
    }

    ParseResponse parseResponse = await queryBuilder.query();

    if(parseResponse.success){

      if(parseResponse.results != null){

        NotificationsModel notification = parseResponse.results!.first;
        await notification.delete();

      } else {

        NotificationsModel notificationsModel = NotificationsModel();
        notificationsModel.setAuthor = currentUser;
        notificationsModel.setAuthorId = currentUser.objectId!;

        notificationsModel.setReceiver = toUser;
        notificationsModel.setReceiverId = toUser.objectId!;

        notificationsModel.setNotificationType = type;
        notificationsModel.setRead = false;

        if(post != null){
          notificationsModel.setPost = post;
        }

        if(live != null){
          notificationsModel.setLive = live;
        }

        await notificationsModel.save();

        if(post != null){

          if(post.getAuthorId != currentUser.objectId){
            if(post.getVideoThumbnail != null) {
              SendNotifications.sendPush(currentUser, toUser, type, objectId: post.objectId!, pictureURL: post.getVideoThumbnail!.url);
            }else if(post.getImagesList!.isNotEmpty){
              SendNotifications.sendPush(currentUser, toUser, type, objectId: post.objectId!, pictureURL: post.getImagesList![0]!.url);
            }else{
              SendNotifications.sendPush(currentUser, toUser, type, objectId: post.objectId!);
            }
          }
        } else if(live != null){
          SendNotifications.sendPush(currentUser, toUser, type, objectId: live.objectId!, pictureURL: live.getImage!.url);
        } else {
          SendNotifications.sendPush(currentUser, toUser, type);
        }
      }
    }
  }

  static Future<ParseResponse> report({required String type, required String message, String? description, required UserModel accuser, required UserModel accused, LiveStreamingModel? liveStreamingModel, PostsModel? postsModel}) async {

    ReportModel reportModel = ReportModel();

    reportModel.setReportType = type;

    reportModel.setAccuser = accuser;
    reportModel.setAccuserId = accuser.objectId!;

    reportModel.setAccused = accused;
    reportModel.setAccusedId = accused.objectId!;

    if(liveStreamingModel != null) reportModel.setLiveStreaming = liveStreamingModel;
    if(postsModel != null) reportModel.setPost = postsModel;

    reportModel.setMessage = message;
    if(description != null) reportModel.setDescription = description;

    return await reportModel.save();

  }

  static Widget getVideoPlaceHolder(String url, {bool adaptive = false, bool showLoading = false}){
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (ctx, value){
        if(showLoading){
          return adaptive ? CircularProgressIndicator.adaptive() : CircularProgressIndicator();
        } else {
          return Container();
        }
      },
    );
  }
  static Widget getImageFeed(BuildContext context, PostsModel post, {bool? cache = true}){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: cache!? CachedNetworkImage(
        imageUrl: post.isVideo!
            ? post.getVideoThumbnail!.url!
            : post.getImage!.url!,
        fit: BoxFit.contain,
        placeholder: (ctx, value){
          return FadeShimmer(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            fadeTheme: QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
          );
        },

      ) : Image.network(
        post.isVideo!
            ? post.getVideoThumbnail!.url!
            : post.getImage!.url!,
        fit: BoxFit.contain,
        loadingBuilder:
            (context, child, loadingProgress) {

          if(loadingProgress != null){
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Center(
                child: CircularProgressIndicator(
                  color: kPrimaryColor,
                ),
              ),
            );

          } else {
            return child;
          }
        },
      )
    );
  }

  static Widget getReelsImage(BuildContext context, PostsModel post, {bool? cache = true}){
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: cache!? CachedNetworkImage(
          imageUrl: post.isVideo!
              ? post.getVideoThumbnail!.url!
              : post.getImage!.url!,
          fit: BoxFit.contain,
          placeholder: (ctx, value){
            return FadeShimmer(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              fadeTheme: QuickHelp.isDarkMode(context) ? FadeTheme.dark : FadeTheme.light,
            );
          },

        ) : Image.network(
          post.isVideo!
              ? post.getVideoThumbnail!.url!
              : post.getImage!.url!,
          fit: BoxFit.contain,
          loadingBuilder:
              (context, child, loadingProgress) {

            if(loadingProgress != null){
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width,
                child: Center(
                  child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  ),
                ),
              );

            } else {
              return child;
            }
          },
        )
    );
  }

  static Widget getVideoPlayer(PostsModel post) {
    return Container();
    /*return BetterPlayerListVideoPlayer(
      BetterPlayerDataSource(
          BetterPlayerDataSourceType.network, post.getVideo!.url!,
          asmsTrackNames: []),
      //key: Key(post.getVideo!.hashCode.toString()),
      playFraction: 0.6,
      autoPlay: true,
      autoPause: true,
      //betterPlayerListVideoPlayerController: controller,
      configuration: BetterPlayerConfiguration(
        fit: BoxFit.fitHeight,
        looping: true,
        aspectRatio: 2/2,
        autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: true,
          showControlsOnInitialize: false,
          enableFullscreen: false,
          enableOverflowMenu: false,
          enableSkips: false,
          enableProgressBarDrag: false,
          enablePip: true,
          enableRetry: true,
          enablePlayPause: false,
          enablePlaybackSpeed: false,
          enableProgressText: false,
          enableProgressBar: false,
          pipMenuIcon: Icons.picture_in_picture_alt,
          pauseIcon: Icons.pause_circle_outlined,
          playIcon: Icons.play_circle_outline,
        ),
        placeholder: QuickActions.photosWidget(
          post.getVideoThumbnail!.url!,
          borderRadius: 0,
          fit: BoxFit.contain,
        ),
        showPlaceholderUntilPlay: true,
        expandToFill: true,
        useRootNavigator: true,
      ),
    );*/
  }
}