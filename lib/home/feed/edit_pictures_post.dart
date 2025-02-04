// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/home/feed/comment_post_screen.dart';
import 'package:trace/home/feed/visualize_multiple_pictures_screen.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/PostsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class EditPicturesPost extends StatefulWidget {
  UserModel? currentUser;
  PostsModel? postsModel;

  EditPicturesPost({
    this.currentUser,
    this.postsModel,
    super.key,
  });

  @override
  State<EditPicturesPost> createState() => _EditPicturesPostState();
}

class _EditPicturesPostState extends State<EditPicturesPost> {
  TextEditingController captionTextEditing = TextEditingController();
  List<dynamic> picturesFromDataBase = [];
  List<dynamic> deletedImagesFromDataBase = [];

  List<UserModel> selectedUser = [];
  var selectedUserIds = [];

  int maxLength = 10;
  int friendAmount = 0;

  List<File> selectedPictures = [];

  List<ParseFileBase> parseFiles = [];

  @override
  void initState() {
    super.initState();
    captionTextEditing.text = widget.postsModel!.getText!;
    for (int i = 0; i < widget.postsModel!.getImagesList!.length; i++) {
      picturesFromDataBase.add(widget.postsModel!.getImagesList![i]);
    }
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
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          title: TextWithTap(
            "edit_post_screen.edit_post".tr(),
            fontWeight: FontWeight.w800,
          ),
          actions: [
            TextButton(
              onPressed: () {

               if(deletedImagesFromDataBase.isNotEmpty) {
                  deleteImageFromDatabase();
                }else{
                  updatePost();
                }

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
                      children: List.generate(
                        picturesFromDataBase.length,
                        (index) {
                          return Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              ContainerCorner(
                                width: size.width / 3.5,
                                height: size.width / 3.5,
                                borderRadius: 7,
                                borderWidth: 0,
                                marginRight: 7,
                                marginBottom: 7,
                                onTap: () {
                                  QuickHelp.goToNavigatorScreen(
                                    context,
                                    VisualizeMultiplePicturesScreen(
                                      initialIndex: index,
                                      picturesFromDataBase: picturesFromDataBase,
                                    ),
                                  );
                                },
                                child: QuickActions.photosWidget(
                                  picturesFromDataBase[index]["url"],
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: ContainerCorner(
                                  borderRadius: 50,
                                  height: 23,
                                  width: 23,
                                  marginTop: 4,
                                  marginRight: 10,
                                  color: Colors.black.withOpacity(0.5),
                                  onTap: () {
                                    setState(
                                      () {
                                        deletedImagesFromDataBase.add(picturesFromDataBase[index]);
                                        picturesFromDataBase.removeAt(index);
                                      },
                                    );
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      weight: 999,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Visibility(
                      visible: selectedPictures.length <
                          (9 - picturesFromDataBase.length),
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
                Visibility(
                  visible: selectedPictures.length >= 1,
                  child: TextWithTap(
                    "edit_post_screen.new_selection".tr(),
                    color: kBlueColor,
                    marginTop: 10,
                    marginBottom: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Wrap(
                  children: List.generate(selectedPictures.length, (index) {
                    return Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        ContainerCorner(
                          width: size.width / 3.5,
                          height: size.width / 3.5,
                          borderRadius: 7,
                          borderWidth: 0,
                          marginRight: 7,
                          marginBottom: 7,
                          onTap: () {
                            QuickHelp.goToNavigatorScreen(
                              context,
                              VisualizeMultiplePicturesScreen(
                                initialIndex: index,
                                selectedPictures: selectedPictures,
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7.0),
                            child: Image.file(
                              selectedPictures[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ContainerCorner(
                            borderRadius: 50,
                            height: 23,
                            width: 23,
                            marginTop: 4,
                            marginRight: 10,
                            color: Colors.black.withOpacity(0.5),
                            onTap: () {
                              setState(() {
                                selectedPictures.removeAt(index);
                              });
                            },
                            child: Center(
                                child: Icon(
                              Icons.close,
                              color: Colors.white,
                              weight: 999,
                              size: 15,
                            )),
                          ),
                        ),
                      ],
                    );
                  }),
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
                  Visibility(
                    visible: selectedUserIds.length > 0,
                    child: Padding(
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteImageFromDatabase() async{
    QuickHelp.showLoadingDialog(context);
    widget.postsModel!.removeImageListFromList = deletedImagesFromDataBase;

    ParseResponse parseResponse = await widget.postsModel!.save();

    if (parseResponse.success && parseResponse.result != null) {
      QuickHelp.hideLoadingDialog(context);

      widget.postsModel = parseResponse.result;
      updatePost();
    }else{
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
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
        });
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

      _choosePhoto(isAvatar);
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
              _choosePhoto(isAvatar);
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
      //_uploadPhotos(ImageSource.gallery);
      _choosePhoto(isAvatar);
    }

    print('Permission $status');
    print('Permission $status2');
  }

  _choosePhoto(bool isAvatar) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        //maxAssets: 9 - selectedPictures.length,
        maxAssets: (9 - picturesFromDataBase.length - selectedPictures.length),
        requestType: RequestType.image,
        filterOptions: FilterOptionGroup(
          containsLivePhotos: false,
        ),
      ),
    );

    if (result != null && result.length > 0) {
      final List<File>? images = [];

      for (int i = 0; i < result.length; i++) {
        images!.add(await result[i].file as File);
      }

      final tempDir = await getTemporaryDirectory();
      List<String> savedImagesPaths = [];
      DateTime date = DateTime.now();

      for (int i = 0; i < images!.length; i++) {
        String imageName =
            'post_picture_${selectedPictures.length + i}_${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        setState(() {
          selectedPictures.add(tempFile);
        });
      }
    } else {
      print("Photos null");
    }
  }

  updatePost() async {
    QuickHelp.showLoadingDialog(context);

    DateTime date = DateTime.now();

    int maxImagesLength = selectedPictures.length + picturesFromDataBase.length;

    for (int i = 0; i < selectedPictures.length; i++) {
      if (selectedPictures[i].absolute.path.isNotEmpty) {
        parseFiles.add(ParseFile(File(selectedPictures[i].absolute.path),
            name: "post_picture_${date.second}_${date.millisecond}.jpg"));
      } else {
        parseFiles.add(ParseWebFile(selectedPictures[i].readAsBytesSync(),
            name: "post_picture_${date.second}_${date.millisecond}.jpg"));
      }
    }

    widget.postsModel!.setImagesList = parseFiles;
    widget.postsModel!.setAuthor = widget.currentUser!;
    widget.postsModel!.setText = captionTextEditing.text;
    widget.postsModel!.setAuthorId = widget.currentUser!.objectId!;
    widget.postsModel!.setNumberOfPictures = maxImagesLength;

    if(selectedUser.isNotEmpty && selectedUserIds.isNotEmpty) {
      widget.postsModel!.setTargetPeople = selectedUser;
      widget.postsModel!.setTargetPeopleID = selectedUserIds;
    }

    ParseResponse parseResponse = await widget.postsModel!.save();

    if (parseResponse.success && parseResponse.result != null) {
      PostsModel updatedPost = parseResponse.result;

      QuickHelp.hideLoadingDialog(context);

      setState(() {
        captionTextEditing.text = "";
        selectedPictures.clear();
        selectedUser.clear();
        picturesFromDataBase.clear();
        selectedUserIds.clear();
      });
      QuickHelp.showAppNotificationAdvanced(
        title: "create_post_screen.post_created_success_title".tr(),
        context: context,
        message: "create_post_screen.post_created_success_explain".tr(),
        isError: false,
      );

      QuickHelp.goToNavigatorScreen(
        context,
        CommentPostScreen(
          currentUser: widget.currentUser,
          post: updatedPost,
        ),
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

}
