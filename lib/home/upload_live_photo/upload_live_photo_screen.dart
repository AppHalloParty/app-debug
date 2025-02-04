// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

class UploadLivePhoto extends StatefulWidget {
  UserModel? currentUser;

  UploadLivePhoto({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<UploadLivePhoto> createState() => _UploadLivePhotoState();
}

class _UploadLivePhotoState extends State<UploadLivePhoto> {
  File? selectedPicture;
  ParseFileBase? parseFile;

  var imagesNotCompliant = [
    "assets/images/img_blurry_avatar.png",
    "assets/images/img_spllicing_pictures.png",
    "assets/images/img_small_character.png",
    "assets/images/img_picture_with_border.png",
    "assets/images/img_pornographic.png",
    "assets/images/img_face_covering.png",
    "assets/images/img_back_view.png",
    "assets/images/img_scenery_photo.png",
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark ? kContentColorLightTheme : kGrayWhite,
      appBar: AppBar(
        backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
        elevation: 1.5,
        centerTitle: true,
        title: TextWithTap(
          "upload_live_photo_screen.live_photo".tr(),
          fontWeight: FontWeight.w900,
        ),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
          onPressed: ()=> QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: ListView(
          children: [
            SizedBox(
              height: 30,
            ),
            photoWidget(),
            TextWithTap(
              "upload_live_photo_screen.start_your_live".tr(),
              marginTop: 20,
              marginBottom: 10,
              fontWeight: FontWeight.w700,
              alignment: Alignment.center,
            ),
            Divider(),
            ContainerCorner(
              borderRadius: 10,
              width: size.width,
              borderWidth: 0,
              height: 230,
              marginTop: 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    "host_rules_screen.cover_no_pass_audit".tr(),
                    marginTop: 7,
                    marginBottom: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: GridView.count(
                        crossAxisCount: 4,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(
                          imagesNotCompliant.length,
                          (index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                imagesNotCompliant[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget photoWidget() {
    Size size = MediaQuery.of(context).size;
    if (widget.currentUser!.getLiveCover != null) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: QuickActions.photosWidget(
                widget.currentUser!.getLiveCover!.url,
              height: size.width / 1.7,
              width: size.width / 1.7,
              borderRadius: 10
            ),
          ),
          Positioned(
            top: 0,
            right: size.width / 6,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.check_circle,
                color: kGreenLight,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ContainerCorner(
              borderRadius: 50,
              height: 35,
              width: size.width / 3,
              colors: [kSecondaryColor, kPrimaryColor],
              marginBottom: 5,
              onTap: () => checkPermission(false),
              child: TextWithTap(
                "upload_live_photo_screen.change_photo".tr(),
                color: Colors.white,
                alignment: Alignment.center,
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/live_photo_model.png",
              height: size.width / 1.7,
              width: size.width / 1.7,
            ),
          ),
          Positioned(
            top: 0,
            left: size.width / 6,
            child: ContainerCorner(
              borderRadius: 10,
              height: 35,
              width: size.width / 3,
              color: kBlueColor1,
              child: TextWithTap(
                "upload_live_photo_screen.sample_photo".tr(),
                color: Colors.white,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ContainerCorner(
              borderRadius: 50,
              height: 35,
              width: size.width / 3,
              colors: [kSecondaryColor, kPrimaryColor],
              marginBottom: 5,
              onTap: () => checkPermission(false),
              child: TextWithTap(
                "upload_live_photo_screen.upload_photo".tr(),
                color: Colors.white,
                alignment: Alignment.center,
              ),
            ),
          )
        ],
      );
    }
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
        String imageName =
            'live_photo_${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        setState(() {
          selectedPicture = tempFile;
        });

        uploadLivePhoto();
      }
    } else {
      print("Photos null");
    }
  }

  uploadLivePhoto() async {
    QuickHelp.showLoadingDialog(context);

    DateTime date = DateTime.now();

    if (selectedPicture!.absolute.path.isNotEmpty) {
      parseFile = ParseFile(File(selectedPicture!.absolute.path),
          name: "live_photo_${date.second}_${date.millisecond}.jpg");
    } else {
      parseFile = ParseWebFile(selectedPicture!.readAsBytesSync(),
          name: "live_photo_${date.second}_${date.millisecond}.jpg");
    }

    widget.currentUser!.setLiveCover = parseFile!;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first;
      });
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
