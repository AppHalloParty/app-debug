// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:faker/faker.dart' as Fake;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart'
    as zego;
import '../../app/constants.dart';
import '../../app/setup.dart';
import '../../helpers/quick_cloud.dart';
import '../../helpers/quick_help.dart';
import '../../models/GiftsModel.dart';
import '../../models/GiftsSentModel.dart';
import '../../models/LiveStreamingModel.dart';
import '../../models/ReportModel.dart';
import '../../models/UserModel.dart';
import '../../ui/button_with_icon.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/colors.dart';
import '../coins_and_points/coins_and_points_screen.dart';
import '../message/message_screen.dart';
import '../prebuild_live/multi_users_live_screen.dart';
import '../prebuild_live/prebuild_audio_room_screen.dart';
import '../prebuild_live/prebuild_live_screen.dart';
import '../rank/rank_screen.dart';
import '../search/global_search_widget.dart';
import 'live_preview.dart';

class AllLivesScreen extends StatefulWidget {
  UserModel? currentUser;
  static String route = "/live/all";

  AllLivesScreen({
    this.currentUser,
    super.key,
  });

  @override
  State<AllLivesScreen> createState() => _AllLivesScreenState();
}

class _AllLivesScreenState extends State<AllLivesScreen>
    with TickerProviderStateMixin {
  int tabTypeParty = 1;
  int numberOfColumns = 2;

  List<dynamic> liveResults = <dynamic>[];
  List<dynamic> liveID = <dynamic>[];
  late QueryBuilder<LiveStreamingModel> queryBuilder;

  var _future;

  AnimationController? animationController;

  //final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  int tagsTabsLength = 0;
  int tagsTabIndex = 0;
  late TabController tagsTabControl;

  late TabController generalTabControl;
  int generalTabsLength = 5;
  int generalTabsIndex = 0;

  var generalTabTitles = [
    "coins_and_points_screen.all_".tr(),
    "coins_and_points_screen.live_streaming".tr(),
    "go_live_options.live_party".tr(),
    "go_live_menu.pk_title".tr(),
    "audio_chat.audio_room".tr(),
  ];

  SharedPreferences? preference;

  initSharedPref() async {
    preference = await SharedPreferences.getInstance();
    Constants.queryParseConfig(preference!);
  }

  Subscription? subscription;
  LiveQuery liveQuery = LiveQuery();
  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);

  @override
  void initState() {
    super.initState();
    loadRewardedAd();
    initSharedPref();
    creditAdded = 0;
    tagsTabsLength = QuickHelp.getLiveTagsList().length;
    animationController = AnimationController.unbounded(vsync: this);
    generalTabControl = TabController(
        vsync: this, length: generalTabsLength, initialIndex: generalTabsIndex)
      ..addListener(() {
        setState(() {
          generalTabsIndex = generalTabControl.index;
        });
        updateLives();
      });
    tagsTabControl = TabController(
        vsync: this, length: tagsTabsLength, initialIndex: tagsTabIndex)
      ..addListener(() {
        setState(() {
          tagsTabIndex = tagsTabControl.index;
        });
        updateLives();
      });
    QuickHelp.saveCurrentRoute(route: AllLivesScreen.route);
    updateLives();
  }

  @override
  void dispose() {
    super.dispose();
    generalTabControl.dispose();
    tagsTabControl.dispose();

    disposeLiveQuery();
  }

  updateLives() {
    _future = _loadLive();
  }

  disposeLiveQuery() {
    if (subscription != null) {
      liveQuery.client.unSubscribe(subscription!);
      subscription = null;
    }
  }

  setupLiveQuery() async {
    debugPrint("liveQuery_stramings *** started ***");
    if (subscription == null) {
      subscription = await liveQuery.client.subscribe(queryBuilder);
    }

    subscription!.on(LiveQueryEvent.create,
            (LiveStreamingModel updatedLive) async {
              debugPrint("liveQuery_stramings *** created ***");
          await updatedLive.getAuthor!.fetch();
          await updatedLive.getPrivateGift!.fetch();
          await updatedLive.getAuthorInvited!.fetch();

          if (!mounted) return;
          setState(() {
            if(!liveID.contains(updatedLive.objectId)) {
              liveID.add(updatedLive.objectId);
              liveResults.add(updatedLive);
            }else{
              int index = 0;
              for(int i=0; i < liveID.length; i++){
                if(liveID.contains(updatedLive.objectId)) {
                  index = i;
                }
              }
              liveID.removeAt(index);
              liveResults.removeAt(index);
              liveID.add(updatedLive.objectId);
              liveResults.add(updatedLive);
            }
          });
        });

    subscription!.on(LiveQueryEvent.enter,
            (LiveStreamingModel updatedLive) async {
              debugPrint("liveQuery_stramings *** enter ***");
              await updatedLive.getAuthor!.fetch();
              await updatedLive.getPrivateGift!.fetch();
              await updatedLive.getAuthorInvited!.fetch();

          if (!mounted) return;
              setState(() {
                if(!liveID.contains(updatedLive.objectId)) {
                  liveID.add(updatedLive.objectId);
                  liveResults.add(updatedLive);
                }else{
                  int index = 0;
                  for(int i=0; i < liveID.length; i++){
                    if(liveID.contains(updatedLive.objectId)) {
                      index = i;
                    }
                  }
                  liveID.removeAt(index);
                  liveResults.removeAt(index);
                  liveID.add(updatedLive.objectId);
                  liveResults.add(updatedLive);
                }
              });
        });

    subscription!.on(LiveQueryEvent.update,
            (LiveStreamingModel updatedLive) async {
              debugPrint("liveQuery_stramings *** update ***");
          if (!mounted) return;
          await updatedLive.getAuthor!.fetch();
          await updatedLive.getPrivateGift!.fetch();
          await updatedLive.getAuthorInvited!.fetch();

          setState(() {
            if(!liveID.contains(updatedLive.objectId)) {
              liveID.add(updatedLive.objectId);
              liveResults.add(updatedLive);
            }else{
              int index = 0;
              for(int i=0; i < liveID.length; i++){
                if(liveID.contains(updatedLive.objectId)) {
                  index = i;
                }
              }
              liveID.removeAt(index);
              liveResults.removeAt(index);
              if(!updatedLive.getStreaming!) {
                liveID.add(updatedLive.objectId);
                liveResults.add(updatedLive);
              }
            }

          });
        });

    subscription!.on(LiveQueryEvent.delete, (LiveStreamingModel updatedLive) {
      if (!mounted) return;

    });
  }

  RewardedAd? _rewardedAd;
  bool adLoad = false;
  int creditAdded = 0;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: Setup.admobAndroidWalletReward,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          setState(() {
            _rewardedAd = ad;
            adLoad = true;
          });

          setCallBacks();
        },
        onAdFailedToLoad: (LoadAdError error) {},
      ),
    );
  }

  void setCallBacks() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (RewardedAd ad) {
        //ad.dispose();

        setState(() {
          adLoad = false;
        });
      }, onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        if (creditAdded != 0) {
          QuickHelp.showAppNotificationAdvanced(
            title: "reward_coins.congratulations_title".tr(),
            message: "reward_coins.congratulations_msg"
                .tr(namedArgs: {"credit": creditAdded.toString()}),
            isError: false,
            context: context,
          );
          QuickHelp.saveCoinTransaction(author: widget.currentUser!, amountTransacted: creditAdded);
          creditAdded = 0;
        }
        loadRewardedAd();
      }, onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        setState(() {
          adLoad = false;
        });
        loadRewardedAd();
      });
      _rewardedAd!.setImmersiveMode(true);
      //showAd();
    }
  }

  void showAd() {
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        creditAdded = Setup.earnCredit;
        widget.currentUser!.addCredit = creditAdded;
        ParseResponse response = await widget.currentUser!.save();

        if (response.success) {
          setState(() {
            widget.currentUser = response.results!.first;
          });
        }
      },
    );
  }

  Future<dynamic> _loadLive() async {
    QueryBuilder<UserModel> queryUsers = QueryBuilder(UserModel.forQuery());
    queryUsers.whereValueExists(UserModel.keyUserStatus, true);
    queryUsers.whereEqualTo(UserModel.keyUserStatus, true);

    queryBuilder = QueryBuilder<LiveStreamingModel>(LiveStreamingModel());

    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);
    queryBuilder.whereNotEqualTo(
        LiveStreamingModel.keyAuthorUid, widget.currentUser!.getUid);
    queryBuilder.whereNotContainedIn(
        LiveStreamingModel.keyAuthor, widget.currentUser!.getBlockedUsers!);
    queryBuilder.whereValueExists(LiveStreamingModel.keyAuthor, true);
    queryBuilder.whereDoesNotMatchQuery(
        LiveStreamingModel.keyAuthor, queryUsers);

    if (tagsTabIndex > 0) {
      queryBuilder.whereContains(LiveStreamingModel.keyHashTags,
          QuickHelp.getLiveTagsList()[tagsTabIndex]);
    }

    if (generalTabsIndex == 1) {
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyLiveType, LiveStreamingModel.liveVideo);
    } else if (generalTabsIndex == 2) {
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyLiveType, LiveStreamingModel.liveTypeParty);
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyPartyType, LiveStreamingModel.liveVideo);
    } else if (generalTabsIndex == 3) {
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyBattleStatus, LiveStreamingModel.battleAlive);
    }else if(generalTabsIndex == 4) {
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyPartyType, LiveStreamingModel.liveAudio);
      queryBuilder.whereEqualTo(
          LiveStreamingModel.keyLiveType, LiveStreamingModel.liveAudio);
    }

    queryBuilder.includeObject([
      LiveStreamingModel.keyAuthor,
      LiveStreamingModel.keyAuthorInvited,
      LiveStreamingModel.keyPrivateLiveGift
    ]);

    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        setupLiveQuery();
        liveResults.clear();
        setState(() {
          for(int i = 0; i < apiResponse.results!.length; i++){
            LiveStreamingModel live = apiResponse.results![i];
            if(!liveID.contains(live.objectId)) {
              liveID.add(live.objectId);
              liveResults.add(live);
            }
          }
        });

        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }

  Future<void> _loadLiveUpdate() async {
    ParseResponse apiResponse = await queryBuilder.query();
    if (apiResponse.success) {
      if (apiResponse.results != null) {
        setState(() {
          liveResults.clear();
          liveResults.addAll(apiResponse.results!);
        });

        return Future(() => null);
      }
    } else {
      return Future(() => null);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return Scaffold(
      floatingActionButton: floating(),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () async {
                UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                  context,
                  ProfileScreen(
                    currentUser: widget.currentUser,
                  ),
                );
                if (user != null) {
                  setState(() {
                    widget.currentUser = user;
                  });
                }
              },
              child: QuickActions.avatarWidget(
                widget.currentUser!,
                height: 27,
                width: 27,
                margin: EdgeInsets.only(
                  left: 10,
                  right: 10,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                  context,
                    CoinsAndPointsScreen(
                      currentUser: widget.currentUser,
                      initialIndex: 0,
                    ),
                );
                if (user != null) {
                  setState(() {
                    widget.currentUser = user;
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/icon_jinbi.png",
                    height: 17,
                    width: 17,
                  ),
                  TextWithTap(
                    QuickHelp.checkFundsWithString(
                      amount: "${widget.currentUser!.getCredits}",
                    ),
                    marginLeft: 5,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async{
              showGlobalSearch(
                currentUser: widget.currentUser!,
                context: context,
                onlyEvent: false,
                onlyLives: true,
                onlyUsers: false
              );
            },
            /*onPressed: () => QuickHelp.goToNavigatorScreen(
              context,
              SearchPage(
                preferences: widget.preferences,
                currentUser: widget.currentUser,
              ),
            ),*/
            icon: SvgPicture.asset(
              isDarkMode
                  ? "assets/svg/ic_search_for_dark_mode.svg"
                  : "assets/svg/ic_search_for_light_mode.svg",
              height: 25,
              width: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: () => QuickHelp.goToNavigatorScreen(
                context,
                RankingScreen(
                  currentUser: widget.currentUser,
                ),
              ),
              icon: SvgPicture.asset(
                "assets/svg/ic_rank.svg",
                height: 25,
                width: 25,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ContainerCorner(
                color: kRoseVipClair,
                marginRight: 10,
                marginLeft: 7,
                borderRadius: 4,
                marginBottom: 7,
                child: TabBar(
                  isScrollable: true,
                  enableFeedback: false,
                  controller: generalTabControl,
                  dividerColor: kTransparentColor,
                  padding: EdgeInsets.all(3),
                  indicatorWeight: 0,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabAlignment: TabAlignment.start,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                    return states.contains(WidgetState.focused)
                        ? null
                        : Colors.transparent;
                  }),
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: 1.0,
                  ),
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: kDarkColorsTheme,
                    fontWeight: FontWeight.w300,
                  ),
                  tabs: List.generate(
                    generalTabControl.length,
                    (index) {
                      return ContainerCorner(
                        color: index == generalTabsIndex
                            ? kBronzeColor
                            : kTransparentColor,
                        borderRadius: 4,
                        shadowColor: kBlueDarker,
                        shadowColorOpacity: 0.1,
                        child: TextWithTap(
                          generalTabTitles[index],
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          marginTop: 3,
                          marginBottom: 3,
                          marginLeft: 20,
                          marginRight: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              TabBar(
                isScrollable: true,
                enableFeedback: false,
                tabAlignment: TabAlignment.center,
                controller: tagsTabControl,
                dividerColor: kTransparentColor,
                unselectedLabelColor: Colors.black,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  return states.contains(WidgetState.focused)
                      ? null
                      : Colors.transparent;
                }),
                indicatorWeight: 2.0,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: 7.0,
                ),
                automaticIndicatorColorAdjustment: false,
                labelColor: Colors.black,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide.none,
                ),
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    TextStyle(fontSize: 14, color: Colors.black),
                tabs: List.generate(tagsTabsLength, (index) {
                  bool selectedTab = tagsTabIndex == index;
                  return ContainerCorner(
                    color: selectedTab ? null : kGrayColor.withOpacity(0.1),
                    colors: selectedTab ? [kPrimaryColor, kPurpreColor] : [],
                    borderRadius: 4,
                    child: TextWithTap(
                      "#${QuickHelp.getLiveTagsByCode(QuickHelp.getLiveTagsList()[index])}",
                      color: selectedTab || isDarkMode
                          ? Colors.white
                          : Colors.black,
                      alignment: Alignment.center,
                      fontWeight: FontWeight.bold,
                      marginLeft: 10,
                      marginRight: 10,
                      marginTop: 5,
                      marginBottom: 5,
                      fontSize: 11,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: generalTabControl,
        children: [for (int i = 0; i < generalTabsLength; i++) initQuery(0)],
      ),
    );
  }

  Widget floating() {
    return ContainerCorner(
      borderRadius: 50,
      colors: [earnCashColor, kSendGiftColor],
      onTap: () {
        /*QuickHelp.goToNavigatorScreen(
            context,
          SvgaListsCreen(),
        );*/
        if (zego.ZegoUIKitPrebuiltLiveStreamingController()
            .minimize
            .isMinimizing) {
          return;
        }
        QuickHelp.goToNavigatorScreen(
          context,
          LivePreviewScreen(
            currentUser: widget.currentUser!,
            liveTypeIndex: 1,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextWithTap(
              "live_streaming.go_live_btn".tr(),
              color: Colors.white,
              marginLeft: 10,
              marginRight: 10,
              fontWeight: FontWeight.bold,
            ),
            Image.asset(
              "assets/images/ic_main_default.png",
              height: 25,
              width: 25,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }

  Widget initQuery(int category) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.all(2),
      child: Column(
        children: [
          Visibility(
            visible: adLoad,
            child: Padding(
              padding: const EdgeInsets.only(left: 5, right: 3, bottom: 5),
              child: GestureDetector(
                onTap: () {
                  if (adLoad) {
                    showAd();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset("assets/images/reward_credit_banner.png"),
                    SizedBox(
                      width: size.width / 3,
                      child: TextWithTap(
                        "earn_coins".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(
                    delay: 100
                        .ms, // this delay only happens once at the very start
                    onPlay: (controller) => controller.repeat(), // loop
                  )
                  .fadeIn(duration: Duration(seconds: 1))
                  .fadeOut(
                    delay: Duration(seconds: 2),
                    duration: Duration(seconds: 2),
                  ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _future,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.custom(
                      physics: const AlwaysScrollableScrollPhysics(),
                      primary: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1,
                        childAspectRatio: 0.7,
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        childCount: 8,
                        (BuildContext context, int index) {
                          return FadeShimmer(
                            height: double.infinity,
                            width: double.infinity,
                            radius: 4,
                            fadeTheme: QuickHelp.isDarkModeNoContext()
                                ? FadeTheme.dark
                                : FadeTheme.light,
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasData) {
                    liveResults = snapshot.data! as List<dynamic>;

                    if (liveResults.isNotEmpty) {
                      return RefreshIndicator(
                        //key: _refreshIndicatorKey,
                        color: Colors.white,
                        backgroundColor: kPrimaryColor,
                        strokeWidth: 2.0,
                        onRefresh: () {
                          //_refreshIndicatorKey.currentState?.show(atTop: true);
                          return _loadLiveUpdate();
                        },
                        child: GridView.custom(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1,
                            childAspectRatio: 0.7,
                            mainAxisSpacing: 1,
                          ),
                          childrenDelegate: SliverChildBuilderDelegate(
                            childCount: liveResults.length,
                            (BuildContext context, int index) {
                              final LiveStreamingModel liveStreaming =
                                  liveResults[index] as LiveStreamingModel;
                              return GestureDetector(
                                onLongPress: () {
                                  if (liveStreaming.getAuthorId !=
                                      widget.currentUser!.objectId) {
                                    openSheet(liveStreaming.getAuthor!,
                                        liveStreaming);
                                  }
                                },
                                onTap: () {
                                  if (zego.ZegoUIKitPrebuiltLiveStreamingController()
                                      .minimize
                                      .isMinimizing) {
                                    return;
                                  }
                                  if(liveStreaming.getPrivate!) {
                                    if(liveStreaming.getPrivateViewersId!.contains(widget.currentUser!.objectId!)) {
                                      getInLiveStreamingRoom(liveStreaming);
                                    }else{
                                      openPayPrivateLiveSheet(liveStreaming);
                                    }
                                  }else{
                                    getInLiveStreamingRoom(liveStreaming);
                                  }
                                },
                                child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      ContainerCorner(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: kTransparentColor,
                                        borderRadius: 3,
                                        child: QuickActions.photosWidget(
                                          liveStreaming.getImage!.url!,
                                          borderRadius: 5,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      ContainerCorner(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.black.withOpacity(0.4),
                                        borderRadius: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, top: 10),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                        "assets/svg/ic_small_viewers.svg",
                                                        height: 13,
                                                      ),
                                                      TextWithTap(
                                                        liveStreaming
                                                            .getViewersCount
                                                            .toString(),
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        marginRight: 15,
                                                        marginLeft: 5,
                                                      ),
                                                    ],
                                                  ),
                                                  /*Lottie.asset(
                                                  "assets/lotties/ic_video_tab.json",
                                                height: 39,
                                                width: 40,
                                              )*/
                                                ],
                                              ),
                                            ),
                                            if(liveStreaming.getPrivate!)
                                              SvgPicture.asset(
                                                "assets/svg/private_live_notifier.svg",
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                                left: 5,
                                              ),
                                              child: Row(
                                                children: [
                                                  QuickActions.avatarWidget(
                                                    liveStreaming.getAuthor!,
                                                    height: 30,
                                                    width: 30,
                                                    vipFrameWidth: 40,
                                                    vipFrameHeight: 37,
                                                    margin: EdgeInsets.only(
                                                      left: 5, bottom: 5,
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ContainerCorner(
                                                        width: size.width / 3,
                                                        child: TextWithTap(
                                                          liveStreaming
                                                              .getAuthor!
                                                              .getFullName!,
                                                          color: Colors.white,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          marginLeft: 10,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Image.asset(
                                                              "assets/images/pop_silver_icon.png",
                                                              height: 12,
                                                              width: 12,
                                                            ),
                                                            TextWithTap(
                                                              liveStreaming
                                                                  .getAuthor!
                                                                  .getDiamondsTotal!
                                                                  .toString(),
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.5),
                                                              fontSize: 12,
                                                              marginLeft: 3,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      if(liveStreaming.getBattleStatus == LiveStreamingModel.battleAlive)
                                      Image.asset(
                                        "assets/images/live_pk_icon_vs.png",
                                        width: 45,
                                        height: 45,
                                      ),
                                    ]),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return ContainerCorner(
                        width: size.width,
                        height: size.height,
                        borderWidth: 0,
                        child: Center(
                            child: Image.asset(
                          "assets/images/szy_kong_icon.png",
                          height: size.width / 2,
                        )),
                      );
                    }
                  } else {
                    return ContainerCorner(
                      width: size.width,
                      height: size.height,
                      borderWidth: 0,
                      child: Center(
                          child: Image.asset(
                        "assets/images/szy_kong_icon.png",
                        height: size.width / 2,
                      )),
                    );
                  }
                }),
          ),
        ],
      ),
    );

    /*if(_isLoading){

      return GridView.custom(
        physics: const AlwaysScrollableScrollPhysics(),
        primary: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        childrenDelegate: SliverChildBuilderDelegate(
          childCount: 8, (BuildContext context, int index) {
          return FadeShimmer(
            height: 60,
            width: 60,
            radius: 4,
            fadeTheme: QuickHelp.isDarkModeNoContext() ? FadeTheme.dark : FadeTheme.light,
          );
        },
        ),
      );

    } else if(liveResults.isNotEmpty) {

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: kPrimaryColor,
        strokeWidth: 2.0,
        onRefresh: () {
          _refreshIndicatorKey.currentState?.show(atTop: true);
          return _loadLiveUpdate(tabIndex);
        },
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          itemCount: liveResults.length,
          itemBuilder: (BuildContext context, int index) {

            if (liveResults[index] is LiveStreamingModel){

              final LiveStreamingModel liveStreaming = liveResults[index] as LiveStreamingModel;
              return GestureDetector(
                onTap: (){
                  checkPermission(false, channel: liveStreaming.getStreamingChannel, liveStreamingModel: liveStreaming);
                },
                child: Stack(children: [
                  ContainerCorner(
                    color: kTransparentColor,
                    child: QuickActions.photosWidget(liveStreaming.getImage!.url!, borderRadius: 5),
                  ),
                  Positioned(
                    top: 0,
                    child: ContainerCorner(
                      radiusTopLeft: 5,
                      radiusTopRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      child: ContainerCorner(
                        color: kTransparentColor,
                        marginLeft: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/svg/ic_small_viewers.svg",
                                  height: 18,
                                ),
                                TextWithTap(liveStreaming.getViewersCount.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginRight: 15,
                                  marginLeft: 5,
                                ),
                                SvgPicture.asset(
                                  "assets/svg/ic_diamond.svg",
                                  height: 24,
                                ),
                                TextWithTap(
                                  liveStreaming.getAuthor!.getDiamondsTotal!.toString(),
                                  color: Colors.white,
                                  fontSize: 14,
                                  marginLeft: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: liveStreaming.getPrivate!,
                    child: Center(
                      child: Icon(Icons.vpn_key, color: Colors.white, size: 35,),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: ContainerCorner(
                      radiusBottomLeft: 5,
                      radiusBottomRight: 5,
                      height: 40,
                      width: (MediaQuery.of(context).size.width / numberOfColumns) - 5,
                      alignment: Alignment.center,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.05)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      child: Row(
                        children: [
                          QuickActions.avatarWidget(
                              liveStreaming.getAuthor!, height: 30, width: 30,
                              margin: EdgeInsets.only(left: 5, bottom: 5)
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextWithTap(
                                liveStreaming.getAuthor!.getFullName!,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                marginLeft: 10,
                              ),
                              Visibility(
                                visible: liveStreaming.getStreamingTags!.isNotEmpty,
                                child: TextWithTap(
                                  liveStreaming.getStreamingTags!,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis,
                                  marginLeft: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              );

            } else {

              return FutureBuilder(
                  future: getNativeAdTest(context: context),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasData) {
                      AdWidget ad = snapshot.data as AdWidget;

                      final Container adContainer = Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: ad,
                      );

                      return adContainer;

                    } else {
                      return Container(
                          alignment: Alignment.topCenter,
                          margin: const EdgeInsets.only(top: 20),
                          child: const CircularProgressIndicator(
                            value: 0.8,
                          ));
                    }
                  });
            }
          },
          staggeredTileBuilder: (int index){

            if (liveResults[index] is LiveStreamingModel){ //if (index % _kAdIndex == 0) {
              return StaggeredTile.count(1, 1);
            } else {
              return StaggeredTile.count(2, 3);
            }

          },
        ),
      );

    } else {

      return Center(
        child: Padding(
          padding:  EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(
            "live_streaming.no_live_title".tr(),
            "live_streaming.no_live_explain".tr(),
            "assets/svg/ic_tab_live_default.svg",
          ),
        ),
      );
    }*/
  }

  getInLiveStreamingRoom(LiveStreamingModel liveStreaming) {
    if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveVideo) {
      QuickHelp.goToNavigatorScreen(
        context,
        PreBuildLiveScreen(
          isHost: false,
          currentUser: widget.currentUser,
          liveStreaming: liveStreaming,
          liveID:
          liveStreaming.getStreamingChannel!,
          localUserID:
          widget.currentUser!.objectId!,
        ),
      );
    } else if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveAudio) {
      QuickHelp.goToNavigatorScreen(
          context,
          PrebuildAudioRoomScreen(
            currentUser: widget.currentUser,
            isHost: false,
            liveStreaming: liveStreaming,
          ));
    } else if (liveStreaming.getLiveType ==
        LiveStreamingModel.liveTypeParty) {
      QuickHelp.goToNavigatorScreen(
        context,
        MultiUsersLiveScreen(
          isHost: false,
          currentUser: widget.currentUser,
          liveStreaming: liveStreaming,
          liveID:
          liveStreaming.getStreamingChannel!,
          localUserID:
          widget.currentUser!.objectId!,
        ),
      );
    }
  }

  void openSheet(UserModel author, LiveStreamingModel live) async {
    showModalBottomSheet(
        context: (context),
        //isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPostOptionsAndReportAuthor(author, live);
        });
  }

  Widget _showPostOptionsAndReportAuthor(
      UserModel author, LiveStreamingModel live) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              visible: !widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.report_live".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                radiusTopLeft: 25.0,
                radiusTopRight: 25.0,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  openReportMessage(author, live, true);
                },
              ),
            ),
            Visibility(
                visible: !widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: !widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.report_live_user"
                    .tr(namedArgs: {"name": author.getFullName!}),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  openReportMessage(author, live, false);
                },
              ),
            ),
            Visibility(
                visible: !widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_suspend".tr(),
                textColor: Colors.black,
                fontSize: 18,
                radiusTopLeft: 25.0,
                radiusTopRight: 25.0,
                fontWeight: FontWeight.w500,
                iconURL: "assets/svg/ic_blocked_menu.svg",
                onTap: () => _suspendUser(live),
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_terminate".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  _terminateLive(live);
                },
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_change".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () => _changePicture(live, terminate: false),
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_change_terminate".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () => _changePicture(live, terminate: true),
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
            Visibility(
              visible: widget.currentUser!.isAdmin!,
              child: ButtonWithIcon(
                text: "live_streaming.live_option_chat".tr(),
                iconURL: "assets/svg/ic_blocked_menu.svg",
                height: 60,
                backgroundColor: Colors.white,
                mainAxisAlignment: MainAxisAlignment.start,
                textColor: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                onTap: () {
                  _gotToChat(widget.currentUser!, live.getAuthor!);
                },
              ),
            ),
            Visibility(visible: widget.currentUser!.isAdmin!, child: Divider()),
          ],
        ),
      ),
    );
  }

  void openReportMessage(UserModel author,
      LiveStreamingModel liveStreamingModel, bool isStreamer) async {
    showModalBottomSheet(
      context: (context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) {
        return _showReportMessageBottomSheet(
            author, liveStreamingModel, isStreamer);
      },
    );
  }

  Widget _showReportMessageBottomSheet(
      UserModel author, LiveStreamingModel streamingModel, bool isStreamer) {
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
              isStreamer
                  ? "live_streaming.report_live".tr()
                  : "live_streaming.report_live_user"
                      .tr(namedArgs: {"name": author.getFirstName!}),
              fontWeight: FontWeight.w900,
              fontSize: 20,
              marginBottom: 50,
            ),
            Column(
              children: List.generate(
                  QuickHelp.getReportCodeMessageList().length, (index) {
                String code = QuickHelp.getReportCodeMessageList()[index];

                return TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    print("Message: " + QuickHelp.getReportMessage(code));
                    _saveReport(QuickHelp.getReportMessage(code), author,
                        live: isStreamer ? streamingModel : null);
                  },
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  }

  _saveReport(String reason, UserModel? user,
      {LiveStreamingModel? live}) async {
    QuickHelp.showLoadingDialog(context);

    ParseResponse response = await QuickActions.report(
        type: ReportModel.reportTypeLiveStreaming,
        message: reason,
        accuser: widget.currentUser!,
        accused: user!,
        liveStreamingModel: live);
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
          context: context,
          user: widget.currentUser,
          title: "live_streaming.report_done".tr(),
          message: "live_streaming.report_done_explain".tr(),
          isError: false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "live_streaming.report_live_error".tr(),
          isError: true);
    }
  }

  _terminateLive(LiveStreamingModel live) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "live_streaming.live_option_terminate".tr(),
      message: "live_streaming.live_option_terminate_ask".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "live_streaming.live_option_terminate_ask_yes".tr(),
      onPressed: () => _confirmTerminateLive(live),
    );
  }

  _suspendUser(LiveStreamingModel live) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "feed.suspend_user_alert".tr(),
      message: "feed.suspend_user_message".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "feed.yes_suspend".tr(),
      onPressed: () => _confirmSuspendUser(live),
    );
  }

  _confirmSuspendUser(LiveStreamingModel live) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    live.setTerminatedByAdmin = true;
    live.setStreaming = false;
    await live.save();

    ParseResponse parseResponse =
        await QuickCloudCode.suspendUSer(objectId: live.getAuthor!.objectId!);
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "suspended".tr(),
        message: "feed.user_suspended".tr(),
        user: live.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "feed.user_not_suspended".tr(),
        user: live.getAuthor,
        isError: true,
      );
    }
  }

  _confirmTerminateLive(LiveStreamingModel live) async {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showLoadingDialog(context);

    live.setTerminatedByAdmin = true;
    ParseResponse parseResponse = await live.save();

    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "live_streaming.live_option_terminate".tr(),
        message: "live_streaming.live_option_terminated".tr(),
        user: live.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "live_streaming.live_option_not_terminated".tr(),
        user: live.getAuthor,
        isError: true,
      );
    }
  }

  _gotToChat(UserModel currentUser, UserModel mUser) {
    QuickHelp.goToNavigatorScreen(
        context,
        MessageScreen(
            currentUser: currentUser,
            mUser: mUser,
        ));
  }

  _changePicture(LiveStreamingModel live, {bool? terminate = false}) {
    QuickHelp.goBackToPreviousPage(context);

    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "live_streaming.live_option_change".tr(),
      message: terminate == true
          ? "live_streaming.live_option_change_photo_ask".tr()
          : "live_streaming.live_option_change_photo_normal_ask".tr(),
      cancelButtonText: "no".tr(),
      confirmButtonText: "live_streaming.live_option_change_photo_ask_yes".tr(),
      onPressed: () => _confirmChangePicture(live, terminate),
    );
  }

  _confirmChangePicture(LiveStreamingModel live, terminate) async {
    QuickHelp.goBackToPreviousPage(context);
    QuickHelp.showLoadingDialog(context);

    List<String> keywords = [];

    if (live.getAuthor!.getGender! == UserModel.keyGenderMale) {
      keywords = ["sexy male", "male model"];
    } else if (live.getAuthor!.getGender! == UserModel.keyGenderFemale) {
      keywords = ["sexy female", "female model"];
    } else {
      keywords = ["model", "sexy"];
    }

    var faker = Fake.Faker();
    String imageUrl = faker.image
        .image(width: 640, height: 640, keywords: keywords, random: true);

    File avatar = await QuickHelp.downloadFile(imageUrl, "avatar.jpeg") as File;

    if (terminate) {
      live.setTerminatedByAdmin = true;
      live.setStreaming = false;
      await live.save();
    } else {
      ParseFileBase parseFile;
      if (QuickHelp.isWebPlatform()) {
        //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
        ParseWebFile file =
            ParseWebFile(null, name: "avatar.jpeg", url: avatar.path);
        await file.download();
        parseFile = ParseWebFile(file.file, name: file.name);
      } else {
        parseFile = ParseFile(File(avatar.path));
      }

      live.setImage = parseFile;
      await live.save();
    }

    ParseResponse parseResponse = await QuickCloudCode.changePicture(
        user: live.getAuthor!, parseFile: avatar.readAsBytesSync());
    if (parseResponse.success) {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "live_streaming.live_option_change".tr(),
        message: "live_streaming.live_option_changed_photo".tr(),
        user: live.getAuthor,
        isError: null,
      );
    } else {
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "live_streaming.live_option_not_changed_photo".tr(),
        user: live.getAuthor,
        isError: true,
      );
    }
  }

  void openPayPrivateLiveSheet(LiveStreamingModel live) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showPayPrivateLiveBottomSheet(live);
        });
  }

  Widget _showPayPrivateLiveBottomSheet(LiveStreamingModel live) {
    Size size = MediaQuery.sizeOf(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
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
                  child: Scaffold(
                    appBar: AppBar(
                      toolbarHeight: 35.0,
                      backgroundColor: kTransparentColor,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      actions: [
                        IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.close)),
                      ],
                    ),
                    backgroundColor: kTransparentColor,
                    body: Column(
                      children: [
                        Center(
                            child: TextWithTap(
                          "live_streaming.private_live".tr(),
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          marginBottom: 15,
                        )),
                        Center(
                          child: TextWithTap(
                            "live_streaming.private_live_explain".tr(),
                            color: Colors.white,
                            fontSize: 16,
                            marginLeft: 20,
                            marginRight: 20,
                            marginTop: 20,
                          ),
                        ),
                        Expanded(
                            child: Lottie.network(
                                live.getPrivateGift!.getFile!.url!,
                                width: 150,
                                height: 150,
                                animate: true,
                                repeat: true)),
                        ContainerCorner(
                          color: kTransparentColor,
                          marginTop: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/ic_coin_with_star.svg",
                                width: 24,
                                height: 24,
                              ),
                              TextWithTap(
                                live.getPrivateGift!.getCoins.toString(),
                                color: Colors.white,
                                fontSize: 18,
                                marginLeft: 5,
                              )
                            ],
                          ),
                        ),
                      ],
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
                        _payForPrivateLive(live);
                      },
                      child: TextWithTap(
                        "live_streaming.pay_for_live".tr(),
                        color: Colors.white,
                        alignment: Alignment.center,
                      ),
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

  _payForPrivateLive(LiveStreamingModel live) async {
    QuickHelp.showLoadingDialog(context);

    GiftsSentModel giftsSentModel = new GiftsSentModel();
    giftsSentModel.setAuthor = widget.currentUser!;
    giftsSentModel.setAuthorId = widget.currentUser!.objectId!;

    giftsSentModel.setReceiver = live.getAuthor!;
    giftsSentModel.setReceiverId = live.getAuthor!.objectId!;

    giftsSentModel.setGift = live.getPrivateGift!;
    giftsSentModel.setGiftId = live.getPrivateGift!.objectId!;
    giftsSentModel.setCounterDiamondsQuantity = live.getPrivateGift!.getCoins!;

    await giftsSentModel.save();

    updateLivePaidUser(live);

    QuickHelp.saveReceivedGifts(
      receiver: live.getAuthor!,
      author: widget.currentUser!,
      gift: live.getPrivateGift!,
    );

    QuickHelp.saveCoinTransaction(
      receiver: live.getAuthor!,
      author: widget.currentUser!,
      amountTransacted: live.getPrivateGift!.getCoins!,
    );

    ParseResponse response = await QuickCloudCode.sendGift(
      author: live.getAuthor!,
      credits: live.getPrivateGift!.getCoins!,
    );

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.hideLoadingDialog(context);
      updateCurrentUserCredit(
          live.getPrivateGift!.getCoins!, live, giftsSentModel);
      getInLiveStreamingRoom(live);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "connection_failed".tr(),
        message: "not_connected".tr(),
        context: context,
      );
    }
  }

  updateLivePaidUser(LiveStreamingModel live) {
    live.setPrivateViewersId = widget.currentUser!.objectId!;
    live.save();;
  }

  updateCurrentUserCredit(
      int coins, LiveStreamingModel live, GiftsSentModel sentModel) async {
    widget.currentUser!.removeCredit = coins;
    ParseResponse userResponse = await widget.currentUser!.save();
    if (userResponse.success) {
      widget.currentUser = userResponse.results!.first as UserModel;
    }
  }
}
