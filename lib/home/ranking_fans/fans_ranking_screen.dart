// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class FansRankingScreen extends StatefulWidget {
  UserModel? currentUser, mUser;
  List<UserModel>? fanRankingUsersList;

  FansRankingScreen(
      {this.mUser,
      this.fanRankingUsersList,
      this.currentUser,
      Key? key})
      : super(key: key);

  @override
  State<FansRankingScreen> createState() => _FansRankingScreenState();
}

class _FansRankingScreenState extends State<FansRankingScreen> {
  int tabIndex = 0;

  List<UserModel> fanRankingUsersList = [];

  var crown = [
    "assets/images/crown_top_2.png",
    "assets/images/crown_top_1.png",
    "assets/images/crown_top_3.png",
  ];

  var crownFrame = [
    "assets/images/crown_top_2_user.png",
    "assets/images/crown_top_1_user.png",
    "assets/images/crown_top_3_user.png",
  ];

  var topClassification = [
    "assets/images/top_2_rating.png",
    "assets/images/top_1_rating.png",
    "assets/images/top_3_rating.png",
  ];

  @override
  void initState() {
    super.initState();
    fanRankingUsersList = widget.fanRankingUsersList ?? [];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: kTransparentColor,
        toolbarHeight: 40,
        leading: BackButton(
          color: Colors.white,
        ),
        centerTitle: true,
        title: TextWithTap(
          "fans_ranking_screen.fans_ranking".tr(),
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            onPressed: () => openRules(),
            icon: Icon(Icons.info_outline),
            color: Colors.white,
          ),
        ],
        //bottom: ,
      ),
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          ContainerCorner(
            width: size.width,
            height: size.height,
            borderWidth: 0,
            child: Image.asset(
              "assets/images/rating_bg.png",
              width: size.width,
              height: size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ContainerCorner(
                      color: tabIndex == 0
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: 50,
                      borderWidth: 0,
                      height: 30,
                      marginRight: 15,
                      onTap: () {
                        setState(() {
                          tabIndex = 0;
                        });
                      },
                      child: TextWithTap(
                        "fans_ranking_screen.today_".tr(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        alignment: Alignment.center,
                        marginRight: 20,
                        fontWeight:
                            tabIndex == 0 ? FontWeight.w900 : FontWeight.w400,
                        marginLeft: 20,
                      ),
                    ),
                    ContainerCorner(
                      color: tabIndex == 1
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: 50,
                      borderWidth: 0,
                      height: 30,
                      marginLeft: 15,
                      onTap: () {
                        setState(() {
                          tabIndex = 1;
                        });
                      },
                      child: TextWithTap(
                        "fans_ranking_screen.recent_7_days".tr(),
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        alignment: Alignment.center,
                        fontWeight:
                            tabIndex == 1 ? FontWeight.w900 : FontWeight.w400,
                        marginRight: 12,
                        marginLeft: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 45,
                ),
                firstThreeRanked(),
                SizedBox(
                  height: 20,
                ),
                users(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget firstThreeRanked() {
    if (fanRankingUsersList.length == 3) {
      return threeFirstOnTheList();
    } else if (fanRankingUsersList.length == 2) {
      return twoFirstOnTheList();
    } else if (fanRankingUsersList.length == 1) {
      return firstOnTheList();
    } else if (fanRankingUsersList.isEmpty) {
      return emptyThreeFirstOnTheList();
    } else {
      return emptyThreeFirstOnTheList();
    }
  }

  Widget emptyThreeFirstOnTheList() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        topClassification.length,
        (index) {
          double noCoinsMarginTop = 0.0;
          if (index == 1) {
            noCoinsMarginTop = size.width / 50;
          } else {
            noCoinsMarginTop = size.width / 5;
          }
          return Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              ContainerCorner(
                width: index == 1 ? size.width / 3.1 : size.width / 3.8,
                child: Image.asset(topClassification[index]),
                marginBottom: index == 1 ? 80 : 0,
              ),
              Positioned(
                top: -30,
                child: ContainerCorner(
                  width: index == 1 ? size.width / 3.1 : size.width / 3.8,
                  child: Image.asset(crown[index]),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: noCoinsMarginTop,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/icon_jinbi.png",
                      height: 13,
                      width: 13,
                    ),
                    TextWithTap(
                      QuickHelp.checkFundsWithString(amount: "0"),
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget firstOnTheList() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        topClassification.length,
        (index) {
          double topClassificationWidth = 0.0;
          double topClassificationMarginBottom = 0.0;
          double crownFrameWidth = 0.0;
          double avatarSize = 0.0;
          UserModel? user;
          double userNameMarginTop = 0.0;
          double noCoinsMarginTop = 0.0;
          double userNameMarginBottom = 0.0;
          if (index == 1) {
            topClassificationWidth = size.width / 3.1;
            topClassificationMarginBottom = 80;
            crownFrameWidth = size.width / 3.1;
            avatarSize = size.width / 6.4;
            user = fanRankingUsersList[0];
            userNameMarginBottom = size.width / 22;
          } else if (index == 2) {
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            userNameMarginTop = size.width / 7;
            noCoinsMarginTop = size.width / 5;
          } else if (index == 0) {
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            userNameMarginTop = size.width / 7;
            noCoinsMarginTop = size.width / 5;
          }
          bool showFirstUser = index == 1;
          return Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              ContainerCorner(
                width: topClassificationWidth,
                child: Image.asset(topClassification[index]),
                marginBottom: topClassificationMarginBottom,
              ),
              Visibility(
                visible: showFirstUser,
                child: Positioned(
                  top: -30,
                  child: ContainerCorner(
                    width: crownFrameWidth,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        QuickActions.avatarWidget(
                          fanRankingUsersList[0],
                          height: avatarSize,
                          width: avatarSize,
                          margin: EdgeInsets.only(top: 8),
                        ),
                        Image.asset(crownFrame[index]),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !showFirstUser,
                child: Positioned(
                  top: -30,
                  child: ContainerCorner(
                    width: crownFrameWidth,
                    child: Image.asset(crown[index]),
                  ),
                ),
              ),
              Visibility(
                visible: showFirstUser,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: userNameMarginTop, bottom: userNameMarginBottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user != null)
                        SizedBox(
                          width: size.width / 5,
                          child: TextWithTap(
                            user.getUsername!,
                            color: kContentColorLightTheme,
                            alignment: Alignment.center,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            marginBottom: 10,
                          ),
                        ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 13,
                            width: 13,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(amount: "1440"),
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !showFirstUser,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: noCoinsMarginTop,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/icon_jinbi.png",
                        height: 13,
                        width: 13,
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(amount: "0"),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget twoFirstOnTheList() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        topClassification.length,
        (index) {
          double topClassificationWidth = 0.0;
          double topClassificationMarginBottom = 0.0;
          double crownFrameWidth = 0.0;
          double avatarSize = 0.0;
          UserModel? user;
          double userNameMarginTop = 0.0;
          double noCoinsMarginTop = 0.0;
          double userNameMarginBottom = 0.0;
          if (index == 1) {
            topClassificationWidth = size.width / 3.1;
            topClassificationMarginBottom = 80;
            crownFrameWidth = size.width / 3.1;
            avatarSize = size.width / 6.4;
            user = fanRankingUsersList[0];
            userNameMarginBottom = size.width / 22;
          } else if (index == 2) {
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            avatarSize = size.width / 8.1;
            userNameMarginTop = size.width / 7;
            noCoinsMarginTop = size.width / 5;
          } else if (index == 0) {
            user = fanRankingUsersList[1];
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            avatarSize = size.width / 8.1;
            userNameMarginTop = size.width / 7;
          }
          bool showTwoUsers = index < (topClassification.length - 1);
          return Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              ContainerCorner(
                width: topClassificationWidth,
                child: Image.asset(topClassification[index]),
                marginBottom: topClassificationMarginBottom,
              ),
              Visibility(
                visible: showTwoUsers,
                child: Positioned(
                  top: -30,
                  child: ContainerCorner(
                    width: crownFrameWidth,
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        if (user != null)
                          QuickActions.avatarWidget(
                            user,
                            height: avatarSize,
                            width: avatarSize,
                            margin: EdgeInsets.only(top: 8),
                          ),
                        Image.asset(crownFrame[index]),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: !showTwoUsers,
                child: Positioned(
                  top: -30,
                  child: ContainerCorner(
                    width: index == 1 ? size.width / 3.1 : size.width / 3.8,
                    child: Image.asset(crown[2]),
                  ),
                ),
              ),
              Visibility(
                visible: showTwoUsers,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: userNameMarginTop, bottom: userNameMarginBottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user != null)
                        SizedBox(
                          width: size.width / 5,
                          child: TextWithTap(
                            user.getUsername!,
                            color: kContentColorLightTheme,
                            alignment: Alignment.center,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            marginBottom: 10,
                          ),
                        ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 13,
                            width: 13,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(amount: "1440"),
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !showTwoUsers,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: noCoinsMarginTop,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/icon_jinbi.png",
                        height: 13,
                        width: 13,
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(amount: "0"),
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget threeFirstOnTheList() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        topClassification.length,
        (index) {
          double topClassificationWidth = 0.0;
          double topClassificationMarginBottom = 0.0;
          double crownFrameWidth = 0.0;
          double avatarSize = 0.0;
          UserModel? user;
          double userNameMarginTop = 0.0;
          double userNameMarginBottom = 0.0;
          if (index == 1) {
            topClassificationWidth = size.width / 3.1;
            topClassificationMarginBottom = 80;
            crownFrameWidth = size.width / 3.1;
            avatarSize = size.width / 6.4;
            user = fanRankingUsersList[0];
            userNameMarginBottom = size.width / 22;
          } else if (index == 2) {
            user = fanRankingUsersList[2];
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            avatarSize = size.width / 8.1;
            userNameMarginTop = size.width / 7;
          } else if (index == 0) {
            user = fanRankingUsersList[1];
            topClassificationWidth = size.width / 3.8;
            crownFrameWidth = size.width / 3.8;
            avatarSize = size.width / 8.1;
            userNameMarginTop = size.width / 7;
          }
          return Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              ContainerCorner(
                width: topClassificationWidth,
                child: Image.asset(topClassification[index]),
                marginBottom: topClassificationMarginBottom,
              ),
              Positioned(
                top: -30,
                child: ContainerCorner(
                  width: crownFrameWidth,
                  child: Stack(
                    alignment: AlignmentDirectional.topCenter,
                    children: [
                      QuickActions.avatarWidget(
                        user!,
                        height: avatarSize,
                        width: avatarSize,
                        margin: EdgeInsets.only(top: 9),
                      ),
                      Image.asset(crownFrame[index]),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: userNameMarginTop, bottom: userNameMarginBottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: size.width / 5,
                      child: TextWithTap(
                        user.getUsername!,
                        color: kContentColorLightTheme,
                        alignment: Alignment.center,
                        overflow: TextOverflow.ellipsis,
                        //marginTop: userNameMarginTop,
                        fontWeight: FontWeight.w600,
                        marginBottom: 10,
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icon_jinbi.png",
                          height: 13,
                          width: 13,
                        ),
                        TextWithTap(
                          QuickHelp.checkFundsWithString(amount: "1440"),
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void openRules() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return _showRules();
        });
  }

  Widget _showRules() {
    bool isDark = QuickHelp.isDarkMode(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 1.0,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return ContainerCorner(
                  borderWidth: 0,
                  color: Colors.black.withOpacity(0.1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ContainerCorner(
                        width: 250,
                        color: isDark ? kContentColorLightTheme : Colors.white,
                        borderRadius: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                          ),
                          child: showRulesAccordingTab(),
                        ),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget showRulesAccordingTab() {
    if (tabIndex == 0) {
      return todayRules();
    } else {
      return weekRules();
    }
  }

  Widget todayRules() {
    var monToTheRules = [
      "fans_ranking_screen.fans_ranking_today".tr(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ContainerCorner(
              height: 30,
              width: 30,
              borderRadius: 50,
              marginTop: 5,
              onTap: () => QuickHelp.hideLoadingDialog(context),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.close,
                  color: kGrayColor,
                ),
              ),
            ),
          ],
        ),
        TextWithTap(
          "fans_ranking_screen.rules_".tr(),
          fontWeight: FontWeight.w900,
          alignment: Alignment.center,
          fontSize: 18,
          marginBottom: 15,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              monToTheRules.length,
              (index) => TextWithTap(
                    monToTheRules[index],
                    fontSize: 12,
                  )),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget weekRules() {
    var monToTheRules = [
      "fans_ranking_screen.fans_ranking_week".tr(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ContainerCorner(
              height: 30,
              width: 30,
              borderRadius: 50,
              marginTop: 5,
              onTap: () => QuickHelp.hideLoadingDialog(context),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(
                  Icons.close,
                  color: kGrayColor,
                ),
              ),
            ),
          ],
        ),
        TextWithTap(
          "fans_ranking_screen.rules_".tr(),
          fontWeight: FontWeight.w900,
          alignment: Alignment.center,
          fontSize: 18,
          marginBottom: 15,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              monToTheRules.length,
              (index) => TextWithTap(
                    monToTheRules[index],
                    fontSize: 12,
                  )),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget users() {
    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());

    queryBuilder.whereGreaterThan(UserModel.keyDiamondsTotal, 10000000);

    Size size = MediaQuery.of(context).size;

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          UserModel user = snapshot.loadedData!;
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ContainerCorner(
              onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  UserProfileScreen(
                    currentUser: widget.currentUser,
                    mUser: user,
                    isFollowing: false,
                  )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QuickActions.avatarWidget(user,
                          width: size.width / 8, height: size.width / 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWithTap(
                              user.getFullName!,
                              fontSize: size.width / 25,
                              fontWeight: FontWeight.w600,
                              marginBottom: 4,
                            ),
                            Row(
                              children: [
                                QuickActions.getGender(
                                    currentUser: user, context: context),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.giftReceivedLevel(
                                  receivedGifts: user.getDiamondsTotal!,
                                  width: 32,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                QuickActions.wealthLevel(
                                  credit: user.getCreditsSent!,
                                  width: 32,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/icon_jinbi.png",
                        height: 16,
                        width: 16,
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount: "${user.getDiamondsTotal!}"),
                        color: kContentColorLightTheme,
                        marginLeft: 3,
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        width: size.width,
        height: size.height / 3,
        borderWidth: 0,
        child: Center(
            child: Image.asset(
              "assets/images/szy_kong_icon.png",
              height: size.width / 3,
            )),
      ),
    );
  }
}
