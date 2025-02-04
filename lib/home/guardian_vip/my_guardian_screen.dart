// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../models/UserModel.dart';
import '../../utils/colors.dart';

class MyGuardianScreen extends StatefulWidget {
  UserModel? currentUser;

  MyGuardianScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<MyGuardianScreen> createState() => _MyGuardianScreenState();
}

class _MyGuardianScreenState extends State<MyGuardianScreen> {

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: ButtonWidget(
            onTap: () => QuickHelp.goBackToPreviousPage(context),
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.black,
              size: 22,
            ),
          ),
          title: TextWithTap(
            'my_guardians.my_guardians_'.tr(),
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        body: TabBar(
          isScrollable: true,
          enableFeedback: false,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: kTransparentColor,
          unselectedLabelColor: kTabIconDefaultColor,
          indicatorWeight: 0.1,
          labelPadding: EdgeInsets.only(left: 30),
          // labelPadding: EdgeInsets.symmetric(horizontal: 7.0),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide.none,
          ),
          automaticIndicatorColorAdjustment: false,
          labelColor: isDark ? Colors.white : Colors.black,
          labelStyle: TextStyle(fontSize: 18),
          unselectedLabelStyle: TextStyle(fontSize: 18),
          tabs: [
            TextWithTap(
              "my_guardians.host_i".tr(),
            ),
            Padding(
              padding: EdgeInsets.only(right: 0),
              child: TextWithTap(
                "my_guardians.guardians_tab".tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
