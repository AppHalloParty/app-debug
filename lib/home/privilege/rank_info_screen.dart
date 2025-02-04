import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../ui/text_with_tap.dart';

class RankInfoScreen extends StatefulWidget {
  const RankInfoScreen({super.key});

  @override
  State<RankInfoScreen> createState() => _RankInfoScreenState();
}

class _RankInfoScreenState extends State<RankInfoScreen> {

  List<String> text = [
    "rank_info_screen.vip_exp_ranking".tr(),
    "rank_info_screen.this_event".tr(),
    "rank_info_screen.ranking_is".tr(),
    "rank_info_screen.all_event".tr(),
    "rank_info_screen.all_rewards".tr(),
    "rank_info_screen.event_resellers".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    // bool isDarkMode = QuickHelp.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: ()=>QuickHelp.goBackToPreviousPage(context),
          child: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
            size: 22,
          ),
        ),
        title: TextWithTap(
          "rank_info_screen.text_app_bar".tr(),
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: List.generate(
          text.length,
          (index) => TextWithTap(
            text[index],
            fontSize: 15,
            marginLeft: 20,
            marginTop: 15,
            marginRight: 15,
            color: Colors.black,
          )
        ),
      ),
    );
  }
}
