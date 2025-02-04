// ignore_for_file: deprecated_member_use, must_be_immutable

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/helpers/send_notifications.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../models/PostsModel.dart';
import 'comment_post_screen.dart';

class CreateTextPostScreen extends StatefulWidget {
  UserModel? currentUser;
  CreateTextPostScreen({Key? key, this.currentUser})
      : super(key: key);

  @override
  State<CreateTextPostScreen> createState() => _CreateTextPostScreenState();
}

class _CreateTextPostScreenState extends State<CreateTextPostScreen> {
  TextEditingController postTextController = TextEditingController();
  bool showSendButton = false;
  FocusNode focusNode = FocusNode();

  late Color backgroundColor;
  late Color textColor;

  bool isKeyBoardVisible = true;

  @override
  void initState() {
    super.initState();

    backgroundColor = kPrimaryColor; // Material red.
    textColor = Colors.white; // A purple color.
    focusNode.requestFocus();
  }

  // Define custom colors. The 'guide' color values are from
  static const Color guidePrimary = Color(0xFF6200EE);
  static const Color guidePrimaryVariant = Color(0xFF3700B3);
  static const Color guideSecondary = Color(0xFF03DAC6);
  static const Color guideSecondaryVariant = Color(0xFF018786);
  static const Color guideError = Color(0xFFB00020);
  static const Color guideErrorDark = Color(0xFFCF6679);
  static const Color blueBlues = Color(0xFF174378);

  // Make a custom ColorSwatch to name map from the above custom colors.
  final Map<ColorSwatch<Object>, String> colorsNameMap =
      <ColorSwatch<Object>, String>{
    ColorTools.createPrimarySwatch(guidePrimary): 'Guide Purple',
    ColorTools.createPrimarySwatch(guidePrimaryVariant): 'Guide Purple Variant',
    ColorTools.createAccentSwatch(guideSecondary): 'Guide Teal',
    ColorTools.createAccentSwatch(guideSecondaryVariant): 'Guide Teal Variant',
    ColorTools.createPrimarySwatch(guideError): 'Guide Error',
    ColorTools.createPrimarySwatch(guideErrorDark): 'Guide Error Dark',
    ColorTools.createPrimarySwatch(blueBlues): 'Blue blues',
  };

  Future<bool> backgroundColorPicker() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: backgroundColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => backgroundColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: TextWithTap(
        'colors_picker.select_color'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      subheading: TextWithTap(
        'colors_picker.select_shade'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      wheelSubheading: TextWithTap(
        'colors_picker.select_both'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  Future<bool> textColorPicker() async {
    return ColorPicker(
      // Use the dialogPickerColor as start color.
      color: textColor,
      // Update the dialogPickerColor using the callback.
      onColorChanged: (Color color) => setState(() => textColor = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: TextWithTap(
        'colors_picker.select_color'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      subheading: TextWithTap(
        'colors_picker.select_shade'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      wheelSubheading: TextWithTap(
        'colors_picker.select_both'.tr(),
        color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      customColorSwatchesAndNames: colorsNameMap,
    ).showPickerDialog(
      context,
      constraints:
          const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        floatingActionButton: Visibility(
          visible: showSendButton,
          child: ContainerCorner(
            marginLeft: 10,
            marginRight: 10,
            borderWidth: 0,
            marginBottom: isKeyBoardVisible
                ? MediaQuery.of(context).viewInsets.bottom
                : 10,
            colors: [Colors.orangeAccent, kColorsDeepOrange600],
            child: ContainerCorner(
              borderWidth: 0,
              color: kTransparentColor,
              marginAll: 5,
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/ic_send_message.svg",
                  color: Colors.white,
                ),
              ),
            ),
            borderRadius: 50,
            height: size.width / 7,
            width: size.width / 7,
            onTap: () {
              createPost();
            },
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kTransparentColor,
          leading: const BackButton(
            color: Colors.white,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: IconButton(
                onPressed: () async {
                  final Color colorBeforeDialog = backgroundColor;
                  if (!(await backgroundColorPicker())) {
                    setState(() {
                      backgroundColor = colorBeforeDialog;
                    });
                  }
                },
                icon: Icon(
                  Icons.color_lens,
                  color: Colors.white,
                  size: size.width / 10,
                ),
              ),
            ),
            SizedBox(
              width: size.width / 30,
            ),
            IconButton(
              onPressed: () async {
                final Color colorBeforeDialog = textColor;
                if (!(await textColorPicker())) {
                  setState(() {
                    textColor = colorBeforeDialog;
                  });
                }
              },
              icon: TextWithTap(
                "T",
                color: Colors.white,
                fontSize: size.width / 10,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(
              width: size.width / 30,
            )
          ],
        ),
        body: ContainerCorner(
          color: backgroundColor,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              ContainerCorner(
                width: size.width,
                height: size.height,
                borderWidth: 0,
                marginBottom: 0,
                color: backgroundColor,
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: AutoSizeTextField(
                        cursorColor: Colors.white,
                        textAlign: TextAlign.center,
                        focusNode: focusNode,
                        autocorrect: false,
                        minFontSize: 14,
                        fullwidth: true,
                        stepGranularity: 7,
                        maxLines: 5,
                        style: GoogleFonts.nunito(
                          color: textColor,
                          fontSize: 49,
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (text.isEmpty) {
                              showSendButton = false;
                            } else {
                              showSendButton = true;
                            }
                          });
                        },
                        keyboardType: TextInputType.multiline,
                        controller: postTextController,
                        decoration: InputDecoration(
                          hintText: "post_chooser_screen.type_moment".tr(),
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.nunito(
                            color: textColor.withOpacity(0.4),
                            fontSize: 40,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _sendPushToFollowers(PostsModel post) async {
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
              SendNotifications.typePost,
              objectId: post.objectId!,
            );
          }
        }
      }
    }
  }

  createPost() async {
    QuickHelp.showLoadingDialog(context);

    PostsModel postModel = PostsModel();
    postModel.setAuthorId = widget.currentUser!.objectId!;
    postModel.setAuthor = widget.currentUser!;
    postModel.setText = postTextController.text;
    postModel.setTextColors = textColor.hex.toString();
    postModel.setBackgroundColor = backgroundColor.hex.toString();

    ParseResponse response = await postModel.save();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      PostsModel savedPost = response.results!.first;
      _sendPushToFollowers(savedPost);
      QuickHelp.goToNavigatorScreen(
        context,
        CommentPostScreen(
          currentUser: widget.currentUser,
          post: savedPost,
        ),
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error_creating.error_title".tr(),
        message: "error_creating.error_explain".tr(),
        context: context,
        isError: true,
      );
    }
  }
}
