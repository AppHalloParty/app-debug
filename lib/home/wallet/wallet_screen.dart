// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../coins/coins_rc_screen.dart';
import '../mvp/privilege_info_screen.dart';
import '../report/report_screen.dart';

class WalletScreen extends StatefulWidget {
  UserModel? currentUser;

  WalletScreen({this.currentUser, super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int tabsLength = 3;
  int tabIndex = 0;

  int diamondsToClaim = 10;

  var premiumIcons = [
    "assets/images/member_footprint.png",
    "assets/images/mvp_icon_accelerate.png",
    "assets/images/mvp_icon_family.png",
    "assets/images/member_speak.png",
    "assets/images/mvp_icon_car.png",
    "assets/images/member_frame.png",
    "assets/images/member_love.png",
    "assets/images/mvp_icon_mini.png",
    "assets/images/member_mark.png",
    "assets/images/mvp_icon_wallpaper.png",
    "assets/images/member_udiamond.png",
  ];

  var premiumTitle = [
    "wallet_screen.exclusive_social".tr(),
    "wallet_screen.level_up".tr(),
    "wallet_screen.family_privilege".tr(),
    "wallet_screen.enhances_presence".tr(),
    "wallet_screen.exclusive_vehicle".tr(),
    "wallet_screen.premium_badge".tr(),
    "wallet_screen.true_love".tr(),
    "wallet_screen.mini_background".tr(),
    "wallet_screen.status_symbol".tr(),
    "wallet_screen.exclusive_background".tr(),
    "wallet_screen.wealth_privileges".tr(),
  ];

  var silverAmount = [1000, 10000, 100000, 1000000, 10000000];

  var months = [1, 3, 6, 12];
  var selectedMonths = [0];
  int coinsPerMonth = 7085;
  int amountToDivide =  1000;
  int maxAmount =  1000000000;

  TextEditingController sliverAmountController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String convertedAmount = "";

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

  @override
  void initState() {
    super.initState();
    loadRewardedAd();
    creditAdded = 0;
    _tabController =
        TabController(vsync: this, length: tabsLength, initialIndex: tabIndex)
          ..addListener(
            () {
              setState(
                () {
                  tabIndex = _tabController.index;
                },
              );
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return GestureDetector(
      onTap: ()=> QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
            onPressed: () => QuickHelp.goBackToPreviousPage(context, result: widget.currentUser),
          ),
          title: TextWithTap(
            "wallet_screen.wallet_".tr(),
          ),
         /* bottom: PreferredSize(
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
                labelPadding: EdgeInsets.symmetric(horizontal: 15),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide.none,
                ),
                automaticIndicatorColorAdjustment: false,
                onTap: (index) {
                  setState(() {
                    tabIndex = index;
                  });
                },
                labelColor: isDark ? Colors.white : Colors.black,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontSize: 15),
                tabs: [
                  TextWithTap("wallet_screen.my_u_diamonds".tr()),
                  TextWithTap("wallet_screen.my_sliver".tr()),
                  TextWithTap("wallet_screen.my_u_beans".tr()),
                ],
              ),
            ),
          ),*/
        ),
        body: myUDiamonds(),
        /*body: TabBarView(
          controller: _tabController,
          children: [
            myUDiamonds(),
            mySilver(),
            myUBeans(),
          ],
        ),*/
      ),
    );
  }

  Widget myUBeans() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return ListView(
      children: [
        ContainerCorner(
          borderWidth: 0,
          marginBottom: 15,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Image.asset("assets/images/task_banner.png"),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWithTap(
                          "wallet_screen.my_u_beans".tr(),
                          color: Colors.white,
                        ),
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/ubean_bling.webp",
                              height: 15,
                            ),
                            TextWithTap(
                                QuickHelp.checkFundsWithString(amount: "${widget.currentUser!.getPCoins}"),
                              fontWeight: FontWeight.w900,
                              fontSize: size.width / 13,
                              color: Colors.white,
                              marginLeft: 5,
                            )
                          ],
                        ),
                      ],
                    ),
                    ContainerCorner(
                      color: Colors.white,
                      borderRadius: 50,
                      child: TextWithTap(
                          "my_u_beans_screen.redeem_gifts".tr(),
                        marginLeft: 13,
                        marginRight: 13,
                        alignment: Alignment.center,
                        marginTop: 3,
                        marginBottom: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          marginRight: 15,
          marginLeft: 15,
        ),
        TextWithTap(
          "my_u_beans_screen.gain_more".tr(),
          marginLeft: 15,
          marginTop: 15,
          marginBottom: 15,
        ),
        ContainerCorner(
          marginLeft: 15,
          marginRight: 15,
          borderRadius: 8,
          color: isDark ? kContentDarkShadow : kGrayWhite,
          height: 50,
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                        "assets/images/task_more_icon_finished.png",
                      height: 25,
                      width: 25,
                    ),
                    TextWithTap(
                      "my_u_beans_screen.complete_mission".tr(),
                      marginLeft: 10,
                    ),
                  ],
                ),
                ContainerCorner(
                  color: Colors.deepPurpleAccent,
                  borderRadius: 50,
                  height: 30,
                  child: TextWithTap(
                    "my_u_beans_screen.do_mission".tr(),
                    marginLeft: 13,
                    marginRight: 13,
                    alignment: Alignment.center,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget mySilver() {
    Size size = MediaQuery.of(context).size;
    return ListView(
      padding: EdgeInsets.only(
        top: 10,
      ),
      children: [
        Stack(
          //alignment: AlignmentDirectional.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15,),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                      "assets/images/bg_ent_head_card.png",
                  ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "wallet_screen.my_sliver".tr(),
                    fontWeight: FontWeight.w600,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 50),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/pop_silver_icon.png",
                          height: 20,
                          width: 20,
                        ),
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                            amount: "${widget.currentUser!.getDiamonds}",
                          ),
                          fontWeight: FontWeight.w900,
                          fontSize: size.width / 13,
                          marginLeft: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 50),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/coin_bling.webp",
                height: 20,
                width: 20,
              ),
              TextWithTap(
                QuickHelp.checkFundsWithString(
                  amount: "${widget.currentUser!.getCredits}",
                ),
                fontWeight: FontWeight.w900,
                fontSize: size.width / 13,
                marginLeft: 10,
              ),
            ],
          ),
        ),
        ContainerCorner(
          height: 250,
          marginLeft: 15,
          marginRight: 15,
          child: GridView.count(
              crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: NeverScrollableScrollPhysics(),
            children: List.generate(
                silverAmount.length, (index) {
                  return ContainerCorner(
                    borderColor: kGrayColor.withOpacity(0.3),
                    borderRadius: 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      Image.asset(
                          "assets/images/ic_silver_exchange_item.png",
                        height: 35,
                        width: 35,
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(amount: "${silverAmount[index]}"),
                        fontWeight: FontWeight.w600,
                      ),
                        ContainerCorner(
                          borderRadius: 50,
                          color: Colors.deepPurpleAccent.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  "assets/images/coin_bling.webp",
                                  height: 15,
                                  width: 15,
                                ),
                                TextWithTap(
                                  QuickHelp.checkFundsWithString(amount: "${silverAmount[index] / amountToDivide}"),
                                  fontWeight: FontWeight.w600,
                                  marginLeft: 5,
                                ),
                              ],
                            ),
                          ),
                        )
                    ],),
                  );
            }
            ),
          ),
        ),
        TextWithTap(
            "my_silver_screen.custom_exchange".tr(),
          marginLeft: 15,
          marginBottom: 25,
        ),
        ContainerCorner(
          borderColor: kGrayColor.withOpacity(0.3),
          borderRadius: 50,
          marginLeft: 15,
          marginRight: 15,
          child: Form(
            key: formKey,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  child: Image.asset(
                    "assets/images/pop_silver_icon.png",
                    height: 20,
                    width: 20,
                  ),
                ),
                Expanded(
                  child: ContainerCorner(
                    marginLeft: 10,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (text) {
                          if(text.isNotEmpty) {
                            setState(() {
                              convertedAmount = "${getConvertedAmount(text)}";
                            });
                          }
                        },
                        maxLines: 1,
                        controller: sliverAmountController,
                        validator: (text) {
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText:
                          "my_silver_screen.enter_coins_amount"
                              .tr(),
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
                ContainerCorner(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: 50,
                  marginRight: 10,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 3, bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/images/coin_bling.webp",
                          height: 15,
                          width: 15,
                        ),
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                              amount: "${convertedAmount}",
                          ),
                          fontWeight: FontWeight.w600,
                          marginLeft: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextWithTap(
            "my_silver_screen.enter_coins_amount_advice".tr(
              namedArgs: {
                "divisible_amount": QuickHelp.checkFundsWithString(amount: "$amountToDivide"),
                "max_amount": QuickHelp.checkFundsWithString(amount: "$maxAmount")
              }
            ),
          marginLeft: 15,
          fontSize: 12,
          color: Colors.red,
          marginTop: 20,
        )
      ],
    );
  }

  int getConvertedAmount(String text) {
    if(int.parse(text) % amountToDivide == 0) {
      return int.parse(text) % amountToDivide;
    }else{
      return 0;
    }
  }

  Widget myUDiamonds() {
    Size size = MediaQuery.of(context).size;
    return ListView(
      padding: EdgeInsets.only(
        top: 10,
      ),
      children: [
        Image.asset("assets/images/wallet_baner.png"),
        Visibility(
          visible: adLoad,
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
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
        TextWithTap(
          "wallet_screen.u_diamonds_balance".tr(),
          fontWeight: FontWeight.w600,
          fontSize: 15,
          marginBottom: 10,
          marginTop: 20,
          marginLeft: 15,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 50),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/icon_jinbi.png",
                height: 20,
                width: 20,
              ),
              TextWithTap(
                QuickHelp.checkFundsWithString(
                  amount: "${widget.currentUser!.getCredits}",
                ),
                fontWeight: FontWeight.w900,
                fontSize: size.width / 17,
                marginLeft: 5,
              ),
            ],
          ),
        ),
        Visibility(
          visible: QuickHelp.isAndroidPlatform(),
          child: TextWithTap(
            "wallet_screen.google_pay".tr(),
            marginLeft: 15,
            fontWeight: FontWeight.w600,
            marginBottom: 20,
          ),
        ),
        Visibility(
          visible: QuickHelp.isIOSPlatform(),
          child: TextWithTap(
            "wallet_screen.apple_pay".tr(),
            marginLeft: 15,
            fontWeight: FontWeight.w600,
            marginBottom: 20,
          ),
        ),
        SizedBox(
          height: 400,
          width: size.width,
          child: CoinsScreen(
            currentUser: widget.currentUser,
            scroll: true,
          ),
        ),
        TextWithTap(
          "wallet_screen.claim_unreached_recharge".tr(),
          color: kPrimaryColor,
          marginLeft: 15,
          marginRight: 30,
        ),
        TextWithTap(
          "wallet_screen.contact_customer_service".tr(),
          color: kGrayColor,
          marginLeft: 15,
          marginRight: 15,
          alignment: Alignment.centerRight,
          fontSize: 12,
          marginTop: 15,
          marginBottom: 25,
          onTap: () => QuickHelp.goToNavigatorScreen(
            context,
            ReportScreen(
              currentUser: widget.currentUser,
            ),
          ),
        ),
        TextWithTap(
          "reward_coins.earn_credits_explain".tr(),
          color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
          marginLeft: 10,
          marginTop: 10,
          marginRight: 10,
          textAlign: TextAlign.center,
        ),
        ContainerCorner(
          borderRadius: 50,
          marginLeft: size.width / 10,
          marginRight: size.width / 10,
          marginTop: size.width / 20,
          marginBottom: 25,
          color: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : Colors.white,
          shadowColor: adLoad ? kGrayColor : null,
          shadowColorOpacity: 0.3,
          height: size.width / 10,
          width: size.width,
          //onTap: () => adLoad ? showAd() : null,
          onTap: () {
            if (adLoad) {
              showAd();
            }
          },
          child: adLoad ?  TextWithTap(
            "reward_coins.earn_credits".tr(),
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
            alignment: Alignment.center,
          ) : QuickHelp.appLoading(),
        ),
      ],
    );
  }

  String platformName() {
    if (QuickHelp.isAndroidPlatform()) {
      return "wallet_screen.google_pay".tr();
    } else if (QuickHelp.isIOSPlatform()) {
      return "wallet_screen.apple_pay".tr();
    } else {
      return "";
    }
  }

  Widget options({
    required String caption,
    required String iconURL,
    required int index,
    double? width,
    double? height,
  }) {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      onTap: () async {
        UserModel? user =
        await QuickHelp.goToNavigatorScreenForResult(
            context, PrivilegeInfoScreen(
          currentUser: widget.currentUser,
          initialIndex: index,
        ));
        if (user != null) {
          setState(() {
            widget.currentUser = user;
          });
        }
      },
      child: Column(
        children: [
          Image.asset(
            iconURL,
            width: width ?? size.width / 8,
            height: height ?? size.width / 8,
            //color: kTra,
          ),
          TextWithTap(
            caption,
            marginTop: 10,
            fontSize: size.width / 38,
          ),
        ],
      ),
    );
  }

  activateMVPlan() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeCredit =
        months[selectedMonths[0]] * coinsPerMonth;
    if (selectedMonths[0] == months[0]) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[0]);
    } else if (selectedMonths[0] == months[1]) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[1]);
    } else if (selectedMonths[0] == months[2]) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[2]);
    } else if (selectedMonths[0] == months[3]) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[3]);
    }

    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.showAppNotificationAdvanced(
        title: "done".tr(),
        context: context,
        isError: false,
        message: "main_activated".tr(),
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
}
