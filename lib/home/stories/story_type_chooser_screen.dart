// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/stories/create_photo_story_screen.dart';
import 'package:trace/home/stories/create_text_story_screen.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class StoryTypeChooserScreen extends StatefulWidget {
  UserModel? currentUser;

  StoryTypeChooserScreen({Key? key, this.currentUser}) : super(key: key);
  static String route = "/home/choose_story_type";

  @override
  State<StoryTypeChooserScreen> createState() => _StoryTypeChooserScreenState();
}

class _StoryTypeChooserScreenState extends State<StoryTypeChooserScreen> {


  @override
  void initState() {
    super.initState();
  }

  checkPermission() async {
    if (QuickHelp.isMobile()) {
      if (await Permission.camera.isGranted) {
        //Choose picture
        QuickHelp.goToNavigatorScreen(
            context,
            CreatePhotoStory(
              currentUser: widget.currentUser,
            ));
      } else if (await Permission.camera.isDenied) {
        QuickHelp.showDialogPermission(
            context: context,
            title: "permissions.photo_access".tr(),
            confirmButtonText: "permissions.okay_".tr().toUpperCase(),
            message: "permissions.photo_access_explain"
                .tr(namedArgs: {"app_name": Setup.appName}),
            onPressed: () async {
              QuickHelp.hideLoadingDialog(context);

              // You can request multiple permissions at once.
              Map<Permission, PermissionStatus> statuses =
                  await [Permission.camera].request();

              if (statuses[Permission.camera]!.isGranted) {
                //Choose picture
                QuickHelp.goToNavigatorScreen(
                    context,
                    CreatePhotoStory(
                      currentUser: widget.currentUser,
                    ));
              } else {
                QuickHelp.showAppNotificationAdvanced(
                    title: "permissions.photo_access_denied".tr(),
                    message: "permissions.photo_access_denied_explain"
                        .tr(namedArgs: {"app_name": Setup.appName}),
                    context: context,
                    isError: true);
              }
            });
      } else if (await Permission.camera.isPermanentlyDenied) {
        openAppSettings();
      }
    } else {
      QuickHelp.goToNavigatorScreen(
          context,
          CreatePhotoStory(
            currentUser: widget.currentUser,
          ));
    }
  }

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
            "story.create_story".tr(),
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
                  colors: [Colors.orangeAccent, kColorsDeepOrange300],
                  width: size.width / 3,
                  height: 170,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  onTap: () => checkPermission(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerCorner(
                        borderRadius: 50,
                        borderWidth: 0,
                        height: 55,
                        width: 55,
                        color: Colors.white,
                        child: Center(child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.black,
                        ),),
                      ),
                      TextWithTap(
                        "story.image_".tr(),
                        marginTop: 5,
                        fontSize: 18,
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
                  width: size.width / 3,
                  height: 170,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  onTap: () => QuickHelp.goToNavigatorScreen(
                      context,
                      CreateTextStoryScreen(
                        currentUser: widget.currentUser,
                      )),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ContainerCorner(
                        borderRadius: 50,
                        borderWidth: 0,
                        height: 55,
                        width: 55,
                        color: Colors.white,
                        child: TextWithTap(
                          "story.a_a".tr(),
                          fontSize: 18,
                          alignment: Alignment.center,
                          color: Colors.black,
                        ),
                      ),
                      TextWithTap(
                        "story.text_".tr(),
                        marginTop: 5,
                        fontSize: 18,
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
}
