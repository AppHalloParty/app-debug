// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/GiftsModel.dart';
import '../../models/ObtainedItemsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../choose_guardian/choose_guardian_screen.dart';
import '../feed/visualize_multiple_pictures_screen.dart';
import '../prebuild_live/gift/components/svga_player_widget.dart';
import '../prebuild_live/gift/gift_data.dart';
import '../prebuild_live/gift/gift_manager/gift_manager.dart';
import '../store/wave.dart';

class MyObtainedItems extends StatefulWidget {
  UserModel? currentUser;

  MyObtainedItems({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<MyObtainedItems> createState() => _MyObtainedItemsState();
}

AnimationController? _animationController;

class _MyObtainedItemsState extends State<MyObtainedItems>
    with TickerProviderStateMixin {
  int tabsLength = 3;

  UserModel? userReceiver;

  int tabTypeAvatarFrame = 0;
  int tabTypePartyTheme = 1;
  int tabTypeEntranceEffect = 2;

  int tabIndex = 0;

  late TabController _tabController;

  var selectedBgImages = [
    "assets/images/bg_avatar_frame_selected.png",
    "assets/images/bg_party_them_selected.png",
    "assets/images/bg_entrance_effect_selected.png",
  ];

  var defaultBgImages = [
    "assets/images/bg_avatar_frame_default.png",
    "assets/images/bg_party_theme_default.png",
    "assets/images/bg_entrance_effect_default.png",
  ];

  var tabTitles = [
    "store_screen.avatar_frame".tr(),
    "store_screen.party_theme".tr(),
    "store_screen.entrance_effect".tr()
  ];

  String actionPurchase = "purchase";
  String actionSending = "sending";

  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);
    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(() {
            setState(() {
              tabIndex = _tabController.index;
            });
          });

    ZegoGiftManager().cache.cacheAllFiles(giftItemList);

    ZegoGiftManager().service.recvNotifier.addListener(onGiftReceived);
  }

