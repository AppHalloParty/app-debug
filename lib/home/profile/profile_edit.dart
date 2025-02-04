// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/profile/update_bio_screen.dart';
import 'package:trace/home/profile/update_username_screen.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// ignore: must_be_immutable
class ProfileEdit extends StatefulWidget {
  static String route = "/ProfileEdit";

  UserModel? currentUser;

  ProfileEdit({Key? key, this.currentUser}) : super(key: key);

  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  DateTime dateTime = DateTime(1999);

  bool isValidBirthday = false;
  String myBirthday = "";

  List<File> selectedPictures = [];

  List<ParseFileBase> parseFiles = [];

  List<ParseFileBase> userPictures = [];

  File? picture_1;
  File? picture_2;
  File? picture_3;
  File? picture_4;
  File? picture_5;

  File? avatarFile;
  String avatarURL = "";
  ParseFileBase? avatarPicture;

  var settingsTitles = ["edit_data_screen.delete_image".tr(), "cancel".tr()];
  var avatarSettingsTitles = [
    "edit_data_screen.update_image".tr(),
    "cancel".tr()
  ];

  getUserPictures() {
    if (widget.currentUser!.getImagesList!.isNotEmpty) {
      for (ParseFileBase image in widget.currentUser!.getImagesList!) {
        setState(() {
          userPictures.add(image);
        });
      }
    } else {
      setState(() {
        userPictures.clear();
      });
    }
    avatarURL = widget.currentUser!.getAvatar!.url!;
  }

  cleanFiles() {
    setState(() {
      if (picture_1 != null) {
        picture_1 = null;
      }
      if (picture_2 != null) {
        picture_2 = null;
      }
      if (picture_3 != null) {
        picture_3 = null;
      }
      if (picture_4 != null) {
        picture_4 = null;
      }
      if (picture_5 != null) {
        picture_5 = null;
      }
    });
  }

  @override
  void initState() {
    dateTime = widget.currentUser!.getBirthday!;
    getUserPictures();
    super.initState();
  }

