// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/home_screen.dart';
import 'package:trace/models/StoriesAuthorsModel.dart';
import 'package:trace/models/StoriesModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../helpers/send_notifications.dart';
import '../feed/visualize_multiple_pictures_screen.dart';

class CreatePhotoStory extends StatefulWidget {
  UserModel? currentUser;

  CreatePhotoStory({Key? key, this.currentUser})
      : super(key: key);

  @override
  _CreatePhotoStoryState createState() => _CreatePhotoStoryState();
}

class _CreatePhotoStoryState extends State<CreatePhotoStory> {
  XFile? image; //for captured image

  String uploadPhoto = "";
  ParseFileBase? parseFile;
  String uploadedPic = "";
  TextEditingController storyCaptionController = TextEditingController();

  bool isKeyBoardVisible = true;
  File? selectedPicture;

  @override
  void initState() {
    storyCaptionController = TextEditingController();
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    storyCaptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kDarkColorsTheme,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: kDarkColorsTheme,
          automaticallyImplyLeading: false,
          leading: const BackButton(
            color: Colors.white,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            children: [
              ContainerCorner(
                color: kContentDarkShadow,
                borderWidth: 0,
                borderRadius: 10,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {},
                    maxLines: 5,
                    maxLength: 100,
                    style: TextStyle(color: Colors.white),
                    controller: storyCaptionController,
                    decoration: InputDecoration(
                      hintText: "create_post_screen.say_something".tr(),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if(selectedPicture != null)
              Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  ContainerCorner(
                    width: size.width / 1.3,
                    height: size.height / 2,
                    borderRadius: 7,
                    borderWidth: 0,
                    marginRight: 7,
                    marginBottom: 7,
                    onTap: () {
                      QuickHelp.goToNavigatorScreen(
                        context,
                        VisualizeMultiplePicturesScreen(
                          initialIndex: 0,
                          selectedPictures: [selectedPicture!],
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedPicture!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: ContainerCorner(
                      borderRadius: 50,
                      height: 35,
                      width: 35,
                      marginTop: 4,
                      marginRight: 10,
                      shadowColor: kGrayColor,
                      shadowColorOpacity: 0.3,
                      color: Colors.white,
                      onTap: () {
                        setState(() {
                          selectedPicture = null;
                        });
                      },
                      child: Center(
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 20,
                          )),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: selectedPicture == null,
                child: ContainerCorner(
                  width: 150,
                  height: 150,
                  color: kGrayWhite,
                  borderRadius: 10,
                  borderWidth: 0,
                  marginRight: 7,
                  marginBottom: 7,
                  onTap: () => _choosePhoto(false),
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
        ),
        bottomNavigationBar: Visibility(
          visible: selectedPicture != null,
          child: ContainerCorner(
            height: 45,
            borderRadius: 50,
            borderWidth: 0,
            marginLeft: 30,
            marginRight: 30,
            color: kPrimaryColor,
            marginBottom: 20,
            onTap: ()=> createStories(),
            child: TextWithTap(
                "audio_chat.share_".tr(),
              color: Colors.white,
              alignment: Alignment.center,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  _choosePhoto(bool isAvatar) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
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
            'live_photo_${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        setState(() {
          selectedPicture = tempFile;
        });
      }
    } else {
      print("Photos null");
    }
  }

  _sendPushToFollowers(StoriesModel story) async {
    if (widget.currentUser!.getFollowers!.isNotEmpty) {
      QueryBuilder<UserModel> queryUsers =
          QueryBuilder<UserModel>(UserModel.forQuery());

      queryUsers.whereContainedIn(
          UserModel.keyObjectId, widget.currentUser!.getFollowers!);

      ParseResponse response = await queryUsers.query();
      if (response.success) {
        if (response.result != null) {
          for (UserModel user in response.results!) {
            SendNotifications.sendPush(
              widget.currentUser!,
              user,
              SendNotifications.typeStory,
              objectId: story.objectId!,
            );
          }
        }
      }
    }
  }

  createStories() async {

    QuickHelp.showLoadingDialog(context);

    DateTime date = DateTime.now();

    if (selectedPicture!.absolute.path.isNotEmpty) {
      parseFile = ParseFile(File(selectedPicture!.absolute.path),
          name: "story_photo_${date.second}_${date.millisecond}.jpg");
    } else {
      parseFile = ParseWebFile(selectedPicture!.readAsBytesSync(),
          name: "story_photo_${date.second}_${date.millisecond}.jpg");
    }

    ParseResponse responsePhoto = await parseFile!.save();

    if(responsePhoto.success && responsePhoto.results != null) {
      StoriesModel story = StoriesModel();

      story.setAuthor = widget.currentUser!;
      story.setAuthorId = widget.currentUser!.objectId!;
      story.setImage = parseFile!;
      story.setExpireDate = QuickHelp.getUntilDateFromDays(1);

      ParseResponse response = await story.save();

      if (response.success) {
        QuickHelp.hideLoadingDialog(context);

        QuickHelp.goToNavigatorScreen(
            context,
            HomeScreen(
              currentUser: widget.currentUser,
            ));

        _createAuthor(story);
      } else {
        QuickHelp.hideLoadingDialog(context);
        Future.delayed(const Duration(seconds: 1));
        QuickHelp.showAppNotificationAdvanced(
          title: "error_creating.error_title".tr(),
          message: "error_creating.error_explain".tr(),
          context: context,
          isError: true,
        );
      }

      if (storyCaptionController.text.isNotEmpty) {
        story.setText = storyCaptionController.text;
      }
    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  //create story author
  _createAuthor(StoriesModel story) async {
    QueryBuilder<StoriesAuthorsModel> query =
        QueryBuilder<StoriesAuthorsModel>(StoriesAuthorsModel());
    query.whereEqualTo(
        StoriesAuthorsModel.keyAuthorId, widget.currentUser!.objectId);
    ParseResponse parseResponse = await query.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        StoriesAuthorsModel storyAuthor = parseResponse.results!.first!;
        storyAuthor.setLastStory = story;
        storyAuthor.setStoriesList = story.objectId!;
        storyAuthor.setLastStoryExpireDate = story.getExpireDate!;
        storyAuthor.setLastStorySeen = false;

        await storyAuthor.save();
        _sendPushToFollowers(story);
      } else {
        StoriesAuthorsModel storyAuthor = StoriesAuthorsModel();
        storyAuthor.setAuthor = widget.currentUser!;
        storyAuthor.setAuthorId = widget.currentUser!.objectId!;
        storyAuthor.setLastStory = story;
        storyAuthor.setStoriesList = story.objectId!;
        storyAuthor.setLastStoryExpireDate = story.getExpireDate!;
        storyAuthor.setLastStorySeen = false;

        await storyAuthor.save();
        _sendPushToFollowers(story);
      }
    }
  }
}
