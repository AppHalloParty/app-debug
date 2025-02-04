// ignore_for_file: deprecated_member_use, unnecessary_statements

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_cloud.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/coins/coins_payment_widget.dart';
import 'package:trace/models/CallsModel.dart';
import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/MessageListModel.dart';
import 'package:trace/models/MessageModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/utils/utilsConstants.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../app/setup.dart';
import '../../helpers/send_notifications.dart';
import '../agency/agent_invitation_screen.dart.dart';
import '../profile/user_profile_screen.dart';
import '../report/report_screen.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;

// ignore_for_file: must_be_immutable
class MessageScreen extends StatefulWidget {
  static String route = '/messages/chat';

  UserModel? currentUser, mUser;

  MessageScreen({Key? key, this.currentUser, this.mUser}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  SharedPreferences? preferences;
  TextEditingController messageController = TextEditingController();

  UserModel? currentUser, mUser;

  String? sendButtonIcon = "assets/svg/ic_menu_gifters.svg";
  Color sendButtonBackground = kColorsBlue400;

  var uploadPhoto;
  ParseFileBase? parseFile;

  int currentView = 0;
  List<Widget>? pages;

  var initialLoad;
  var settingsTitles = [];

  var callsTitles = [
    "calls_sheet.video_call".tr(),
    "calls_sheet.voice_call".tr(),
    "cancel".tr()
  ];

  var unreadMessages = [];

  bool emojiShowing = false;

  List<MessageModel> messages = [];

  bool showMicrophone = false;
  String micButtonCaption = "message_screen.press_to_talk".tr();

  FlutterSoundPlayer myPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder myRecorder = FlutterSoundRecorder();
  FlutterSound flutterSound = FlutterSound();

  String myPath = "";

  String voiceDuration = "00:00";
  String currentVoiceMessageURL = "";

  ParseFileBase? audioFile;
  String? globalVoiceUrl;
  String? globalVoiceDuration;

  bool blockedByMe = false;
  bool blockedByHim = false;

  bool audioPlaying = false;
  bool animateAudioPlaying = false;

  bool cancelNotice = false;

  final StopWatchTimer stopWatchTimer = StopWatchTimer();

  final StopWatchTimer audioTimer = StopWatchTimer();

  String messageKey = "messageKey";

  ScrollController _scrollController = new ScrollController();

  double initialPosition = 0.0;
  double actualPosition = 0.0;

  bool showTempAlert = false;

  showTemporaryAlert() {
    setState(() {
      showTempAlert = true;
    });
    hideTemporaryAlert();
  }

  hideTemporaryAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showTempAlert = false;
      });
    });
  }

  Future<void> startRecording() async {
    Initialized.fullyInitialized;

    var tempDir = await getTemporaryDirectory();
    myPath = '${tempDir.path}/flutter_sound.aac';

    await myRecorder.startRecorder(
      toFile: myPath,
      codec: Codec.aacADTS,
    );

    setState(() {
      showMicrophone = true;
      micButtonCaption = "message_screen.release_to_send".tr();
    });

    stopWatchTimer.onExecute.add(StopWatchExecute.start);
  }

  checkMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      startRecording();
    } else {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.microphone_access".tr(),
          message: "permissions.microphone_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);
            requestMicrophonePermission();
          });
    }
  }

  Future<void> requestMicrophonePermission() async {
    var asked = await Permission.microphone.request();

    if (asked.isGranted) {
      startRecording();
    } else if (asked.isDenied) {
      QuickHelp.showAppNotification(
          context: context,
          title: "permissions.microphone_access_denied".tr(),
          isError: true);
    } else if (asked.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.microphone_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.microphone_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);
            openAppSettings();
          });
    }
  }

  playAndPause(String voiceUrl) {
    if (currentVoiceMessageURL == voiceUrl) {
      if (myPlayer.isPlaying || myPlayer.isPaused) {
        pausePlayer(voiceUrl);
      } else {
        play(voiceUrl);
      }
    } else {
      play(voiceUrl);
    }
  }

  void play(String voiceUrl) async {
    audioTimer.onExecute.add(StopWatchExecute.reset);
    await myPlayer.startPlayer(
      fromURI: voiceUrl,
      codec: Codec.aacADTS,
      whenFinished: () {
        setState(() {
          audioPlaying = false;
          animateAudioPlaying = false;
          audioTimer.onExecute.add(StopWatchExecute.reset);
        });
      },
    );
    audioTimer.onExecute.add(StopWatchExecute.start);
    setState(() {
      audioPlaying = true;
      animateAudioPlaying = true;
      currentVoiceMessageURL = voiceUrl;
    });
  }

  Future<void> pausePlayer(String voiceUrl) async {
    if (myPlayer.isPlaying) {
      await myPlayer.pausePlayer();
      setState(() {
        audioPlaying = false;
        animateAudioPlaying = false;
      });
      audioTimer.onExecute.add(StopWatchExecute.stop);
    } else if (myPlayer.isPaused) {
      await myPlayer.resumePlayer();
      setState(() {
        audioPlaying = true;
        animateAudioPlaying = true;
      });
      audioTimer.onExecute.add(StopWatchExecute.start);
    } else {
      play(voiceUrl);
    }
  }

  Future<void> stopRecording() async {
    await myRecorder.stopRecorder();
    stopWatchTimer.onExecute.add(StopWatchExecute.reset);
  }

  Future<void> saveVoiceMessage() async {
    stopRecording();

    if (QuickHelp.isWebPlatform()) {
      ParseWebFile file = ParseWebFile(null, name: "voice.aac", url: myPath);
      await file.download();
      audioFile = ParseWebFile(file.file, name: file.name);
    } else {
      audioFile = ParseFile(File(myPath), name: "voice.aac");
    }
    final player = AudioPlayer();
    if (audioFile != null) {
      var duration = await player.setFilePath(myPath);

      _saveMessage(
        "voice",
        messageType: MessageModel.messageTypeVoice,
        voiceMessage: audioFile,
        voiceDuration: QuickHelp.getDurationInMinutes(duration: duration),
      );
    }
  }

  //Live query stuff
  late QueryBuilder<MessageModel> queryBuilder;
  final LiveQuery liveQuery = LiveQuery();
  Subscription? subscription;
  List<dynamic> results = <dynamic>[];

  GroupedItemScrollController listScrollController =
      GroupedItemScrollController();

  String toggleVoiceKeyboardButton = "assets/svg/ic_voice_message.svg";

  void openPicture(ParseFileBase picture) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showMessagePictureBottomSheet(picture);
        });
  }

  _choosePhoto() async {
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
      final File? image = await result.first.file;
      cropPhoto(image!.path);
    } else {
      print("Photos null");
    }
  }

  void cropPhoto(String path) async {
    CroppedFile? croppedFile =
        await ImageCropper().cropImage(sourcePath: path, uiSettings: [
      AndroidUiSettings(
          toolbarTitle: "edit_photo".tr(),
          toolbarColor: kPrimaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false),
      IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    ]);

    if (croppedFile != null) {
      compressImage(croppedFile.path, setState);
    }
  }

  void compressImage(String path, StateSetter setState) {
    QuickHelp.showLoadingAnimation();

    Future.delayed(Duration(seconds: 1), () async {
      var result = await QuickHelp.compressImage(path);

      if (result != null) {
        uploadFile(result, setState);
      } else {
        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "crop_image_scree.cancelled_by_user".tr(),
          message: "crop_image_scree.image_not_cropped_error".tr(),
        );
      }
    });
  }

  uploadFile(XFile imageFile, StateSetter setState) async {
    if (imageFile.path.isNotEmpty) {
      parseFile = ParseFile(File(imageFile.path), name: "avatar.jpg");

      setState(() {
        uploadPhoto = imageFile.path;
      });
    } else {
      setState(() {
        uploadPhoto = imageFile.readAsBytes();
      });

      parseFile = ParseWebFile(imageFile.readAsBytes() as foundation.Uint8List?,
          name: "avatar.jpg");
    }

    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await parseFile!.save();
    if (parseResponse.success) {
      QuickHelp.hideLoadingDialog(context);
      _saveMessage(MessageModel.messageTypePicture,
          messageType: MessageModel.messageTypePicture, pictureFile: parseFile);
    } else {
      QuickHelp.showLoadingDialog(context);
      QuickHelp.showAppNotification(
          context: context, title: parseResponse.error!.message);
    }
  }

  void changeButtonIcon(String text) {
    setState(() {
      if (text.isNotEmpty) {
        sendButtonIcon = "assets/svg/ic_send_message.svg";
        sendButtonBackground = kPrimaryColor;
      } else {
        sendButtonIcon = "assets/svg/ic_menu_gifters.svg";
        sendButtonBackground = kColorsBlue400;
      }
    });
  }

  clearChatHistory() async {
    for (MessageModel message in messages) {
      await message.delete();
      messageKey = QuickHelp.generateUId().toString();
    }

    setState(() {
      this.results.clear();
      messages.clear();
    });
  }

  String blackListText() {
    if (widget.currentUser!.getIdFromBlackList!
        .contains(widget.mUser!.objectId!)) {
      return "message_settings.un_block".tr();
    } else {
      return "message_settings.add_into_blacklist".tr();
    }
  }

  addToBlackList() async {
    widget.currentUser!.setIdToBlackList = widget.mUser!.objectId!;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      setState(() {
        widget.currentUser = response.results!.first;
        blockedByMe = true;
      });
      showTemporaryAlert();
    } else {
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        message: "audio_chat.invitation_failed_explain".tr(),
        context: context,
      );
    }
  }

  removeToBlackList() async {
    widget.currentUser!.removeIdFromBlackList = widget.mUser!.objectId!;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      setState(() {
        widget.currentUser = response.results!.first;
        blockedByMe = false;
      });
    } else {
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        message: "audio_chat.invitation_failed_explain".tr(),
        context: context,
      );
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(microseconds: 100), () {
      setState(() {
        initialLoad = _loadMessages();
      });
    });

    //Open audio session
    myPlayer.openPlayer().then((value) {
      setState(() {
        Initialized.fullyInitialized;
      });
    });

    if (QuickHelp.isMobile()) {
      myRecorder.openRecorder().then((value) {
        setState(() {
          Initialized.fullyInitialized;
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();

    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
    }

    stopWatchTimer.dispose();
    audioTimer.dispose();

    //close audion session
    myRecorder.closeRecorder();
    myPlayer.closePlayer();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    settingsTitles = [
      blackListText(),
      "message_settings.clear_chat_history".tr(),
      "message_settings.report_".tr(),
      "message_settings.cancel_".tr()
    ];

    bool isDarkMode = QuickHelp.isDarkMode(context);

    blockedByMe = widget.currentUser!.getIdFromBlackList!
        .contains(widget.mUser!.objectId);
    blockedByHim = widget.mUser!.getIdFromBlackList!
        .contains(widget.currentUser!.objectId);

    if (currentUser == null && mUser == null) {
      currentUser = widget.currentUser;
      mUser = widget.mUser;
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }

        setState(() {
          emojiShowing = false;
        });
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: 75,
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BackButton(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  ContainerCorner(
                    width: 22,
                    height: 22,
                    borderWidth: 0,
                    borderRadius: 50,
                    color:
                        unreadMessages.isEmpty ? kTransparentColor : Colors.red,
                    onTap: () => QuickHelp.goBackToPreviousPage(context),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: unreadMessagesCount(),
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    widget.mUser!.getUsername!,
                    marginRight: 3,
                  ),
                  QuickActions.userState(
                    state: widget.mUser!.getUserStateInApp!,
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () => openSettingsSheet(),
                    icon: RotatedBox(
                      quarterTurns: 1,
                      child: SvgPicture.asset(
                        "assets/svg/ic_post_config.svg",
                        color: isDarkMode ? Colors.white : kGrayColor,
                        height: 15,
                        width: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                _messageSpace(context),
                Visibility(
                  visible: showMicrophone,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContainerCorner(
                        borderWidth: 0,
                        borderRadius: 10,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : Colors.black.withOpacity(0.7),
                        width: 180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StreamBuilder<int>(
                              stream: stopWatchTimer.secondTime,
                              initialData: 0,
                              builder: (context, snap) {
                                final value = snap.data;
                                voiceDuration = QuickHelp.formatTime(value!);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: TextWithTap(
                                        QuickHelp.formatTime(value),
                                        color: isDarkMode
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Lottie.asset("assets/lotties/ic_message_mic.json",
                                width: 150, height: 150),
                            Visibility(
                              visible: !cancelNotice,
                              child: TextWithTap(
                                "message_screen.slide_up_to_send".tr(),
                                color: isDarkMode ? Colors.black : Colors.white,
                                marginBottom: 10,
                              ),
                            ),
                            Visibility(
                              visible: cancelNotice,
                              child: ContainerCorner(
                                height: 35,
                                radiusBottomRight: 10,
                                radiusBottomLeft: 10,
                                width: 180,
                                color: Colors.red,
                                child: Center(
                                  child: TextWithTap(
                                    "message_screen.release_to_cancel".tr(),
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ContainerCorner(
                            borderRadius: 50,
                            borderWidth: 2,
                            marginRight: 15,
                            borderColor: Colors.red,
                            height: 45,
                            width: 45,
                            onTap: () {
                              setState(() {
                                showMicrophone = false;
                              });
                              micButtonCaption =
                                  "message_screen.press_to_talk".tr();
                              stopRecording();
                              stopWatchTimer.onExecute
                                  .add(StopWatchExecute.reset);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.red,
                                size: 15,
                              ),
                            ),
                          ),
                          ContainerCorner(
                            borderRadius: 50,
                            borderWidth: 2,
                            marginLeft: 15,
                            borderColor: Colors.greenAccent,
                            height: 45,
                            width: 45,
                            onTap: () {
                              setState(() {
                                showMicrophone = false;
                              });
                              micButtonCaption =
                                  "message_screen.press_to_talk".tr();
                              saveVoiceMessage();
                              stopWatchTimer.onExecute
                                  .add(StopWatchExecute.reset);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.send,
                                color: Colors.greenAccent,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: showTempAlert,
            child: ContainerCorner(
              color: Colors.black.withOpacity(0.5),
              height: 50,
              marginRight: 50,
              marginLeft: 50,
              borderRadius: 50,
              width: size.width / 2,
              shadowColor: kGrayColor,
              shadowColorOpacity: 0.3,
              child: TextWithTap(
                "added_".tr(),
                color: Colors.white,
                marginBottom: 5,
                marginTop: 5,
                marginLeft: 15,
                marginRight: 15,
                fontSize: 12,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget unreadMessagesCount() {
    QueryBuilder<MessageModel> query =
        QueryBuilder<MessageModel>(MessageModel());

    query.whereEqualTo(MessageModel.keyReceiver, currentUser!);
    query.whereEqualTo(MessageModel.keyRead, false);

    int? indexToRemove;

    return ParseLiveListWidget<MessageModel>(
      query: query,
      scrollController: _scrollController,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<MessageModel> snapshot) {
        if (snapshot.failed) {
          return showViewersCount(amountText: "${unreadMessages.length}");
        }

        if (snapshot.hasData) {
          MessageModel message = snapshot.loadedData!;

          if (!unreadMessages.contains(message.getAuthorId)) {
            if (message.isRead!) {
              unreadMessages.add(message.objectId);

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                return await _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 5),
                    curve: Curves.easeInOut);
              });
            }
          } else {
            if (!message.isRead!) {
              for (int i = 0; i < unreadMessages.length; i++) {
                if (unreadMessages[i] == message.objectId) {
                  indexToRemove = i;
                }
              }

              unreadMessages.removeAt(indexToRemove!);
            }
          }

          return showViewersCount(
              amountText: "${QuickHelp.convertToK(unreadMessages.length)}");
        } else {
          return showViewersCount(amountText: "${unreadMessages.length}");
        }
      },
      listLoadingElement:
          showViewersCount(amountText: "${unreadMessages.length}"),
      queryEmptyElement:
          showViewersCount(amountText: "${unreadMessages.length}"),
    );
  }

  Widget showViewersCount({required String amountText}) {
    return TextWithTap(
      amountText,
      color: unreadMessages.isEmpty ? kTransparentColor : Colors.white,
      fontSize: 9,
      marginLeft: 2,
      marginTop: 2,
    );
  }

  void openStartCallSheet(bool isVideo) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showStartCallsSheet(isVideo);
        });
  }

  Widget showStartCallsSheet(bool isVideo) {
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setState) {
              return ContainerCorner(
                radiusTopLeft: 25,
                radiusTopRight: 25,
                borderWidth: 0,
                imageDecoration: "assets/images/live_bg.png",
                child: Scaffold(
                  backgroundColor: kTransparentColor,
                  body: SizedBox(
                    width: size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QuickActions.avatarWidget(
                          widget.mUser!,
                          width: 100,
                          height: 100,
                        ),
                        TextWithTap(
                          widget.mUser!.getFullName!,
                          fontSize: 20,
                          marginBottom: 10,
                          marginTop: 10,
                          fontWeight: FontWeight.w900,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          color: Colors.white,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ContainerCorner(
                              color: kRedColor1,
                              height: 60,
                              width: 60,
                              borderRadius: 50,
                              marginRight: 30,
                              onTap: () => QuickHelp.hideLoadingDialog(context),
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                              ),
                            ),
                            ZegoSendCallInvitationButton(
                              isVideoCall: isVideo,
                              resourceID: Setup.zegoPushResourceID,
                              invitees: [
                                ZegoUIKitUser(
                                  id: widget.mUser!.objectId!,
                                  name: widget.mUser!.getFullName!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

  void openCallBottomSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showCallsSheet();
        });
  }

  Widget showCallsSheet() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.3,
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
                      callsTitles.length,
                      (index) => callsOptions(
                        caption: callsTitles[index],
                        index: index,
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

  Widget callsOptions({required String caption, required int index}) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);
    String coinsNeeded = "";
    String callIcon = "";

    if (index == 0) {
      coinsNeeded = Setup.coinsNeededForVideoCallPerMinute.toString();
      callIcon = "assets/svg/ic_video_call.svg";
    } else if (index == 1) {
      coinsNeeded = Setup.coinsNeededForVoiceCallPerMinute.toString();
      callIcon = "assets/svg/ic_voice_call.svg";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerCorner(
          height: 55,
          width: size.width,
          marginTop: index == (callsTitles.length - 1) ? 6 : 0,
          radiusTopRight: index == 0 ? 25 : 0,
          radiusTopLeft: index == 0 ? 25 : 0,
          color: isDarkMode ? kContentDarkShadow : Colors.white,
          onTap: () {
            if (index == 0) {
              startCall(true);
            } else if (index == 1) {
              startCall(false);
            } else {
              QuickHelp.goBackToPreviousPage(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: index != 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: SvgPicture.asset(
                        callIcon,
                        height: 17,
                        width: 17,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  TextWithTap(
                    caption,
                    fontSize: size.width / 23,
                  ),
                ],
              ),
              Visibility(
                visible: index != 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/ic_coin_inactive.svg",
                      height: 9,
                      width: 9,
                    ),
                    TextWithTap(
                      "calls_sheet.coin_per_minute"
                          .tr(namedArgs: {"coins_amount": coinsNeeded}),
                      fontSize: 10,
                      marginLeft: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Visibility(
            visible: index < (callsTitles.length - 2),
            child: ContainerCorner(
              height: 0.5,
              color: kGrayColor.withOpacity(0.5),
              width: size.width,
            ))
      ],
    );
  }

  void openSettingsSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showSettingsSheet();
        });
  }

  Widget showSettingsSheet() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.3,
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

  goToUserProfile(UserModel user) {
    QuickHelp.goToNavigatorScreen(
      context,
      UserProfileScreen(
        currentUser: widget.currentUser,
        mUser: user,
        isFollowing: widget.currentUser!.getFollowing!.contains(user.objectId),
      ),
    );
  }

  Widget options({required String caption, required int index}) {
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
            } else if (index == (settingsTitles.length - 2)) {
              QuickHelp.goToNavigatorScreen(
                  context,
                  ReportScreen(
                    currentUser: widget.currentUser,
                    userToReport: widget.mUser,
                  ));
            } else if (index == 1) {
              QuickHelp.goBackToPreviousPage(context);
              clearChatHistory();
            } else if (index == 0) {
              if (widget.currentUser!.getIdFromBlackList!
                  .contains(widget.mUser!.objectId)) {
                removeToBlackList();
              } else {
                addToBlackList();
              }
              QuickHelp.goBackToPreviousPage(context);
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
            ))
      ],
    );
  }

  startCall(bool isVideoCall) {
    if (isVideoCall) {
      if (currentUser!.getCredits! >= Setup.coinsNeededForVideoCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.video_call_price".tr(),
            message: "video_call.video_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVideoCallPerMinute.toString(),
              "name": mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () async {
              QuickHelp.hideLoadingDialog(context);
              openStartCallSheet(true);

              /*UserModel? userModel =
                  await QuickHelp.goToNavigatorScreenForResult(
                      context,
                      QuickHelp.goToNavigatorScreen(
                        context,
                        CallPage(
                          callID: "caleras",
                          currentUser: widget.currentUser,
                        ),
                      ));

              currentUser = userModel;*/
            });
      } else {
        QuickHelp.showAppNotificationAdvanced(
            title: "video_call.no_coins".tr(),
            message: "video_call.no_coins_video".tr(namedArgs: {
              "coins": Setup.coinsNeededForVideoCallPerMinute.toString()
            }),
            context: context,
            isError: true);

        CoinsFlowPayment(
            context: context,
            currentUser: currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print("onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
              startCall(true);
            });
      }
    } else {
      if (currentUser!.getCredits! >= Setup.coinsNeededForVoiceCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.voice_call_price".tr(),
            message: "video_call.voice_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVoiceCallPerMinute.toString(),
              "name": mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () {
              QuickHelp.hideLoadingDialog(context);
              openStartCallSheet(false);

              /*QuickHelp.goToNavigatorScreen(
                context,
                CallPage(
                  callID: "caleras",
                  currentUser: widget.currentUser,
                ),
              );*/
            });
      } else {
        QuickHelp.showAppNotificationAdvanced(
            title: "video_call.no_coins".tr(),
            message: "video_call.no_coins_voice".tr(namedArgs: {
              "coins": Setup.coinsNeededForVoiceCallPerMinute.toString()
            }),
            context: context,
            isError: true);

        CoinsFlowPayment(
            context: context,
            currentUser: currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print("onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
              startCall(false);
            });
      }
    }
  }

  _updateMessageList(MessageListModel messageListModel) async {
    messageListModel.setIsRead = true;
    messageListModel.setCounter = 0;
    await messageListModel.save();
  }

  _updateMessageStatus(MessageModel messageModel) async {
    messageModel.setIsRead = true;
    await messageModel.save();
  }

  Future<void> _objectUpdated(MessageModel object) async {
    for (int i = 0; i < results.length; i++) {
      if (results[i].get<String>(keyVarObjectId) ==
          object.get<String>(keyVarObjectId)) {
        if (UtilsConstant.after(results[i], object) == null) {
          setState(() {
            // ignore: invalid_use_of_protected_member
            results[i] = object.clone(object.toJson(full: true));
          });
        }
        break;
      }
    }
  }

  setupLiveQuery() async {
    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilder);
    }

    subscription!.on(LiveQueryEvent.create, (MessageModel message) {
      if (message.getAuthorId == mUser!.objectId) {
        setState(() {
          results.add(message);
        });
      } else {
        setState(() {});
      }
    });

    subscription!.on(LiveQueryEvent.update, (MessageModel message) {
      _objectUpdated(message);
    });
  }

  Future<List<dynamic>?> _loadMessages() async {
    QueryBuilder<MessageModel> queryFrom =
        QueryBuilder<MessageModel>(MessageModel());

    queryFrom.whereEqualTo(MessageModel.keyAuthor, currentUser!);

    queryFrom.whereEqualTo(MessageModel.keyReceiver, mUser!);

    QueryBuilder<MessageModel> queryTo =
        QueryBuilder<MessageModel>(MessageModel());
    queryTo.whereEqualTo(MessageModel.keyAuthor, mUser!);
    queryTo.whereEqualTo(MessageModel.keyReceiver, currentUser!);

    queryBuilder = QueryBuilder.or(MessageModel(), [queryFrom, queryTo]);
    queryBuilder.orderByDescending(MessageModel.keyCreatedAt);

    setupLiveQuery();

    queryBuilder.includeObject([
      MessageModel.keyCall,
      MessageModel.keyAuthor,
      MessageModel.keyReceiver,
      MessageModel.keyListMessage,
    ]);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      print("Messages count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        for (MessageModel message in apiResponse.results!) {
          if (!messages.contains(message)) {
            messages.add(message);
            setState(() {});
          }
        }
        return apiResponse.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return apiResponse.error as dynamic;
    }
  }

  scrollToBottom(
      {required int position,
      bool? animated = false,
      int? duration = 3,
      Curve? curve = Curves.easeOut}) {
    if (listScrollController.isAttached) {
      if (animated = true) {
        listScrollController.scrollTo(
            index: position,
            duration: Duration(seconds: duration!),
            curve: curve!);
      } else {
        listScrollController.jumpTo(index: position, automaticAlignment: false);
      }
    }
  }

  Widget _messageSpace(BuildContext showContext) {
    Size size = MediaQuery.sizeOf(context);
    bool isDark = QuickHelp.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        key: Key(messageKey),
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>?>(
                future: initialLoad,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    results = snapshot.data as List<dynamic>;
                    var reversedList = results.reversed.toList();

                    return StickyGroupedListView<dynamic, DateTime>(
                      elements: reversedList,
                      reverse: true,
                      order: StickyGroupedListOrder.DESC,
                      // Check first
                      groupBy: (dynamic message) {
                        if (message.createdAt != null) {
                          return DateTime(message.createdAt!.year,
                              message.createdAt!.month, message.createdAt!.day);
                        } else {
                          return DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day);
                        }
                      },
                      floatingHeader: true,
                      groupComparator: (DateTime value1, DateTime value2) {
                        return value1.compareTo(value2);
                      },
                      itemComparator: (dynamic element1, dynamic element2) {
                        if (element1.createdAt != null &&
                            element2.createdAt != null) {
                          return element1.createdAt!
                              .compareTo(element2.createdAt!);
                        } else if (element1.createdAt == null &&
                            element2.createdAt != null) {
                          return DateTime.now().compareTo(element2.createdAt!);
                        } else if (element1.createdAt != null &&
                            element2.createdAt == null) {
                          return element1.createdAt!.compareTo(DateTime.now());
                        } else {
                          return DateTime.now().compareTo(DateTime.now());
                        }
                      },
                      groupSeparatorBuilder: (dynamic element) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 0, top: 3),
                          child: TextWithTap(
                            QuickHelp.getMessageTime(element.createdAt != null
                                ? element.createdAt!
                                : DateTime.now()),
                            textAlign: TextAlign.center,
                            color: kGreyColor1,
                            fontSize: 12,
                          ),
                        );
                      },
                      itemBuilder: (context, dynamic chatMessage) {
                        bool isMe =
                            chatMessage.getAuthorId! == currentUser!.objectId!
                                ? true
                                : false;
                        if (!isMe && !chatMessage.isRead!) {
                          _updateMessageStatus(chatMessage);
                        }

                        MessageModel message = chatMessage;

                        if (chatMessage.getMessageList != null &&
                            chatMessage.getMessageList!.getAuthorId ==
                                mUser!.objectId) {
                          MessageListModel chatList =
                              chatMessage.getMessageList as MessageListModel;

                          if (!chatList.isRead! &&
                              chatList.objectId ==
                                  chatMessage.getMessageListId) {
                            _updateMessageList(chatMessage.getMessageList!);
                          }
                        }

                        return Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Container(
                            padding: EdgeInsets.only(top: 20),
                            child: isMe
                                ? Align(
                                    alignment: Alignment.centerRight,
                                    child: Column(
                                      children: [
                                        if (chatMessage.getMessageType ==
                                            MessageModel
                                                .messageTypeAgencyInvitation)
                                          ContainerCorner(
                                            width: size.width / 2,
                                            color: isDark
                                                ? kContentColorLightTheme
                                                : Colors.white,
                                            borderRadius: 10,
                                            shadowColor: kGrayColor,
                                            shadowColorOpacity: 0.3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: TextWithTap(
                                                "add_host_screen.invitation_sent"
                                                    .tr(),
                                                fontWeight: FontWeight.w600,
                                                textAlign: TextAlign.center,
                                                marginTop: 5,
                                                marginBottom: 5,
                                              ),
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel
                                                .messageTypeLeaveAgencyApplication)
                                          ContainerCorner(
                                            width: size.width / 1.8,
                                            color: isDark
                                                ? kContentColorLightTheme
                                                : Colors.white,
                                            borderRadius: 10,
                                            shadowColor: kGrayColor,
                                            shadowColorOpacity: 0.3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                      "assets/images/img_leave_agency_msg.png"),
                                                  TextWithTap(
                                                    "leave_agency_screen.leave_agency_sent"
                                                        .tr(),
                                                    fontWeight: FontWeight.w600,
                                                    textAlign: TextAlign.center,
                                                    marginTop: 5,
                                                    marginBottom: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeVoice)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ContainerCorner(
                                                radiusBottomLeft: 10,
                                                radiusTopLeft: 10,
                                                radiusTopRight: 10,
                                                marginTop: 10,
                                                marginBottom: 10,
                                                color: widget.currentUser!
                                                            .getIsUserVip ==
                                                        true
                                                    ? kOrangeColorVip
                                                    : kPrimaryColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 3),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              playAndPause(
                                                                  chatMessage
                                                                      .getVoiceMessage!
                                                                      .url!);
                                                            },
                                                            icon: Icon(
                                                              audioPlaying &&
                                                                      currentVoiceMessageURL ==
                                                                          chatMessage
                                                                              .getVoiceMessage!
                                                                              .url!
                                                                  ? Icons
                                                                      .pause_circle
                                                                  : Icons
                                                                      .play_circle_filled,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextWithTap(
                                                                chatMessage
                                                                    .getVoiceDuration,
                                                                color: Colors
                                                                    .white,
                                                                marginRight: 15,
                                                                marginBottom: 2,
                                                              ),
                                                              Visibility(
                                                                visible: audioPlaying &&
                                                                    currentVoiceMessageURL ==
                                                                        chatMessage
                                                                            .getVoiceMessage!
                                                                            .url!,
                                                                child:
                                                                    StreamBuilder<
                                                                        int>(
                                                                  stream: audioTimer
                                                                      .secondTime,
                                                                  initialData:
                                                                      0,
                                                                  builder:
                                                                      (context,
                                                                          snap) {
                                                                    final value =
                                                                        snap.data;
                                                                    voiceDuration =
                                                                        QuickHelp.formatTime(
                                                                            value!);
                                                                    return TextWithTap(
                                                                      QuickHelp
                                                                          .formatTime(
                                                                              value),
                                                                      fontSize:
                                                                          9,
                                                                      color: Colors
                                                                          .amberAccent,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Lottie.asset(
                                                            "assets/lotties/ic_live_animation.json",
                                                            height: 27,
                                                            width: 27,
                                                            animate: animateAudioPlaying &&
                                                                currentVoiceMessageURL ==
                                                                    chatMessage
                                                                        .getVoiceMessage!
                                                                        .url!,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextWithTap(
                                                            chatMessage.createdAt !=
                                                                    null
                                                                ? QuickHelp.getMessageTime(
                                                                    chatMessage
                                                                        .createdAt!,
                                                                    time: true)
                                                                : "sending_"
                                                                    .tr(),
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.7),
                                                            fontSize: 10,
                                                            marginRight: 10,
                                                            marginLeft: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 3),
                                                            child: Icon(
                                                              chatMessage.createdAt !=
                                                                      null
                                                                  ? Icons
                                                                      .done_all
                                                                  : Icons
                                                                      .access_time_outlined,
                                                              color: chatMessage
                                                                      .isRead!
                                                                  ? kBlueColor1
                                                                  : Colors
                                                                      .white,
                                                              size: 11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5, bottom: 8),
                                                child:
                                                    QuickActions.avatarWidget(
                                                  currentUser!,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeCall)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ContainerCorner(
                                                radiusBottomLeft: 10,
                                                radiusTopLeft: 10,
                                                radiusTopRight: 10,
                                                marginTop: 10,
                                                marginBottom: 10,
                                                color: kColorsLightBlue300,
                                                child: callMessage(
                                                    chatMessage, true),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5),
                                                child:
                                                    QuickActions.avatarWidget(
                                                  currentUser!,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeText)
                                          ContainerCorner(
                                            radiusBottomLeft: 10,
                                            radiusTopLeft: 10,
                                            radiusTopRight: 10,
                                            colors: widget.currentUser!
                                                        .getIsUserVip ==
                                                    true
                                                ? [
                                                    kOrangeColorVip,
                                                    kOrangeColorVip
                                                  ]
                                                : [
                                                    kPrimaryColor,
                                                    kSecondaryColor
                                                  ],
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextWithTap(
                                                  chatMessage.getDuration!,
                                                  marginBottom: 5,
                                                  marginTop: 10,
                                                  color: Colors.white,
                                                  marginLeft: 10,
                                                  marginRight: 10,
                                                  fontSize: 14,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  selectableText: true,
                                                  urlDetectable: true,
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextWithTap(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? QuickHelp
                                                              .getMessageTime(
                                                                  chatMessage
                                                                      .createdAt!,
                                                                  time: true)
                                                          : "sending_".tr(),
                                                      color: Colors.white
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                      marginRight: 10,
                                                      marginLeft: 10,
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 3),
                                                      child: Icon(
                                                        chatMessage.createdAt !=
                                                                null
                                                            ? Icons.done_all
                                                            : Icons
                                                                .access_time_outlined,
                                                        color:
                                                            chatMessage.isRead!
                                                                ? kBlueColor1
                                                                : kGrayColor,
                                                        size: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeGif)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              gifMessage(
                                                  chatMessage.getGifMessage),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? Icons.done_all
                                                          : Icons
                                                              .access_time_outlined,
                                                      color: chatMessage.isRead!
                                                          ? kBlueColor1
                                                          : kGrayColor,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypePicture)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              pictureMessage(chatMessage
                                                  .getPictureMessage),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10),
                                                    child: Icon(
                                                      chatMessage.createdAt !=
                                                              null
                                                          ? Icons.done_all
                                                          : Icons
                                                              .access_time_outlined,
                                                      color: chatMessage.isRead!
                                                          ? kBlueColor1
                                                          : kGrayColor,
                                                      size: 15,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                      ],
                                    ),
                                  )
                                : Align(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (chatMessage.getMessageType ==
                                            MessageModel
                                                .messageTypeAgencyInvitation)
                                          ContainerCorner(
                                            width: size.width / 2,
                                            color: isDark
                                                ? kContentColorLightTheme
                                                : Colors.white,
                                            borderRadius: 10,
                                            shadowColor: kGrayColor,
                                            shadowColorOpacity: 0.3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Expanded(
                                                      child: SizedBox(
                                                    height: 100,
                                                  )),
                                                  TextWithTap(
                                                    "add_host_screen.you_received_invitation"
                                                        .tr(),
                                                    fontWeight: FontWeight.w600,
                                                    textAlign: TextAlign.center,
                                                    marginTop: 5,
                                                    marginBottom: 5,
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        message.getReceiverId ==
                                                            widget.currentUser!
                                                                .objectId,
                                                    child: ContainerCorner(
                                                      color: kPrimaryColor
                                                          .withOpacity(0.2),
                                                      borderRadius: 50,
                                                      height: 35,
                                                      width: size.width / 1.8,
                                                      marginLeft: 5,
                                                      marginRight: 5,
                                                      onTap: () {
                                                        QuickHelp
                                                            .goToNavigatorScreen(
                                                          context,
                                                          AgentInvitationScreen(
                                                            currentUser: widget
                                                                .currentUser,
                                                            agent: widget.mUser,
                                                          ),
                                                        );
                                                      },
                                                      child: TextWithTap(
                                                        "add_host_screen.go_check_out"
                                                            .tr(),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: kPrimaryColor,
                                                        alignment:
                                                            Alignment.center,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel
                                                .messageTypeLeaveAgencyApplication)
                                          ContainerCorner(
                                            width: size.width / 1.8,
                                            color: isDark
                                                ? kContentColorLightTheme
                                                : Colors.white,
                                            borderRadius: 10,
                                            shadowColor: kGrayColor,
                                            shadowColorOpacity: 0.3,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                      "assets/images/img_leave_agency_msg.png"),
                                                  TextWithTap(
                                                    "leave_agency_screen.leave_agency_msg"
                                                        .tr(namedArgs: {
                                                      "name":
                                                          "${message.getReceiver!.getFirstName}"
                                                    }),
                                                    fontWeight: FontWeight.w600,
                                                    textAlign: TextAlign.center,
                                                    marginTop: 5,
                                                    marginBottom: 5,
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        message.getReceiverId ==
                                                            widget.currentUser!
                                                                .objectId,
                                                    child: ContainerCorner(
                                                      color: kPrimaryColor
                                                          .withOpacity(0.2),
                                                      borderRadius: 50,
                                                      height: 35,
                                                      width: size.width / 1.8,
                                                      marginLeft: 5,
                                                      marginRight: 5,
                                                      child: TextWithTap(
                                                        "leave_agency_screen.immediate_processing"
                                                            .tr(),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: kPrimaryColor,
                                                        alignment:
                                                            Alignment.center,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeVoice)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 5, bottom: 8),
                                                child:
                                                    QuickActions.avatarWidget(
                                                  mUser!,
                                                  width: 30,
                                                  height: 30,
                                                ),
                                              ),
                                              ContainerCorner(
                                                radiusTopLeft: 10,
                                                radiusTopRight: 10,
                                                radiusBottomRight: 10,
                                                marginTop: 10,
                                                marginBottom: 10,
                                                color: widget.currentUser!
                                                            .getIsUserVip ==
                                                        true
                                                    ? kOrangeColorVip
                                                    : kGreyColor0,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 10.0,
                                                    left: 10,
                                                    right: 10,
                                                    bottom: 3,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              playAndPause(
                                                                  chatMessage
                                                                      .getVoiceMessage!
                                                                      .url!);
                                                            },
                                                            icon: Icon(
                                                              audioPlaying &&
                                                                      currentVoiceMessageURL ==
                                                                          chatMessage
                                                                              .getVoiceMessage!
                                                                              .url!
                                                                  ? Icons
                                                                      .pause_circle
                                                                  : Icons
                                                                      .play_circle_filled,
                                                              color:
                                                                  Colors.white,
                                                              size: 30,
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              TextWithTap(
                                                                chatMessage
                                                                    .getVoiceDuration,
                                                                color: Colors
                                                                    .white,
                                                                marginRight: 15,
                                                              ),
                                                              Visibility(
                                                                visible: audioPlaying &&
                                                                    currentVoiceMessageURL ==
                                                                        chatMessage
                                                                            .getVoiceMessage!
                                                                            .url!,
                                                                child:
                                                                    StreamBuilder<
                                                                        int>(
                                                                  stream: audioTimer
                                                                      .secondTime,
                                                                  initialData:
                                                                      0,
                                                                  builder:
                                                                      (context,
                                                                          snap) {
                                                                    final value =
                                                                        snap.data;
                                                                    voiceDuration =
                                                                        QuickHelp.formatTime(
                                                                            value!);
                                                                    return TextWithTap(
                                                                      QuickHelp
                                                                          .formatTime(
                                                                              value),
                                                                      fontSize:
                                                                          9,
                                                                      color: Colors
                                                                          .amberAccent,
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Lottie.asset(
                                                            "assets/lotties/ic_live_animation.json",
                                                            height: 27,
                                                            width: 27,
                                                            animate: animateAudioPlaying &&
                                                                currentVoiceMessageURL ==
                                                                    chatMessage
                                                                        .getVoiceMessage!
                                                                        .url!,
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      TextWithTap(
                                                        chatMessage.createdAt !=
                                                                null
                                                            ? QuickHelp
                                                                .getMessageTime(
                                                                    chatMessage
                                                                        .createdAt!,
                                                                    time: true)
                                                            : "sending_".tr(),
                                                        color: widget
                                                                    .currentUser!
                                                                    .getIsUserVip ==
                                                                true
                                                            ? Colors.white
                                                            : kGrayColor,
                                                        fontSize: 12,
                                                        marginRight: 10,
                                                        marginLeft: 10,
                                                        marginBottom: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeCall)
                                          ContainerCorner(
                                            radiusTopLeft: 10,
                                            radiusTopRight: 10,
                                            radiusBottomRight: 10,
                                            marginTop: 10,
                                            marginBottom: 10,
                                            color: kGreyColor0,
                                            child:
                                                callMessage(chatMessage, false),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeText)
                                          ContainerCorner(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    goToUserProfile(
                                                        chatMessage.getAuthor);
                                                  },
                                                  child:
                                                      QuickActions.avatarWidget(
                                                    mUser!,
                                                    width: 30,
                                                    height: 30,
                                                  ),
                                                ),
                                                Flexible(
                                                  child: GestureDetector(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        ContainerCorner(
                                                          radiusTopLeft: 10,
                                                          radiusTopRight: 10,
                                                          radiusBottomRight: 10,
                                                          marginRight: 10,
                                                          marginLeft: 5,
                                                          color: widget
                                                                      .currentUser!
                                                                      .getIsUserVip ==
                                                                  true
                                                              ? kOrangeColorVip
                                                              : kGreyColor0,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              TextWithTap(
                                                                chatMessage
                                                                    .getDuration!,
                                                                marginBottom:
                                                                    10,
                                                                marginTop: 10,
                                                                color: widget
                                                                            .currentUser!
                                                                            .getIsUserVip ==
                                                                        true
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                                marginLeft: 10,
                                                                marginRight: 10,
                                                                fontSize: 14,
                                                                selectableText:
                                                                    true,
                                                                urlDetectable:
                                                                    true,
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  TextWithTap(
                                                                    chatMessage.createdAt !=
                                                                            null
                                                                        ? QuickHelp.getMessageTime(
                                                                            chatMessage
                                                                                .createdAt!,
                                                                            time:
                                                                                true)
                                                                        : "sending_"
                                                                            .tr(),
                                                                    color: widget.currentUser!.getIsUserVip ==
                                                                            true
                                                                        ? Colors
                                                                            .white
                                                                        : kGrayColor,
                                                                    fontSize:
                                                                        12,
                                                                    marginRight:
                                                                        10,
                                                                    marginLeft:
                                                                        10,
                                                                    marginBottom:
                                                                        5,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypeGif)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              QuickActions.avatarWidget(mUser!,
                                                  width: 25, height: 25),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  gifMessage(chatMessage
                                                      .getGifMessage),
                                                  TextWithTap(
                                                    chatMessage.createdAt !=
                                                            null
                                                        ? QuickHelp
                                                            .getMessageTime(
                                                                chatMessage
                                                                    .createdAt!,
                                                                time: true)
                                                        : "sending_".tr(),
                                                    color: kGrayColor,
                                                    fontSize: 12,
                                                    marginRight: 10,
                                                    marginLeft: 10,
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        if (chatMessage.getMessageType ==
                                            MessageModel.messageTypePicture)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              QuickActions.avatarWidget(mUser!,
                                                  width: 25, height: 25),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  pictureMessage(chatMessage
                                                      .getPictureMessage),
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextWithTap(
                                                        chatMessage.createdAt !=
                                                                null
                                                            ? QuickHelp
                                                                .getMessageTime(
                                                                    chatMessage
                                                                        .createdAt!,
                                                                    time: true)
                                                            : "sending_".tr(),
                                                        color: kGrayColor,
                                                        fontSize: 12,
                                                        marginRight: 10,
                                                        marginLeft: 10,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      },
                      // optional
                      itemScrollController: listScrollController, // optional
                    );
                  } else if (snapshot.hasError) {
                    return ContainerCorner();
                  } else {
                    return Center(
                      child: QuickHelp.showLoadingAnimation(),
                    );
                  }
                }),
          ),
          Visibility(
            visible: blockedByHim || blockedByMe,
            child: TextWithTap(
              "message_screen.cannot_text"
                  .tr(namedArgs: {"name": widget.mUser!.getFirstName!}),
              textAlign: TextAlign.center,
              alignment: Alignment.center,
              marginBottom: 20,
            ),
          ),
          Visibility(
            visible: !blockedByHim && !blockedByMe,
            child: chatInputField(),
          ),
        ],
      ),
    );
  }

  Widget chatInputField() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      marginTop: 20,
      marginBottom: 10,
      marginLeft: 10,
      marginRight: 10,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  toggleVoiceKeyboardButton,
                  color:
                      isDarkMode ? Colors.white : Colors.black.withOpacity(0.7),
                  height: 25,
                  width: 25,
                ),
                onPressed: () {
                  setState(
                    () {
                      if (toggleVoiceKeyboardButton ==
                          "assets/svg/ic_voice_message.svg") {
                        toggleVoiceKeyboardButton =
                            "assets/svg/ic_keyboard.svg";
                      } else {
                        toggleVoiceKeyboardButton =
                            "assets/svg/ic_voice_message.svg";
                      }
                    },
                  );
                },
              ),
              Visibility(
                visible: toggleVoiceKeyboardButton !=
                    "assets/svg/ic_voice_message.svg",
                child: Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        checkMicPermission();
                      });
                    },
                    child: ContainerCorner(
                      borderWidth: 0,
                      borderRadius: 50,
                      height: 35,
                      color: kGrayColor.withOpacity(0.2),
                      child: Center(
                        child: TextWithTap(
                          micButtonCaption,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: toggleVoiceKeyboardButton ==
                    "assets/svg/ic_voice_message.svg",
                child: Expanded(
                  child: ContainerCorner(
                    borderWidth: 0,
                    borderRadius: 50,
                    height: 38,
                    color: kGrayColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        autocorrect: false,
                        keyboardType: TextInputType.multiline,
                        onChanged: (text) {
                          setState(() {
                            changeButtonIcon(text);
                          });
                        },
                        maxLines: 1,
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "message_screen.type_message".tr(),
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 14, color: kGrayColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ContainerCorner(
                height: 27,
                borderRadius: 50,
                borderWidth: 0,
                marginLeft: 10,
                color: kPrimaryColor,
                onTap: () {
                  if (messageController.text.isNotEmpty) {
                    _saveMessage(messageController.text,
                        messageType: MessageModel.messageTypeText);
                    setState(() {
                      messageController.text = "";
                    });
                  }
                },
                child: Center(
                  child: TextWithTap(
                    "greetingS_from_new_friend_screen.send_".tr(),
                    marginRight: 10,
                    marginLeft: 10,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              /*ContainerCorner(
                marginLeft: 10,
                color: sendButtonBackground,
                child: ContainerCorner(
                  color: kTransparentColor,
                  marginAll: 5,
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    sendButtonIcon!,
                    color: Colors.white,
                    height: 10,
                    width: 30,
                  ),
                ),
                borderRadius: 50,
                height: 45,
                width: 45,
                onTap: () {
                  if (messageController.text.isNotEmpty) {
                    _saveMessage(messageController.text,
                        messageType: MessageModel.messageTypeText);
                    setState(() {
                      messageController.text = "";
                      changeButtonIcon("");
                    });
                  } else {
                    CoinsFlowPayment(
                      context: context,
                      currentUser: currentUser!,
                      showOnlyCoinsPurchase: false,
                      onCoinsPurchased: (coins) {
                        print(
                            "onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
                      },
                      onGiftSelected: (gift) {
                        print("onGiftSelected called ${gift.getCoins}");
                        _checkAndSendGift(gift);
                      },
                    );
                  }
                },
              ),*/
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ContainerCorner(
                marginLeft: 20,
                height: 35,
                width: 35,
                onTap: () => openCallBottomSheet(),
                child: Lottie.asset("assets/lotties/ic_video_call.json",
                    repeat: false),
              ),
              ContainerCorner(
                marginLeft: 20,
                height: 35,
                width: 35,
                onTap: () => _choosePhoto(),
                child: SvgPicture.asset("assets/svg/ic_image.svg"),
              ),
              ContainerCorner(
                marginLeft: 10,
                height: 50,
                width: 50,
                onTap: () {
                  setState(() {
                    emojiShowing = !emojiShowing;
                  });
                },
                child: SvgPicture.asset("assets/svg/ic_emoji.svg"),
              ),
              ContainerCorner(
                marginLeft: 10,
                height: 40,
                width: 40,
                onTap: () {
                  CoinsFlowPayment(
                    context: context,
                    currentUser: currentUser!,
                    showOnlyCoinsPurchase: false,
                    onCoinsPurchased: (coins) {
                      print(
                          "onCoinsPurchased: $coins new: ${currentUser!.getCredits}");
                    },
                    onGiftSelected: (gift) {
                      print("onGiftSelected called ${gift.getCoins}");
                      _checkAndSendGift(gift);
                    },
                  );
                },
                child: Lottie.asset(
                  "assets/lotties/ic_gift.json",
                  repeat: false,
                ),
              ),
            ],
          ),
          Offstage(
            offstage: !emojiShowing,
            child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: messageController,
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.20
                              : 1.0),
                    ),
                    viewOrderConfig: const ViewOrderConfig(
                      top: EmojiPickerItem.categoryBar,
                      middle: EmojiPickerItem.emojiView,
                      bottom: EmojiPickerItem.searchBar,
                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(),
                    searchViewConfig: const SearchViewConfig(),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  _checkAndSendGift(GiftsModel gift) async {
    if (currentUser!.getCredits! >= gift.getCoins!) {
      currentUser!.removeCredit = gift.getCoins!;
      ParseResponse saved = await currentUser!.save();

      if (saved.success) {
        QuickCloudCode.sendGift(
          author: mUser!,
          credits: gift.getCoins!,
        );

        currentUser = saved.results!.first! as UserModel;

        _saveMessage(
          MessageModel.messageTypeGif,
          gif: gift.getFile!,
          messageType: MessageModel.messageTypeGif,
        );
      }
    }
  }

  // Save the message
  _saveMessage(String messageText,
      {ParseFileBase? gif,
      required String messageType,
      ParseFileBase? voiceMessage,
      String? voiceDuration,
      ParseFileBase? pictureFile}) async {
    if (messageText.isNotEmpty) {
      MessageModel message = MessageModel();

      message.setAuthor = currentUser!;
      message.setAuthorId = currentUser!.objectId!;

      if (pictureFile != null) {
        message.setPictureMessage = pictureFile;
      }

      if (voiceMessage != null) {
        message.setVoiceMessage = voiceMessage;
      }

      if (voiceDuration != null) {
        message.setVoiceDuration = voiceDuration;
      }

      message.setReceiver = mUser!;
      message.setReceiverId = mUser!.objectId!;

      message.setDuration = messageText;
      message.setIsMessageFile = false;

      message.setMessageType = messageType;

      message.setIsRead = false;

      if (!widget.currentUser!.getChatWithUsersIds!
          .contains(widget.mUser!.objectId!)) {
        widget.currentUser!.setChatWithUsersIds = widget.mUser!.objectId!;
        widget.currentUser!.save();
      }

      if (gif != null) {
        message.setGifMessage = gif;
      }

      setState(() {
        this.results.insert(0, message as dynamic);
      });

      await message.save();
      _saveList(message);

      SendNotifications.sendPush(
          currentUser!, mUser!, SendNotifications.typeChat,
          message: getMessageType(messageType, currentUser!.getFullName!,
              message: messageText));
    }
  }

  String getMessageType(String type, String name, {String? message}) {
    if (type == MessageModel.messageTypeGif) {
      return "push_notifications.new_gif_title".tr(namedArgs: {"name": name});
    } else if (type == MessageModel.messageTypePicture) {
      return "push_notifications.new_picture_title"
          .tr(namedArgs: {"name": name});
    } else {
      return message!;
    }
  }

  // Update or Create message list
  _saveList(MessageModel messageModel) async {
    QueryBuilder<MessageListModel> queryFrom =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(
        MessageListModel.keyListId, currentUser!.objectId! + mUser!.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(
        MessageListModel.keyListId, mUser!.objectId! + currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
        QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = currentUser!;
        messageListModel.setAuthorId = currentUser!.objectId!;

        messageListModel.setReceiver = mUser!;
        messageListModel.setReceiverId = mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.normalMessage;

        messageListModel.setIsRead = false;
        messageListModel.setListId = currentUser!.objectId! + mUser!.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = currentUser!;
        messageListModel.setAuthorId = currentUser!.objectId!;

        messageListModel.setReceiver = mUser!;
        messageListModel.setReceiverId = mUser!.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.normalMessage;

        messageListModel.setListId = currentUser!.objectId! + mUser!.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

  Widget gifMessage(ParseFileBase? gifMessage) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          child: Column(
            children: [
              ContainerCorner(
                color: kTransparentColor,
                marginTop: 5,
                marginLeft: 5,
                marginRight: 5,
                height: 160,
                width: 170,
                marginBottom: 5,
                borderRadius: 20,
                child: Lottie.network(gifMessage!.url!,
                    width: 170, height: 160, animate: true, repeat: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String voiceStatus(CallsModel call) {
    String response = "";

    if (!call.getAccepted! && call.getAuthorId! != currentUser!.objectId!) {
      response = "message_screen.missed_call".tr();
    } else if (call.getAuthorId != currentUser!.objectId!) {
      response = "message_screen.out_going_call".tr();
    } else if (call.getAuthorId == currentUser!.objectId!) {
      response = "message_screen.incoming_call".tr();
    }
    return response;
  }

  Widget callMessage(MessageModel messageModel, bool isMe) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ContainerCorner(
                marginRight: 50,
                marginLeft: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: !messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId! !=
                              currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_received,
                            color: Colors.red,
                          ),
                          TextWithTap(
                            "message_screen.missed_call".tr(),
                            color: Colors.red,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId! ==
                              currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_made,
                            color: Colors.red,
                          ),
                          TextWithTap(
                            "message_screen.missed_call".tr(),
                            color: Colors.red,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId ==
                              currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_made,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                          TextWithTap(
                            "message_screen.out_going_call".tr(),
                            color: Colors.white,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: messageModel.getCall!.getAccepted! &&
                          messageModel.getCall!.getAuthorId !=
                              currentUser!.objectId!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.call_received,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                          TextWithTap(
                            "message_screen.incoming_call".tr(),
                            color: isMe ? Colors.white : Colors.black,
                            marginLeft: 10,
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        TextWithTap(
                          QuickHelp.getMessageTime(messageModel.createdAt!,
                              time: true),
                          marginRight: 10,
                          color: isMe ? Colors.white : Colors.black,
                        ),
                        Visibility(
                          visible: messageModel.getCall!.getAccepted!,
                          child: TextWithTap(
                            messageModel.getCall!.getDuration!,
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              ContainerCorner(
                color: kGrayColor,
                height: 50,
                marginBottom: 5,
                marginRight: 2,
                marginTop: 5,
                borderRadius: 70,
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    messageModel.getCall!.getIsVoiceCall!
                        ? Icons.phone
                        : Icons.videocam,
                    color: Colors.white,
                    size: 25,
                  ),
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget callInfo(bool appear, IconData icon, String text) {
    return Visibility(
      visible: appear,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.red,
          ),
          TextWithTap(
            text,
            color: Colors.red,
            marginLeft: 10,
          )
        ],
      ),
    );
  }

  Widget pictureMessage(ParseFileBase picture) {
    return Column(
      children: [
        ContainerCorner(
          color: kTransparentColor,
          borderRadius: 20,
          onTap: () => openPicture(picture),
          child: Column(
            children: [
              ContainerCorner(
                color: kTransparentColor,
                marginTop: 5,
                marginLeft: 5,
                marginRight: 5,
                height: 200,
                width: 200,
                marginBottom: 5,
                child: QuickActions.photosWidget(
                    picture.saved ? picture.url : "",
                    borderRadius: 20,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _showMessagePictureBottomSheet(ParseFileBase picture) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    color: kTransparentColor,
                    height: MediaQuery.of(context).size.height - 200,
                    child: QuickActions.photosWidget(picture.url,
                        borderRadius: 5, fit: BoxFit.contain),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
