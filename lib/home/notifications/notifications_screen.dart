// ignore_for_file: deprecated_member_use, unused_local_variable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/feed/comment_post_screen.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../ui/button_widget.dart';
import '../reels/reels_single_screen.dart';

// ignore_for_file: must_be_immutable
class NotificationsScreen extends StatefulWidget {
  static const String route = '/home/notifications';

  UserModel? currentUser;

  NotificationsScreen({this.currentUser});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationsModel> messages = [];

  @override
  void initState() {
    getAllMessages();
    super.initState();
  }

  getAllMessages() async{
    QueryBuilder<NotificationsModel> queryBuilder =
    QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(
        NotificationsModel.keyReceiver, widget.currentUser!);
    queryBuilder.orderByDescending(NotificationsModel.keyCreatedAt);

    queryBuilder.includeObject([
      NotificationsModel.keyAuthor,
      NotificationsModel.keyReceiver,
      NotificationsModel.keyPost,
      NotificationsModel.keyLive,
      NotificationsModel.keyLiveAuthor,
      NotificationsModel.keyPostAuthor,
    ]);

    queryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.result != null) {
        for (NotificationsModel message in parseResponse.results!) {
          if (!messages.contains(message)) {
            messages.add(message);
            setState(() {});
          }
        }
      }
    }

  }



  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context, "page_title.notifications_title".tr());
    Size size = MediaQuery.of(context).size;

    QueryBuilder<NotificationsModel> queryBuilder =
        QueryBuilder<NotificationsModel>(NotificationsModel());
    queryBuilder.whereEqualTo(
        NotificationsModel.keyReceiver, widget.currentUser!);
    queryBuilder.orderByDescending(NotificationsModel.keyCreatedAt);

    queryBuilder.includeObject([
      NotificationsModel.keyAuthor,
      NotificationsModel.keyReceiver,
      NotificationsModel.keyPost,
      NotificationsModel.keyLive,
      NotificationsModel.keyLiveAuthor,
      NotificationsModel.keyPostAuthor,
    ]);

    queryBuilder.whereNotEqualTo(
        NotificationsModel.keyAuthor, widget.currentUser!);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextWithTap(
            "interactive_messages_screen.interactive_messages".tr(),
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          leading: BackButton(
            color: kGrayColor,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: messages.isEmpty ? null : () => showAlert(),
                child: TextWithTap(
                  "interactive_messages_screen.clear_up".tr(),
                  color: messages.isEmpty ? kGrayDark : kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
        body: ContainerCorner(
          marginAll: 10,
          color: kTransparentColor,
          borderColor: kTransparentColor,
          width: size.width,
          height: size.height,
          child: ParseLiveListWidget<NotificationsModel>(
            query: queryBuilder,
            reverse: false,
            lazyLoading: false,
            shrinkWrap: true,
            duration: Duration(milliseconds: 200),
            childBuilder: (BuildContext context,
                ParseLiveListElementSnapshot<ParseObject> snapshot) {
              if (snapshot.failed) {
                return Text('not_connected'.tr());
              } else if (snapshot.hasData) {
                NotificationsModel notifications =
                    snapshot.loadedData! as NotificationsModel;

                return ButtonWidget(
                  color: notifications.isRead! ? kTransparentColor : kPrimaryColor.withOpacity(0.07),
                  marginBottom: 3,
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    String type = notifications.getNotificationType!;
                    UserModel user = notifications.getAuthor!;
                    PostsModel? post;
                    LiveStreamingModel? live;

                    if (notifications.getPost != null) {
                      post = notifications.getPost!;
                    }

                    if (notifications.getLive != null) {
                      live = notifications.getLive!;
                    }

                    _saveRead(notifications);

                    if (type == NotificationsModel.notificationTypeFollowers) {
                      QuickActions.showUserProfile(
                          context, widget.currentUser!,
                          user,
                      );
                    } else if (type ==
                        NotificationsModel.notificationTypeCommentPost) {
                      if (post == null) {
                        return;
                      }

                      if (post.isVideo!) {
                        QuickHelp.goToNavigatorScreen(
                            context,
                            ReelsSingleScreen(
                              currentUser: widget.currentUser,
                              post: post,
                            ),
                        );
                      } else {
                        QuickHelp.goToNavigatorScreen(
                          context, CommentPostScreen(
                          currentUser: widget.currentUser,
                          post: post,
                        ),
                        );
                      }
                    } else if (type ==
                            NotificationsModel.notificationTypeLikedReels ||
                        type ==
                            NotificationsModel.notificationTypeCommentReels) {
                      if (post == null) {
                        return;
                      }

                      QuickHelp.goToNavigatorScreen(
                        context,
                        ReelsSingleScreen(
                          currentUser: widget.currentUser,
                          post: post,
                        ),
                      );
                    } else if (type ==
                        NotificationsModel.notificationTypeLikedPost) {
                      if (post == null) {
                        return;
                      }

                      if (post.isVideo!) {
                        QuickHelp.goToNavigatorScreen(
                            context,
                            ReelsSingleScreen(
                              currentUser: widget.currentUser,
                              post: post,
                            ));
                      } else {
                        QuickHelp.goToNavigatorScreen(
                            context, CommentPostScreen(
                          currentUser: widget.currentUser,
                          post: post,
                        ),
                        );
                      }
                    } else if (type ==
                        NotificationsModel.notificationTypeLiveInvite) {
                      debugPrint("a reaparer...");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, right: 10),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  ContainerCorner(
                                    color: kTransparentColor,
                                    borderWidth: 0,
                                    height: 50,
                                    width: 50,
                                    child: QuickActions.avatarWidget(
                                      notifications.getAuthor!,
                                    ),
                                    onTap: () => _goToProfile(
                                      notifications.getAuthor!,
                                    ),
                                  ),
                                  if(notifications.getAuthor!.getAvatarFrame != null && notifications.getAuthor!.getCanUseAvatarFrame!)
                                  ContainerCorner(
                                    borderWidth: 0,
                                    width: 65,
                                    height: 65,
                                    child: CachedNetworkImage(
                                      imageUrl: notifications.getAuthor!.getAvatarFrame!.url!,
                                      imageBuilder: (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  "${notifications.getAuthor!.getFullName!}",
                                  color: kPrimaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  marginBottom: 8,
                                ),
                                notificationType(
                                    type: notifications.getNotificationType!),
                              ],
                            )
                          ],
                        ),
                        ContainerCorner(
                          height: 60,
                          width: 60,
                          child: notificationContent(notifications.getAuthor!,
                              notifications.getNotificationType!,
                              notification: notifications,
                              post: notifications.getPost,
                              live: notifications.getLive),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
            listLoadingElement: Center(
              child: CircularProgressIndicator(),
            ),
            queryEmptyElement: QuickActions.noContentFound(context),
          ),
          //onTap: () => _goToProfile(user!),
        ));
  }

  deleteInteractiveMessages() async{
    for (NotificationsModel message in messages) {
      await message.delete();
    }
    setState(() {
      messages.clear();
    });
  }

  showAlert() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWithTap(
                  "notifications_screen.clear_all_messages".tr(),
                  textAlign: TextAlign.center,
                  marginTop: 10,
                  marginBottom: 30,
                  fontSize: 16,
                ),
                ContainerCorner(width: size.width, height: 0.4, color: kGrayColor,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWidget(
                      marginLeft: 25,
                      onTap: () => QuickHelp.goBackToPreviousPage(context),
                      child: TextWithTap("no".tr()),
                    ),
                    ContainerCorner(width: 0.5, height: 20, color: kGrayColor,),
                    ButtonWidget(
                      marginRight: 25,
                      onTap: () {
                        QuickHelp.goBackToPreviousPage(context);
                        deleteInteractiveMessages();
                      },
                      child: TextWithTap("yes".tr()),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  _goToProfile(UserModel user) {
    QuickActions.showUserProfile(context, widget.currentUser!, user);
  }

  Widget notificationType({required String type}) {
    bool isDarkMode = QuickHelp.isDarkMode(context);

    if (type == NotificationsModel.notificationTypeFollowers) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/ic_followers.png",
            width: 15,
            height: 15,
          ),
          TextWithTap(
            "notifications_screen.started_follow_you".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      );
    } else if (type == NotificationsModel.notificationTypeLikedPost) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/svg/ic_post_clap.svg",
            color: kPrimaryColor,
            height: 15,
            width: 15,
          ),
          TextWithTap(
            "notifications_screen.liked_your_post".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ],
      );
    } else if (type == NotificationsModel.notificationTypeCommentPost) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/svg/uil_comment.svg",
            color: kPrimaryColor,
            height: 15,
            width: 15,
          ),
          TextWithTap(
            "notifications_screen.commented_post".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          )
        ],
      );
    } else if (type == NotificationsModel.notificationTypeLiveInvite) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset("assets/lotties/ic_live_animation.json",
              width: 15, height: 15),
          TextWithTap(
            "notifications_screen.live_invitation".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          )
        ],
      );
    } else if (type == NotificationsModel.notificationTypeLikedReels) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/svg/ic_heart.svg",
            color: kPrimaryColor,
            height: 15,
            width: 15,
          ),
          TextWithTap(
            "notifications_screen.liked_reels".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          )
        ],
      );
    } else if (type == NotificationsModel.notificationTypeCommentReels) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/svg/ic_post_comment.svg",
            color: kPrimaryColor,
            height: 15,
            width: 15,
          ),
          TextWithTap(
            "notifications_screen.commented_reels".tr().toLowerCase(),
            marginLeft: 5,
            fontSize: 12,
            color: isDarkMode ? Colors.white : Colors.black,
          )
        ],
      );
    }
    return Container();
  }

  Widget notificationContent(
    UserModel user,
    String type, {
    PostsModel? post,
    LiveStreamingModel? live,
    NotificationsModel? notification,
  }) {
    if (live != null) {
      return Stack(
        children: [
          ContainerCorner(
            borderWidth: 0,
            height: 60,
            width: 60,
            child: QuickActions.photosWidget(live.getImage!.url),
          ),
          ContainerCorner(
            borderWidth: 0,
            height: 60,
            width: 60,
            borderRadius: 8,
            color: Colors.black.withOpacity(0.4),
            child: Lottie.asset("assets/lotties/ic_live_animation.json"),
          ),
        ],
      );
    } else if (post != null) {
      if (post.getImagesList!.length > 0) {
        return ContainerCorner(
          borderWidth: 0,
          height: 60,
          width: 60,
          child: QuickActions.photosWidget(post.getImagesList![0]["url"]),
        );
      } else if (post.getVideo != null) {
        return Stack(
          children: [
            ContainerCorner(
              borderWidth: 0,
              height: 60,
              width: 60,
              child: QuickActions.photosWidget(post.getVideoThumbnail!.url),
            ),
            ContainerCorner(
              borderWidth: 0,
              height: 60,
              width: 60,
              borderRadius: 8,
              color: Colors.black.withOpacity(0.4),
              child: Icon(
                Icons.play_circle,
                color: Colors.white,
              ),
            ),
          ],
        );
      } else {
        return Container(
          height: 20,
          width: 20,
        );
      }
    } else if (type == NotificationsModel.notificationTypeFollowers) {
      return ContainerCorner(
        height: 60,
        width: 60,
        child: Padding(
          padding: const EdgeInsets.all(7.0),
          child: Image.asset(
            "assets/images/ic_followers.png",
          ),
        ),
      );
    }

    return Container(
      height: 20,
      width: 20,
    );
  }

  Widget notificationPreview() {
    return ContainerCorner();
  }

  _saveRead(NotificationsModel notifications) async {
    notifications.setRead = true;
    await notifications.save();
  }
}
