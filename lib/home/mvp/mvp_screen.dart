// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/models/MvpCoinRewardModel.dart';
import 'package:trace/models/MvpModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/mvp/privilege_info_screen.dart';

import '../../app/Config.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../report/report_screen.dart';

class MVPScreen extends StatefulWidget {
  UserModel? currentUser;

  MVPScreen({this.currentUser, super.key});

  @override
  State<MVPScreen> createState() => _MVPScreenState();
}

class _MVPScreenState extends State<MVPScreen> {
  var months = [1, 3, 6, 12];
  var points = [5000, 16000, 28000, 57000];
  var selectedMonths = [0];
  int coinsPerMonth = 7085;
  int amountToDivide = 1000;
  int maxAmount = 1000000000;

  int diamondsToClaim = 150;

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kContentColorLightTheme,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
        ),
        title: TextWithTap(
          "mvp_screen.become_mvp_member".tr(),
          color: Colors.white,
        ),
      ),
      body: ListView(

        children: [
          Stack(
            children: [
              Image.asset(
                  "assets/images/google_points_mvp_one_time_receive_bg.png"),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          // "wallet_screen.mvp_membership"
                          //     .tr(namedArgs: {"app_name": Config.appName}),
                          "MVP Membership",
                          color: Colors.white,
                          fontSize: size.width / 17,
                          fontWeight: FontWeight.w800,
                        ),
                        // TextWithTap(
                        //   "wallet_screen.mvp_not_activated".tr(),
                        //   color: Colors.white,
                        //   fontWeight: FontWeight.w600,
                        //   marginTop: 10,
                        // ),
                      ],
                    ),
                    // Image.asset(
                    //   "assets/images/mvp_banner.png",
                    //   height: size.width / 5,
                    //   width: size.width / 5,
                    // ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextWithTap(
                      "MVP Exclusive Benefits",
                      fontSize: size.width / 20,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(
                      width: size.width / 2,
                      child: TextWithTap(
                        "wallet_screen.today_premium"
                            .tr(namedArgs: {"amount": "$diamondsToClaim"}),
                        color: kGrayColor,
                        fontSize: 13,
                        marginTop: 10,
                      ),
                    ),
                  ],
                ),
                ContainerCorner(
                  color: Colors.deepPurpleAccent.withOpacity(0.1),
                  borderWidth: 0,
                  borderRadius: 50,
                  onTap: () async{
                    if(QuickHelp.isMvpUser(widget.currentUser)) {

                      QuickHelp.showLoadingDialog(context);

                      QueryBuilder query = QueryBuilder(MvpCoinsRewardModel());
                      query.whereEqualTo(MvpCoinsRewardModel.keyAuthorId, widget.currentUser!.objectId!);
                      query.orderByDescending(MvpCoinsRewardModel.keyCreatedAt);
                      query.setLimit(1);
                      ParseResponse response = await query.query();
                      if(response.success) {
                        QuickHelp.hideLoadingDialog(context);
                        if(response.results != null){
                          MvpCoinsRewardModel rewardCoin = response.results!.first;
                          if(QuickHelp.has24HoursPassed(rewardCoin.createdAt!)) {
                            updateUserCredit();
                          }else{
                            QuickHelp.showAppNotificationAdvanced(
                              title: "next_reward".tr(),
                              message: "try_again_in".tr(namedArgs: {"time": QuickHelp.timeUntil24Hours(rewardCoin.createdAt!)}),
                              context: context,
                            );
                          }
                        }else{
                          updateUserCredit();
                        }
                      }else{
                        QuickHelp.hideLoadingDialog(context);
                        QuickHelp.showAppNotificationAdvanced(
                          title: "error".tr(),
                          context: context,
                          message: "report_screen.report_failed_explain".tr(),
                        );
                      }
                    }else{
                      QuickHelp.showAppNotificationAdvanced(
                        title: "not_mvp".tr(),
                        message: "activate_mvp".tr(),
                        context: context,
                      );
                    }
                  },
                  child: TextWithTap(
                    "wallet_screen.claim_".tr(),
                    alignment: Alignment.center,
                    color: Colors.deepPurpleAccent,
                    fontSize: 12,
                    marginRight: 15,
                    marginLeft: 15,
                    marginTop: 10,
                    marginBottom: 10,
                  ),
                ),
              ],
            ),
          ),
          ContainerCorner(
            borderRadius: 10,
            width: size.width,
            height: 475,
            marginTop: 25,
            marginRight: 15,
            marginLeft: 15,
            marginBottom: 25,
            child: GridView.count(
              crossAxisCount: 3,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                premiumTitle.length,
                    (index) {
                  return options(
                    caption: premiumTitle[index],
                    index: index,
                    iconURL: premiumIcons[index],
                  );
                },
              ),
            ),
          ),
          ContainerCorner(
            borderWidth: 0,
            width: size.width,
            height: 135,
            marginBottom: 25,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List.generate(months.length, (index) {
                bool selected = selectedMonths.contains(index);
                return ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 130,
                  width: 110,
                  marginLeft: 5,
                  marginRight: 5,
                  borderRadius: 8,
                  borderColor: selected ? kPrimaryColor : kTransparentColor,
                  onTap: () {
                    selectedMonths.clear();
                    selectedMonths.add(index);
                    setState(() {});
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextWithTap(
                        "wallet_screen.month_"
                            .tr(namedArgs: {"amount": "${months[index]}"}),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/coin_bling.webp",
                            height: 15,
                            width: 15,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                                amount: "${months[index] * coinsPerMonth}"),
                            fontWeight: FontWeight.w700,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                      TextWithTap(
                        "wallet_screen.exclusive_membership_privileges".tr(),
                        fontSize: 9,
                        marginLeft: 5,
                        marginRight: 5,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          TextWithTap(
            "wallet_screen.notice_".tr(),
            color: kGrayColor,
            fontSize: 12,
            marginLeft: 15,
            marginBottom: 15,
          ),
          TextWithTap(
            "wallet_screen.notice_1".tr(namedArgs: {
              "app_name": Config.appName,
              "platform": platformName(),
            }),
            color: kGrayColor,
            fontSize: 12,
            marginLeft: 15,
            marginBottom: 25,
            marginRight: 15,
          ),
          TextWithTap(
            "wallet_screen.notice_2".tr(),
            color: kGrayColor,
            fontSize: 12,
            marginLeft: 15,
            marginBottom: 25,
            marginRight: 15,
          ),
          TextWithTap(
            "wallet_screen.notice_3"
                .tr(namedArgs: {"amount": "$diamondsToClaim"}),
            color: kGrayColor,
            fontSize: 12,
            marginLeft: 15,
            marginBottom: 25,
            marginRight: 15,
          ),
          TextWithTap(
            "wallet_screen.recharge_issues".tr(),
            color: kPrimaryColor,
            marginLeft: 15,
            marginBottom: 25,
            marginRight: 15,
            alignment: Alignment.center,
            fontWeight: FontWeight.w700,
            onTap: () => QuickHelp.goToNavigatorScreen(
              context,
              ReportScreen(
                currentUser: widget.currentUser,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ContainerCorner(
        borderRadius: 50,
        height: 60,
        marginLeft: 15,
        marginRight: 15,
        marginBottom: 20,
        color: kPrimaryColor,
        onTap: () {
          if (widget.currentUser!.getCredits! <
              months[selectedMonths[0]] * coinsPerMonth) {
            QuickHelp.showAppNotificationAdvanced(
              title: "error".tr(),
              message: "guardian_and_vip_screen.coins_not_enough".tr(),
              context: context,
            );
          } else {
            activateMVPlan();
          }
        },
        child: TextWithTap(
          "wallet_screen.activate_now".tr(namedArgs: {
            "amount": "${months[selectedMonths[0]] * coinsPerMonth}"
          }),
          color: Colors.white,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  getDailyReward() async {
    MvpCoinsRewardModel mvpReward = MvpCoinsRewardModel();
    mvpReward.setAuthorId = widget.currentUser!.objectId!;
    mvpReward.setAuthor = widget.currentUser!;
    mvpReward.setCoinAmount = diamondsToClaim;
    await mvpReward.save();
    QuickHelp.hideLoadingDialog(context);
    QuickHelp.showAppNotificationAdvanced(
      title: "daily_received".tr(),
      message: "next_reward".tr(),
      context: context,
      isError: false,
    );
  }

  updateUserCredit() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.addCredit = diamondsToClaim;
    widget.currentUser!.addUserPoints =  diamondsToClaim ~/ 2;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success) {
      setState(() {
        widget.currentUser = response.results!.first;
      });
      QuickHelp.saveCoinTransaction(
        author: widget.currentUser!,
        amountTransacted: diamondsToClaim,
      );
      getDailyReward();
    }else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  activateMVPlan() async {
    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeCredit =
        months[selectedMonths[0]] * coinsPerMonth;
    if (selectedMonths[0] == 0) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[0]);
      widget.currentUser!.addUserPoints = points[0];
    } else if (selectedMonths[0] == 1) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[1]);
      widget.currentUser!.addUserPoints = points[1];
    } else if (selectedMonths[0] == 2) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[2]);
      widget.currentUser!.addUserPoints = points[2];
    } else if (selectedMonths[0] == 3) {
      widget.currentUser!.setMVPMember =
          QuickHelp.getUntilDateFromDays(30 * months[3]);
      widget.currentUser!.addUserPoints = points[3];
    }

    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      checkExistingVipMember();
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

  checkExistingVipMember() async{
    QueryBuilder queryBuilder = QueryBuilder(MvpModels());
    queryBuilder.whereEqualTo(MvpModels.keyAuthorId, widget.currentUser!.objectId!);
    queryBuilder.setLimit(1);
    ParseResponse response = await queryBuilder.query();

    if(response.success && response.results != null) {
      MvpModels mvpMember = response.results!.first;
      if (selectedMonths[0] == 0) {
        mvpMember.setMVPEndDate =
            QuickHelp.getUntilDateFromDays(30 * months[0]);
        widget.currentUser!.addUserPoints = points[0];
      } else if (selectedMonths[0] == 1) {
        mvpMember.setMVPEndDate =
            QuickHelp.getUntilDateFromDays(30 * months[1]);
        QuickHelp.getUntilDateFromDays(30 * months[1]);
        widget.currentUser!.addUserPoints = points[1];
      } else if (selectedMonths[0] == 2) {
        mvpMember.setMVPEndDate =
            QuickHelp.getUntilDateFromDays(30 * months[2]);
        widget.currentUser!.addUserPoints = points[2];
      } else if (selectedMonths[0] == 3) {
        mvpMember.setMVPEndDate =
            QuickHelp.getUntilDateFromDays(30 * months[3]);
        widget.currentUser!.addUserPoints = points[3];
      }
      mvpMember.save();
    }else{
      createMVPMember();
    }
  }

  createMVPMember() {
    MvpModels newMvpMember = MvpModels();
    newMvpMember.setAuthor = widget.currentUser!;
    newMvpMember.setAuthorId = widget.currentUser!.objectId!;
    if (selectedMonths[0] == 0) {
      newMvpMember.setMVPEndDate =
          QuickHelp.getUntilDateFromDays(30 * months[0]);
      widget.currentUser!.addUserPoints = points[0];
    } else if (selectedMonths[0] == 1) {
      newMvpMember.setMVPEndDate =
          QuickHelp.getUntilDateFromDays(30 * months[1]);
      QuickHelp.getUntilDateFromDays(30 * months[1]);
    } else if (selectedMonths[0] == 2) {
      newMvpMember.setMVPEndDate =
          QuickHelp.getUntilDateFromDays(30 * months[2]);
      widget.currentUser!.addUserPoints = points[2];
    } else if (selectedMonths[0] == 3) {
      newMvpMember.setMVPEndDate =
          QuickHelp.getUntilDateFromDays(30 * months[3]);
      widget.currentUser!.addUserPoints = points[3];
    }
    newMvpMember.save();
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

  String platformName() {
    if (QuickHelp.isAndroidPlatform()) {
      return "wallet_screen.google_pay".tr();
    } else if (QuickHelp.isIOSPlatform()) {
      return "wallet_screen.apple_pay".tr();
    } else {
      return "";
    }
  }
}
