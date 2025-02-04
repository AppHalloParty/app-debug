import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/app_bar.dart';

class StatisticsScreen extends StatefulWidget {

  static String route = "/menu/statistics";

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.statistics_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: SafeArea(
        child: body(),
      ),
    );
  }

  Widget body(){
    return Container();
  }
}
