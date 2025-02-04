// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/home/feed/upload_banuba_edited_video_screen.dart';
import 'package:video_compress/video_compress.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'create_pictures_post_screen.dart';
import 'create_text_post_screen.dart';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trace/app/setup.dart';

import '../../audio_browser.dart';

import 'create_video_post_screen.dart';

/// The entry point for Audio Browser implementation
@pragma('vm:entry-point')
void audioBrowser() => runApp(AudioBrowserWidget());

class PostTypeChooserScreen extends StatefulWidget {
  UserModel? currentUser;

  PostTypeChooserScreen({this.currentUser, super.key});

  @override
  State<PostTypeChooserScreen> createState() => _PostTypeChooserScreenState();
}

class _PostTypeChooserScreenState extends State<PostTypeChooserScreen> {
  File? videoFile;
  File? thumbnailFile;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kDarkColorsTheme,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kDarkColorsTheme,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
        ),
        title: TextWithTap(
          "post_chooser_screen.create_post".tr(),
          fontSize: size.width / 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      body: ContainerCorner(
        borderWidth: 0,
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ContainerCorner(
                borderWidth: 0,
                borderRadius: 10,
                colors: [kColorsPink900, kColorsBlue900],
                width: size.width / 3.5,
                height: 140,
                begin: Alignment.topLeft,
                onTap: () {
                  QuickHelp.goToNavigatorScreen(
                    context,
                    CreateVideoPostScreen(
                      currentUser: widget.currentUser,
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      borderWidth: 0,
                      height: size.width / 10,
                      width: size.width / 10,
                      color: Colors.white,
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/svg/ic_video_post.svg",
                          height: size.width / 25,
                          width: size.width / 25,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextWithTap(
                      "post_chooser_screen.video_".tr(),
                      marginTop: 5,
                      fontSize: size.width / 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )
                  ],
                ),
              ),
              ContainerCorner(
                borderWidth: 0,
                borderRadius: 10,
                colors: [Colors.orangeAccent, kColorsDeepOrange600],
                width: size.width / 3.5,
                height: 160,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  CreatePicturesPostScreen(
                    currentUser: widget.currentUser!,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      borderWidth: 0,
                      height: size.width / 9,
                      width: size.width / 9,
                      color: Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: size.width / 22,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextWithTap(
                      "story.image_".tr(),
                      marginTop: 5,
                      fontSize: size.width / 25,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    )
                  ],
                ),
              ),
              ContainerCorner(
                borderWidth: 0,
                borderRadius: 10,
                colors: [Colors.deepPurpleAccent, kSecondaryColor],
                width: size.width / 3.5,
                height: 140,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  CreateTextPostScreen(
                    currentUser: widget.currentUser,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerCorner(
                      borderRadius: 50,
                      borderWidth: 0,
                      height: size.width / 10,
                      width: size.width / 10,
                      color: Colors.white,
                      child: TextWithTap(
                        "story.a_a".tr(),
                        fontSize: size.width / 25,
                        alignment: Alignment.center,
                        color: Colors.black,
                      ),
                    ),
                    TextWithTap(
                      "story.text_".tr(),
                      marginTop: 5,
                      fontSize: size.width / 27,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const platform = MethodChannel(Setup.channelName);

  String errorMessage = '';

  Future<void> _initVideoEditor() async {
    await platform.invokeMethod(
        Setup.methodInitVideoEditor, Setup.licenseToken);
  }

  Future<void> _startVideoEditorDefault() async {
    try {
      await _initVideoEditor();

      final result = await platform.invokeMethod(Setup.methodStartVideoEditor);

      _handleExportResult(result);
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  void _handleExportResult(dynamic result) async{
    debugPrint('Export result = $result');

    // You can use any kind of export result passed from platform.
    // Map is used for this sample to demonstrate playing exported video file.
    if (result is Map) {
      final exportedVideoFilePath = result[Setup.argExportedVideoFile];

      //print("resultados_video_editado $result");

      // Use video cover preview to meet your requirements
      final exportedVideoCoverPreviewPath =
          result[Setup.argExportedVideoCoverPreviewPath];

      String filePath = exportedVideoCoverPreviewPath;
      String reducedPath = filePath.replaceFirst("file://", "");

      thumbnailFile = File(reducedPath);
      videoFile = File(exportedVideoFilePath);

      QuickHelp.showLoadingDialogWithText(
          context,
          description: "prepare_video".tr(),
        backgroundColor: Colors.black.withOpacity(0.3),
      );
      var videoCompressed = await VideoCompress.compressVideo(
        videoFile!.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false, // It's false by default
      );
      QuickHelp.hideLoadingDialog(context);

      _showConfirmation(context, "banuba_video_editor_sdk.publish_video".tr(), () {
        //platform.invokeMethod(Setup.methodDemoPlayExportedVideo, exportedVideoFilePath);
        QuickHelp.goToNavigatorScreen(
          context,
          UploadBanubaEditedVideoScreen(
            currentUser: widget.currentUser,
            videoFile: videoCompressed!.file,
            thumbNailFile: thumbnailFile,
          ),
        );
      });
    }
  }

  Future<void> startVideoEditorPIP() async {
    try {
      await _initVideoEditor();

      // Use your implementation to provide correct video file path to start Video Editor SDK in PIP mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint(
            'Cannot open video editor with PIP - video was not selected!');
      } else {
        debugPrint('Open video editor in pip with video = ${file.path}');
        final result = await platform.invokeMethod(
            Setup.methodStartVideoEditorPIP, file.path);

        _handleExportResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  Future<void> startVideoEditorTrimmer() async {
    try {
      await _initVideoEditor();

      // Use your implementation to provide correct video file path to start Video Editor SDK in Trimmer mode
      final ImagePicker _picker = ImagePicker();
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (file == null) {
        debugPrint(
            'Cannot open video editor with Trimmer - video was not selected!');
      } else {
        debugPrint('Open video editor in trimmer with video = ${file.path}');
        final result = await platform.invokeMethod(
            Setup.methodStartVideoEditorTrimmer, file.path);

        _handleExportResult(result);
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    }
  }

  // Handle exceptions thrown on Android, iOS platform while opening Video Editor SDK
  void _handlePlatformException(PlatformException exception) {
    debugPrint("Error: '${exception.message}'.");

    QuickHelp.goToNavigatorScreen(
      context,
      CreateVideoPostScreen(
        currentUser: widget.currentUser,
      ),
    );

    String errorMessage = '';
    switch (exception.code) {
      case Setup.errEditorLicenseRevokedCode:
        errorMessage = Setup.errEditorLicenseRevokedMessage;
        break;
      case Setup.errEditorNotInitializedCode:
        errorMessage = Setup.errEditorNotInitializedMessage;
        break;
      default:
        errorMessage = 'unknown error';
    }

    errorMessage = errorMessage;
    setState(() {});
  }

  void _showConfirmation(
      BuildContext context, String message, VoidCallback block) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          MaterialButton(
            color: Colors.red,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.redAccent,
            onPressed: () => {Navigator.pop(context)},
            child: TextWithTap(
              "cancel".tr(),
            ),
          ),
          MaterialButton(
            color: Colors.green,
            textColor: Colors.white,
            disabledColor: Colors.grey,
            disabledTextColor: Colors.black,
            padding: const EdgeInsets.all(12.0),
            splashColor: Colors.greenAccent,
            onPressed: () {
              Navigator.pop(context);
              block.call();
            },
            child: TextWithTap(
              "ok_".tr(),
            ),
          )
        ],
      ),
    );
  }

  void openSheet() async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return showVideoEditorOptions();
      },
    );
  }

  Widget showVideoEditorOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: Colors.white,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  _startVideoEditorDefault();
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "video_editor_sdk_options.video_editor".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  color: Colors.black,
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  startVideoEditorPIP();
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "video_editor_sdk_options.video_editor_pip".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  color: Colors.black,
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  startVideoEditorTrimmer();
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "video_editor_sdk_options.video_editor_trimmer".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  color: Colors.black,
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  QuickHelp.goToNavigatorScreen(
                    context,
                    CreateVideoPostScreen(
                      currentUser: widget.currentUser,
                    ),
                  );
                },
                child: TextWithTap(
                  "video_editor_sdk_options.upload_video".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  color: Colors.black,
                ),
              ),
              Divider(),
              TextButton(
                onPressed: () {
                  QuickHelp.goBackToPreviousPage(context);
                },
                child: TextWithTap(
                  "cancel".tr(),
                  alignment: Alignment.center,
                  color: Colors.black,
                  marginBottom: 10,
                  marginTop: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
