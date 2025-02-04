// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/home/feed/video_player_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';
import '../reels/reels_single_screen.dart';

class EditVideoPostScreen extends StatefulWidget {
  UserModel? currentUser;
  PostsModel? postsModel;

  EditVideoPostScreen(
      {this.postsModel, this.currentUser, super.key});

  @override
  State<EditVideoPostScreen> createState() => _EditVideoPostScreenState();
}

class _EditVideoPostScreenState extends State<EditVideoPostScreen> {

  TextEditingController captionTextEditing = TextEditingController();
  List<UserModel> selectedUser = [];
  var selectedUserIds = [];

  List<dynamic> videoFromDataBase = [];

  int maxLength = 10;
  int friendAmount = 0;

  ParseFileBase? parseVideoFile;
  ParseFileBase? parseVideoThumbnailFile;

  List<File> selectedVideos = [];
  File? videoFile;
  String videoPath = "";

  @override
  void initState() {
    super.initState();
    videoFromDataBase.add(widget.postsModel!.getVideo!);
    captionTextEditing.text = widget.postsModel!.getText!;
  }

  @override
  void dispose() {
    super.dispose();
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
          automaticallyImplyLeading: false,
          leadingWidth: 70,
          leading: TextButton(
            onPressed: () => QuickHelp.hideLoadingDialog(context),
            child: TextWithTap(
              "cancel".tr(),
              color: kRedColor1,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
          title: TextWithTap(
            "edit_post_screen.edit_video_post".tr(),
            fontWeight: FontWeight.w700,
          ),
          actions: [
            TextButton(
              onPressed: () {
                updatePost();
              },
              child: TextWithTap(
                "edit_post_screen.update_".tr(),
                color: kGreenLight,
                fontWeight: FontWeight.w800,
              ),
            )
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
                      children: List.generate(videoFromDataBase.length, (index) {
                        return Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                QuickHelp.goToNavigatorScreen(
                                  context,
                                  ReelsSingleScreen(
                                    currentUser: widget.currentUser,
                                    post: widget.postsModel,
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
                                      child: QuickActions.photosWidget(
                                        widget.postsModel!.getVideoThumbnail!.url,
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
                            Visibility(
                              visible: false,
                              child: Positioned(
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
                                      videoFromDataBase.clear();
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
                            ),
                          ],
                        );
                      }),
                    ),
                    Wrap(
                      children: List.generate(selectedVideos.length, (index) {
                        return Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                QuickHelp.goToNavigatorScreen(
                                  context,
                                  VideoPlayerScreen(
                                    currentUser: widget.currentUser,
                                    video: videoFile,
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
                                        selectedVideos[0],
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
                            Visibility(
                              visible: false,
                              child: Positioned(
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
                            ),
                          ],
                        );
                      }),
                    ),
                    Visibility(
                      visible: videoFromDataBase.length < 1 && selectedVideos.length < 1,
                      child: ContainerCorner(
                        width: size.width / 3.5,
                        height: size.width / 3.5,
                        color: kGrayWhite,
                        borderRadius: 10,
                        borderWidth: 0,
                        marginRight: 7,
                        marginBottom: 7,
                        onTap: () => checkPermission(false),
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

  Future<void> checkPermission(bool isAvatar) async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission android');

      checkStatus(status, status2, isAvatar);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission ios');

      checkStatus(status, status2, isAvatar);
    } else {
      print('Permission other device');

      _pickVideoFile();
    }
  }

  void checkStatus(
      PermissionStatus status, PermissionStatus status2, bool isAvatar) {
    if (status.isDenied || status2.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.

      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted) {
              _pickVideoFile();
            }
          });
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.photo_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted && status2.isGranted) {
      _pickVideoFile();
    }

    print('Permission $status');
    print('Permission $status2');
  }

  updatePost() async {
    QuickHelp.showLoadingDialog(context);

    if(selectedVideos.isNotEmpty) {
      widget.postsModel!.setVideo = parseVideoFile!;
      widget.postsModel!.setVideoThumbnail = parseVideoThumbnailFile!;
    }

    widget.postsModel!.setAuthor = widget.currentUser!;
    widget.postsModel!.setText = captionTextEditing.text;
    widget.postsModel!.setAuthorId = widget.currentUser!.objectId!;

    if(selectedUser.isNotEmpty && selectedUserIds.isNotEmpty) {
      widget.postsModel!.setTargetPeople = selectedUser;
      widget.postsModel!.setTargetPeopleID = selectedUserIds;
    }

    ParseResponse parseResponse = await widget.postsModel!.save();

    if (parseResponse.success && parseResponse.result != null) {

      QuickHelp.hideLoadingDialog(context);

      setState(() {
        captionTextEditing.text = "";
        selectedUser.clear();
        selectedUserIds.clear();
        selectedVideos.clear();
      });

      QuickHelp.goToNavigatorScreen(
        context,
        HomeScreen(
          currentUser: widget.currentUser,
          initialTabIndex: 0,
        ),
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

  _pickVideoFile() async {

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.video,
      ),
    );

    if (result != null && result.length > 0) {
      final File? file = await result.first.file;


      if (file!.lengthSync() <= Setup.maxVideoSize * 1024 * 1024) {

        String? mimeStr = lookupMimeType(file.path);
        var fileType = mimeStr!.split('/');

        print('Selected file type $fileType');

        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 100,
        );

        prepareVideo(file, thumbnail!);

      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "upload_video.size_exceeded_title".tr(),
          message: "upload_video.size_exceeded_explain"
              .tr(namedArgs: {"amount": "${Setup.maxVideoSize}"}),
          context: context,
        );
      }
    }
  }

  prepareVideo(File file, String previewPath) async {
    DateTime date = DateTime.now();

    final thumbnailFile = File(previewPath);

    parseVideoThumbnailFile =
        ParseFile(File(previewPath), name: "thumbnail.jpg");

    videoFile = file.absolute;

    setState(() {
      selectedVideos.add(thumbnailFile);
    });

    if (selectedVideos[0].absolute.path.isNotEmpty) {
      parseVideoFile =  await ParseFile(File(videoFile!.absolute.path),
          name: "video_${date.second}_${date.millisecond}.mp4");
    } else {
      parseVideoFile = await ParseWebFile(videoFile!.readAsBytesSync(),
          name: "video_${date.second}_${date.millisecond}.pm4");
    }

  }

}
