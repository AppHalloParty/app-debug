// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../models/UserModel.dart';


class MyLevelScreen extends StatefulWidget {
  UserModel? currentUser;

  MyLevelScreen({this.currentUser, super.key});

  @override
  State<MyLevelScreen> createState() => _MyLevelScreenState();
}

class _MyLevelScreenState extends State<MyLevelScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(color: isDark ? Colors.white : Colors.black,),
        title: TextWithTap("my_level_screen.my_level".tr()),
      ),
      body: ListView(
        children: [
        ],
      ),
    );
  }
}
