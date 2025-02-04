// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trace/models/LiveStreamingModel.dart';

import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/EventsModel.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../services/deep_links_service.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../prebuild_live/multi_users_live_screen.dart';
import '../prebuild_live/prebuild_audio_room_screen.dart';
import '../prebuild_live/prebuild_live_screen.dart';
import '../profile/user_profile_screen.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart'
as zego;

TextEditingController searchTextController = TextEditingController();

showGlobalSearch({
  required BuildContext context,
  required UserModel currentUser,
  required bool onlyEvent,
  required bool onlyLives,
  required bool onlyUsers,
}) {
  bool searching = false;
  bool noResult = false;
  EventsModel? searchedEvent;
  PostsModel? searchedChallie;
  List<LiveStreamingModel> livesList = [];
  var livesIdsList = [];

  List<UserModel> usersList = [];
  var usersIdsList = [];

  Size size = MediaQuery.sizeOf(context);
  searchTextController.text = "";
  showDialog(
    context: context,
    barrierColor: kTransparentColor,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, newState) {

        searchLives() async {
          QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
          queryUsers.whereValueExists(UserModel.keyUserStatus, true);
          queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

          QueryBuilder<LiveStreamingModel> queryBuilder = QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

          queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
          queryBuilder.whereNotEqualTo(
              LiveStreamingModel.keyAuthorUid, currentUser.getUid);
          queryBuilder.whereNotContainedIn(
              LiveStreamingModel.keyAuthor, currentUser.getBlockedUsers!);
          queryBuilder.whereValueExists(LiveStreamingModel.keyAuthor, true);
          queryBuilder.whereDoesNotMatchQuery(
              LiveStreamingModel.keyAuthor, queryUsers);
          queryBuilder.whereContains(LiveStreamingModel.keyAudioRoomTitle, searchTextController.text);
          queryBuilder.includeObject([
            LiveStreamingModel.keyAuthor,
            LiveStreamingModel.keyAuthorInvited,
            LiveStreamingModel.keyPrivateLiveGift
          ]);
          queryBuilder.setLimit(20);
          ParseResponse response = await queryBuilder.query();
          newState(() {
            if (response.success) {
              searching = false;
              if (response.results != null) {
                for (LiveStreamingModel live in response.results!) {
                  if(!livesIdsList.contains(live.objectId)) {
                    livesList.add(live);
                    livesIdsList.add(live.objectId);
                  }
                }
              } else {
                noResult = true;
              }
            } else {
              noResult = true;
              searching = false;
            }
            searchTextController.text = "";
          });
        }

        searchChallie() async {
          QueryBuilder<PostsModel> query =
              QueryBuilder<PostsModel>(PostsModel());

          query.whereEqualTo(UserModel.keyObjectId, searchTextController.text);
          query.setLimit(1);
          ParseResponse response = await query.query();
          newState(() {
            if (response.success) {
              searching = false;
              if (response.results != null) {
                searchedChallie = response.results!.first;
              } else {
                noResult = true;
              }
            } else {
              noResult = true;
              searching = false;
            }
            searchTextController.text = "";
          });
        }

        searchEvent() async {
          QueryBuilder<EventsModel> query =
              QueryBuilder<EventsModel>(EventsModel());

          query.whereEqualTo(EventsModel.keyEventID, searchTextController.text);
          query.setLimit(1);
          ParseResponse response = await query.query();
          newState(() {
            if (response.success) {
              searching = false;
              if (response.results != null) {
                searchedEvent = response.results!.first;
              } else {
                noResult = true;
              }
            } else {
              noResult = true;
              searching = false;
            }
            searchTextController.text = "";
          });
        }

        searchUser() async {
          QueryBuilder<UserModel> query =
              QueryBuilder<UserModel>(UserModel.forQuery());

          if(QuickHelp.isNumericString(searchTextController.text)) {
            query.whereEqualTo(
                UserModel.keyUid, int.parse(searchTextController.text));
          }else{
            query.whereContains(
                UserModel.keyFullName, searchTextController.text);
          }
          query.whereNotEqualTo(UserModel.keyObjectId, currentUser.objectId!);

          query.setLimit(5);
          ParseResponse response = await query.query();
          newState(() {
            if (response.success) {
              searching = false;
              if (response.results != null) {

                for (UserModel user in response.results!) {
                  if(!usersIdsList.contains(user.objectId)) {
                    usersList.add(user);
                    usersIdsList.add(user.objectId);
                  }
                }

              } else {
                noResult = true;
              }
            } else {
              searching = false;
              noResult = true;
            }
          });
        }

        return GestureDetector(
          onTap: () => QuickHelp.removeFocusOnTextField(context),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: kIamonGraySearch,
            alignment: Alignment.topCenter,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: size.height / 5,
            ),
            content: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10,top: 50),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: SizedBox(
                        width: double.infinity,
                        height: onlyLives ? livesIdsList.length*85 : onlyUsers ? usersIdsList.length*70 :double.infinity,
                      ),
                    ),
                  ),
                ),
                ContainerCorner(
                  color: kSearcherBg.withOpacity(0.5),
                  borderRadius: 10,
                  borderWidth: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerCorner(
                          color: kSearcherBg,
                          height: 50,
                          borderRadius: 8,
                          borderWidth: 0,
                          width: size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10, left: 15),
                            child: TextFormField(
                              controller: searchTextController,
                              autocorrect: false,
                              onChanged: (text) {},
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                /*prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: SvgPicture.asset(
                                    "assets/svg/ic_search_for_light_mode.svg",
                                    height: 15,
                                    width: 15,
                                  ),
                                ),*/
                                border: InputBorder.none,
                                hintText: onlyLives ? "search_live_by_title".tr() : onlyUsers ? "search_users".tr() : "search...",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 15,
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    if(searchTextController.text.isNotEmpty) {
                                      newState(() {
                                        searching = true;
                                        noResult = false;
                                        livesIdsList.clear();
                                        livesList.clear();
                                        usersIdsList.clear();
                                        usersList.clear();
                                        searchedEvent = null;
                                        searchedChallie = null;
                                      });
                                      QuickHelp.removeFocusOnTextField(context);
                                      if(onlyLives) {
                                        searchLives();
                                      }else if (onlyEvent) {
                                        searchEvent();
                                      }else if(onlyUsers){
                                        searchUser();
                                      } else {
                                        if (searchTextController.text.length == 5) {
                                          searchEvent();
                                        } else if (searchTextController.text.length ==
                                            10) {
                                          searchUser();
                                        } else {
                                          searchChallie();
                                        }
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: SvgPicture.asset(
                                      "assets/svg/ic_search_for_light_mode.svg",
                                      height: 15,
                                      width: 15,
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: noResult,
                          child: TextWithTap(
                            "no_result".tr(),
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            marginLeft: 15,
                            marginBottom: 15,
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Visibility(
                          visible: searching,
                          child: QuickHelp.appLoading(),
                        ),
                        if(livesList.isNotEmpty)
                          ContainerCorner(
                            borderWidth: 0,
                            height: 170,
                            width: size.width,
                            marginLeft: 10,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  livesIdsList.length, (index){
                                    LiveStreamingModel liveStreaming = livesList[index];
                                    return ContainerCorner(
                                      marginRight: 15,
                                      width: size.width / 2.3,
                                      height: 150,
                                      marginBottom: 10,
                                      onTap: () {
                                        if (zego.ZegoUIKitPrebuiltLiveStreamingController()
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
                                      },
                                      child: Stack(
                                          alignment: AlignmentDirectional.center,
                                          children: [
                                            ContainerCorner(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: kTransparentColor,
                                              borderRadius: 3,
                                              borderWidth: 0,
                                              child: QuickActions.photosWidget(
                                                liveStreaming.getImage!.url!,
                                                borderRadius: 5,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                            ContainerCorner(
                                              width: double.infinity,
                                              height: double.infinity,
                                              color: Colors.black.withOpacity(0.4),
                                              borderRadius: 5,
                                              borderWidth: 0,
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 15, top: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/svg/ic_small_viewers.svg",
                                                              height: 13,
                                                            ),
                                                            TextWithTap(
                                                              liveStreaming
                                                                  .getViewersCount
                                                                  .toString(),
                                                              color: Colors.white,
                                                              fontSize: 14,
                                                              marginRight: 15,
                                                              marginLeft: 5,
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(right: 10),
                                                          child: Lottie.asset(
                                                              "assets/lotties/ic_live_animation.json",
                                                            height: 15,
                                                            width: 15,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                        bottom: 10, left: 5),
                                                    child: Row(
                                                      children: [
                                                        QuickActions.avatarWidget(
                                                            liveStreaming.getAuthor!,
                                                            height: 20,
                                                            width: 20,
                                                            margin: EdgeInsets.only(
                                                                left: 5, bottom: 5)),
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            ContainerCorner(
                                                              width: size.width / 3.2,
                                                              child: TextWithTap(
                                                                liveStreaming
                                                                    .getAuthor!
                                                                    .getFullName!,
                                                                color: Colors.white,
                                                                overflow: TextOverflow
                                                                    .ellipsis,
                                                                marginLeft: 5,
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(left: 10),
                                                              child: Row(
                                                                mainAxisSize:
                                                                MainAxisSize.min,
                                                                children: [
                                                                  Image.asset(
                                                                    "assets/images/pop_silver_icon.png",
                                                                    height: 9,
                                                                    width: 9,
                                                                  ),
                                                                  TextWithTap(
                                                                    liveStreaming
                                                                        .getAuthor!
                                                                        .getDiamondsTotal!
                                                                        .toString(),
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                        0.5),
                                                                    fontSize: 10,
                                                                    marginLeft: 3,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ]),
                                    );
                              }
                              ),
                            ),
                          ),
                        if (usersList.isNotEmpty)
                          ContainerCorner(
                            height: usersIdsList.length * 70,
                            width: size.width,
                            marginLeft: 10,
                            borderWidth: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                  usersIdsList.length,
                                  (index) {
                                    UserModel? searchedUser = usersList[index];
                                    return ContainerCorner(
                                      marginLeft: 10,
                                      onTap: () => QuickHelp.goToNavigatorScreen(
                                        context,
                                        UserProfileScreen(
                                          currentUser: currentUser,
                                          mUser: searchedUser,
                                          isFollowing: currentUser.getFollowing!.contains(searchedUser.objectId),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          QuickActions.avatarBorder(
                                            searchedUser,
                                            height: 60,
                                            width: 60,
                                            borderColor: Colors.white,
                                            borderWidth: 2,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                TextWithTap(
                                                  searchedUser.getUsername!,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  marginRight: 4,
                                                ),
                                                QuickHelp.usersMoreInfo(context, searchedUser),
                                                TextWithTap(
                                                  "face_authentication_screen.id_".tr(
                                                    namedArgs: {
                                                      "id": "${searchedUser.getUid!}"
                                                    },
                                                  ).toUpperCase(),
                                                  fontSize: 13,
                                                  color: Colors.white.withOpacity(0.7),
                                                  marginBottom: 3,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                    },
                              ),
                            ),
                          ),
                        if (searchedEvent != null)
                          Visibility(
                            visible: searchedEvent != null,
                            child: ContainerCorner(
                              height: 90,
                              shadowColor: Colors.black,
                              shadowColorOpacity: 0.5,
                              borderRadius: 10,
                              setShadowToBottom: true,
                              marginLeft: 10,
                              marginRight: 10,
                              marginBottom: 10,
                              onTap: () {
                                QuickHelp.hideLoadingDialog(context);
                                showEventDetails(
                                  eventsModel: searchedEvent!,
                                  context: context,
                                  currentUser: currentUser,
                                );
                              },
                              child: Stack(
                                children: [
                                  QuickActions.photosWidget(
                                    searchedEvent!.getBannerImage!.url,
                                    width: size.width,
                                    height: 90,
                                    borderRadius: 10,
                                  ),
                                  ContainerCorner(
                                    color: Colors.black.withOpacity(0.3),
                                    height: 90,
                                    width: size.width,
                                    borderWidth: 0,
                                    borderRadius: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextWithTap(
                                            searchedEvent!.getName!,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: size.width / 20,
                                          ),
                                          TextWithTap(
                                            searchedEvent!.getDescription!,
                                            color: Colors.white,
                                          ),
                                          TextWithTap(
                                            QuickHelp.getMessageTime(
                                                searchedEvent!.getExpireDate!),
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            marginBottom: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (searchedChallie != null)
                          Visibility(
                            visible: searchedChallie != null,
                            child: ContainerCorner(
                              height: 90,
                              shadowColor: Colors.black,
                              color: kPrimaryColor,
                              shadowColorOpacity: 0.5,
                              borderRadius: 10,
                              setShadowToBottom: true,
                              marginLeft: 10,
                              marginRight: 10,
                              marginBottom: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

showEventDetails({
  required EventsModel eventsModel,
  required BuildContext context,
  required UserModel currentUser,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Size size = MediaQuery.of(context).size;
      bool following =
          eventsModel.getFollowers!.contains(currentUser.objectId!);
      return StatefulBuilder(builder: (context, newState) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            alignment: AlignmentDirectional.topEnd,
            clipBehavior: Clip.none,
            children: [
              QuickActions.eventBgImage(
                eventsModel.getBgImage!.url!,
                height: size.height * 0.7,
                width: double.infinity,
                borderRadius: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: SizedBox(
                      width: double.infinity, height: size.height * 0.7),
                ),
              ),
              ContainerCorner(
                color: Colors.black.withOpacity(0.2),
                height: size.height * 0.7,
                borderRadius: 10,
                borderWidth: 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerCorner(
                        height: 100,
                        shadowColor: Colors.black,
                        shadowColorOpacity: 0.5,
                        borderRadius: 10,
                        setShadowToBottom: true,
                        child: Stack(
                          children: [
                            QuickActions.photosWidget(
                              eventsModel.getBannerImage!.url,
                              width: size.width,
                              height: 100,
                              borderRadius: 10,
                            ),
                            ContainerCorner(
                              color: Colors.black.withOpacity(0.3),
                              height: 100,
                              width: size.width,
                              borderWidth: 0,
                              borderRadius: 10,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextWithTap(
                                      eventsModel.getName!,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: size.width / 20,
                                    ),
                                    TextWithTap(
                                      eventsModel.getDescription!,
                                      color: Colors.white,
                                    ),
                                    TextWithTap(
                                      QuickHelp.getMessageTime(
                                          eventsModel.getExpireDate!),
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      marginBottom: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextWithTap(
                        "event_screen.event_name".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        marginTop: 20,
                      ),
                      TextWithTap(
                        eventsModel.getName!,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      TextWithTap(
                        "event_screen.event_id".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        marginTop: 15,
                      ),
                      TextWithTap(
                        eventsModel.getEventID!,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      TextWithTap(
                        "event_screen.description_".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        marginTop: 15,
                      ),
                      TextWithTap(
                        eventsModel.getDescription!,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                      TextWithTap(
                        "event_screen.participants_".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        marginTop: 15,
                      ),
                      ContainerCorner(
                        height: 100,
                        width: size.width,
                        child: _getParticipants(eventsModel),
                      ),
                      ContainerCorner(
                        color: kIamonGrayDark.withOpacity(0.6),
                        borderRadius: 10,
                        height: 65,
                        marginBottom: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SvgPicture.asset("assets/svg/data_event.svg"),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWithTap(
                                  QuickHelp.getTimeByDate(
                                      date: eventsModel.getExpireDate!),
                                  color: kIamonDarkBarColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                                TextWithTap(
                                  QuickHelp.getMessageTime(
                                      eventsModel.getExpireDate!),
                                  color: kIamonGrayDarker,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 70,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ContainerCorner(
                            borderWidth: 0,
                            borderRadius: 50,
                            color: kBlueIamon,
                            marginBottom: 15,
                            onTap: following
                                ? null
                                : () {
                                    newState(() {
                                      following = true;
                                    });
                                    followEvent(
                                      eventsModel: eventsModel,
                                      currentUser: currentUser,
                                    );
                                  },
                            child: TextWithTap(
                              following
                                  ? "tab_profile.followings_".tr()
                                  : "event_screen.follow_event".tr(),
                              color: Colors.white,
                              textItalic: true,
                              marginLeft: 30,
                              marginRight: 30,
                              marginTop: 10,
                              marginBottom: 10,
                            ),
                          ),
                          ContainerCorner(
                            marginBottom: 15,
                            onTap: () async {
                              final box =
                                  context.findRenderObject() as RenderBox?;
                              String linkToShare =
                                  await DeepLinksService.createLink(
                                branchObject: DeepLinksService.branchObject(
                                  shareAction: DeepLinksService.keyEventShare,
                                  objectID: eventsModel.getEventID!,
                                  imageURL: eventsModel.getImage!.url,
                                  title: eventsModel.getName,
                                  description: eventsModel.getDescription,
                                ),
                                branchProperties:
                                    DeepLinksService.linkProperties(
                                  channel: "link",
                                ),
                                context: context,
                              );
                              if (linkToShare.isNotEmpty) {
                                Share.share(
                                  "share_event".tr(namedArgs: {
                                    "link": linkToShare,
                                    "app_name": Setup.appName
                                  }),
                                  sharePositionOrigin:
                                      box!.localToGlobal(Offset.zero) &
                                          box.size,
                                );
                              }
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/iamon_share_enven.svg",
                                ),
                                TextWithTap(
                                  "audio_chat.share_".tr(),
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: GestureDetector(
                    onTap: () => QuickHelp.hideLoadingDialog(context),
                    child: SvgPicture.asset("assets/svg/event_close.svg")),
              )
            ],
          ),
        );
      });
    },
  );
}

followEvent({
  required EventsModel eventsModel,
  required UserModel currentUser,
}) async {
  eventsModel.setFollowers = currentUser.objectId!;
  await eventsModel.save();
  /*QuickActions.createOrDeleteNotification(currentUser, eventsModel.getAuthor!,
      NotificationsModel.notificationTypeEventNewFollower,
      event: eventsModel);*/
}

_getParticipants(EventsModel eventsModel) {
  QueryBuilder<UserModel> query = QueryBuilder<UserModel>(UserModel.forQuery());

  query.whereContainedIn(UserModel.keyObjectId, eventsModel.getParticipantIDs!);
  query.orderByAscending(UserModel.keyUpdatedAt);

  return ParseLiveListWidget<UserModel>(
    query: query,
    reverse: false,
    lazyLoading: false,
    shrinkWrap: true,
    scrollDirection: Axis.horizontal,
    duration: const Duration(milliseconds: 400),
    childBuilder: (BuildContext context,
        ParseLiveListElementSnapshot<UserModel> snapshot) {
      if (snapshot.hasData) {
        UserModel friend = snapshot.loadedData!;

        return Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QuickActions.avatarBorder(
                friend,
                width: 50,
                height: 50,
              ),
              SizedBox(
                width: 50,
                child: TextWithTap(
                  friend.username!,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                  alignment: Alignment.center,
                  fontSize: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      } else {
        return TextWithTap(
          "event_screen.participants_".tr(),
          color: Colors.black,
          textAlign: TextAlign.center,
          alignment: Alignment.center,
        );
      }
    },
    listLoadingElement: QuickHelp.appLoading(),
    queryEmptyElement: TextWithTap(
      "event_screen.participants_".tr(),
      color: kColorsGrey,
      textAlign: TextAlign.center,
      alignment: Alignment.center,
    ),
  );
}