  void onGiftReceived() {
    final receivedGift = ZegoGiftManager().service.recvNotifier.value ??
        ZegoGiftProtocolItem.empty();
    final giftData = queryGiftInItemList(receivedGift.name);
    if (null == giftData) {
      debugPrint('not ${receivedGift.name} exist');
      return;
    }

    //Uncomment to play on receive

    //ZegoGiftManager().playList.add(giftData,);

    QuickHelp.showAppNotificationAdvanced(
      title: "Gift Recebido",
      context: context,
      isError: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    ZegoGiftManager().service.recvNotifier.removeListener(onGiftReceived);
    ZegoGiftManager().service.uninit();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
          onPressed: () => QuickHelp.goBackToPreviousPage(context,
              result: widget.currentUser),
        ),
        centerTitle: true,
        title: TextWithTap(
          "my_obtained_items_screen.mine_".tr(),
          fontWeight: FontWeight.w700,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: ContainerCorner(
            width: size.width,
            marginLeft: 10,
            marginTop: 15,
            color: isDark ? kContentDarkShadow : kGrayWhite,
            child: TabBar(
              isScrollable: true,
              enableFeedback: false,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: kTransparentColor,
              unselectedLabelColor: kTabIconDefaultColor,
              indicatorWeight: 2.0,
              labelPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 10),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide.none,
              ),
              automaticIndicatorColorAdjustment: false,
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              tabs: List.generate(selectedBgImages.length, (index) {
                return Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Image.asset(
                      tabIndex == index
                          ? selectedBgImages[index]
                          : defaultBgImages[index],
                      width: size.width / 3.3,
                    ),
                    SizedBox(
                      width: size.width / 3.2,
                      child: TextWithTap(
                        tabTitles[index],
                        color: Colors.white,
                        marginLeft: 30,
                        fontWeight: FontWeight.w900,
                        marginRight: 5,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_getAvatarFrames(), _getPartyThemes(), _getEntranceEffect()],
      ),
    );
  }

  _getEntranceEffect() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<ObtainedItemsModel> query =
        QueryBuilder<ObtainedItemsModel>(ObtainedItemsModel());

    query.whereEqualTo(
        ObtainedItemsModel.keyAuthorId, widget.currentUser!.objectId!);
    query.includeObject([ObtainedItemsModel.keyItem]);

    //query.whereEqualTo(GiftsModel.keyGiftCategories, GiftsModel.categoryEntranceEffect);
    query.whereEqualTo(GiftsModel.keyGiftCategories, GiftsModel.categorySvgaGifts);

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
          child: ParseLiveGridWidget<ObtainedItemsModel>(
            query: query,
            crossAxisCount: 2,
            reverse: false,
            crossAxisSpacing: 10,
            mainAxisSpacing: 20,
            lazyLoading: false,
            childAspectRatio: .8,
            shrinkWrap: true,
            listeningIncludes: [ObtainedItemsModel.keyItem],
            duration: const Duration(milliseconds: 200),
            animationController: _animationController,
            childBuilder: (BuildContext context,
                ParseLiveListElementSnapshot<ObtainedItemsModel> snapshot) {
              if (snapshot.hasData) {
                ObtainedItemsModel obtainedItems = snapshot.loadedData!;
                GiftsModel storeItem = obtainedItems.getItem!;
                bool using =
                    storeItem.objectId == widget.currentUser!.getEntranceEffectId;
                return ContainerCorner(
                  color: isDark ? kContentColorLightTheme : Colors.white,
                  borderRadius: 10,
                  borderWidth: 0,
                  onTap: () {
                    selectedGiftItemNotifier.value = storeItem;
                    /// local play
                    ZegoGiftManager().playList.add(storeItem);
                  },
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Column(
                        children: [
                          ClipPath(
                            clipper: WaveClipper(),
                            child: ContainerCorner(
                              radiusTopLeft: 10,
                              radiusTopRight: 10,
                              borderWidth: 0,
                              height: 120,
                              imageDecoration: "assets/images/bg_entrance_item.png",
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          QuickActions.photosWidget(
                            storeItem.getFile!.url!,
                            width: 90,
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                          TextWithTap(
                            storeItem.getName!,
                            marginBottom: 10,
                            marginTop: 15,
                          ),
                          TextWithTap(
                            "my_obtained_items_screen.remaining_time"
                                .tr(namedArgs: {
                              "time": QuickHelp.getRemainingTime(
                                  futureDate: obtainedItems.getExpirationDate!),
                            }),
                            color: kGrayColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ContainerCorner(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  borderRadius: 50,
                                  marginTop: 15,
                                  child: TextWithTap(
                                    "renew_".tr(),
                                    color: kPrimaryColor,
                                    marginRight: 8,
                                    marginLeft: 8,
                                    marginTop: 5,
                                    marginBottom: 5,
                                  ),
                                ),
                                ContainerCorner(
                                  color: kPrimaryColor,
                                  borderRadius: 50,
                                  marginTop: 15,
                                  child: TextWithTap(
                                    using
                                        ? "my_obtained_items_screen.take_off".tr()
                                        : "use_".tr(),
                                    color: Colors.white,
                                    marginRight: 8,
                                    marginLeft: 8,
                                    marginTop: 5,
                                    marginBottom: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: using,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: ContainerCorner(
                            height: 30,
                            width: 80,
                            radiusTopRight: 10,
                            radiusBottomLeft: 10,
                            marginRight: 1,
                            color: earnCashColor,
                            child: TextWithTap(
                              "my_obtained_items_screen.using_".tr(),
                              color: Colors.white,
                              alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              fontSize: 9,
                              marginRight: 8,
                              marginLeft: 8,
                              marginTop: 5,
                              marginBottom: 5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: QuickHelp.appLoading(),
                );
              }
            },
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
            gridLoadingElement: QuickHelp.appLoading(),
          ),
        ),
        ValueListenableBuilder<GiftsModel?>(
          valueListenable: ZegoGiftManager().playList.playingDataNotifier,
          builder: (context, playData, _) {
            if (null == playData) {
              return const SizedBox.shrink();
            }
            return svgaWidget(playData);
          },
        ),
      ],
    );
  }

  Widget svgaWidget(GiftsModel giftItem) {
    /// you can define the area and size for displaying your own
    /// animations here
    return Positioned(
      child: ZegoSvgaPlayerWidget(
        key: UniqueKey(),
        giftItem: giftItem,
        onPlayEnd: () {
          /// if there is another gift animation, then play
          ZegoGiftManager().playList.next();
        },
        count: 1,
      ),
    );
  }

  _getAvatarFrames() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<ObtainedItemsModel> query =
        QueryBuilder<ObtainedItemsModel>(ObtainedItemsModel());
    query.whereEqualTo(
        ObtainedItemsModel.keyCategory, GiftsModel.categoryAvatarFrame);
    query.whereEqualTo(
        ObtainedItemsModel.keyAuthorId, widget.currentUser!.objectId!);
    query.includeObject([ObtainedItemsModel.keyItem]);

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: ParseLiveGridWidget<ObtainedItemsModel>(
        query: query,
        crossAxisCount: 2,
        reverse: false,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        lazyLoading: false,
        childAspectRatio: .8,
        shrinkWrap: true,
        listeningIncludes: [ObtainedItemsModel.keyItem],
        duration: const Duration(milliseconds: 200),
        animationController: _animationController,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<ObtainedItemsModel> snapshot) {
          if (snapshot.hasData) {
            ObtainedItemsModel obtainedItems = snapshot.loadedData!;
            GiftsModel storeItem = obtainedItems.getItem!;
            bool using =
                storeItem.objectId == widget.currentUser!.getAvatarFrameId;
            return ContainerCorner(
              color: isDark ? kContentColorLightTheme : Colors.white,
              borderRadius: 10,
              borderWidth: 0,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Column(
                    children: [
                      ClipPath(
                        clipper: WaveClipper(),
                        child: ContainerCorner(
                          radiusTopLeft: 10,
                          radiusTopRight: 10,
                          borderWidth: 0,
                          height: 120,
                          colors: [
                            silverColor.withOpacity(0.8),
                            kPrimaryColor.withOpacity(0.2)
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          QuickActions.avatarWidget(widget.currentUser!,
                              width: size.width / 5, height: size.width / 5, hideAvatarFrame: true),
                          QuickActions.photosWidget(
                            storeItem.getFile!.url!,
                            width: size.width / 4,
                            height: size.width / 4,
                          )
                        ],
                      ),
                      TextWithTap(
                        storeItem.getName!,
                        marginBottom: 10,
                      ),
                      TextWithTap(
                        "my_obtained_items_screen.remaining_time"
                            .tr(namedArgs: {
                          "time": QuickHelp.getRemainingTime(
                              futureDate: obtainedItems.getExpirationDate!),
                        }),
                        color: kGrayColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ContainerCorner(
                            color: kPrimaryColor.withOpacity(0.2),
                            borderRadius: 50,
                            marginTop: 15,
                            onTap: () {
                              if (widget.currentUser!.getCredits! <
                                  storeItem.getCoins!) {
                                QuickHelp.showAppNotificationAdvanced(
                                  title: "error".tr(),
                                  context: context,
                                  message:
                                      "live_streaming.not_enough_coins".tr(),
                                );
                              } else {
                                renew(obtainedItem: obtainedItems);
                              }
                            },
                            child: TextWithTap(
                              "renew_".tr(),
                              color: kPrimaryColor,
                              marginRight: 8,
                              marginLeft: 8,
                              marginTop: 5,
                              marginBottom: 5,
                            ),
                          ),
                          ContainerCorner(
                            color: kPrimaryColor,
                            borderRadius: 50,
                            marginTop: 15,
                            onTap: () {
                              if (using) {
                                removeUsingItem(item: storeItem);
                              } else {
                                useObtainedItem(item: storeItem);
                              }
                            },
                            child: TextWithTap(
                              using
                                  ? "my_obtained_items_screen.take_off".tr()
                                  : "use_".tr(),
                              color: Colors.white,
                              marginRight: 8,
                              marginLeft: 8,
                              marginTop: 5,
                              marginBottom: 5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: using,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ContainerCorner(
                        height: 30,
                        width: 80,
                        radiusTopRight: 10,
                        radiusBottomLeft: 10,
                        marginRight: 1,
                        color: earnCashColor,
                        child: TextWithTap(
                          "my_obtained_items_screen.using_".tr(),
                          color: Colors.white,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          fontSize: 9,
                          marginRight: 8,
                          marginLeft: 8,
                          marginTop: 5,
                          marginBottom: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: QuickHelp.appLoading(),
            );
          }
        },
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
        gridLoadingElement: QuickHelp.appLoading(),
      ),
    );
  }

  _getPartyThemes() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<ObtainedItemsModel> query =
        QueryBuilder<ObtainedItemsModel>(ObtainedItemsModel());

    query.whereEqualTo(
        ObtainedItemsModel.keyCategory, GiftsModel.categoryPartyTheme);
    query.whereEqualTo(
        ObtainedItemsModel.keyAuthorId, widget.currentUser!.objectId!);
    query.includeObject([
      ObtainedItemsModel.keyItem,
    ]);

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: ParseLiveGridWidget<ObtainedItemsModel>(
        query: query,
        crossAxisCount: 2,
        reverse: false,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
        lazyLoading: false,
        childAspectRatio: .8,
        shrinkWrap: true,
        listeningIncludes: [ObtainedItemsModel.keyItem],
        duration: const Duration(milliseconds: 200),
        animationController: _animationController,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<ObtainedItemsModel> snapshot) {
          if (snapshot.hasData) {
            ObtainedItemsModel obtainedItems = snapshot.loadedData!;
            GiftsModel storeItem = obtainedItems.getItem!;
            bool using =
                storeItem.objectId == widget.currentUser!.getPartyThemeId;
            return ContainerCorner(
              color: isDark ? kContentColorLightTheme : Colors.white,
              borderRadius: 10,
              borderWidth: 0,
              onTap: () {
                QuickHelp.goToNavigatorScreen(
                  context,
                  VisualizeMultiplePicturesScreen(
                    picturesFromDataBase: [storeItem.getFile!],
                  ),
                );
              },
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  QuickActions.photosWidget(
                    storeItem.getFile!.url!,
                    borderRadius: 8,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWithTap(
                        storeItem.getName!,
                        marginTop: 10,
                        color: Colors.white,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "my_obtained_items_screen.remaining_time"
                                .tr(namedArgs: {
                              "time": QuickHelp.getRemainingTime(
                                  futureDate: obtainedItems.getExpirationDate!),
                            }),
                            color: Colors.white,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ContainerCorner(
                                color: silverColor,
                                borderRadius: 50,
                                marginTop: 15,
                                marginBottom: 10,
                                onTap: () {
                                  if (widget.currentUser!.getCredits! <
                                      storeItem.getCoins!) {
                                    QuickHelp.showAppNotificationAdvanced(
                                      title: "error".tr(),
                                      context: context,
                                      message: "live_streaming.not_enough_coins"
                                          .tr(),
                                    );
                                  } else {
                                    renew(obtainedItem: obtainedItems);
                                  }
                                },
                                child: TextWithTap(
                                  "renew_".tr(),
                                  color: kPrimaryColor,
                                  marginRight: 8,
                                  marginLeft: 8,
                                  marginTop: 5,
                                  marginBottom: 5,
                                ),
                              ),
                              ContainerCorner(
                                color: kPrimaryColor,
                                borderRadius: 50,
                                marginTop: 15,
                                marginBottom: 10,
                                onTap: () {
                                  if (using) {
                                    removeUsingItem(item: storeItem);
                                  } else {
                                    useObtainedItem(item: storeItem);
                                  }
                                },
                                child: TextWithTap(
                                  using
                                      ? "my_obtained_items_screen.take_off".tr()
                                      : "use_".tr(),
                                  color: Colors.white,
                                  marginRight: 8,
                                  marginLeft: 8,
                                  marginTop: 5,
                                  marginBottom: 5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Visibility(
                    visible: using,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ContainerCorner(
                        height: 30,
                        width: 80,
                        radiusTopRight: 10,
                        radiusBottomLeft: 10,
                        marginRight: 1,
                        color: earnCashColor,
                        child: TextWithTap(
                          "my_obtained_items_screen.using_".tr(),
                          color: Colors.white,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          fontSize: 9,
                          marginRight: 8,
                          marginLeft: 8,
                          marginTop: 5,
                          marginBottom: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: QuickHelp.appLoading(),
            );
          }
        },
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
        gridLoadingElement: QuickHelp.appLoading(),
      ),
    );
  }

  void openOperations(
      {required GiftsModel item, required String action}) async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showItemOperations(item: item, action: action);
        });
  }

  Widget _showItemOperations(
      {required GiftsModel item, required String action}) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    String userReceiverName = "";
    bool obtained =
        widget.currentUser!.getMyObtainedItems!.contains(item.objectId);
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Scaffold(
                        appBar: AppBar(
                          toolbarHeight: 30,
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              onPressed: () =>
                                  QuickHelp.hideLoadingDialog(context),
                              icon: Icon(
                                Icons.close,
                                color: kGrayColor,
                              ),
                            )
                          ],
                        ),
                        body: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  itemPreview(item: item),
                                  TextWithTap(
                                    item.getName!,
                                    fontWeight: FontWeight.w900,
                                    marginLeft: 10,
                                    marginTop: 5,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 20, bottom: 15),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              TextWithTap(
                                "store_screen.select_specification".tr(),
                                fontWeight: FontWeight.w900,
                              ),
                              ContainerCorner(
                                marginTop: 20,
                                height: 70,
                                width: 20,
                                marginRight: size.width / 1.6,
                                borderRadius: 10,
                                borderColor: kOrangeColor,
                                color: kOrangeColor.withOpacity(0.1),
                                marginBottom: 20,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextWithTap(
                                        "${item.getPeriod}d",
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        marginBottom: 4,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            "assets/images/icon_jinbi.png",
                                            width: 13,
                                            height: 13,
                                          ),
                                          TextWithTap(
                                            QuickHelp.checkFundsWithString(
                                                amount: "${item.getCoins}"),
                                            color: kGrayColor,
                                            marginLeft: 2,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: action == actionSending,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWithTap(
                                      "store_screen.select_object".tr(),
                                      fontWeight: FontWeight.w900,
                                    ),
                                    ContainerCorner(
                                      borderWidth: 0,
                                      borderRadius: 10,
                                      marginTop: 10,
                                      marginBottom: 20,
                                      height: 35,
                                      color: isDark
                                          ? kContentDarkShadow
                                          : kGrayColor.withOpacity(0.1),
                                      onTap: () async {
                                        UserModel? user = await QuickHelp
                                            .goToNavigatorScreenForResult(
                                                context,
                                                ChooseGuardianScreen(
                                                  isSending: true,
                                                  currentUser:
                                                      widget.currentUser,
                                                ));
                                        if (user != null) {
                                          setState(() {
                                            userReceiver = user;
                                            userReceiverName =
                                                user.getFirstName!;
                                          });
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextWithTap(
                                                "store_screen.send_".tr(),
                                                fontWeight: FontWeight.w900,
                                                marginLeft: 10,
                                              ),
                                              TextWithTap(
                                                userReceiverName,
                                                marginLeft: 5,
                                              ),
                                            ],
                                          ),
                                          TextWithTap(
                                            "my_agency_screen.choose_method"
                                                .tr(),
                                            color: kPrimaryColor,
                                            marginRight: 10,
                                            fontWeight: FontWeight.w900,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/icon_jinbi.png",
                                        width: 20,
                                        height: 20,
                                      ),
                                      TextWithTap(
                                        QuickHelp.checkFundsWithString(
                                            amount:
                                                "${widget.currentUser!.getCredits!}"),
                                        marginLeft: 5,
                                        fontWeight: FontWeight.w900,
                                        marginRight: 5,
                                        fontSize: 15,
                                      ),
                                      Image.asset(
                                        "assets/images/icon_ppbi_do_task.png",
                                        width: 20,
                                        height: 20,
                                      ),
                                      TextWithTap(
                                        QuickHelp.checkFundsWithString(
                                            amount:
                                                "${widget.currentUser!.getPCoins!}"),
                                        marginLeft: 5,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                      ),
                                    ],
                                  ),
                                  ContainerCorner(
                                    color: kPrimaryColor,
                                    borderRadius: 50,
                                    borderWidth: 0,
                                    onTap: () {
                                      if (widget.currentUser!.getCredits! <
                                          item.getCoins!) {
                                        QuickHelp.showAppNotificationAdvanced(
                                            title: "error".tr(),
                                            context: context,
                                            message:
                                                "live_streaming.not_enough_coins"
                                                    .tr());
                                      } else {
                                        if (action == actionSending) {
                                          if (userReceiver != null) {
                                            //sendItem();
                                          } else {
                                            QuickHelp.showAppNotificationAdvanced(
                                                title: "error".tr(),
                                                context: context,
                                                message:
                                                    "store_screen.select_object"
                                                        .tr());
                                          }
                                        } else {
                                          //purchaseItem(item: item);
                                        }
                                      }
                                    },
                                    child: TextWithTap(
                                      action == actionSending
                                          ? "store_screen.send_".tr()
                                          : obtained
                                              ? "renew_".tr()
                                              : "store_screen.purchase_".tr(),
                                      marginLeft: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      marginRight: 8,
                                      marginTop: 5,
                                      marginBottom: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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

  Widget itemPreview({required GiftsModel item}) {
    Size size = MediaQuery.of(context).size;
    if (item.getGiftCategories == GiftsModel.categoryAvatarFrame) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          QuickActions.avatarWidget(widget.currentUser!,
              width: size.width / 6, height: size.width / 6, hideAvatarFrame: true),
          QuickActions.photosWidget(
            item.getFile!.url!,
            width: size.width / 5,
            height: size.width / 5,
          )
        ],
      );
    } else if (item.getGiftCategories == GiftsModel.categoryPartyTheme) {
      return QuickActions.photosWidget(
        item.getFile!.url!,
        width: size.width / 7,
        height: size.width / 7,
      );
    }
    return SizedBox();
  }

  useObtainedItem({required GiftsModel item}) async {
    QuickHelp.showLoadingDialog(context);
    if (tabIndex == 0) {
      widget.currentUser!.setAvatarFrame = item.getFile!;
      widget.currentUser!.setAvatarFrameId = item.objectId!;
      widget.currentUser!.setCanUseAvatarFrame = true;
    } else if (tabIndex == 1) {
      widget.currentUser!.setPartyTheme = item.getFile!;
      widget.currentUser!.setPartyThemeId = item.objectId!;
      widget.currentUser!.setCanUsePartyTheme = true;
    } else if (tabIndex == 2) {
      widget.currentUser!.setEntranceEffect = item.getFile!;
      widget.currentUser!.setEntranceEffectId = item.objectId!;
      widget.currentUser!.setCanUseEntranceEffect = true;
    }
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first;
      });
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  removeUsingItem({required GiftsModel item}) async {
    QuickHelp.showLoadingDialog(context);
    if (tabIndex == 0) {
      //widget.currentUser!.setAvatarFrame = item.getFile!;
      widget.currentUser!.setAvatarFrameId = "";
      widget.currentUser!.setCanUseAvatarFrame = false;
    } else if (tabIndex == 1) {
      //widget.currentUser!.setPartyTheme = item.getFile!;
      widget.currentUser!.setPartyThemeId = "";
      widget.currentUser!.setCanUsePartyTheme = false;
    } else if (tabIndex == 2) {
      //widget.currentUser!.setEntranceEffect = item.getFile!;
      widget.currentUser!.setEntranceEffectId = "";
      widget.currentUser!.setCanUseEntranceEffect = false;
    }
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first;
      });
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  String getItemCategory() {
    if (tabIndex == 0) {
      return tabTitles[0];
    } else if (tabIndex == 1) {
      return tabTitles[1];
    } else if (tabIndex == 2) {
      return tabTitles[2];
    } else {
      return "";
    }
  }

  renew({required ObtainedItemsModel obtainedItem}) async {
    QuickHelp.showLoadingDialog(context);
    obtainedItem.setExpirationDate = obtainedItem.getExpirationDate!
        .add(Duration(days: obtainedItem.getItem!.getPeriod!));
    ParseResponse response = await obtainedItem.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      removeUserCredit(item: obtainedItem.getItem!);
      QuickHelp.showAppNotificationAdvanced(
        title: "done".tr(),
        isError: false,
        context: context,
        message: "my_obtained_items_screen.renewed_succeed".tr(namedArgs: {
          "item_name": "${obtainedItem.getItem!.getName}",
          "category": getItemCategory(),
          "days": "${obtainedItem.getItem!.getPeriod!}",
        }),
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

  removeUserCredit({required GiftsModel item}) async {
    widget.currentUser!.removeCredit = item.getCoins!;
    widget.currentUser!.setMyObtainedItems = item.objectId!;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      setState(() {
        widget.currentUser = response.results!.first;
      });
    }
  }
}
