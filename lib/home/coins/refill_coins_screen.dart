import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/coins/coins_rc_screen.dart';
import 'package:trace/ui/app_bar.dart';

import '../../models/UserModel.dart';

// ignore: must_be_immutable
class RefillCoinsScreen extends StatefulWidget {

  static String route = "/menu/refill";

  UserModel? currentUser;

  RefillCoinsScreen({this.currentUser});

  @override
  _RefillCoinsScreenState createState() => _RefillCoinsScreenState();
}

class _RefillCoinsScreenState extends State<RefillCoinsScreen> {

  @override
  Widget build(BuildContext context) {
    return ToolBar(
      title: "page_title.refill_coins_title".tr(),
      centerTitle: QuickHelp.isAndroidPlatform() ? true : false,
      leftButtonIcon: Icons.arrow_back_ios,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
      child: CoinsScreen(currentUser: widget.currentUser,),
    );
  }
}
