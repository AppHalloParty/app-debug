// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/feed/video_player_screen.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../helpers/send_notifications.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';

class UploadBanubaEditedVideoScreen extends StatefulWidget {
  UserModel? currentUser;
  File? videoFile;
  File? thumbNailFile;

  UploadBanubaEditedVideoScreen({
    this.currentUser,
    this.videoFile,
    this.thumbNailFile,
    super.key,
  });

  @override
  State<UploadBanubaEditedVideoScreen> createState() =>
      _UploadBanubaEditedVideoScreenState();
}

class _UploadBanubaEditedVideoScreenState
    extends State<UploadBanubaEditedVideoScreen> {
  TextEditingController captionTextEditing = TextEditingController();
  List<UserModel> selectedUser = [];
  var selectedUserIds = [];

  int maxLength = 10;
  int friendAmount = 0;

  ParseFileBase? parseVideoFile;
  ParseFileBase? parseVideoThumbnailFile;

  List<File> selectedVideos = [];

  File? videoFileLocal;
  File? thumbnailFileLocal;

  prepareVideo() async {
    DateTime date = DateTime.now();

    parseVideoThumbnailFile = await ParseFile(widget.thumbNailFile, name: "thumbnail.jpg");

    if (widget.videoFile!.absolute.path.isNotEmpty) {
      parseVideoFile = await ParseFile(File(widget.videoFile!.absolute.path),
          name: "video_${date.second}_${date.millisecond}.mp4");
    } else {
      parseVideoFile = await ParseWebFile(widget.videoFile!.readAsBytesSync(),
          name: "video_${date.second}_${date.millisecond}.pm4");
    }
  }

  @override
  void initState() {
    prepareVideo();
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    widget.thumbNailFile = null;
    selectedUser.clear();
    selectedUserIds.clear();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          title: TextWithTap("create_post_screen.post_moment".tr()),
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: BackButton(
              color: kGrayColor,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15, top: 8, bottom: 8),
              child: TextButton(
                onPressed: () {
                  if (parseVideoFile != null) {
                    createPost();
                  } else {
                    QuickHelp.showAppNotificationAdvanced(
                      title:
                          "create_post_screen.choose_video_advise_title".tr(),
                      message:
                          "create_post_screen.choose_video_advise_explain".tr(),
                      context: context,
                    );
                  }
                },
                child: TextWithTap(
                  "create_post_screen.post_".tr(),
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {},
                    maxLines: 5,
                    maxLength: 250,
                    controller: captionTextEditing,
                    decoration: InputDecoration(
                      hintText: "create_post_screen.say_something".tr(),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  children: [
                    Wrap(
                      children: List.generate(1, (index) {
                        return Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                QuickHelp.goToNavigatorScreen(
                                  context,
                                  VideoPlayerScreen(
                                    currentUser: widget.currentUser,
                                    video: widget.videoFile,
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  ContainerCorner(
                                    width: size.width / 3.5,
                                    height: size.width / 2.3,
                                    borderRadius: 7,
                                    borderWidth: 0,
                                    marginRight: 7,
                                    marginBottom: 7,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        widget.thumbNailFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  ContainerCorner(
                                    width: size.width / 3.5,
                                    height: size.width / 2.3,
                                    borderRadius: 7,
                                    borderWidth: 0,
                                    marginRight: 7,
                                    marginBottom: 7,
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        color: Colors.white.withOpacity(0.4),
                                        size: size.width / 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: -3,
                              right: -10,
                              child: ContainerCorner(
                                borderRadius: 50,
                                height: 30,
                                width: 30,
                                marginTop: 4,
                                marginRight: 10,
                                color: QuickHelp.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                                onTap: () {
                                  setState(() {
                                    selectedVideos.clear();
                                  });
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.redAccent,
                                    weight: 999,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    Visibility(
                      //visible: selectedVideos.length < 1,
                      visible: false,
                      child: ContainerCorner(
                        width: size.width / 3.5,
                        height: size.width / 3.5,
                        color: kGrayWhite,
                        borderRadius: 10,
                        borderWidth: 0,
                        marginRight: 7,
                        marginBottom: 7,
                        onTap: () {},
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: kGrayColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  child: IconButton(
                    onPressed: () => showPeopleToMentionBottomModal(),
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "@",
                          fontWeight: FontWeight.w700,
                        ),
                        TextWithTap(
                          "audio_chat.mention_".tr(),
                          marginLeft: 5,
                          marginRight: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedUserIds.length > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "create_post_screen.one_target_user_selected".tr(
                              namedArgs: {
                                "name": selectedUser[0].getFullName!
                              }),
                          fontWeight: FontWeight.w900,
                          color: Colors.blueAccent,
                        ),
                        Visibility(
                          visible: selectedUserIds.length > 1,
                          child: TextWithTap(
                            "create_post_screen.multiple_target_users_selected"
                                .tr(namedArgs: {
                              "amount": "${selectedUserIds.length - 1}"
                            }),
                            marginLeft: 5,
                            marginRight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showPeopleToMentionBottomModal() {
    showModalBottomSheet(
      context: (context),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: true,
      builder: (context) {
        return showPeopleToMention();
      },
    );
  }

  Widget showPeopleToMention() {
    Size size = MediaQuery.of(context).size;
    int? indexSelected;

    QueryBuilder<UserModel> query = QueryBuilder(UserModel.forQuery());
    query.whereContainedIn(
      UserModel.keyObjectId,
      widget.currentUser!.getFollowing!,
    );

    return ContainerCorner(
      color: Colors.black.withOpacity(0.01),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.1,
        maxChildSize: 1.0,
        builder: (_, controller) {
          return StatefulBuilder(
            builder: (context, newState) {
              return ContainerCorner(
                radiusTopRight: 25.0,
                radiusTopLeft: 25.0,
                borderWidth: 0,
                child: ContainerCorner(
                  borderWidth: 0,
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorLightTheme
                      : Colors.white,
                  child: Scaffold(
                    backgroundColor: kTransparentColor,
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      backgroundColor: kTransparentColor,
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                      title: TextWithTap(
                        "audio_chat.mention_".tr(),
                      ),
                      leading: BackButton(
                        color: kGrayColor,
                        onPressed: () {
                          newState(() {
                            selectedUser.clear();
                            selectedUserIds.clear();
                          });
                          setState(() {});
                          QuickHelp.goBackToPreviousPage(context);
                        },
                      ),
                      actions: [
                        TextWithTap(
                          "create_post_screen.completed_".tr(namedArgs: {
                            "amount": "${selectedUser.length}/$maxLength"
                          }),
                          color: Colors.blueAccent,
                          marginRight: 10,
                          onTap: () => QuickHelp.goBackToPreviousPage(context),
                        ),
                      ],
                    ),
                    body: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ContainerCorner(
                          height: 45,
                          color: kGrayLight,
                          width: size.width,
                          borderWidth: 0,
                          child: Center(
                            child: TextWithTap(
                              "create_post_screen.follow_each_other"
                                  .tr(namedArgs: {"amount": "$friendAmount"}),
                              color: Colors.black,
                              alignment: Alignment.centerLeft,
                              marginLeft: 15,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ContainerCorner(
                            child: ParseLiveListWidget<UserModel>(
                              query: query,
                              reverse: false,
                              lazyLoading: false,
                              shrinkWrap: true,
                              duration: Duration(milliseconds: 30),
                              childBuilder: (BuildContext context,
                                  ParseLiveListElementSnapshot<UserModel>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  UserModel user =
                                      snapshot.loadedData as UserModel;
                                  bool isMale =
                                      user.getGender == UserModel.keyGenderMale;

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, bottom: 5),
                                    child: GestureDetector(
                                      onTap: () {
                                        newState(() {
                                          if (selectedUserIds
                                              .contains(user.objectId)) {
                                            for (int i = 0;
                                                i < selectedUserIds.length;
                                                i++) {
                                              if (user.objectId ==
                                                  selectedUserIds[i]) {
                                                indexSelected = i;
                                              }
                                            }

                                            selectedUser
                                                .removeAt(indexSelected!);
                                            selectedUserIds
                                                .removeAt(indexSelected!);
                                          } else {
                                            if (selectedUserIds.length <=
                                                maxLength) {
                                              selectedUser.add(user);
                                              selectedUserIds
                                                  .add(user.objectId!);
                                            }
                                          }
                                        });
                                        setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ContainerCorner(
                                              child: Row(
                                                children: [
                                                  QuickActions.avatarWidget(
                                                    user,
                                                    width: 50,
                                                    height: 50,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWithTap(
                                                          user.getFullName!,
                                                        ),
                                                        QuickActions.getGender(
                                                          currentUser: user,
                                                          context: context,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          selectedUserIds
                                                  .contains(user.objectId)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: isMale
                                                      ? Colors.lightBlue
                                                      : Colors.redAccent,
                                                )
                                              : Icon(
                                                  Icons.radio_button_unchecked,
                                                  color: isMale
                                                      ? Colors.lightBlue
                                                      : Colors.redAccent,
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                              queryEmptyElement: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: ContainerCorner(
                                      width: 180,
                                      child: Center(
                                        child: TextWithTap(
                                          "create_post_screen.empty_friend_to_mention"
                                              .tr(),
                                          alignment: Alignment.center,
                                          textAlign: TextAlign.center,
                                          color: kGrayColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              listLoadingElement: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  createPost() async {
    QuickHelp.showLoadingDialog(context);

    PostsModel newPost = PostsModel();

    newPost.setVideo = parseVideoFile!;
    newPost.setVideoThumbnail = parseVideoThumbnailFile!;
    newPost.setAuthor = widget.currentUser!;
    newPost.setText = captionTextEditing.text;
    newPost.setAuthorId = widget.currentUser!.objectId!;

    newPost.setTargetPeople = selectedUser;
    newPost.setTargetPeopleID = selectedUserIds;

    ParseResponse parseResponse = await newPost.save();

    if (parseResponse.success && parseResponse.result != null) {
      PostsModel postsModel = parseResponse.result;
      savePostIdOnUser(postsModel.objectId!);

      QuickHelp.hideLoadingDialog(context);

      setState(() {
        captionTextEditing.text = "";
        selectedUser.clear();
        selectedUserIds.clear();
      });

      _sendPushToFollowers(postsModel);

      QuickHelp.goToNavigatorScreen(
        context,
        HomeScreen(
          currentUser: widget.currentUser,
          initialTabIndex: 0,
        ),
        finish: true,
        back: false,
      );

      QuickHelp.showAppNotificationAdvanced(
        title: "create_post_screen.post_created_success_title".tr(),
        context: context,
        message: "create_post_screen.post_created_success_explain".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  _sendPushToFollowers(PostsModel post) async {
    if (widget.currentUser!.getFollowers!.isNotEmpty) {
      QueryBuilder<UserModel> queryUsers =
          QueryBuilder<UserModel>(UserModel.forQuery());

      queryUsers.whereContainedIn(
        UserModel.keyObjectId,
        widget.currentUser!.getFollowers!,
      );

      ParseResponse response = await queryUsers.query();
      if (response.success) {
        if (response.result != null) {
          for (UserModel user in response.results!) {
            SendNotifications.sendPush(
              widget.currentUser!,
              user,
              SendNotifications.typePost,
              objectId: post.objectId!,
            );
          }
        }
      }
    }
  }

  savePostIdOnUser(String postId) async {
    widget.currentUser!.setIdToPostList = postId;
    await widget.currentUser!.save();
  }
}
