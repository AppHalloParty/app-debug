// ignore_for_file: unused_local_variable, must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../app/constants.dart';
import '../../app/setup.dart';
import '../../helpers/quick_actions.dart';
import '../../models/GiftsModel.dart';
import '../prebuild_live/global_private_live_price_sheet.dart';
import '../prebuild_live/multi_users_live_screen.dart';
import '../prebuild_live/prebuild_audio_room_screen.dart';
import '../prebuild_live/prebuild_live_screen.dart';
import '../upload_live_photo/upload_live_photo_screen.dart';
import 'package:flutter/cupertino.dart' as cupertino;

class LivePreviewScreen extends StatefulWidget {
  UserModel? currentUser;
  int? liveTypeIndex;

  LivePreviewScreen({
    Key? key,
    this.currentUser,
    this.liveTypeIndex,
  }) : super(key: key);

  static String route = "/live/preview";

  @override
  _LivePreviewScreenState createState() => _LivePreviewScreenState();
}

class _LivePreviewScreenState extends State<LivePreviewScreen>
    with TickerProviderStateMixin {
  String? _privacySelection = LiveStreamingModel.privacyTypeAnyone;

  TextEditingController liveTitleTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<CameraDescription>? listOfCameras;
  CameraController? cameraController;
  bool isFrontCamera = false;
  late Future<void> initializeControllerFuture;

  bool partyBtnSelected = false;
  bool goLiveBtnSelected = true;
  bool battleBtnSelected = false;

  bool isFirstTime = false;

  var liveTagsSelected = [];

  int pagesIndex = 1;

  bool showTempAlert = false;
  bool showErrorOnTitleInput = false;

  late SharedPreferences preferences;


  bool privateLive = false;
  GiftsModel? privateLiveGiftPrice;

  var shareOptionIcons = [
    "assets/images/icon_share_facebook_tr.png",
    "assets/images/icon_share_messager_tr.png",
    "assets/images/icon_share_whatsapp_tr.png",
    "assets/images/icon_share_line_tr.png",
  ];

  var selectedPartyChair = [
    "assets/images/ic_party_person_4_select.png",
    "assets/images/ic_party_person_6_select.png",
    "assets/images/ic_party_person_9_select.png",
  ];

  //var audioRoomSeatsNumber = [8,12,16,20,24];
  var audioRoomSeatsNumber = [8,12,16];

  var unselectedPartyChair = [
    "assets/images/ic_party_person_4_unselect.png",
    "assets/images/ic_party_person_6_unselect.png",
    "assets/images/ic_party_person_9_unselect.png",
  ];

  var selectedPartyChairsNumber = [0];
  var selectedAudioRoomSeatNumber = [0];

  var liveTitle = [
    "random_live_title.live_chat".tr(),
    "random_live_title.playing_chat".tr(),
    "random_live_title.live_cooking".tr(),
    "random_live_title.leve_music".tr(),
    "random_live_title.live_meme".tr(),
    "random_live_title.relaxing_live".tr(),
    "random_live_title.complete_live".tr(),
    "random_live_title.drawing_live".tr(),
    "random_live_title.to_films".tr(),
  ];

  var liveTypeOptionTitle = [
    "go_live_options.video_stream".tr(),
    "go_live_options.live_party".tr(),
    "go_live_options.audio_stream".tr(),
  ];

  @override
  void initState() {
    super.initState();
    initSharedPref();
    loadCamera();
    liveTitle.add("random_live_title.live_with_me".tr(
      namedArgs: {"name": "${widget.currentUser!.getUsername}"},
    ));
    liveTitle.shuffle();
    liveTitleTextController.text = liveTitle[3];

    liveTagsSelected = [
      QuickHelp.getLiveTagsList()[0],
      QuickHelp.getLiveTagsList()[1],
      QuickHelp.getLiveTagsList()[2],
      QuickHelp.getLiveTagsList()[3],
    ];

    isFirstLive();
  }

  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);
  final countNotifier = ValueNotifier<String>('1');

  @override
  void dispose() {
    super.dispose();
  }

  bool switchedCamera = false;

  loadCamera() async {
    listOfCameras = await availableCameras();

    CameraDescription selectedCamera = isFrontCamera
        ? listOfCameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front)
        : listOfCameras!.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);

    cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.ultraHigh,
    );

    initializeControllerFuture = cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });

    if (!mounted) return;

    setState(() {});
  }

  switchCamera() {
    setState(() {
      if (switchedCamera) {
        cameraController =
            CameraController(listOfCameras![0], ResolutionPreset.ultraHigh);
        switchedCamera = false;
      } else {
        cameraController =
            CameraController(listOfCameras![1], ResolutionPreset.ultraHigh);
        switchedCamera = true;
      }
      cameraController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Scaffold(
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              backgroundColor: kContentColorLightTheme,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: kTransparentColor,
                leading: Visibility(
                  visible: pagesIndex == 0,
                  child: IconButton(
                    onPressed: () => switchCamera(),
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => QuickHelp.goBackToPreviousPage(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              body: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: ContainerCorner(
                  color: kTransparentColor,
                  borderWidth: 0,
                  marginBottom: 0,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      ContainerCorner(
                        width: size.width,
                        height: size.height,
                        borderWidth: 0,
                        child: background(),
                        marginBottom: 0,
                      ),
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            liveTitleAndTags(),
                            ContainerCorner(
                              borderWidth: 0,
                              marginTop: 2,
                              color: Colors.black.withOpacity(0.2),
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ContainerCorner(
                                      width: size.width / 1.5,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          TextWithTap(
                                            "private_live_title".tr(),
                                            fontSize: 16,
                                            marginBottom: 10,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          TextWithTap(
                                            "private_live_explain".tr(),
                                            color: kGreyColor1,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        cupertino.CupertinoSwitch(
                                          value: privateLive,
                                          onChanged: (value) {
                                            setState(() {
                                              privateLive = value;
                                            });
                                            if(privateLive) {
                                              PrivateLivePriceWidget(
                                                  context: context,
                                                  onCancel: () {disablePrivateLive();},
                                                  onGiftSelected: (gift){
                                                    selectPrivateRoomPrice(gift);
                                                  }
                                              );
                                            }
                                          },
                                          activeColor: kPrimaryColor,
                                        ),
                                        if(privateLive && privateLiveGiftPrice != null)
                                          Column(
                                            children: [
                                              Container(
                                                width: 35,
                                                height: 35,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(3),
                                                  child: QuickActions.photosWidget(
                                                      privateLiveGiftPrice!.getPreview!.url),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/svg/ic_coin_with_star.svg",
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  TextWithTap(
                                                    privateLiveGiftPrice!.getCoins.toString(),
                                                    fontSize: 14,
                                                    marginLeft: 5,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                  )
                                                ],
                                              )
                                            ],
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            footer(),
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
                            "live_start_screen.choose_live_sub_type".tr(),
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
                ),
              ),
              bottomNavigationBar: ContainerCorner(
                borderWidth: 0,
                width: size.width,
                height: 40,
                marginBottom: 40,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          List.generate(liveTypeOptionTitle.length, (index) {
                        bool selected = pagesIndex == index;
                        return TextButton(
                          onPressed: () {
                            setState(() {
                              pagesIndex = index;
                            });
                          },
                          child: TextWithTap(
                            liveTypeOptionTitle[index],
                            color: selected ? Colors.white : kGreyColor1,
                            fontWeight:
                                selected ? FontWeight.w900 : FontWeight.w700,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
        return _showPassionsList();
      },
    );
  }

  Widget _showPassionsList() {
    Size size = MediaQuery.sizeOf(context);
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
        color: kWhitenDark,
        width: size.width,
        borderWidth: 0,
        child: Scaffold(
          backgroundColor: kTransparentColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: kTransparentColor,
            backgroundColor: kTransparentColor,
            title: Column(
              children: [
                TextWithTap(
                  "go_live_options.stream_tags".tr(),
                  fontSize: 18,
                  color: Colors.black,
                  alignment: Alignment.center,
                  marginBottom: 10,
                ),
              ],
            ),
            toolbarHeight: 80,
          ),
          body: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return ListView(
                padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: List.generate(
                      QuickHelp.getLiveTagsList().length,
                      (index) => Stack(
                        alignment: AlignmentDirectional.topEnd,
                        clipBehavior: Clip.none,
                        children: [
                          ContainerCorner(
                            onTap: () {
                              setState(() {
                                if (liveTagsSelected.contains(
                                    QuickHelp.getLiveTagsList()[index])) {
                                  liveTagsSelected.removeAt(
                                      liveTagsSelected.indexOf(QuickHelp
                                          .getLiveTagsList()[index]));
                                } else {
                                  if (liveTagsSelected.length < 5) {
                                    liveTagsSelected.add(
                                        QuickHelp.getLiveTagsList()[index]);
                                  }
                                }
                              });
                            },
                            color: liveTagsSelected.contains(
                                    QuickHelp.getLiveTagsList()[index])
                                ? kVioletColor
                                : kWhiteDarcula,
                            marginRight: 10,
                            borderWidth: 0,
                            marginBottom: 25,
                            borderRadius: 10,
                            child: TextWithTap(
                              "#${QuickHelp.getLiveTagsByCode(QuickHelp.getLiveTagsList()[index])}",
                              color: liveTagsSelected.contains(
                                      QuickHelp.getLiveTagsList()[index])
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                              marginLeft: 15,
                              marginRight: 15,
                              marginTop: 8,
                              marginBottom: 8,
                              fontSize: 13,
                            ),
                          ),
                          if (liveTagsSelected
                              .contains(QuickHelp.getLiveTagsList()[index]))
                            Positioned(
                              top: -5,
                              child: ContainerCorner(
                                color: kRedColor1,
                                borderWidth: 0,
                                borderRadius: 50,
                                child: TextWithTap(
                                  "${liveTagsSelected.indexOf(QuickHelp.getLiveTagsList()[index]) + 1}",
                                  color: Colors.white,
                                  fontSize: 8,
                                  marginRight: 5,
                                  marginLeft: 5,
                                  marginTop: 2,
                                  marginBottom: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: ContainerCorner(
            colors: [kPrimaryColor, kVioletColor],
            borderRadius: 20,
            borderWidth: 0,
            marginLeft: 40,
            marginRight: 40,
            marginBottom: 20,
            marginTop: 10,
            width: size.width,
            height: 50,
            onTap: () {
              QuickHelp.goBackToPreviousPage(context);
              saveLiveTag();
            },
            child: TextWithTap(
              "confirm_".tr(),
              color: Colors.white,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  selectPrivateRoomPrice(GiftsModel gift) {
    setState(() {
      privateLiveGiftPrice = gift;
    });
    QuickHelp.hideLoadingDialog(context);
  }

  disablePrivateLive() {
    QuickHelp.hideLoadingDialog(context);
    setState(() {
      privateLive = false;
      privateLiveGiftPrice = null;
    });
  }

  saveLiveTag() {
    setState(() {});
  }

  Widget footer() {
    var size = MediaQuery.of(context).size;
    if (pagesIndex == 0) {
      return ContainerCorner(
        color: kVioletColor,
        borderWidth: 0,
        height: 45,
        marginBottom: 45,
        borderRadius: 50,
        width: size.width / 1.8,
        onTap: () {
          if (ZegoUIKitPrebuiltLiveStreamingController()
              .minimize
              .isMinimizing) {
            return;
          }
          if (formKey.currentState!.validate()) {
            if (widget.currentUser!.getLiveCover != null) {
              startLive();
            } else {
              QuickHelp.showAppNotificationAdvanced(
                title: "live_starter_screen.select_live_cover_tittle".tr(),
                message: "live_starter_screen.select_live_cover_explain".tr(),
                context: context,
              );
            }
          }
        },
        child: TextWithTap(
          "live_streaming.go_live_btn".tr(),
          color: Colors.white,
          alignment: Alignment.center,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (pagesIndex == 1) {
      return ContainerCorner(
        width: size.width,
        marginLeft: 15,
        marginRight: 15,
        borderRadius: 10,
        borderWidth: 0,
        marginBottom: 15,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(selectedPartyChair.length, (index) {
                    return ContainerCorner(
                      onTap: () {
                        selectedPartyChairsNumber.clear();
                        setState(() {
                          selectedPartyChairsNumber.add(index);
                        });
                      },
                      child: Image.asset(
                        selectedPartyChairsNumber.contains(index)
                            ? selectedPartyChair[index]
                            : unselectedPartyChair[index],
                        height: size.width / 5,
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            ContainerCorner(
              color: kPurpleColor,
              borderWidth: 0,
              height: 45,
              borderRadius: 50,
              marginLeft: 10,
              width: size.width / 1.8,
              onTap: () {
                if (ZegoUIKitPrebuiltLiveStreamingController()
                    .minimize
                    .isMinimizing) {
                  return;
                }
                if (formKey.currentState!.validate()) {
                  startSelectedLiveType();
                }
              },
              child: TextWithTap(
                "live_start_screen.start_party".tr(),
                color: Colors.white,
                fontWeight: FontWeight.bold,
                alignment: Alignment.center,
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(audioRoomSeatsNumber.length, (index) {
              bool isSelected = selectedAudioRoomSeatNumber.contains(index);
              return ContainerCorner(
                onTap: () {
                  selectedAudioRoomSeatNumber.clear();
                  setState(() {
                    selectedAudioRoomSeatNumber.add(index);
                  });
                },
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [isSelected ? kRedColor1 : kTransparentColor, isSelected ? kGoogleColor: kTransparentColor],
                borderRadius: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWithTap(
                      "${audioRoomSeatsNumber[index]}",
                      color: isSelected ? Colors.white: Colors.white54,
                      fontWeight: FontWeight.w900,
                      marginRight: 5,
                      marginLeft: 3,
                    ),
                    SvgPicture.asset(
                      "assets/svg/audio_room_seats.svg",
                      width: 25,
                      colorFilter: ColorFilter.mode(
                        isSelected ? Colors.white: Colors.white54,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 3,),
                  ],
                ),
              );
            }),
          ),
          ContainerCorner(
            color: kVioletColor,
            borderWidth: 0,
            height: 45,
            marginBottom: 45,
            marginTop: 30,
            borderRadius: 50,
            width: size.width / 1.8,
            onTap: () {
              if (ZegoUIKitPrebuiltLiveStreamingController()
                  .minimize
                  .isMinimizing) {
                return;
              }
              if (formKey.currentState!.validate()) {
                if (widget.currentUser!.getLiveCover != null) {
                  createAudioRoom();
                } else {
                  QuickHelp.showAppNotificationAdvanced(
                    title: "live_starter_screen.select_live_cover_tittle".tr(),
                    message: "live_starter_screen.select_live_cover_explain".tr(),
                    context: context,
                  );
                }
              }
            },
            child: TextWithTap(
              "start_audio_room".tr(),
              color: Colors.white,
              alignment: Alignment.center,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
  }

  void createAudioRoom() async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);

    ParseResponse parseResponse = await queryBuilder.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveStreamingModel live =
            parseResponse.results!.first! as LiveStreamingModel;

        live.setStreaming = false;
        await live.save();

        startNewAudioRoom();
      } else {
        startNewAudioRoom();
      }
    } else {
      QuickHelp.showErrorResult(context, parseResponse.error!.code);
      QuickHelp.hideLoadingDialog(context);
    }
  }

  startNewAudioRoom() async {
    LiveStreamingModel streamingModel = LiveStreamingModel();
    streamingModel.setStreamingChannel = widget.currentUser!.objectId! +
        widget.currentUser!.getUid!.toString() +
        LiveStreamingModel.livePrefixAudioRoom;

    streamingModel.setAuthor = widget.currentUser!;
    streamingModel.setAuthorId = widget.currentUser!.objectId!;
    streamingModel.setAuthorUid = widget.currentUser!.getUid!;
    streamingModel.addAuthorTotalDiamonds =
        widget.currentUser!.getDiamondsTotal!;
    streamingModel.setFirstLive = widget.currentUser!.isFirstLive!;
    streamingModel.setAuthorUserName = widget.currentUser!.getUsername!;
    streamingModel.setHashtags = liveTagsSelected;

    if(privateLive && privateLiveGiftPrice != null) {
      streamingModel.setPrivate = true;
      streamingModel.setPrivateLivePrice = privateLiveGiftPrice!;
    }

    if(selectedAudioRoomSeatNumber[0] == 0) {
      streamingModel.setNumberOfChairs = audioRoomSeatsNumber[0];
    }else if(selectedAudioRoomSeatNumber[0] == 1){
      streamingModel.setNumberOfChairs = audioRoomSeatsNumber[1];
    }else if(selectedAudioRoomSeatNumber[0] == 2){
      streamingModel.setNumberOfChairs = audioRoomSeatsNumber[2];
    }else if(selectedAudioRoomSeatNumber[0] == 3){
      streamingModel.setNumberOfChairs = audioRoomSeatsNumber[3];
    }else if(selectedAudioRoomSeatNumber[0] == 4){
      streamingModel.setNumberOfChairs = audioRoomSeatsNumber[4];
    }

    streamingModel.setLiveTitle = liveTitleTextController.text;
    if (widget.currentUser!.getLiveCover != null) {
      streamingModel.setImage = widget.currentUser!.getLiveCover!;
    } else {
      streamingModel.setImage = widget.currentUser!.getAvatar!;
    }

    if (widget.currentUser!.getPartyTheme != null) {
      streamingModel.setPartyTheme = widget.currentUser!.getPartyTheme!;
    }
    streamingModel.setPartyType = LiveStreamingModel.liveAudio;
    streamingModel.setLiveType = LiveStreamingModel.liveAudio;

    if (widget.currentUser!.getGeoPoint != null) {
      streamingModel.setStreamingGeoPoint = widget.currentUser!.getGeoPoint!;
    }

    streamingModel.setStreaming = true;
    streamingModel.addViewersCount = 0;
    streamingModel.addDiamonds = 0;

    ParseResponse parseResponse = await streamingModel.save();

    if (parseResponse.success && parseResponse.results != null) {
      QuickHelp.hideLoadingDialog(context);
      LiveStreamingModel liveStreaming = parseResponse.results!.first!;
      QuickHelp.goToNavigatorScreen(
        context,
        PrebuildAudioRoomScreen(
          currentUser: widget.currentUser,
          isHost: true,
          liveStreaming: liveStreaming,
        ),
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  Widget background() {
    var size = MediaQuery.of(context).size;
    if (pagesIndex == 0) {
      if (cameraController == null) {
        return ContainerCorner(
          borderWidth: 0,
          width: size.width,
          height: size.height,
          color: kContentColorLightTheme,
        );
      } else {
        return CameraPreview(cameraController!);
      }
    } else if (pagesIndex == 1) {
      return Image.asset(
        "assets/images/live_bg.png",
        height: size.height,
        width: size.width,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset(
        "assets/images/audio_bg_start.png",
        height: size.height,
        width: size.width,
        fit: BoxFit.fill,
      );
    }
  }

  showTemporaryAlert() {
    setState(() {
      showTempAlert = true;
    });
    hideTemporaryAlert();
  }

  hideTemporaryAlert() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showTempAlert = false;
      });
    });
  }

  startSelectedLiveType() {
    if (liveTagsSelected.isEmpty) {
      showTemporaryAlert();
    } else {
      if (widget.currentUser!.getLiveCover != null) {
        createParty();
      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "live_starter_screen.select_live_cover_tittle".tr(),
          message: "live_starter_screen.select_live_cover_explain".tr(),
          context: context,
        );
      }
    }
  }

  Row whoCanSeeFilters(String gender, String text, String selected) {
    return Row(
      children: [
        Radio(
            activeColor: kPrimaryColor,
            value: gender,
            groupValue: _privacySelection,
            onChanged: (String? value) {
              setState(() {
                _privacySelection = value;
                widget.currentUser!.setGender = gender;
                //currentUser!.save();
              });
            }),
        SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _privacySelection = gender;
              widget.currentUser!.setGender = gender;
              //currentUser!.save();
            });
          },
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: selected == gender ? Colors.white : kGrayColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void isFirstLive() async {
    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);

    ParseResponse parseResponse = await queryBuilder.count();

    if (parseResponse.success) {
      if (parseResponse.count > 0) {
        isFirstTime = false;
      } else {
        isFirstTime = true;
      }
    }
  }

  Widget liveTitleAndTags() {
    Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        ContainerCorner(
          borderWidth: 0,
          marginTop: 5,
          width: 90,
          height: 90,
          marginLeft: 10,
          color: Colors.black.withOpacity(0.1),
          borderRadius: 10,
          onTap: () async {
            UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                context,
                UploadLivePhoto(
                  currentUser: widget.currentUser,
                ));
            if (user != null) {
              setState(() {
                widget.currentUser = user;
              });
            }
          },
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              if (widget.currentUser!.getLiveCover != null)
                QuickActions.photosWidget(
                  widget.currentUser!.getLiveCover!.url,
                  borderRadius: 8,
                ),
              if (widget.currentUser!.getLiveCover == null)
                Center(
                    child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 35,
                )),
              ContainerCorner(
                width: double.infinity,
                radiusBottomLeft: 7,
                radiusBottomRight: 7,
                height: 20,
                color: Colors.black.withOpacity(0.54),
                borderWidth: 0,
                child: TextWithTap(
                  "edit_photo".tr(),
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                  alignment: Alignment.center,
                  fontSize: 8,
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: ContainerCorner(
            height: 90,
            color: Colors.black.withOpacity(0.1),
            borderRadius: 10,
            marginRight: 20,
            marginLeft: 10,
            borderWidth: 0,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContainerCorner(
                    marginTop: 10,
                    height: 40,
                    width: size.width,
                    borderRadius: 10,
                    marginLeft: 10,
                    marginRight: 10,
                    borderColor:
                        showErrorOnTitleInput ? Colors.red : kTransparentColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 1),
                      child: TextFormField(
                        controller: liveTitleTextController,
                        maxLines: 1,
                        autocorrect: false,
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "live_streaming.enter_title".tr(),
                          hintStyle: GoogleFonts.roboto(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          errorStyle: GoogleFonts.roboto(
                            fontSize: 0.0,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) {
                          if (value!.isEmpty) {
                            showErrorOnTitleInput = true;
                            setState(() {});
                            return "";
                          } else {
                            showErrorOnTitleInput = false;
                            setState(() {});
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: liveTagsSelected.isEmpty,
                    child: TextWithTap(
                      "go_live_options.stream_tags".tr(),
                      fontSize: 12,
                      marginLeft: 10,
                      marginTop: 5,
                      color: Colors.white,
                      onTap: () => openSheet(),
                    ),
                  ),
                  Visibility(
                    visible: liveTagsSelected.isNotEmpty,
                    child: ContainerCorner(
                      height: 24,
                      width: size.width,
                      marginLeft: 10,
                      marginRight: 20,
                      onTap: () => openSheet(),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        children:
                            List.generate(liveTagsSelected.length, (index) {
                          return TextWithTap(
                            "#${QuickHelp.getLiveTagsByCode(liveTagsSelected[index])}",
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                            marginRight: 7,
                            fontSize: 13,
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void startLive() {
    if (liveTagsSelected.isEmpty) {
      liveTagsSelected.add(
        QuickHelp.getLiveTagsList()[5],
      );
    }
    createLive();
  }

  void createLive() async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);

    ParseResponse parseResponse = await queryBuilder.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveStreamingModel live =
            parseResponse.results!.first! as LiveStreamingModel;

        live.setStreaming = false;
        await live.save();

        createLiveFinish();
      } else {
        createLiveFinish();
      }
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "live_streaming.live_set_cover_error".tr(),
        message: parseResponse.error!.message,
        isError: true,
        user: widget.currentUser,
      );
    }
  }

  createLiveFinish() async {
    LiveStreamingModel streamingModel = LiveStreamingModel();
    if (Setup.isDebug) print("Check live 1");
    streamingModel.setStreamingChannel = widget.currentUser!.objectId! +
        widget.currentUser!.getUid!.toString() +
        LiveStreamingModel.livePrefixLive;
    if (Setup.isDebug) print("Check live 2");
    streamingModel.setAuthor = widget.currentUser!;
    if (Setup.isDebug) print("Check live 3");
    streamingModel.setAuthorId = widget.currentUser!.objectId!;
    if (Setup.isDebug) print("Check live 4");
    streamingModel.setAuthorUid = widget.currentUser!.getUid!;
    if (Setup.isDebug) print("Check live 5");
    streamingModel.addAuthorTotalDiamonds =
        widget.currentUser!.getDiamondsTotal!;
    if (Setup.isDebug) print("Check live 6");
    streamingModel.setFirstLive = widget.currentUser!.isFirstLive!;
    if (Setup.isDebug) print("Check live 7");

    if (widget.currentUser!.getLiveCover != null) {
      streamingModel.setImage = widget.currentUser!.getLiveCover!;
    } else {
      streamingModel.setImage = widget.currentUser!.getAvatar!;
    }

    if (Setup.isDebug) print("Check live 8");
    if (widget.currentUser!.getGeoPoint != null) {
      if (Setup.isDebug) print("Check live 9");
      streamingModel.setStreamingGeoPoint = widget.currentUser!.getGeoPoint!;
    }

    if (Setup.isDebug) print("Check live 10");

    if (Setup.isDebug) print("Check live 3");
    streamingModel.setStreaming = true;
    if (Setup.isDebug) print("Check live 14");
    streamingModel.addViewersCount = 0;
    if (Setup.isDebug) print("Check live 15");
    streamingModel.addDiamonds = 0;
    if (Setup.isDebug) print("Check live 16");

    streamingModel.setLiveTitle = liveTitleTextController.text;
    if (Setup.isDebug) print("Check live 16");

    streamingModel.setLiveType = LiveStreamingModel.liveVideo;
    streamingModel.setAuthorUserName = widget.currentUser!.getUsername!;
    streamingModel.setHashtags = liveTagsSelected;

    if(privateLive && privateLiveGiftPrice != null) {
      streamingModel.setPrivate = true;
      streamingModel.setPrivateLivePrice = privateLiveGiftPrice!;
    }

    streamingModel.save().then((value) {
      if (Setup.isDebug) print("Check live 17");

      if (value.success) {
        LiveStreamingModel liveStreaming = value.results!.first!;

        QuickHelp.hideLoadingDialog(context);

        QuickHelp.goToNavigatorScreen(
          context,
          PreBuildLiveScreen(
            currentUser: widget.currentUser,
            liveID: liveStreaming.getStreamingChannel!,
            localUserID: widget.currentUser!.objectId!,
            liveStreaming: liveStreaming,
            isHost: true,
          ),
        );

        if (widget.currentUser!.isFirstLive!) {
          widget.currentUser!.setIsFirstLive = false;
          widget.currentUser!.save().then((value) {
            if (value.success && value.results != null)
              setState(() {
                widget.currentUser = value.results!.first;
              });
          });
        }
      } else {
        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "live_streaming.live_set_cover_error".tr(),
            message: value.error!.message,
            isError: true,
            user: widget.currentUser);
      }

      if (Setup.isDebug) print("Check live 17 (1)");
    }).onError((ParseError error, stackTrace) {
      if (Setup.isDebug) print("Check live 18");

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "live_streaming.live_set_cover_error".tr(),
          message: "unknown_error".tr(),
          isError: true,
          user: widget.currentUser);
    }).catchError((err) {
      if (Setup.isDebug) print("Check live 19: $err");

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "live_streaming.live_set_cover_error".tr(),
          message: "unknown_error".tr(),
          isError: true,
          user: widget.currentUser);
    });
  }

  initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preferences);
  }

  void createParty() async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    QueryBuilder<LiveStreamingModel> queryBuilder =
        QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);

    ParseResponse parseResponse = await queryBuilder.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveStreamingModel live =
            parseResponse.results!.first! as LiveStreamingModel;

        live.setStreaming = false;
        await live.save();

        createLivePartyFinish();
      } else {
        createLivePartyFinish();
      }
    } else {
      QuickHelp.showErrorResult(context, parseResponse.error!.code);
      QuickHelp.hideLoadingDialog(context);
    }
  }

  createLivePartyFinish() async {
    int numberOfChairs = 0;
    LiveStreamingModel streamingModel = LiveStreamingModel();
    streamingModel.setStreamingChannel = widget.currentUser!.objectId! +
        widget.currentUser!.getUid!.toString() +
        LiveStreamingModel.livePrefixParty;

    streamingModel.setAuthor = widget.currentUser!;
    streamingModel.setAuthorId = widget.currentUser!.objectId!;
    streamingModel.setAuthorUid = widget.currentUser!.getUid!;
    streamingModel.addAuthorTotalDiamonds =
        widget.currentUser!.getDiamondsTotal!;
    streamingModel.setFirstLive = isFirstTime;
    streamingModel.setAuthorUserName = widget.currentUser!.getUsername!;

    streamingModel.setLiveTitle = liveTitleTextController.text;
    streamingModel.setImage = widget.currentUser!.getLiveCover!;
    streamingModel.setHashtags = liveTagsSelected;

    if(privateLive && privateLiveGiftPrice != null) {
      streamingModel.setPrivate = true;
      streamingModel.setPrivateLivePrice = privateLiveGiftPrice!;
    }

    if (widget.currentUser!.getPartyTheme != null) {
      streamingModel.setPartyTheme = widget.currentUser!.getPartyTheme!;
    }

    if (selectedPartyChairsNumber[0] == 0) {
      numberOfChairs = 4;
    } else if (selectedPartyChairsNumber[0] == 1) {
      numberOfChairs = 6;
    } else {
      numberOfChairs = 9;
    }
    streamingModel.setNumberOfChairs = numberOfChairs;

    streamingModel.setPartyType = LiveStreamingModel.liveVideo;
    streamingModel.setLiveType = LiveStreamingModel.liveTypeParty;

    if (widget.currentUser!.getGeoPoint != null) {
      streamingModel.setStreamingGeoPoint = widget.currentUser!.getGeoPoint!;
    }

    streamingModel.setStreaming = true;
    streamingModel.addViewersCount = 0;
    streamingModel.addDiamonds = 0;

    ParseResponse parseResponse = await streamingModel.save();

    if (parseResponse.success) {
      QuickHelp.hideLoadingDialog(context);
      LiveStreamingModel liveStreaming = parseResponse.results!.first!;

      QuickHelp.goToNavigatorScreen(
        context,
        MultiUsersLiveScreen(
          currentUser: widget.currentUser,
          liveID: liveStreaming.getStreamingChannel!,
          localUserID: widget.currentUser!.objectId!,
          liveStreaming: liveStreaming,
          isHost: true,
        ),
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, 100);
    }
  }
}
