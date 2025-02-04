// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:like_button/like_button.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_cloud.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/models/FanClubModel.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../../app/constants.dart';
import '../../app/setup.dart';
import '../../helpers/send_notifications.dart';
import '../../models/CommentsModel.dart';
import '../../models/FanClubMembersModel.dart';
import '../../models/GiftReceivedModel.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
import '../../models/ReportModel.dart';
import '../../models/VisitsModel.dart';

import '../../services/deep_links_service.dart';
import '../calls/video_call_screen.dart';
import '../calls/voice_call_screen.dart';
import '../coins/coins_payment_widget.dart';
import '../feed/comment_post_screen.dart';
import '../feed/feed_on_reels_screen.dart';
import '../ranking_fans/fans_ranking_screen.dart';
import '../report/report_screen.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatefulWidget {
  UserModel? currentUser, mUser;
  bool? isFollowing;

  UserProfileScreen({this.currentUser, this.mUser, this.isFollowing});

  static String route = '/user/profile';

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

AnimationController? _animationController;

class _UserProfileScreenState extends State<UserProfileScreen>
    with TickerProviderStateMixin {
  int tabIndex = 0;

  int tabsLength = 3;

  int tabData = 0;
  int tabGifts = 1;
  int tabMoments = 2;

  bool showTempAlert = false;

  late TabController _tabController;
  final CarouselController _controller = CarouselController();

  var fansFrames = [
    "assets/images/ic_fans_rank_frame_1.png",
    "assets/images/ic_fans_rank_frame_2.png",
    "assets/images/ic_fans_rank_frame_3.png",
  ];

  var topFansFrames = [
    "assets/images/ic_frame_top1.png",
    "assets/images/ic_frame_top2.png",
    "assets/images/ic_frame_top3.png",
  ];

  var ratingFansFrames = [
    "assets/images/bg_contribution_frame_1.png",
    "assets/images/bg_contribution_frame_1.png",
    "assets/images/bg_contribution_frame_1.png",
  ];

  var ratingsFansSeat = [
    "assets/images/bg_contribution_seat_frame_1.png",
    "assets/images/bg_contribution_seat_frame_2.png",
    "assets/images/bg_contribution_seat_frame_3.png",
  ];

  var callsTitles = [
    "calls_sheet.video_call".tr(),
    "calls_sheet.voice_call".tr(),
    "cancel".tr()
  ];

  var fansClubPrivileges = [
    "profile_page.sort_priority".tr(),
    "profile_page.fans_badge".tr(),
    "profile_page.exclusive_gift".tr()
  ];

  var fansClubPrivilegesIcons = [
    "assets/images/ic_sort_priority.png",
    "assets/images/ic_exclusive_gift.png",
    "assets/images/ic_fans_badge.png"
  ];

  bool showCopiedTempAlert = false;

  showCopiedTemporaryAlert() {
    setState(() {
      showCopiedTempAlert = true;
    });
    hideCopiedTemporaryAlert();
  }

  hideCopiedTemporaryAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showCopiedTempAlert = false;
      });
    });
  }

  int hostSpend = 10000;
  int fanCluGift = 300;
  int fanCluVoting = 15;
  int chatSpeak = 15;
  int intimacyIncreaseLimit = 5;
  int fanClubRenewalFee = 300;
  int platformFloatTag = 50;
  int feeToJoinFanClub = 100;
  int timeDeadDays = 30;

  int fanClubIndex = 0;

  var fanClubPrivileges = [];

  List<UserModel> fanClubUsersList = [];
  List<UserModel> fanRankingUsersList = [];

  List<dynamic> postsResults = <dynamic>[];

  List<ParseFileBase> userPictures = [];

  var _future;

  List<PostsModel> allPosts = [];

  late FocusNode? commentTextFieldFocusNode;

  int _current = 0;
  bool blockedByMe = false;

  TextEditingController commentController = TextEditingController();

  var settingsTitles = [];

  String blackListText() {
    if (widget.currentUser!.getIdFromBlackList!
        .contains(widget.mUser!.objectId!)) {
      return "message_settings.un_block".tr();
    } else {
      return "message_settings.add_into_blacklist".tr();
    }
  }

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

  saveVisit() async {
    QueryBuilder<VisitsModel> query = QueryBuilder<VisitsModel>(VisitsModel());

    query.whereEqualTo(VisitsModel.keyVisitorId, widget.currentUser!.objectId);
    query.whereEqualTo(VisitsModel.keyVisitedId, widget.mUser!.objectId);

    ParseResponse response = await query.query();

    if (response.success && response.results != null) {
      VisitsModel visitResponse = response.results!.first;

      visitResponse.setViewed = false;
      visitResponse.save();
    } else {
      VisitsModel visit = VisitsModel();

      visit.setViewed = false;
      visit.setVisited = widget.mUser!;
      visit.setVisitedId = widget.mUser!.objectId!;
      visit.setVisitor = widget.currentUser!;
      visit.setVisitorId = widget.currentUser!.objectId!;
      visit.save();
    }
  }

  _createComment(PostsModel post, String text) async {
    CommentsModel comment = CommentsModel();
    comment.setAuthor = widget.currentUser!;
    comment.setText = text;
    comment.setAuthorId = widget.currentUser!.objectId!;
    comment.setPostId = post.objectId!;
    comment.setPost = post;

    await comment.save();

    post.setComments = comment.objectId!;
    await post.save();

    QuickActions.createOrDeleteNotification(
      widget.currentUser!,
      post.getAuthor!,
      NotificationsModel.notificationTypeCommentPost,
      post: post,
    );
  }

  getUserPictures() {
    setState(() {
      userPictures.add(widget.mUser!.getAvatar!);

      if (widget.mUser!.getImagesList!.isNotEmpty) {
        for (ParseFileBase image in widget.mUser!.getImagesList!) {
          userPictures.add(image);
        }
      }
    });
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
              checkPermission(true);
            } else if (index == 1) {
              checkPermission(false);
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

  checkPermission(bool isVideoCall) async {
    if (await Permission.camera.isGranted &&
        await Permission.microphone.isGranted) {
      startCall(isVideoCall);
    } else if (await Permission.camera.isDenied ||
        await Permission.microphone.isDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.call_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.call_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.microphone,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.microphone]!.isGranted) {
              startCall(isVideoCall);
            } else {
              QuickHelp.showAppNotificationAdvanced(
                title: "permissions.call_access_denied".tr(),
                message: "permissions.call_access_denied_explain"
                    .tr(namedArgs: {"app_name": Setup.appName}),
                context: context,
                isError: true,
              );
            }
          });
    } else if (await Permission.camera.isPermanentlyDenied ||
        await Permission.microphone.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  startCall(bool isVideoCall) {
    if (isVideoCall) {
      if (widget.currentUser!.getCredits! >=
          Setup.coinsNeededForVideoCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.video_call_price".tr(),
            message: "video_call.video_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVideoCallPerMinute.toString(),
              "name": widget.mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () async {
              QuickHelp.hideLoadingDialog(context);
              UserModel? userModel =
                  await QuickHelp.goToNavigatorScreenForResult(
                      context,
                      VideoCallScreen(
                        key: Key(QuickHelp.generateUId().toString()),
                        currentUser: widget.currentUser,
                        mUser: widget.mUser,
                        channel: widget.currentUser!.objectId,
                        isCaller: true,
                      ));

              widget.currentUser = userModel;
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
            currentUser: widget.currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print(
                  "onCoinsPurchased: $coins new: ${widget.currentUser!.getCredits}");
              startCall(true);
            });
      }
    } else {
      if (widget.currentUser!.getCredits! >=
          Setup.coinsNeededForVoiceCallPerMinute) {
        QuickHelp.showDialogWithButtonCustom(
            context: context,
            title: "video_call.voice_call_price".tr(),
            message: "video_call.voice_explain".tr(namedArgs: {
              "coins": Setup.coinsNeededForVoiceCallPerMinute.toString(),
              "name": widget.mUser!.getFirstName!
            }),
            cancelButtonText: "cancel".tr(),
            confirmButtonText: "continue".tr(),
            onPressed: () {
              QuickHelp.hideLoadingDialog(context);

              QuickHelp.goToNavigatorScreen(
                  context,
                  VoiceCallScreen(
                    key: Key(QuickHelp.generateUId().toString()),
                    mUser: widget.mUser,
                    currentUser: widget.currentUser,
                    channel: widget.currentUser!.objectId,
                    isCaller: true,
                  ));
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
            currentUser: widget.currentUser!,
            showOnlyCoinsPurchase: true,
            onCoinsPurchased: (coins) {
              print(
                  "onCoinsPurchased: $coins new: ${widget.currentUser!.getCredits}");
              startCall(false);
            });
      }
    }
  }

  int clickedPostIndex = 0;
  int clickedImageIndex = 0;

  static final _kAdIndex = 2;

  @override
  void initState() {
    SendNotifications.sendPush(
      widget.currentUser!,  widget.mUser!,
      SendNotifications.typeProfileVisit,
      pictureURL:widget.currentUser!.getAvatar!.url,
    );

    _getAllFanClub();
    _getAllRatingClub();

    init();
    saveVisit();
    getUserPictures();

    _future = _loadFeeds(false);

    commentTextFieldFocusNode = FocusNode();

    _animationController = AnimationController.unbounded(vsync: this);

    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabData)
          ..addListener(() {
            setState(() {
              tabIndex = _tabController.index;
            });

            switch (_tabController.index) {
              case 1:
                setState(() {
                  tabIndex = 2;
                });
                _future = _loadFeeds(false);
                break;
            }
          });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    fanClubUsersList.clear();
    fanRankingUsersList.clear();
    _tabController.dispose();
  }

  SharedPreferences? preferences;

  init() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    fanClubPrivileges = [
      "fan_club_privileges.privilege_1".tr(),
      "fan_club_privileges.privilege_2".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$hostSpend")
      }),
      "fan_club_privileges.privilege_3".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$fanCluGift")
      }),
      "fan_club_privileges.privilege_4".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$fanCluVoting")
      }),
      "fan_club_privileges.privilege_5".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$chatSpeak")
      }),
      "fan_club_privileges.privilege_6".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$fanClubRenewalFee")
      }),
      "fan_club_privileges.privilege_7".tr(namedArgs: {
        "amount": QuickHelp.checkFundsWithString(amount: "$platformFloatTag")
      }),
      "fan_club_privileges.privilege_8".tr(namedArgs: {
        "days": QuickHelp.checkFundsWithString(amount: "$intimacyIncreaseLimit")
      }),
    ];

    settingsTitles = [
      blackListText(),
      "message_settings.report_".tr(),
      "message_settings.cancel_".tr()
    ];

    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    bool justChat = widget.currentUser!.getChatWithUsersIds!
        .contains(widget.mUser!.objectId!);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          backgroundColor: isDark ? kContentColorLightTheme : kGrayWhite,
          body: NestedScrollView(
            physics: BouncingScrollPhysics(),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    centerTitle: true,
                    pinned: true,
                    elevation: 0,
                    stretch: true,
                    automaticallyImplyLeading: false,
                    leading: BackButton(
                      color: Colors.white,
                    ),
                    actions: [
                      IconButton(
                        onPressed: () => openSettingsSheet(),
                        icon: RotatedBox(
                          quarterTurns: 1,
                          child: SvgPicture.asset(
                            "assets/svg/ic_post_config.svg",
                            color: kGrayColor,
                            height: 18,
                            width: 18,
                          ),
                        ),
                      ),
                    ],
                    title: Visibility(
                      visible: innerBoxIsScrolled,
                      child: TextWithTap(
                        widget.mUser!.getFullName!,
                      ),
                    ),
                    backgroundColor:
                        isDark ? kContentColorLightTheme : Colors.white,
                    expandedHeight: 360,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      collapseMode: CollapseMode.parallax,
                      stretchModes: [StretchMode.zoomBackground],
                      background: ContainerCorner(
                        borderWidth: 0,
                        width: MediaQuery.of(context).size.width,
                        color: widget.mUser!.getAvatar == null
                            ? Colors.black
                            : Colors.transparent,
                        child: Stack(
                          children: [
                            userImages(),
                            Positioned(
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 20),
                                child: SizedBox(
                                  width: size.width,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ContainerCorner(
                                        height: 30,
                                        borderRadius: 50,
                                        color: Colors.black.withOpacity(0.2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Lottie.asset(
                                                  "assets/lotties/ic_online.json",
                                                  height: 13,
                                                  width: 13),
                                            ),
                                            TextWithTap(
                                              "profile_page.connected_".tr(),
                                              marginLeft: 5,
                                              marginRight: 10,
                                              color: Colors.white,
                                              fontSize: 12,
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 25, bottom: 10),
                                        child: Image.asset(
                                          "assets/images/ic_guard_avatar_frame.webp",
                                          height: 60,
                                          width: 60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size(size.width, 15),
                      child: ContainerCorner(
                        color: isDark ? kContentColorLightTheme : kGrayWhite,
                        radiusTopLeft: 20,
                        radiusTopRight: 20,
                        height: 15,
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Builder(builder: (BuildContext context) {
              return CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWithTap(
                                      widget.mUser!.getFullName!,
                                      fontSize: size.width / 20,
                                      fontWeight: FontWeight.bold,
                                      marginBottom: 10,
                                    ),
                                    QuickHelp.usersMoreInfo(
                                      context,
                                      widget.mUser!,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        TextWithTap(
                                          "tab_profile.id_".tr(),
                                          fontSize: size.width / 30,
                                          fontWeight: FontWeight.w900,
                                          color: kGrayColor,
                                          marginLeft: 10,
                                        ),
                                        TextWithTap(
                                          widget.mUser!.getUid!.toString(),
                                          fontSize: size.width / 30,
                                          marginLeft: 3,
                                          color: kGrayColor,
                                          marginRight: 3,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            QuickHelp.copyText(
                                                textToCopy:
                                                    "${widget.mUser!.getUid!}");
                                            showCopiedTemporaryAlert();
                                          },
                                          child: Icon(
                                            Icons.copy,
                                            color: kGrayColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        TextWithTap(
                                          "profile_screen.following_".tr(),
                                          color: kGrayColor,
                                          marginRight: 3,
                                          fontSize: 12,
                                        ),
                                        TextWithTap(
                                          QuickHelp.convertToK(widget
                                              .mUser!.getFollowing!.length),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          marginRight: 15,
                                        ),
                                        TextWithTap(
                                          "profile_screen.followers_".tr(),
                                          color: kGrayColor,
                                          marginRight: 3,
                                          fontSize: 12,
                                        ),
                                        TextWithTap(
                                          QuickHelp.convertToK(widget
                                              .mUser!.getFollowers!.length),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: !widget.isFollowing!,
                                  child: TextButton(
                                    onPressed: () =>
                                        followOrUnfollow(widget.isFollowing!),
                                    child: Image.asset(
                                      "assets/images/icon_follow.png",
                                      height: 30,
                                      width: 50,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height -
                                kToolbarHeight -
                                MediaQuery.of(context).padding.top,
                            child: DefaultTabController(
                              length: tabsLength,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    TabBar(
                                      isScrollable: true,
                                      enableFeedback: false,
                                      controller: _tabController,
                                      indicatorSize: TabBarIndicatorSize.label,
                                      dividerColor: kTransparentColor,
                                      unselectedLabelColor:
                                          kTabIconDefaultColor,
                                      indicatorWeight: 2.0,
                                      labelPadding: EdgeInsets.symmetric(
                                        horizontal: 7.0,
                                      ),
                                      automaticIndicatorColorAdjustment: false,
                                      labelColor:
                                          isDark ? Colors.white : Colors.black,
                                      indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            width: 3.0, color: kPrimaryColor),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                        insets: EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      unselectedLabelStyle:
                                          TextStyle(fontSize: 14),
                                      tabs: [
                                        TextWithTap(
                                            "profile_page.tab_data".tr()),
                                        TextWithTap("profile_page.tab_gifts".tr(
                                            namedArgs: {
                                              "amount": widget
                                                  .mUser!.getGiftsAmount!
                                                  .toString()
                                            })),
                                        TextWithTap("profile_page.tab_moments"
                                            .tr(namedArgs: {
                                          "amount": widget
                                              .mUser!.getPostIdList!.length
                                              .toString()
                                        })),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    Flexible(
                                      child: TabBarView(
                                        controller: _tabController,
                                        children: [
                                          tabUserData(),
                                          _getReceivedGifts(),
                                          initQuery(false),
                                          //Container(color: Colors.red),
                                          //Container(color: Colors.red),
                                          //Container(color: Colors.red),
                                        ],
                                        //children: List.generate(tabsLength, (index) => initQuery(index)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          bottomNavigationBar: ContainerCorner(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ContainerCorner(
                  color: kRedColor1,
                  borderRadius: 50,
                  marginBottom: 10,
                  marginTop: 5,
                  width: size.width / 2.5,
                  height: 40,
                  onTap: () {
                    if (widget.currentUser!.getChatWithUsersIds!
                        .contains(widget.mUser!.objectId)) {
                      QuickHelp.gotoChat(
                        context,
                        currentUser: widget.currentUser,
                        mUser: widget.mUser!,
                      );
                    } else {
                      _saveMessage(
                        "tab_feed.hello_".tr(),
                        receiver: widget.mUser!,
                        messageType: MessageModel.messageTypeText,
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                        child: SvgPicture.asset(
                          justChat
                              ? "assets/svg/ic_go_chat_white.svg"
                              : "assets/svg/ic_msg_hi.svg",
                          height: 20,
                          width: 20,
                        ),
                      ),
                      TextWithTap(
                        justChat
                            ? "tab_feed.go_chat".tr()
                            : "tab_feed.say_hello".tr(),
                        color: Colors.white,
                        marginRight: 10,
                        marginLeft: 5,
                        marginBottom: 5,
                        //marginTop: 5,
                      ),
                    ],
                  ),
                ),
                ContainerCorner(
                  color: kPrimaryColor,
                  borderRadius: 50,
                  marginBottom: 10,
                  marginTop: 5,
                  width: size.width / 2.5,
                  height: 40,
                  onTap: () => openStartCallSheet(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          bottom: 5,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/ic_video_call.svg",
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                      ),
                      TextWithTap(
                        "calls_sheet.video_call".tr(),
                        color: Colors.white,
                        marginRight: 10,
                        marginLeft: 5,
                        marginBottom: 5,
                        //marginTop: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        Visibility(
          visible: showCopiedTempAlert,
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
              "copied_".tr(),
              color: Colors.white,
              marginBottom: 5,
              marginTop: 5,
              marginLeft: 20,
              marginRight: 20,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void openStartCallSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showStartCallsSheet();
        });
  }

  Widget showStartCallsSheet() {
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
                              isVideoCall: true,
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

  Widget userImages() {
    if (userPictures.length <= 1) {
      return Stack(
        children: [
          QuickActions.profileAvatar(
            widget.mUser!.getAvatar!.url!,
            width: double.infinity,
            height: double.infinity,
          ),
          ContainerCorner(
            borderWidth: 0,
            color: Colors.black.withOpacity(0.1),
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      );
    } else {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          ContainerCorner(
            borderWidth: 0,
            child: CarouselView(
              controller: _controller,
              itemExtent: double.infinity,
              children: List.generate(userPictures.length, (index){
                return Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    QuickActions.profileAvatar(
                      userPictures[index].url!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    ContainerCorner(
                      borderWidth: 0,
                      color: Colors.black.withOpacity(0.1),
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ],
                );
            }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: userPictures.asMap().entries.map((entry) {
                return ContainerCorner(
                  width: _current == entry.key ? 18.0 : 8,
                  height: 7.0,
                  marginRight: 2,
                  borderRadius: 8,
                  borderWidth: 0,
                  onTap: () => _controller.jumpTo(entry.key+0.0),
                  color: _current == entry.key
                      ? kWarninngColor
                      : kWarninngColor.withOpacity(0.3),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }
  }

  _getReceivedGifts() {
    QueryBuilder<GiftsReceivedModel> query =
        QueryBuilder<GiftsReceivedModel>(GiftsReceivedModel());

    query.whereEqualTo(
        GiftsReceivedModel.keyReceiverId, widget.mUser!.objectId);
    query.includeObject([GiftsReceivedModel.keyGift]);

    return ParseLiveGridWidget<GiftsReceivedModel>(
      query: query,
      crossAxisCount: 4,
      reverse: false,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      lazyLoading: false,
      childAspectRatio: .8,
      shrinkWrap: true,
      duration: const Duration(milliseconds: 200),
      animationController: _animationController,
      listeningIncludes: [GiftsReceivedModel.keyGift],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<GiftsReceivedModel> snapshot) {
        if (snapshot.hasData) {
          GiftsReceivedModel gift = snapshot.loadedData!;
          return ContainerCorner(
            height: double.infinity,
            width: double.infinity,
            color: kPrimaryColor.withOpacity(0.1),
            borderWidth: 0,
            borderRadius: 8,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: ContainerCorner(
                    color: kPrimaryColor,
                    radiusBottomLeft: 10,
                    radiusTopRight: 10,
                    child: TextWithTap(
                      "x${gift.getQuantity}",
                      color: Colors.white,
                      fontSize: 12,
                      marginTop: 2,
                      marginLeft: 5,
                      marginRight: 5,
                      marginBottom: 2,
                    ),
                  ),
                ),
                QuickActions.photosWidget(
                  gift.getGift!.getFile!.url!,
                  width: 60,
                  height: 60,
                ),
                TextWithTap(
                  gift.getGift!.getName!,
                  overflow: TextOverflow.ellipsis,
                  marginLeft: 2,
                  marginRight: 2,
                )
              ],
            ),
          );
        } else {
          return Center(
            child: QuickHelp.appLoading(),
          );
        }
      },
      queryEmptyElement:
          Center(child: TextWithTap("profile_page.no_gift_found".tr())),
    );
  }

  Widget tabUserData() {
    Size size = MediaQuery.of(context).size;

    double wealthPercent = widget.mUser!.getCreditsSent! /
        QuickHelp.wealthLevelValue(creditSent: widget.mUser!.getCreditsSent!) *
        100;
    String wealthPercentString = wealthPercent.toStringAsFixed(2);

    double receivedGiftPercent = widget.mUser!.getDiamondsTotal! /
        QuickHelp.receivedGiftsValue(
            receivedGift: widget.mUser!.getDiamondsTotal!) *
        100;
    String receivedGiftPercentString = receivedGiftPercent.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FlipCard(
              fill: Fill.fillBack,
              direction: FlipDirection.VERTICAL,
              side: CardSide.FRONT,
              front: ContainerCorner(
                width: size.width / 2.3,
                height: 50,
                borderRadius: 8,
                marginLeft: 10,
                colors: [kSecondGreenLevel, kPrimaryGreenLevel],
                child: Row(
                  children: [
                    TextWithTap(
                      "profile_page.lv_".tr(),
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      marginLeft: 10,
                      marginRight: 15,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width / 3.3,
                          child: AutoSizeText(
                            "profile_page.wealth_level".tr(),
                            maxFontSize: 12.0,
                            minFontSize: 5.0,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        TextWithTap(
                          QuickHelp.wealthLevelNumber(
                                  creditSent: widget.mUser!.getCreditsSent!)
                              .toString(),
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              back: ContainerCorner(
                width: size.width / 2.3,
                height: 50,
                borderRadius: 10,
                color: Colors.white,
                shadowColor: kRoseVip,
                borderColor: kRoseVip.withOpacity(0.3),
                borderWidth: 2,
                shadowColorOpacity: 0.3,
                setShadowToBottom: true,
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    FAProgressBar(
                      currentValue: widget.mUser!.getCreditsSent!.toDouble(),
                      size: 50,
                      maxValue: QuickHelp.wealthLevelValue(
                              creditSent: widget.mUser!.getCreditsSent!)
                          .toDouble(),
                      changeColorValue: 0,
                      changeProgressColor: kRoseVip,
                      backgroundColor: kTransparentColor,
                      progressColor: Colors.lightBlue,
                      animatedDuration: const Duration(seconds: 2),
                      direction: Axis.horizontal,
                      verticalDirection: VerticalDirection.up,
                      displayText: '%',
                      displayTextStyle: GoogleFonts.roboto(
                        color: kRoseVip,
                        fontSize: 1,
                      ),
                      formatValueFixed: 0,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "profile_page.current_progress".tr(),
                          color: Colors.black,
                          fontSize: 10,
                          marginBottom: 2,
                          marginTop: 1,
                        ),
                        TextWithTap(
                          wealthPercentString,
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          marginTop: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FlipCard(
              fill: Fill.fillBack,
              direction: FlipDirection.VERTICAL,
              side: CardSide.FRONT,
              front: ContainerCorner(
                width: size.width / 2.2,
                height: 50,
                borderRadius: 8,
                marginLeft: 5,
                colors: [kSecondaryColor, kPrimaryColor],
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: SvgPicture.asset(
                        "assets/svg/ic_live_level.svg",
                        height: 35,
                        width: 35,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size.width / 3.3,
                          child: AutoSizeText(
                            "profile_page.streaming_level".tr(),
                            maxFontSize: 12.0,
                            minFontSize: 5.0,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                        ),
                        TextWithTap(
                          QuickHelp.receivedGiftsLevelNumber(
                                  receivedGift: widget.mUser!.getDiamondsTotal!)
                              .toString(),
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              back: ContainerCorner(
                width: size.width / 2.2,
                height: 50,
                borderRadius: 10,
                marginLeft: 5,
                color: Colors.white,
                shadowColor: kPrimaryColor,
                borderColor: kPrimaryColor.withOpacity(0.3),
                borderWidth: 2,
                shadowColorOpacity: 0.3,
                setShadowToBottom: true,
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    FAProgressBar(
                      currentValue: widget.mUser!.getDiamondsTotal!.toDouble(),
                      size: 50,
                      maxValue: QuickHelp.receivedGiftsValue(
                              receivedGift:
                                  widget.currentUser!.getDiamondsTotal!)
                          .toDouble(),
                      changeColorValue: 0,
                      changeProgressColor: kPrimaryColor,
                      backgroundColor: kTransparentColor,
                      progressColor: Colors.lightBlue,
                      animatedDuration: const Duration(seconds: 2),
                      direction: Axis.horizontal,
                      verticalDirection: VerticalDirection.up,
                      displayText: '%',
                      displayTextStyle: GoogleFonts.roboto(
                        color: kPrimaryColor,
                        fontSize: 1,
                      ),
                      formatValueFixed: 0,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "profile_page.current_progress".tr(),
                          color: Colors.black,
                          fontSize: 10,
                          marginBottom: 2,
                          marginTop: 1,
                        ),
                        TextWithTap(
                          receivedGiftPercentString,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          marginTop: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        ContainerCorner(
          borderRadius: 10,
          color: kGrayPro.withOpacity(0.1),
          marginLeft: 10,
          marginRight: 15,
          marginTop: 15,
          height: 150,
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => openFunClub(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "profile_page.fan_club".tr(),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            marginBottom: 10,
                          ),
                          TextWithTap(
                            "profile_page.number_club_members".tr(namedArgs: {
                              "amount":
                                  "${widget.mUser!.getMyFanClubMembers!.length}"
                            }),
                            color: kGrayColor,
                            fontSize: 11,
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      fansList(),
                      const SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kGrayColor,
                        size: 15,
                      )
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                ),
                GestureDetector(
                  onTap: () {
                    QuickHelp.goToNavigatorScreen(
                        context,
                        FansRankingScreen(
                          currentUser: widget.currentUser,
                          mUser: widget.mUser,
                          fanRankingUsersList: fanRankingUsersList,
                        ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "profile_page.fan_rating".tr(),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            marginBottom: 10,
                          ),
                          TextWithTap(
                            "profile_page.number_list_participants"
                                .tr(namedArgs: {"amount": "0"}),
                            color: kGrayColor,
                            fontSize: 11,
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ratingFansList(),
                      const SizedBox(
                        width: 3,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kGrayColor,
                        size: 15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWithTap(
              "profile_page.personal_information".tr(),
              fontWeight: FontWeight.w900,
              fontSize: 16,
              marginBottom: 10,
              marginTop: 20,
              marginLeft: 15,
            ),
            TextWithTap(
              widget.mUser!.getBio!,
              color: kGrayColor,
              marginLeft: 15,
            )
          ],
        ),
      ],
    );
  }

  _getAllFanClub() async {
    QueryBuilder<FanClubMembersModel> queryBuilder =
        QueryBuilder<FanClubMembersModel>(FanClubMembersModel());
    queryBuilder.whereEqualTo(
        FanClubMembersModel.keyFanClubId, widget.mUser!.getMyFanClubId!);
    queryBuilder.includeObject(
        [FanClubMembersModel.keyFanClub, FanClubMembersModel.keyMember]);
    queryBuilder.orderByDescending(FanClubMembersModel.keyCreatedAt);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.result != null) {
        int i = 0;

        for (FanClubMembersModel fan in parseResponse.results!) {
          if (!fanClubUsersList.contains(fan.getMember)) {
            if (i < 3) {
              fanClubUsersList.add(fan.getMember!);
              setState(() {});
            }
            i++;
          }
        }
      }
    }
  }

  _getAllRatingClub() async {
    QueryBuilder<UserModel> query =
        QueryBuilder<UserModel>(UserModel.forQuery());

    query.whereGreaterThan(UserModel.keyCoins, 90000000000);
    query.whereNotEqualTo(UserModel.keyObjectId, widget.currentUser!.objectId);
    query.orderByDescending(UserModel.keyCoins);

    ParseResponse parseResponse = await query.query();

    if (parseResponse.success) {
      if (parseResponse.result != null) {
        int i = 0;

        for (UserModel fan in parseResponse.results!) {
          if (!fanRankingUsersList.contains(fan)) {
            if (i < 3) {
              fanRankingUsersList.add(fan);
              setState(() {});
            }
            i++;
          }
        }
      }
    }
  }

  Widget fansList() {
    double frameSize = 35.0;
    if (fanClubUsersList.length == 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(fanClubUsersList.length, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: topFansFrames[index],
            child: Padding(
              padding: const EdgeInsets.all(5.8),
              child: QuickActions.avatarWidget(fanClubUsersList[index]),
            ),
          );
        }),
      );
    } else if (fanClubUsersList.length == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(fanClubUsersList.length, (index) {
              return ContainerCorner(
                height: frameSize,
                width: frameSize,
                borderWidth: 0,
                marginLeft: 3,
                imageDecoration: topFansFrames[index],
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: QuickActions.avatarWidget(fanClubUsersList[index]),
                ),
              );
            }),
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: fansFrames[2],
          ),
        ],
      );
    } else if (fanClubUsersList.length == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              fanClubUsersList.length,
              (index) {
                return ContainerCorner(
                  height: frameSize,
                  width: frameSize,
                  borderWidth: 0,
                  marginLeft: 3,
                  imageDecoration: topFansFrames[index],
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: QuickActions.avatarWidget(fanClubUsersList[index]),
                  ),
                );
              },
            ),
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: fansFrames[1],
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: fansFrames[2],
          ),
        ],
      );
    } else if (fanClubUsersList.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: fansFrames[index],
          );
        }),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: fansFrames[index],
          );
        }),
      );
    }
  }

  Widget ratingFansList() {
    double frameSize = 35.0;
    if (fanRankingUsersList.length == 3) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(fanRankingUsersList.length, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingFansFrames[index],
            child: Padding(
              padding: const EdgeInsets.all(5.8),
              child: QuickActions.avatarWidget(fanRankingUsersList[index]),
            ),
          );
        }),
      );
    } else if (fanRankingUsersList.length == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(fanRankingUsersList.length, (index) {
              return ContainerCorner(
                height: frameSize,
                width: frameSize,
                borderWidth: 0,
                marginLeft: 3,
                imageDecoration: ratingFansFrames[index],
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: QuickActions.avatarWidget(fanRankingUsersList[index]),
                ),
              );
            }),
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingsFansSeat[2],
          ),
        ],
      );
    } else if (fanRankingUsersList.length == 1) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              fanRankingUsersList.length,
              (index) {
                return ContainerCorner(
                  height: frameSize,
                  width: frameSize,
                  borderWidth: 0,
                  marginLeft: 3,
                  imageDecoration: ratingFansFrames[index],
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child:
                        QuickActions.avatarWidget(fanRankingUsersList[index]),
                  ),
                );
              },
            ),
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingsFansSeat[1],
          ),
          ContainerCorner(
            height: frameSize - 2,
            width: frameSize - 2,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingsFansSeat[2],
          ),
        ],
      );
    } else if (fanClubUsersList.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingsFansSeat[index],
          );
        }),
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return ContainerCorner(
            height: frameSize,
            width: frameSize,
            borderWidth: 0,
            marginLeft: 3,
            imageDecoration: ratingsFansSeat[index],
          );
        }),
      );
    }
  }

  Future<List<dynamic>?> _loadFeeds(bool? isExclusive) async {
    QueryBuilder<PostsModel> queryBuilder = QueryBuilder<PostsModel>(PostsModel());
    queryBuilder.includeObject([
      PostsModel.keyAuthor,
      PostsModel.keyLastLikeAuthor,
      PostsModel.keyLastDiamondAuthor
    ]);
    queryBuilder.whereEqualTo(PostsModel.keyAuthor, widget.mUser);
    queryBuilder.orderByDescending(PostsModel.keyCreatedAt);

    queryBuilder.orderByDescending(keyVarCreatedAt);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      print("Lives count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        for (PostsModel post in apiResponse.results!) {
          if (!allPosts.contains(post)) {
            allPosts.add(post);
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

  goToFeedOnReels({required PostsModel post}) {
    for (int i = 0; i < allPosts.length; i++) {
      if (allPosts[i].objectId == post.objectId) {
        clickedPostIndex = i;
      }
    }

    QuickHelp.goToNavigatorScreen(
      context,
      FeedReelsScreen(
        currentUser: widget.currentUser,
        preloadsPost: allPosts,
        initialIndex: clickedPostIndex,
        pictureIndex: clickedImageIndex,
      ),
    );
  }

  double imageWidth({required int numberOfPictures}) {
    Size size = MediaQuery.of(context).size;
    if (numberOfPictures == 1) {
      return size.width / 1.7;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return size.width / 2.2;
    } else {
      return size.width / 3.4;
    }
  }

  double imageHeight({required int numberOfPictures}) {
    Size size = MediaQuery.of(context).size;
    if (numberOfPictures == 1) {
      return 350;
    } else if (numberOfPictures == 2 || numberOfPictures == 4) {
      return 170;
    } else {
      return size.width / 3.4;
    }
  }

  Widget initQuery(bool isExclusive) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {
            postsResults = snapshot.data! as List<dynamic>;

            if (postsResults.isNotEmpty) {
              return ListView.separated(
                itemCount: postsResults.length,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final PostsModel post = postsResults[index] as PostsModel;

                  bool justTalked = widget.currentUser!.getChatWithUsersIds!
                      .contains(post.getAuthorId!);

                  return ContainerCorner(
                    //height: 450,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    marginTop: 7,
                    marginBottom: 0,
                    marginLeft: 10,
                    marginRight: 10,
                    borderRadius: 10,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.getTargetPeopleID != null &&
                            post.getTargetPeopleID!
                                .contains(widget.currentUser!.objectId))
                          TextWithTap(
                            "feed.you_was_mentioned".tr(
                              namedArgs: {
                                "author_name": post.getAuthor!.getFullName!
                              },
                            ),
                            marginLeft: 10,
                            color: kGrayColor.withOpacity(0.7),
                            fontSize: 7,
                            alignment: Alignment.center,
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: ContainerCorner(
                                  marginTop: 10,
                                  color: QuickHelp.isDarkMode(context)
                                      ? kContentColorLightTheme
                                      : Colors.white,
                                  child: Row(
                                    children: [
                                      QuickActions.avatarWidget(post.getAuthor!,
                                          width: 50, height: 50),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWithTap(
                                              post.getAuthor!.getFullName!,
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.width / 20,
                                              marginBottom: 5,
                                            ),
                                            QuickActions.getGender(
                                              currentUser: post.getAuthor!,
                                              context: context,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  marginLeft: 15,
                                  onTap: () {}),
                            ),
                            IconButton(
                              onPressed: () => openSheet(post.getAuthor!, post),
                              icon: SvgPicture.asset(
                                "assets/svg/ic_post_config.svg",
                                color: kGrayColor,
                                height: 13,
                                width: 13,
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: post.getText!.isNotEmpty,
                          child: TextWithTap(
                            post.getText!,
                            textAlign: TextAlign.start,
                            marginTop: 10,
                            marginBottom: 5,
                            marginLeft: 10,
                          ),
                        ),
                        Divider(
                          height: 6,
                          color: kTransparentColor,
                        ),
                        if (post.getTargetPeople != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Wrap(
                              children: List.generate(
                                post.getTargetPeopleID!.length,
                                (targetIndex) => TextWithTap(
                                  "@${post.getTargetPeople![targetIndex][UserModel.keyFullName]}",
                                  color: Colors.blueAccent,
                                  marginRight: 5,
                                  marginBottom: 8,
                                  onTap: () {
                                    if (post.getTargetPeople![targetIndex]
                                            [UserModel.keyObjectId] ==
                                        widget.currentUser!.objectId) {
                                      QuickHelp.goToNavigatorScreen(
                                        context,
                                        ProfileScreen(
                                          currentUser: widget.currentUser,
                                        ),
                                      );
                                    } else {
                                      QuickHelp.goToNavigatorScreen(
                                        context,
                                        UserProfileScreen(
                                          currentUser: widget.currentUser,
                                          mUser: post
                                              .getTargetPeople![targetIndex],
                                          isFollowing: widget
                                              .currentUser!.getFollowing!
                                              .contains(post.getTargetPeopleID![
                                                  targetIndex]),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        Divider(
                          height: 10,
                          color: kTransparentColor,
                        ),
                        showPost(post)
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (post.getVideo == null)
                                    Wrap(
                                      children: List.generate(
                                        post.getNumberOfPictures,
                                        (index) => ContainerCorner(
                                          width: imageWidth(
                                              numberOfPictures:
                                                  post.getNumberOfPictures),
                                          height: imageHeight(
                                              numberOfPictures:
                                                  post.getNumberOfPictures),
                                          borderWidth: 0,
                                          marginRight: 5,
                                          marginBottom: 5,
                                          borderRadius: 8,
                                          onTap: () {
                                            setState(() {
                                              clickedImageIndex = index;
                                            });
                                            goToFeedOnReels(post: post);
                                          },
                                          child: QuickActions.photosWidget(
                                              post.getImagesList![index].url),
                                        ),
                                      ),
                                    ),
                                  if (post.getVideo != null)
                                    ContainerCorner(
                                      width: size.width / 1.7,
                                      height: 350,
                                      borderRadius: 10,
                                      borderWidth: 0,
                                      onTap: () => goToFeedOnReels(post: post),
                                      child: Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          QuickActions.photosWidget(
                                              post.getVideoThumbnail!.url),
                                          ContainerCorner(
                                            height: 40,
                                            width: 40,
                                            borderRadius: 50,
                                            borderWidth: 0,
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            child: Center(
                                                child: Icon(
                                              Icons.play_circle_outline,
                                              color: Colors.white,
                                            )),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              )
                            : GestureDetector(
                                onTap: () => chargeUserAndShowImage(post),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.width,
                                      child: Image.asset(
                                          "assets/images/blurred_image.jpg"),
                                    ),
                                    ContainerCorner(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: 20,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/ic_coin_with_star.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            TextWithTap(
                                              "feed.post_cost_exclusive".tr(
                                                  namedArgs: {
                                                    "coins": post.getPaidAmount!
                                                        .toString()
                                                  }),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              marginLeft: 6,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.watch_later_outlined,
                                size: 14,
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: 8.0),
                              Container(
                                width: 220,
                                child: Text(
                                  QuickHelp.getTimeAgoForFeed(post.createdAt!),
                                  style: TextStyle(
                                    //color: isDark ? Colors.white : kContentColorLightTheme,
                                    color: kPrimaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: showPost(post),
                          child: ContainerCorner(
                            color: QuickHelp.isDarkMode(context)
                                ? kContentColorLightTheme
                                : Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _likeWidget(post),
                                    ContainerCorner(
                                      marginBottom: 10,
                                      marginTop: 10,
                                      marginLeft: 10,
                                      onTap: () {
                                        QuickHelp.goToNavigatorScreen(
                                          context,
                                          CommentPostScreen(
                                            post: post,
                                            currentUser: widget.currentUser,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svg/uil_comment.svg",
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            height: 20,
                                            width: 20,
                                          ),
                                          TextWithTap(
                                            post.getComments!.length.toString(),
                                            color: kGrayColor,
                                            marginLeft: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    ContainerCorner(
                                      marginBottom: 10,
                                      marginLeft: 10,
                                      marginTop: 10,
                                      onTap: () async {
                                        String linkToShare =
                                            await DeepLinksService.createLink(
                                          branchObject:
                                              DeepLinksService.branchObject(
                                            shareAction:
                                                DeepLinksService.keyPostShare,
                                            objectID: post.objectId!,
                                            imageURL:
                                                QuickHelp.getImageToShare(post),
                                            title:
                                                QuickHelp.getTitleToShare(post),
                                            description:
                                                post.getAuthor!.getFullName,
                                          ),
                                          branchProperties:
                                              DeepLinksService.linkProperties(
                                            channel: "link",
                                          ),
                                          context: context,
                                        );
                                        if (linkToShare.isNotEmpty) {
                                          Share.share(
                                            "share_post".tr(namedArgs: {
                                              "link": linkToShare,
                                              "app_name": Setup.appName
                                            }),
                                          );
                                        }
                                      },
                                      child: Image.asset(
                                        "assets/images/feed_icon_details_share_new.png",
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible: post.getAuthorId! !=
                                      widget.currentUser!.objectId,
                                  child: ContainerCorner(
                                    color: kGrayWhite,
                                    borderRadius: 50,
                                    marginRight: 10,
                                    marginBottom: 10,
                                    marginTop: 5,
                                    onTap: () {
                                      if (widget
                                          .currentUser!.getChatWithUsersIds!
                                          .contains(post.getAuthorId!)) {
                                        QuickHelp.gotoChat(
                                          context,
                                          currentUser: widget.currentUser,
                                          mUser: post.getAuthor!,
                                        );
                                      } else {
                                        _saveMessage(
                                          "tab_feed.hello_".tr(),
                                          receiver: post.getAuthor!,
                                          messageType:
                                              MessageModel.messageTypeText,
                                        );
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 5, bottom: 5),
                                          child: SvgPicture.asset(
                                            justTalked
                                                ? "assets/svg/ic_go_chat.svg"
                                                : "assets/svg/msg_hi.svg",
                                            height: 20,
                                            width: 20,
                                          ),
                                        ),
                                        TextWithTap(
                                          justTalked
                                              ? "tab_feed.go_chat".tr()
                                              : "tab_feed.say_hello".tr(),
                                          color: Colors.black,
                                          marginRight: 10,
                                          marginLeft: 5,
                                          marginBottom: 5,
                                          //marginTop: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  if (index % _kAdIndex == 0 && Setup.isAdsOnFeedEnabled) {
                    //futureAds = loadAds();
                    return getAdsFuture();
                    //return getBannerAd();
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return QuickActions.noContentFound(context);
            }
          } else {
            return QuickActions.noContentFound(context);
          }
        });
  }

  Widget _likeWidget(PostsModel postModel) {
    bool isDark = QuickHelp.isDarkMode(context);
    return LikeButton(
      size: 30,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      countPostion: CountPostion.right,
      circleColor: CircleColor(start: kPrimaryColor, end: kPrimaryColor),
      bubblesColor: BubblesColor(
        dotPrimaryColor: kPrimaryColor,
        dotSecondaryColor: kPrimaryColor,
      ),
      isLiked: postModel.getLikes!.contains(widget.currentUser!.objectId),
      likeCountAnimationType: LikeCountAnimationType.all,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? Icons.favorite : Icons.favorite_outline_outlined,
          color: isLiked
              ? kPrimaryColor
              : isDark
                  ? Colors.white
                  : kContentColorLightTheme,
          size: 20,
        );
      },
      likeCount: postModel.getLikes!.length,
      countBuilder: (count, bool isLiked, String text) {
        Widget result;
        if (count == 0) {
          result = TextWithTap(
            "",
          );
        } else
          result = TextWithTap(
            QuickHelp.convertNumberToK(count!),
          );
        return result;
      },
      onTap: (isLiked) {
        print("Liked: $isLiked");

        if (isLiked) {
          postModel.removeLike = widget.currentUser!.objectId!;

          postModel.save().then((value) {
            postModel = value.results!.first as PostsModel;
          });

          _deleteLike(postModel);

          return Future.value(false);
        } else {
          postModel.setLikes = widget.currentUser!.objectId!;
          postModel.setLastLikeAuthor = widget.currentUser!;

          postModel.save().then((value) {
            postModel = value.results!.first as PostsModel;
          });

          _likePost(postModel);

          return Future.value(true);
        }
      },
    );
  }

  showBottomModal(PostsModel post) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return _showComments(post);
        });
  }

  Widget _showComments(PostsModel post) {
    return GestureDetector(
      onTap: () {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          QuickHelp.removeFocusOnTextField(context);
        } else {
          QuickHelp.goBackToPreviousPage(context);
        }
      },
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
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
                    onTap: () => QuickHelp.removeFocusOnTextField(context),
                    radiusTopRight: 10.0,
                    radiusTopLeft: 10.0,
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
                          "tab_feed.comments_".tr(namedArgs: {
                            "amount": post.getComments!.length.toString()
                          }),
                          color: QuickHelp.isDarkMode(context)
                              ? Colors.white
                              : kContentColorLightTheme,
                          fontWeight: FontWeight.w700,
                        ),
                        actions: [
                          IconButton(
                              onPressed: () {
                                if (MediaQuery.of(context).viewInsets.bottom >
                                    0) {
                                  QuickHelp.removeFocusOnTextField(context);
                                } else {
                                  QuickHelp.goBackToPreviousPage(context);
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                color: QuickHelp.isDarkMode(context)
                                    ? Colors.white
                                    : Colors.black,
                                size: 25,
                              ))
                        ],
                      ),
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(child: showAllComments(post, newState)),
                          ContainerCorner(
                            child: commentInputField(post),
                            marginBottom:
                                MediaQuery.of(context).viewInsets.bottom,
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
      ),
    );
  }

  Widget commentInputField(PostsModel post) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20 / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 32,
            color: Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20 * 0.75,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      onChanged: (text) {},
                      focusNode: commentTextFieldFocusNode,
                      maxLines: null,
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "comment_post.leave_comment".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ContainerCorner(
            marginLeft: 10,
            color: kBlueColor1,
            child: ContainerCorner(
              color: kTransparentColor,
              marginAll: 5,
              height: 30,
              width: 30,
              child: SvgPicture.asset(
                "assets/svg/ic_send_message.svg",
                color: Colors.white,
                height: 10,
                width: 30,
              ),
            ),
            borderRadius: 50,
            height: 45,
            width: 45,
            onTap: () {
              if (commentController.text.isNotEmpty) {
                _createComment(post, commentController.text);
                setState(() {
                  commentController.text = "";
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget showAllComments(PostsModel post, StateSetter newState) {
    QueryBuilder<CommentsModel> queryBuilder =
        QueryBuilder<CommentsModel>(CommentsModel());
    queryBuilder.whereEqualTo(CommentsModel.keyPost, post);

    queryBuilder.includeObject([
      CommentsModel.keyAuthor,
      CommentsModel.keyPost,
    ]);

    return ParseLiveListWidget<CommentsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(seconds: 0),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.hasData) {
          CommentsModel commentsModel = snapshot.loadedData as CommentsModel;

          return Padding(
            padding: const EdgeInsets.only(left: 15, top: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    QuickActions.avatarWidget(commentsModel.getAuthor!,
                        width: 60, height: 60),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            commentsModel.getAuthor!.getFullName!,
                            marginLeft: 10,
                            marginBottom: 5,
                            fontWeight: FontWeight.bold,
                            color: kGrayColor,
                            fontSize: 16,
                          ),
                          TextWithTap(
                            commentsModel.getText!,
                            marginLeft: 10,
                            marginRight: 10,
                            color: kGrayColor,
                          ),
                          TextWithTap(
                            QuickHelp.getTimeAgoForFeed(
                              commentsModel.createdAt!,
                            ),
                            marginLeft: 10,
                            color: kGrayColor,
                            marginTop: 10,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 1,
                  marginLeft: 5,
                  marginRight: 5,
                  marginTop: 20,
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      queryEmptyElement: QuickActions.noContentFound(context),
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  // Save the message
  _saveMessage(String messageText,
      {required String messageType, required UserModel receiver}) async {
    if (messageText.isNotEmpty) {
      QuickHelp.showLoadingDialog(context);
      MessageModel message = MessageModel();

      message.setAuthor = widget.currentUser!;
      message.setAuthorId = widget.currentUser!.objectId!;

      message.setReceiver = receiver;
      message.setReceiverId = receiver.objectId!;

      message.setDuration = messageText;
      message.setIsMessageFile = false;

      message.setMessageType = messageType;

      message.setIsRead = false;

      widget.currentUser!.setChatWithUsersIds = receiver.objectId!;
      widget.currentUser!.save();

      ParseResponse response = await message.save();

      if (response.success) {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.gotoChat(
          context,
          currentUser: widget.currentUser,
          mUser: receiver,
        );
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            title: "tab_feed.say_hell_failed_title".tr(),
            context: context,
            message: "tab_feed.say_hell_failed_explain".tr());
      }

      _saveList(message, receiver: receiver);

      SendNotifications.sendPush(
          widget.currentUser!, receiver, SendNotifications.typeChat,
          message: messageText);
    }
  }

  // Update or Create message list
  _saveList(MessageModel messageModel, {required UserModel receiver}) async {
    QueryBuilder<MessageListModel> queryFrom =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(MessageListModel.keyListId,
        widget.currentUser!.objectId! + receiver.objectId!);

    QueryBuilder<MessageListModel> queryTo =
        QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(MessageListModel.keyListId,
        receiver.objectId! + widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
        QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = receiver;
        messageListModel.setReceiverId = receiver.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.greetingsMessage;

        messageListModel.setIsRead = false;
        messageListModel.setListId =
            widget.currentUser!.objectId! + receiver.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = receiver;
        messageListModel.setReceiverId = receiver.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.greetingsMessage;

        messageListModel.setListId =
            widget.currentUser!.objectId! + receiver.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

  Widget getAdsFuture() {
    return FutureBuilder(
        future: loadAds(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: QuickHelp.showLoadingAnimation(),
            );
          } else if (snapshot.hasData) {
            AdWithView ad = snapshot.data as AdWithView;

            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              color: QuickHelp.isDarkMode(context)
                  ? kContentColorLightTheme
                  : Colors.white,
              margin: EdgeInsets.only(top: 7),
              child: AdWidget(ad: ad),
            );
          } else {
            return Container();
          }
        });
  }

  Future<dynamic> loadAds() async {
    BannerAdListener bannerAdListener = BannerAdListener(
      onAdWillDismissScreen: (ad) {
        debugPrint("Ad Got onAdWillDismissScreen");
        ad.dispose();
      },
      onAdClosed: (ad) {
        debugPrint("Ad Got Closeed");
        ad.dispose();
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint("Ad Got onAdFailedToLoad");
        ad.dispose();
      },
      onAdLoaded: (ad) {
        debugPrint("Ad Got onAdLoaded");
      },
    );

    BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Constants.getAdmobFeedNativeUnit(),
      listener: bannerAdListener,
      request: const AdRequest(),
    );

    return bannerAd..load();
  }

  void followOrUnfollow(bool follow) async {
    setState(() {
      widget.isFollowing = !widget.isFollowing!;
    });

    if (widget.currentUser!.getFollowing!.contains(widget.mUser!.objectId)) {
      widget.currentUser!.removeFollowing = widget.mUser!.objectId!;
      await widget.currentUser!.save();
    } else {
      widget.currentUser!.setFollowing = widget.mUser!.objectId!;
      await widget.currentUser!.save();
    }
    ParseResponse parseResponse;

    if (follow) {
      parseResponse = await QuickCloudCode.unFollowUser(
        author: widget.currentUser!,
        receiver: widget.mUser!,
      );
    } else {
      parseResponse = await QuickCloudCode.followUser(
        author: widget.currentUser!,
        receiver: widget.mUser!,
      );
    }

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          widget.mUser!, NotificationsModel.notificationTypeFollowers);
    }
  }

  _deleteLike(PostsModel postsModel) async {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        postsModel.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: postsModel);
  }

  _likePost(PostsModel post) {
    QuickActions.createOrDeleteNotification(widget.currentUser!,
        post.getAuthor!, NotificationsModel.notificationTypeLikedPost,
        post: post);
  }

  bool showPost(PostsModel post) {
    if (post.getExclusive!) {
      if (post.getAuthorId == widget.currentUser!.objectId) {
        return true;
      } else if (post.getPaidBy!.contains(widget.currentUser!.objectId)) {
        return true;
      } else if (widget.currentUser!.isAdmin!) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  void chargeUserAndShowImage(PostsModel post) async {
    if (widget.currentUser!.getCredits! >= post.getPaidAmount!) {
      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.removeCredit = post.getPaidAmount!;
      ParseResponse saved = await widget.currentUser!.save();
      if (saved.success) {
        QuickCloudCode.sendGift(
          author: post.getAuthor!,
          credits: post.getPaidAmount!,
        );

        widget.currentUser = saved.results!.first! as UserModel;

        post.setPaidBy = widget.currentUser!.objectId!;
        ParseResponse savedPost = await post.save();
        if (savedPost.success) {
          QuickHelp.hideLoadingDialog(context);
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotification(
              title: "error".tr(), context: context, isError: true);
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotification(
            title: "error".tr(), context: context, isError: true);
      }
    } else {
      QuickHelp.showAppNotification(
          title: "video_call.no_coins".tr(), context: context, isError: true);
    }
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
            } else if (index == 0) {
              if (widget.currentUser!.getIdFromBlackList!
                  .contains(widget.mUser!.objectId)) {
                removeToBlackList();
              } else {
                addToBlackList();
              }
              QuickHelp.goBackToPreviousPage(context);
            } else if (index == 1) {
              QuickHelp.goToNavigatorScreen(
                context,
                ReportScreen(
                  currentUser: widget.currentUser,
                  userToReport: widget.mUser,
                ),
              );
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

  void openSheet(UserModel author, PostsModel? post) async {
    showModalBottomSheet(
        context: (context),
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, post: post!);
        });
  }

  Widget _showPostOptionsAndReportAuthor(UserModel author,
      {required PostsModel post}) {
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
              Visibility(
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: TextWithTap(
                  "feed.report_post"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 20,
                  onTap: () {
                    openReportMessage(author, post);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.objectId != post.getAuthorId,
                  child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId != post.getAuthorId,
                child: TextWithTap(
                  "feed.block_user"
                      .tr(namedArgs: {"name": author.getFullName!}),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 10,
                  onTap: () {
                    Navigator.of(context).pop();
                    QuickHelp.showDialogWithButtonCustom(
                      context: context,
                      title: "feed.post_block_title".tr(),
                      message: "feed.post_block_message"
                          .tr(namedArgs: {"name": author.getFullName!}),
                      cancelButtonText: "cancel".tr(),
                      confirmButtonText: "feed.post_block_confirm".tr(),
                      onPressed: () => _blockUser(author),
                    );
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: TextWithTap(
                  "feed.delete_post".tr(),
                  alignment: Alignment.center,
                  marginBottom: 10,
                  marginTop: 10,
                  onTap: () {
                    _deletePost(post);
                  },
                ),
              ),
              Visibility(
                visible: widget.currentUser!.objectId == post.getAuthorId ||
                    widget.currentUser!.isAdmin!,
                child: Divider(),
              ),
              Visibility(
                visible: widget.currentUser!.isAdmin!,
                child: TextWithTap(
                  "feed.suspend_user".tr(),
                  marginBottom: 10,
                  marginTop: 10,
                  onTap: () {
                    _suspendUser(post.getAuthor!);
                  },
                ),
              ),
              Visibility(
                  visible: widget.currentUser!.isAdmin!, child: Divider()),
            ],
          ),
        ),
      ),
    );
  }

  _blockUser(UserModel author) async {
    Navigator.of(context).pop();
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setBlockedUser = author;
    widget.currentUser!.setBlockedUserIds = author.objectId!;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      widget.currentUser = response.results!.first as UserModel;

      QuickHelp.hideLoadingDialog(context);
      //QuickHelp.goToNavigator(context, BlockedUsersScreen.route);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_block_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
        message: "feed.post_block_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.hideLoadingDialog(context);
    }
  }

  void openReportMessage(UserModel author, PostsModel post) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportMessageBottomSheet(author, post);
        });
  }

  Widget _showReportMessageBottomSheet(UserModel author, PostsModel post) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
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
                    radiusTopRight: 20.0,
                    radiusTopLeft: 20.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: Column(
                      children: [
                        ContainerCorner(
                          color: kGreyColor1,
                          width: 50,
                          marginTop: 5,
                          borderRadius: 50,
                          marginBottom: 10,
                        ),
                        TextWithTap(
                          "feed.report_".tr(),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          marginBottom: 50,
                        ),
                        Column(
                          children: List.generate(
                              QuickHelp.getReportCodeMessageList().length,
                              (index) {
                            String code =
                                QuickHelp.getReportCodeMessageList()[index];

                            return TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                print("Message: " +
                                    QuickHelp.getReportMessage(code));
                                Navigator.of(context).pop();
                                _saveReport(
                                    QuickHelp.getReportMessage(code), post);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWithTap(
                                        QuickHelp.getReportMessage(code),
                                        color: kGrayColor,
                                        fontSize: 15,
                                        marginBottom: 5,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 1.0,
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                        ContainerCorner(
                          marginTop: 30,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: TextWithTap(
                              "cancel".tr().toUpperCase(),
                              color: kGrayColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  _saveReport(String reason, PostsModel post) async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser?.setReportedPostIDs = post.objectId;
    widget.currentUser?.setReportedPostReason = reason;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {});
    } else {
      QuickHelp.hideLoadingDialog(context);
    }

    ParseResponse parseResponse = await QuickActions.report(
        type: ReportModel.reportTypePost,
        message: reason,
        accuser: widget.currentUser!,
        accused: post.getAuthor!,
        postsModel: post);

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": post.getAuthor!.getFullName!}),
        message: "feed.post_report_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  _deletePost(PostsModel post) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.delete_post_alert".tr(),
      message: "feed.delete_post_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_delete".tr(),
      onPressed: () => _confirmDeletePost(post),
    );
  }

  _suspendUser(UserModel user) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(user),
    );
  }

  _confirmSuspendUser(UserModel userModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    userModel.setActivationStatus = true;
    ParseResponse parseResponse =
        await QuickCloudCode.suspendUSer(objectId: userModel.objectId!);
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "suspended".tr(),
        message: "feed.user_suspended".tr(),
        user: userModel,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.user_not_suspended".tr(),
        user: userModel,
        isError: true,
      );
    }
  }

  _confirmDeletePost(PostsModel postsModel) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await postsModel.delete();
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "deleted".tr(),
        message: "feed.post_deleted".tr(),
        user: postsModel.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.post_not_deleted".tr(),
        user: postsModel.getAuthor,
        isError: true,
      );
    }
  }

  void openReportUserMessage(UserModel author) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showReportUserMessageBottomSheet(author);
        });
  }

  Widget _showReportUserMessageBottomSheet(UserModel author) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.45,
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
                    radiusTopRight: 20.0,
                    radiusTopLeft: 20.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: Column(
                      children: [
                        ContainerCorner(
                          color: kGreyColor1,
                          width: 50,
                          marginTop: 5,
                          borderRadius: 50,
                          marginBottom: 10,
                        ),
                        TextWithTap(
                          "feed.report_".tr(),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          marginBottom: 50,
                        ),
                        Column(
                          children: List.generate(
                              QuickHelp.getReportCodeMessageList().length,
                              (index) {
                            String code =
                                QuickHelp.getReportCodeMessageList()[index];

                            return TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                print("Message: " +
                                    QuickHelp.getReportMessage(code));
                                Navigator.of(context).pop();
                                _saveUserReport(
                                    QuickHelp.getReportMessage(code), author);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWithTap(
                                        QuickHelp.getReportMessage(code),
                                        color: kGrayColor,
                                        fontSize: 15,
                                        marginBottom: 5,
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 18,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 1.0,
                                  )
                                ],
                              ),
                            );
                          }),
                        ),
                        ContainerCorner(
                          marginTop: 30,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: TextWithTap(
                              "cancel".tr().toUpperCase(),
                              color: kGrayColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  _saveUserReport(String reason, UserModel author) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponse = await QuickActions.report(
      type: ReportModel.reportTypeProfile,
      message: reason,
      accuser: widget.currentUser!,
      accused: author,
    );

    if (parseResponse.success) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "feed.post_report_success_title"
            .tr(namedArgs: {"name": author.getFullName!}),
        message: "feed.post_report_success_message".tr(),
        isError: false,
      );
    } else {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  void openFunClub() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showFanClub();
        });
  }

  Widget _showFanClub() {
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.63,
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
                    radiusTopRight: 20.0,
                    radiusTopLeft: 20.0,
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    child: IndexedStack(
                      index: fanClubIndex,
                      children: [
                        Scaffold(
                          body: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              ContainerCorner(
                                height: 90,
                                borderWidth: 0,
                                marginLeft: 15,
                                marginRight: 15,
                                marginTop: 10,
                                borderRadius: 10,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          QuickActions.avatarBorder(
                                            widget.mUser!,
                                            width: 60,
                                            height: 60,
                                            borderColor: Colors.white,
                                            hideAvatarFrame: true,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ContainerCorner(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Image.asset(
                                                        "assets/images/tab_fst_no_level.png",
                                                        height: 25,
                                                        width: 25,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 70,
                                                      child: TextWithTap(
                                                        widget.mUser!
                                                            .getMyFanClubName!,
                                                        color: Colors.white,
                                                        marginRight: 5,
                                                        fontSize: 12,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                color: earnCashColor,
                                                borderRadius: 50,
                                              ),
                                              TextWithTap(
                                                widget.mUser!.getFullName!,
                                                color: kGrayColor,
                                                marginTop: 10,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 30),
                                        child: IconButton(
                                          onPressed: () =>
                                              fanClubPrivilegesList(),
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: kGrayColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ContainerCorner(
                                color: kGrayColor.withOpacity(0.1),
                                borderRadius: 10,
                                borderWidth: 0,
                                marginLeft: 15,
                                marginRight: 15,
                                height: 60,
                                onTap: () {
                                  setState(() {
                                    fanClubIndex = 1;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 85,
                                            child: TextWithTap(
                                              "profile_page.number_members"
                                                  .tr(),
                                              color: kGrayColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17,
                                            ),
                                          ),
                                          TextWithTap(
                                            QuickHelp.convertToK(widget.mUser!
                                                .getMyFanClubMembers!.length),
                                            fontSize: 18,
                                            marginLeft: 8,
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: kGrayColor,
                                        size: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              fanClubInfo(),
                            ],
                          ),
                          bottomNavigationBar: fanClubFooter(),
                        ),
                        Scaffold(
                          appBar: AppBar(
                            automaticallyImplyLeading: false,
                            leading: BackButton(
                              color: isDark
                                  ? Colors.white
                                  : kContentColorLightTheme,
                              onPressed: () {
                                setState(() {
                                  fanClubIndex = 0;
                                });
                              },
                            ),
                            centerTitle: true,
                            title: TextWithTap("profile_page.fans_club".tr(
                                namedArgs: {
                                  "amount":
                                      "${widget.mUser!.getMyFanClubMembers!.length}"
                                })),
                          ),
                          body: myClub(),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget fanClubInfo() {
    var taskText = [
      "profile_page.send_gift_to_host".tr(),
      "profile_page.speaking_in_live_room".tr(),
      "profile_page.renew_fans".tr(),
      "profile_page.platform_speaker".tr(),
    ];

    var maxTaskValue = [300, 15, 300, 50];
    var currentTaskValue = [0, 0, 100, 0];

    Size size = MediaQuery.of(context).size;

    if (widget.mUser!.getMyFanClubMembers!
        .contains(widget.currentUser!.objectId)) {
      return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWithTap(
              "profile_page.intimacy_task".tr(),
              marginTop: 15,
              marginBottom: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                  taskText.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FAProgressBar(
                              currentValue: currentTaskValue[index] + 0.0,
                              size: 5,
                              maxValue: maxTaskValue[index] + 0.0,
                              changeColorValue: 0,
                              changeProgressColor: kPrimaryColor,
                              backgroundColor: kGrayColor.withOpacity(0.1),
                              progressColor: Colors.lightBlue,
                              animatedDuration: const Duration(seconds: 2),
                              direction: Axis.horizontal,
                              verticalDirection: VerticalDirection.up,
                              displayText: '%',
                              displayTextStyle: GoogleFonts.roboto(
                                color: kRoseVip,
                                fontSize: 1,
                              ),
                              formatValueFixed: 0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: size.width / 1.6,
                                    child: TextWithTap(
                                      taskText[index],
                                      color: kGrayColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextWithTap(
                                        "profile_page.intimacy_".tr(),
                                        color: kGrayColor,
                                        fontSize: 10,
                                      ),
                                      TextWithTap(
                                        "+${currentTaskValue[index]}",
                                        color: currentTaskValue[index] > 0
                                            ? kPrimaryColor
                                            : kGrayColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      TextWithTap(
                                        "/${maxTaskValue[index]}",
                                        color: kGrayColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWithTap(
            "profile_page.fans_club_privilege".tr(),
            marginLeft: 15,
            marginTop: 15,
          ),
          ContainerCorner(
            color: kGrayColor.withOpacity(0.1),
            borderRadius: 10,
            borderWidth: 0,
            marginLeft: 15,
            marginRight: 15,
            marginTop: 15,
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  fansClubPrivileges.length,
                  (index) => Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 15),
                        child: Row(
                          children: [
                            Image.asset(
                              fansClubPrivilegesIcons[index],
                              height: 18,
                              width: 18,
                            ),
                            TextWithTap(
                              fansClubPrivileges[index],
                              color: kGrayColor,
                              marginLeft: 10,
                            ),
                          ],
                        ),
                      )),
            ),
          )
        ],
      );
    }
  }

  Widget fanClubFooter() {
    Size size = MediaQuery.of(context).size;
    if (widget.mUser!.getMyFanClubMembers!
        .contains(widget.currentUser!.objectId)) {
      return ContainerCorner(
        width: size.width,
        marginBottom: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ContainerCorner(
              color: kPrimaryColor.withOpacity(0.2),
              height: 50,
              borderRadius: 50,
              width: size.width / 2.3,
              onTap: () {},
              child: TextWithTap(
                "profile_page.enter_group_chat".tr(),
                color: kPrimaryColor,
                fontSize: 15,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w600,
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                ContainerCorner(
                  color: kPrimaryColor,
                  height: 50,
                  borderRadius: 50,
                  width: size.width / 2.3,
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextWithTap(
                        "profile_page.renew_".tr(),
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      TextWithTap(
                        "profile_page.coins_per_month"
                            .tr(namedArgs: {"amount": "200"}),
                        color: Colors.white,
                        fontSize: 12,
                        marginBottom: 3,
                      ),
                    ],
                  ),
                ),
                ContainerCorner(
                  borderWidth: 0,
                  borderRadius: 50,
                  marginBottom: 10,
                  height: 15,
                  width: size.width / 3,
                  color: earnCashColor,
                  child: TextWithTap(
                    "profile_page.valid_period"
                        .tr(namedArgs: {"date": "2023-08-03"}),
                    fontSize: 9,
                    color: Colors.white,
                    alignment: Alignment.center,
                    textAlign: TextAlign.center,
                    marginLeft: 5,
                    marginRight: 5,
                    marginBottom: 2,
                    marginTop: 2,
                  ),
                )
              ],
            )
          ],
        ),
      );
    } else {
      return Stack(
        alignment: AlignmentDirectional.topEnd,
        children: [
          ContainerCorner(
            height: 45,
            borderRadius: 50,
            marginLeft: 10,
            marginRight: 10,
            marginBottom: 15,
            marginTop: 10,
            color: kPrimaryColor,
            onTap: () => confirmJoinFanClub(),
            child: TextWithTap(
              "profile_page.join_fans_club"
                  .tr(namedArgs: {"amount": "$feeToJoinFanClub"}),
              color: Colors.white,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            ),
          ),
          ContainerCorner(
            borderWidth: 0,
            borderRadius: 50,
            marginBottom: 10,
            marginRight: 15,
            height: 15,
            width: 170,
            color: earnCashColor,
            child: TextWithTap(
              "profile_page.join_fan_club_to_enjoy".tr(),
              fontSize: 9,
              color: Colors.white,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
              marginLeft: 5,
              marginRight: 5,
              marginBottom: 2,
              marginTop: 2,
            ),
          )
        ],
      );
    }
  }

  confirmJoinFanClub() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWithTap(
                      "profile_page.join_club".tr(),
                      fontWeight: FontWeight.w900,
                      textAlign: TextAlign.center,
                      fontSize: 16,
                    ),
                    TextWithTap(
                      "profile_page.join_club_explain".tr(namedArgs: {
                        "amount": "$feeToJoinFanClub",
                        "days": "$timeDeadDays"
                      }),
                      marginTop: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          child: TextWithTap(
                            "cancel".tr(),
                            color: kGrayColor,
                            marginRight: 15,
                            marginLeft: 15,
                          ),
                          onPressed: () =>
                              QuickHelp.goBackToPreviousPage(context),
                        ),
                        TextButton(
                          child: TextWithTap(
                            "confirm_".tr(),
                            color: kPrimaryColor,
                            marginRight: 20,
                            marginLeft: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () {
                            if (widget.currentUser!.getCredits! <
                                feeToJoinFanClub) {
                              QuickHelp.showAppNotificationAdvanced(
                                  title: "error".tr(),
                                  context: context,
                                  message:
                                      "live_streaming.not_enough_coins".tr());
                            } else {
                              joinFanClub();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  joinFanClub() async {
    QuickHelp.showLoadingDialog(context);

    QueryBuilder<FanClubModel> queryBuilder =
        QueryBuilder<FanClubModel>(FanClubModel());
    queryBuilder.whereEqualTo(
        FanClubModel.keyAuthorId, widget.mUser!.objectId!);
    ParseResponse response = await queryBuilder.query();
    FanClubModel fanClubModel = FanClubModel();

    if (response.success) {
      if (response.results != null) {
        fanClubModel = response.results!.first;
        fanClubModel.setFans = widget.currentUser!;
        fanClubModel.setFansId = widget.currentUser!.objectId!;
        await fanClubModel.save();
        becomeFanClubMember(fanClubModel);
      } else {
        fanClubModel.setAuthorId = widget.mUser!.objectId!;
        fanClubModel.setAuthor = widget.mUser!;
        fanClubModel.setName = "fan_club_screen.fans_";
        fanClubModel.setFans = widget.currentUser!;
        fanClubModel.setFansId = widget.currentUser!.objectId!;
        await fanClubModel.save();
        becomeFanClubMember(fanClubModel);
      }
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  becomeFanClubMember(FanClubModel fanClub) async {
    FanClubMembersModel fanClubMember = FanClubMembersModel();

    fanClubMember.setFanClub = fanClub;
    fanClubMember.setFanClubId = fanClub.objectId!;
    fanClubMember.setMember = widget.currentUser!;
    fanClubMember.setMemberId = widget.currentUser!.objectId!;
    fanClubMember.setAuthor = widget.mUser!;
    fanClubMember.setAuthorId = widget.mUser!.objectId!;
    fanClubMember.setExpirationDate = QuickHelp.getUntilDateFromDays(30);
    fanClubMember.addIntimacy = feeToJoinFanClub;
    ParseResponse response = await fanClubMember.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickCloudCode.addUserToMyFanClub(
          fanId: widget.currentUser!.objectId!, user: widget.mUser!);
      saveFanClubChangesInUser(fanClub.objectId!);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  saveFanClubChangesInUser(String fanClubId) {
    widget.currentUser!.setJoinedFanClubIds = fanClubId;
    widget.currentUser!.save();
  }

  Widget myClub() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<FanClubMembersModel> queryBuilder =
        QueryBuilder<FanClubMembersModel>(FanClubMembersModel());
    queryBuilder.whereEqualTo(
        FanClubMembersModel.keyFanClubId, widget.mUser!.getMyFanClubId!);
    queryBuilder.includeObject(
        [FanClubMembersModel.keyFanClub, FanClubMembersModel.keyMember]);

    return ParseLiveListWidget<FanClubMembersModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      scrollPhysics: const NeverScrollableScrollPhysics(),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<FanClubMembersModel> snapshot) {
        if (snapshot.hasData) {
          FanClubMembersModel fanClubMembers = snapshot.loadedData!;
          UserModel user = fanClubMembers.getMember!;
          return Padding(
            padding: const EdgeInsets.only(left: 15, bottom: 10, right: 15),
            child: Row(
              children: [
                QuickActions.avatarWidget(user, width: 40, height: 40),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: TextWithTap(
                            user.getFullName!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        QuickActions.giftReceivedLevel(
                          receivedGifts: user.getDiamondsTotal!,
                          width: 25,
                        ),
                        ContainerCorner(
                          marginLeft: 10,
                          color: kGreenLight,
                          borderRadius: 50,
                          child: Row(
                            children: [
                              Image.asset(
                                QuickHelp.fanClubIcon(day: 0),
                                width: 30,
                              ),
                              TextWithTap(
                                user.getFullName!,
                                color: Colors.white,
                                fontSize: 10,
                                marginRight: 5,
                                marginLeft: 3,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextWithTap(
                          "fan_club_screen.intimacy_".tr(),
                          fontSize: 12,
                          color: kGrayColor,
                        ),
                        TextWithTap(
                          "${fanClubMembers.getIntimacy}",
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(
            child: Image.asset(
          "assets/images/szy_kong_icon.png",
          height: size.width / 2,
        )),
      ),
    );
  }

  fanClubPrivilegesList() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: Scaffold(
                backgroundColor: kTransparentColor,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  backgroundColor: kTransparentColor,
                  title: TextWithTap(
                    "fan_club_privileges.fan_club_info".tr(),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                body: ListView(
                  children: List.generate(
                      fanClubPrivileges.length,
                      (index) => TextWithTap(
                            fanClubPrivileges[index],
                            marginTop: 8,
                          )),
                ),
                bottomNavigationBar: ContainerCorner(
                  height: 45,
                  onTap: () => QuickHelp.hideLoadingDialog(context),
                  child: TextWithTap(
                    "fan_club_privileges.i_see".tr(),
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w900,
                    alignment: Alignment.center,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          });
        });
  }
}