  @override
  void dispose() {
    userPictures.clear();
    selectedPictures.clear();
    parseFiles.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TextWithTap(
          "edit_data_screen.edit_data".tr(),
        ),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
          onPressed: () => QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5, right: 2),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.only(topLeft: Radius.circular(10)),
                          child: Stack(
                            children: [
                              QuickActions.pictureWithDifferentRadius(
                                avatarURL,
                                width: size.width / 1.62,
                                height: 225,
                                borderRadius: 0,
                                margin: EdgeInsets.only(
                                  bottom: 5,
                                  top: 0,
                                ),
                              ),
                              ContainerCorner(
                                radiusTopLeft: 10,
                                radiusBottomRight: 10,
                                color: Colors.black.withOpacity(0.2),
                                child: TextWithTap(
                                  "edit_data_screen.avatar_".tr(),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  marginRight: 10,
                                  marginLeft: 10,
                                  marginTop: 5,
                                  marginBottom: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () => checkPermission(true),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        firstSelectOrShowPictures(),
                        secondSelectOrShowPictures(),
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    fifthSelectOrShowPictures(),
                    fourthSelectOrShowPictures(),
                    thirdSelectOrShowPictures()
                  ],
                ),
              ],
            ),
          ),
          ContainerCorner(
            width: size.width,
            color: kGrayWhite,
            borderWidth: 0,
            marginTop: 10,
            child: TextWithTap(
              "edit_data_screen.my_profile".tr(),
              fontWeight: FontWeight.bold,
              color: kContentColorLightTheme,
              fontSize: 18,
              marginTop: 10,
              marginLeft: 10,
              marginBottom: 10,
            ),
          ),
          userDataToModify(
            title: "edit_data_screen.username_".tr(),
            content: widget.currentUser!.getFullName!,
            screenToGo: UpdateUsernameScreen(
              currentUser: widget.currentUser,
            ),
          ),
          userNotModifyData(
            title: "edit_data_screen.gender_".tr(),
            content: widget.currentUser!.getGender!.capitalize,
          ),
          userDataToModify(
            title: "edit_data_screen.birthday_".tr(),
            content:
                QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!),
          ),
          userNotModifyData(
            title: widget.currentUser!.getCountry!,
            content: "",
          ),
          userDataToModify(
            title: "edit_data_screen.self_presentation".tr(),
            content: widget.currentUser!.getBio!,
            screenToGo: UpdateBioScreen(
              currentUser: widget.currentUser,
            ),
          ),
        ],
      ),
    );
  }

  Widget firstSelectOrShowPictures() {
    if (userPictures.length >= 1) {
      return showPictureCard(
        userImage: userPictures[0],
        radiusTopRight: 10,
        pictureIndex: 0,
      );
    } else if (picture_1 != null) {
      return showPictureCard(
          image: picture_1, radiusTopRight: 10, pictureIndex: 0);
    } else {
      return addPictureCard(radiusTopRight: 10);
    }
  }

  Widget secondSelectOrShowPictures() {
    if (userPictures.length >= 2) {
      return showPictureCard(
        userImage: userPictures[1],
        pictureIndex: 1,
      );
    } else if (picture_2 != null) {
      return showPictureCard(
        image: picture_2,
        pictureIndex: 1,
      );
    } else {
      return addPictureCard();
    }
  }

  Widget thirdSelectOrShowPictures() {
    if (userPictures.length >= 3) {
      return showPictureCard(
        userImage: userPictures[2],
        radiusBottomRight: 10,
        pictureIndex: 2,
      );
    } else if (picture_3 != null) {
      return showPictureCard(
          image: picture_3, radiusBottomRight: 10, pictureIndex: 2);
    } else {
      return addPictureCard(radiusBottomRight: 10);
    }
  }

  Widget fourthSelectOrShowPictures() {
    if (userPictures.length >= 4) {
      return showPictureCard(
        userImage: userPictures[3],
        pictureIndex: 3,
      );
    } else if (picture_4 != null) {
      return showPictureCard(
        image: picture_4,
        pictureIndex: 3,
      );
    } else {
      return addPictureCard();
    }
  }

  Widget fifthSelectOrShowPictures() {
    if (userPictures.length >= 5) {
      return showPictureCard(
        userImage: userPictures[4],
        radiusTopRight: 10,
        pictureIndex: 4,
      );
    } else if (picture_5 != null) {
      return showPictureCard(
        image: picture_5,
        radiusBottomLeft: 10,
        pictureIndex: 4,
      );
    } else {
      return addPictureCard(radiusBottomLeft: 10);
    }
  }

  Widget addPictureCard({
    double radiusTopRight = 0,
    double radiusBottomRight = 0,
    double radiusBottomLeft = 0,
  }) {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      width: size.width / 3.3,
      height: size.width / 3.5,
      color: kGrayWhite,
      radiusBottomRight: radiusBottomRight,
      radiusBottomLeft: radiusBottomLeft,
      radiusTopRight: radiusTopRight,
      borderWidth: 0,
      marginBottom: 3,
      onTap: () {
        userPictures.clear();
        getUserPictures();
        selectedPictures.clear();
        checkPermission(false);
      },
      child: Center(
        child: Icon(
          Icons.add,
          color: kGrayColor,
        ),
      ),
    );
  }

  Widget showPictureCard(
      {File? image,
      ParseFileBase? userImage,
      double radiusTopRight = 0,
      double radiusBottomRight = 0,
      double radiusBottomLeft = 0,
      required int pictureIndex}) {
    Size size = MediaQuery.of(context).size;
    bool isLocal = userImage == null;
    return ContainerCorner(
      width: size.width / 3.3,
      height: size.width / 3.5,
      color: kGrayWhite,
      radiusBottomRight: radiusBottomRight,
      radiusBottomLeft: radiusBottomLeft,
      radiusTopRight: radiusTopRight,
      borderWidth: 0,
      marginBottom: 5,
      onTap: () {
        userPictures.clear();
        getUserPictures();
        selectedPictures.clear();
        openSettingsSheet(pictureIndex);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(radiusTopRight),
          bottomLeft: Radius.circular(radiusBottomLeft),
          bottomRight: Radius.circular(radiusBottomRight),
        ),
        child: imageWidget(
            isLocal: isLocal, image: image, networkImage: userImage),
      ),
    );
  }

  Widget imageWidget(
      {required bool isLocal, File? image, ParseFileBase? networkImage}) {
    if (isLocal && image != null) {
      return Image.file(
        image,
        fit: BoxFit.cover,
      );
    } else if (!isLocal && networkImage != null) {
      return QuickActions.pictureWithDifferentRadius(
        networkImage.url,
      );
    } else {
      return Container();
    }
  }

  void openSettingsSheet(int index) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showSettingsSheet(index);
        });
  }

  Widget showSettingsSheet(int pictureIndex) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.2,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setState) {
              return ContainerCorner(
                radiusTopLeft: 25,
                radiusTopRight: 25,
                color:
                    isDarkMode ? Colors.black : Colors.white.withOpacity(0.9),
                borderWidth: 0,
                child: Scaffold(
                  backgroundColor: kTransparentColor,
                  body: Column(
                    children: List.generate(
                      settingsTitles.length,
                      (index) => options(
                        caption: settingsTitles[index],
                        index: index,
                        pictureIndex: pictureIndex,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget options({
    required String caption,
    required int index,
    required int pictureIndex,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerCorner(
          height: 55,
          width: size.width,
          marginTop: index == (settingsTitles.length - 1) ? 6 : 0,
          radiusTopRight: index == 0 ? 25 : 0,
          radiusTopLeft: index == 0 ? 25 : 0,
          color: isDarkMode ? kContentDarkShadow : Colors.white,
          onTap: () {
            if (index == (settingsTitles.length - 1)) {
              QuickHelp.goBackToPreviousPage(context);
            } else {
              QuickHelp.goBackToPreviousPage(context);
              deletePicture(pictureIndex);
            }
          },
          child: Center(
            child: TextWithTap(
              caption,
              fontSize: size.width / 23,
            ),
          ),
        ),
        Visibility(
          visible: index < (settingsTitles.length - 2),
          child: ContainerCorner(
            height: 0.5,
            color: kGrayColor.withOpacity(0.5),
            width: size.width,
          ),
        ),
      ],
    );
  }

  Widget userNotModifyData({required String title, required String content}) {
    return ContainerCorner(
      marginLeft: 10,
      marginRight: 10,
      marginTop: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWithTap(
                title,
                marginRight: 5,
              ),
              TextWithTap("edit_data_screen.not_modified".tr(),
                  color: kGrayColor)
            ],
          ),
          TextWithTap(
            content,
            color: kGrayColor,
            marginRight: 5,
          ),
        ],
      ),
    );
  }

  Widget userDataToModify(
      {required String title, required String content, Widget? screenToGo}) {
    return ContainerCorner(
      marginLeft: 10,
      marginRight: 10,
      marginTop: 20,
      onTap: () {
        if (screenToGo != null) {
          QuickHelp.goToNavigatorScreen(context, screenToGo);
        } else {
          showCalendar();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWithTap(title),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWithTap(
                content,
                color: kGrayColor,
                marginRight: 5,
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: kGrayColor,
                size: 13,
              )
            ],
          ),
        ],
      ),
    );
  }

  showCalendar() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                isDarkMode ? kContentColorLightTheme : Colors.white,
            insetPadding: EdgeInsets.only(left: 10, right: 10),
            content: ContainerCorner(
              height: 400,
              width: size.width,
              child: CalendarDatePicker2WithActionButtons(
                config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDayOfWeek: 1,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  selectedDayHighlightColor: Colors.purple[800],
                ),
                onValueChanged: (dates) => setState(() {
                  dateTime = dates[0]!;
                }),
                onCancelTapped: () {
                  setState(() {
                    dateTime = widget.currentUser!.getBirthday!;
                  });
                  QuickHelp.hideLoadingDialog(context);
                },
                onOkTapped: () {
                  _validateBirthday(
                      "${dateTime.day}/${dateTime.month}/${dateTime.year}");
                  QuickHelp.hideLoadingDialog(context);
                },
                value: [],
              ),
            ),
          );
        });
  }

  String? _validateBirthday(String value) {
    isValidBirthday = false;
    if (value.isEmpty) {
      return "profile_screen.choose_birthday".tr();
    } else if (!QuickHelp.isValidDateBirth(value, QuickHelp.dateFormatDmy)) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "personal_data.error_".tr(),
        message: "profile_screen.invalid_date".tr(),
        isError: true,
        user: widget.currentUser!,
      );
    } else if (!QuickHelp.minimumAgeAllowed(value, QuickHelp.dateFormatDmy)) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "personal_data.error_".tr(),
        message: "profile_screen.mim_age_required"
            .tr(namedArgs: {'age': Setup.minimumAgeToRegister.toString()}),
        isError: true,
        user: widget.currentUser!,
      );
      setState(() {
        dateTime = widget.currentUser!.getBirthday!;
      });
    } else {
      isValidBirthday = true;
      myBirthday = value;
      updateBirthDay();
      return null;
    }
    return null;
  }

  updateBirthDay() {
    widget.currentUser!.setBirthday = dateTime;
    widget.currentUser!.save();
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
        String imageName = 'user_pic_${i}_${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        if (isAvatar) {
          setState(() {
            avatarFile = tempFile;
          });
          updateAvatar();
        } else {
          setState(() {
            selectedPictures.add(tempFile);
          });

          if (userPictures.length == 0) {
            picture_1 = tempFile;
          } else if (userPictures.length == 1) {
            picture_2 = tempFile;
          } else if (userPictures.length == 2) {
            picture_3 = tempFile;
          } else if (userPictures.length == 3) {
            picture_4 = tempFile;
          } else if (userPictures.length == 4) {
            picture_5 = tempFile;
          }
          addUserPicture();
        }
      }
    } else {
      print("Photos null");
    }
  }

  updateAvatar() async {
    QuickHelp.showLoadingDialog(context);

    if (avatarFile!.absolute.path.isNotEmpty) {
      avatarPicture =
          ParseFile(File(avatarFile!.absolute.path), name: "avatar.jpg");
    } else {
      avatarPicture =
          ParseWebFile(avatarFile!.readAsBytesSync(), name: "avatar.jpg");
    }

    widget.currentUser!.setAvatar = avatarPicture!;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first;
        avatarURL = widget.currentUser!.getAvatar!.url!;
      });
      QuickHelp.showAppNotificationAdvanced(
        title: "edit_data_screen.updated_success_title".tr(),
        message: "edit_data_screen.avatarUpdated_success_explain".tr(),
        isError: false,
        context: context,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "edit_data_screen.error_".tr(),
        message: "edit_data_screen.updated_failed_explain".tr(),
        context: context,
      );
    }
  }

  addUserPicture() async {
    QuickHelp.showLoadingDialog(context);
    DateTime date = DateTime.now();

    for (int i = 0; i < selectedPictures.length; i++) {
      if (selectedPictures[i].absolute.path.isNotEmpty) {
        parseFiles.add(ParseFile(File(selectedPictures[i].absolute.path),
            name: "profile_picture_${date.second}_${date.millisecond}.jpg"));
      } else {
        parseFiles.add(ParseWebFile(selectedPictures[i].readAsBytesSync(),
            name: "profile_picture_${date.second}_${date.millisecond}.jpg"));
      }
    }

    widget.currentUser!.setImagesList = parseFiles;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);

      parseFiles.clear();
      selectedPictures.clear();
      setState(() {
        widget.currentUser = response.results!.first;
      });
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "edit_data_screen.error_".tr(),
        message: "edit_data_screen.updated_failed_explain".tr(),
        context: context,
      );
    }
  }

  deletePicture(int index) async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeImageFromList =
        widget.currentUser!.getImagesList![index];
    ParseResponse parseResponse = await widget.currentUser!.save();

    if (parseResponse.success && parseResponse.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = parseResponse.results!.first;
      });
      userPictures.clear();
      cleanFiles();
      getUserPictures();
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "edit_data_screen.error_".tr(),
        message: "edit_data_screen.updated_failed_explain".tr(),
        context: context,
      );
    }
  }
}
