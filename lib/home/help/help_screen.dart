// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_help.dart';
import '../../ui/text_with_tap.dart';
import '../feedback/my_feedback_screen.dart';
import '../report/report_screen.dart';

class HelpScreen extends StatefulWidget {
  UserModel? currentUser;

  HelpScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  var topicList = [
    "help_screen.frequent_".tr(),
    "help_screen.livestream_".tr(),
    "help_screen.recharge_".tr(),
    "help_screen.games_".tr(),
    "help_screen.report_".tr(),
    "help_screen.account_".tr(),
  ];

  var selectedTopic = [
    "help_screen.frequent_".tr(),
  ];

  var freqQuestions = [
    "help_screen.freq_question_face_auth_failed".tr(),
    "help_screen.freq_question_become_agent".tr(),
    "help_screen.freq_question_become_coin_seller".tr(),
    "help_screen.freq_question_withdraw_point".tr(),
    "help_screen.freq_question_salary_no_received".tr(),
    "help_screen.freq_question_coin_no_received".tr(),
    "help_screen.freq_question_quit_agency".tr(),
    "help_screen.freq_question_task_missing".tr()
  ];

  var freqResponses = [
    "help_screen.freq_response_face_auth_failed".tr(),
    "help_screen.freq_response_become_agent".tr(),
    "help_screen.freq_response_become_coin_seller".tr(),
    "help_screen.freq_response_withdraw_point".tr(),
    "help_screen.freq_response_salary_no_received".tr(),
    "help_screen.freq_response_coin_no_received".tr(),
    "help_screen.freq_response_quit_agency".tr(),
    "help_screen.freq_response_task_missing".tr()
  ];

  var liveQuestion = [
    "help_screen.liv_question_male_conditions".tr(),
    "help_screen.liv_question_higher_reward".tr(),
  ];

  var liveResponse = [
    "help_screen.liv_response_male_conditions".tr(),
    "help_screen.liv_response_higher_reward".tr(),
  ];

  var rechargeQuestion = [
    "help_screen.recharge_question_coin_no_received".tr()
  ];

  var rechargeResponse = [
    "help_screen.recharge_response_coin_no_received".tr()
  ];

  var gamesQuestion = [
    "help_screen.game_question_exchange_diamonds".tr(),
    "help_screen.game_question_no_winning_coins_received".tr()
  ];

  var gamesResponse = [
    "help_screen.game_response_exchange_diamonds".tr(),
    "help_screen.game_response_no_winning_coins_received".tr()
  ];

  var reportQuestion = ["help_screen.report_question_user_violation".tr()];

  var reportResponse = ["help_screen.report_response_user_violation".tr()];

  var accountQuestion = [
    "help_screen.account_question_forget_login_method".tr(),
    "help_screen.account_question_change_gender".tr()
  ];

  var accountResponse = [
    "help_screen.account_response_forget_login_method".tr(),
    "help_screen.account_response_change_gender".tr()
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap("help_screen.help_".tr()),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Wrap(
            children: List.generate(
              topicList.length,
              (index) {
                bool selected = selectedTopic.contains(topicList[index]);
                return ContainerCorner(
                  width: size.width / 3.5,
                  height: 45,
                  marginRight: 10,
                  marginBottom: 10,
                  borderRadius: 10,
                  color:
                      selected ? kPrimaryColor : kPrimaryColor.withOpacity(0.2),
                  onTap: () {
                    setState(() {
                      selectedTopic.clear();
                      selectedTopic.add(topicList[index]);
                    });
                  },
                  child: TextWithTap(
                    topicList[index],
                    alignment: Alignment.center,
                    marginLeft: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    color: selected
                        ? Colors.white
                        : isDark
                            ? Colors.white
                            : kContentColorLightTheme,
                  ),
                );
              },
            ),
          ),
          TextWithTap(
            selectedTopic[0],
            fontWeight: FontWeight.w900,
            fontSize: 20,
            alignment: Alignment.centerLeft,
            marginLeft: 15,
            marginTop: 5,
            marginBottom: 20,
          ),
          Flexible(
            child: ListView.builder(
              itemCount: getTitleList().length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: TextWithTap(
                    getTitleList()[index],
                    fontSize: 16,
                  ),
                  children: [
                    TextWithTap(
                      getResponseList()[index],
                      marginLeft: 25,
                      marginRight: 10,
                      marginBottom: 20,
                      color: kGrayColor.withOpacity(.8),
                      fontSize: 14,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ContainerCorner(
        width: size.width,
        marginBottom: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ContainerCorner(
              color: kPrimaryColor.withOpacity(0.3),
              height: 45,
              borderRadius: 10,
              width: size.width / 2.3,
              onTap: () => QuickHelp.goToNavigatorScreen(
                context,
                MyFeedbackScreen(
                  currentUser: widget.currentUser,
                ),
              ),
              child: Center(
                child: TextWithTap(
                  "help_screen.my_feedback".tr(),
                  color: isDark ? Colors.white : kPrimaryColor,
                ),
              ),
            ),
            ContainerCorner(
              color: kPrimaryColor,
              height: 45,
              borderRadius: 10,
              width: size.width / 2.3,
              onTap: () => QuickHelp.goToNavigatorScreen(
                context,
                ReportScreen(
                  currentUser: widget.currentUser,
                ),
              ),
              child: Center(
                child: TextWithTap(
                  "help_screen.message_feedback".tr(),
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List getTitleList() {
    if (selectedTopic.contains(topicList[0])) {
      return freqQuestions;
    } else if (selectedTopic.contains(topicList[1])) {
      return liveQuestion;
    } else if (selectedTopic.contains(topicList[2])) {
      return rechargeQuestion;
    } else if (selectedTopic.contains(topicList[3])) {
      return gamesQuestion;
    } else if (selectedTopic.contains(topicList[4])) {
      return reportQuestion;
    } else if (selectedTopic.contains(topicList[5])) {
      return accountQuestion;
    } else {
      return [];
    }
  }

  List getResponseList() {
    if (selectedTopic.contains(topicList[0])) {
      return freqResponses;
    } else if (selectedTopic.contains(topicList[1])) {
      return liveResponse;
    } else if (selectedTopic.contains(topicList[2])) {
      return rechargeResponse;
    } else if (selectedTopic.contains(topicList[3])) {
      return gamesResponse;
    } else if (selectedTopic.contains(topicList[4])) {
      return reportResponse;
    } else if (selectedTopic.contains(topicList[5])) {
      return accountResponse;
    } else {
      return [];
    }
  }
}
