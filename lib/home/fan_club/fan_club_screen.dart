// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';

import '../../helpers/quick_help.dart';
import '../../models/FanClubMembersModel.dart';
import '../../models/FanClubModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class FanClubScreen extends StatefulWidget {
  UserModel? currentUser;

  FanClubScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<FanClubScreen> createState() => _FanClubScreenState();
}

class _FanClubScreenState extends State<FanClubScreen>
    with TickerProviderStateMixin {
  TextEditingController funClubNameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int tabTypeJoinedClub = 0;
  int tabTypeMyClub = 1;
  int tabsLength = 2;
  int tabIndex = 0;
  late TabController _tabController;

  int editFee = 10000;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(() {
            setState(() {
              tabIndex = _tabController.index;
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
        ),
        centerTitle: true,
        title: TextWithTap(
          "fan_club_screen.fans_club".tr(),
          fontWeight: FontWeight.w900,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: ContainerCorner(
            height: 30,
            width: size.width,
            child: TabBar(
              isScrollable: true,
              enableFeedback: false,
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: kTransparentColor,
              unselectedLabelColor: kTabIconDefaultColor,
              indicatorWeight: 2.0,
              labelPadding: EdgeInsets.symmetric(horizontal: size.width / 8),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                    width: 3.0,
                    color: isDark ? Colors.white : kContentColorLightTheme),
                borderRadius: BorderRadius.all(Radius.circular(50)),
                insets: EdgeInsets.symmetric(horizontal: 20.0),
              ),
              automaticIndicatorColorAdjustment: false,
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              labelColor: isDark ? Colors.white : Colors.black,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: [
                TextWithTap("fan_club_screen.joined_club".tr()),
                TextWithTap("fan_club_screen.my_club".tr()),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          joinedClub(),
          ListView(
            shrinkWrap: true,
            children: [
              ContainerCorner(
                height: 90,
                borderWidth: 0,
                colors: [kPrimaryColor, kSecondaryColor],
                marginLeft: 15,
                marginRight: 15,
                marginTop: 10,
                borderRadius: 10,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      QuickActions.avatarBorder(
                        widget.currentUser!,
                        width: 60,
                        height: 60,
                        borderColor: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              ContainerCorner(
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Image.asset(
                                        "assets/images/tab_fst_no_level.png",
                                        height: 25,
                                        width: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 70,
                                      child: TextWithTap(
                                        widget.currentUser!.getMyFanClubName!,
                                        color: Colors.white,
                                        marginRight: 5,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                color: earnCashColor,
                                borderRadius: 50,
                              ),
                              ContainerCorner(
                                marginLeft: 10,
                                onTap: () => changeFunClubNameWidget(),
                                child: TextWithTap(
                                  "fan_club_screen.edit_price".tr(namedArgs: {
                                    "amount": QuickHelp.checkFundsWithString(
                                        amount: "$editFee")
                                  }),
                                  color: Colors.white,
                                  fontSize: 9,
                                  marginLeft: 2,
                                  marginRight: 2,
                                  marginTop: 1,
                                  marginBottom: 1,
                                ),
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: 50,
                              ),
                            ],
                          ),
                          TextWithTap(
                            widget.currentUser!.getFullName!,
                            color: Colors.white,
                            marginTop: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              TextWithTap(
                "fan_club_screen.club_members".tr(namedArgs: {
                  "amount": "${widget.currentUser!.getMyFanClubMembers!.length}"
                }),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                marginLeft: 15,
                marginTop: 15,
                marginBottom: 20,
              ),
              myClub(),
            ],
          )
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: tabIndex == 0,
        child: ContainerCorner(
          marginLeft: 25,
          marginRight: 25,
          height: 45,
          marginBottom: 20,
          borderRadius: 50,
          marginTop: 10,
          color: kPrimaryColor,
          child: TextWithTap(
            "fan_club_screen.one_click_btn".tr(),
            color: Colors.white,
            alignment: Alignment.center,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget joinedClub() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<FanClubModel> queryBuilder =
        QueryBuilder<FanClubModel>(FanClubModel());
    queryBuilder.includeObject([FanClubModel.keyAuthor]);
    queryBuilder.whereContainedIn(
        FanClubModel.keyObjectId,
        widget.currentUser!.getJoinedFanClubIds!,
    );

    return ParseLiveListWidget<FanClubModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [FanClubModel.keyAuthor],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<FanClubModel> snapshot) {
        if (snapshot.hasData) {
          FanClubModel fanClub = snapshot.loadedData!;
          return ContainerCorner(
            borderRadius: 10,
            borderWidth: 0,
            marginRight: 15,
            marginLeft: 15,
            marginTop: 10,
            color: isDark ? kContentColorLightTheme : Colors.white,
            //height: 100,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: Row(
                    children: [
                      QuickActions.avatarWidget(fanClub.getAuthor!,
                          width: 50, height: 50),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ContainerCorner(
                                color: kGreenLight,
                                borderRadius: 50,
                                marginBottom: 10,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      QuickHelp.fanClubIcon(day: 0),
                                      width: 30,
                                    ),
                                    TextWithTap(
                                      fanClub.getName!,
                                      color: Colors.white,
                                      fontSize: 12,
                                      marginRight: 5,
                                      marginLeft: 3,
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                "assets/images/icon_peidaizhong.png",
                                height: 30,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextWithTap(
                                "fan_club_screen.host_".tr(),
                                color: kGrayColor,
                                marginRight: 10,
                                fontSize: 12,
                              ),
                              TextWithTap(fanClub.getAuthor!.getFullName!)
                            ],
                          ),
                          TextWithTap(
                            "fan_club_screen.intimacy_expiration".tr(
                                namedArgs: {
                                  "amount": "100",
                                  "date": "2023.08.03"
                                }),
                            color: kGrayColor,
                            fontSize: 12,
                            marginTop: 10,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Divider(
                    height: 0.5,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: TextWithTap(
                        "fan_club_screen.renew_".tr(),
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: TextWithTap(
                        "fan_club_screen.wear_".tr(),
                        color: earnCashColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                )
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

  Widget myClub() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<FanClubMembersModel> queryBuilder =
        QueryBuilder<FanClubMembersModel>(FanClubMembersModel());
    queryBuilder.whereEqualTo(
        FanClubMembersModel.keyFanClubId, widget.currentUser!.getMyFanClubId!);
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

  changeFunClubNameWidget() {
    bool activateHeight = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, newState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWithTap(
                      "fan_club_screen.change_name".tr(),
                      fontWeight: FontWeight.w900,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ContainerCorner(
                      color: kGrayColor.withOpacity(0.2),
                      borderWidth: 0.3,
                      borderColor: kGrayColor,
                      borderRadius: 4,
                      marginBottom: 15,
                      marginTop: 5,
                      height: activateHeight ? 35 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          autocorrect: false,
                          keyboardType: TextInputType.name,
                          maxLines: 1,
                          controller: funClubNameController,
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          validator: (text) {
                            if (text!.isEmpty) {
                              newState(() {
                                activateHeight = false;
                              });
                              return "fan_club_screen.enter_name".tr();
                            } else {
                              newState(() {
                                activateHeight = true;
                              });
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "fan_club_screen.enter_name".tr(),
                            border: InputBorder.none,
                            hintStyle: GoogleFonts.roboto(
                              color: kGrayColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        TextWithTap("fan_club_screen.effect_preview".tr()),
                        ContainerCorner(
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  "assets/images/tab_fst_no_level.png",
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: TextWithTap(
                                  widget.currentUser!.getMyFanClubName!,
                                  color: Colors.white,
                                  marginRight: 5,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          color: earnCashColor,
                          borderRadius: 50,
                        ),
                      ],
                    ),
                    const SizedBox(
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
                            if (formKey.currentState!.validate()) {
                              if (widget.currentUser!.getMyFanClubName !=
                                  funClubNameController.text) {
                                changeFunClubName();
                              }
                              QuickHelp.hideLoadingDialog(context);
                            }
                          },
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
    );
  }

  changeFunClubName() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.setMyFanClubName = funClubNameController.text;
    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
    updateFanClub();
  }

  updateFanClub() async {
    QueryBuilder<FanClubModel> queryBuilder =
        QueryBuilder<FanClubModel>(FanClubModel());
    queryBuilder.whereEqualTo(
        FanClubModel.keyAuthorId, widget.currentUser!.objectId!);
    ParseResponse response = await queryBuilder.query();

    if (response.success) {
      if (response.results != null) {
        FanClubModel fanClubModel = response.results!.first;
        fanClubModel.setName = funClubNameController.text;
        await fanClubModel.save();
      } else {
        FanClubModel fanClubModel = FanClubModel();
        fanClubModel.setAuthorId = widget.currentUser!.objectId!;
        fanClubModel.setAuthor = widget.currentUser!;
        fanClubModel.setName = funClubNameController.text;
        await fanClubModel.save();
      }
    }
  }

  wear() {}

  renew() {}
}
