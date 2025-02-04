import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../helpers/quick_help.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class LiveLoadingScreen extends StatefulWidget {
  LiveLoadingScreen({super.key});

  @override
  State<LiveLoadingScreen> createState() => _LiveLoadingScreenState();
}

class _LiveLoadingScreenState extends State<LiveLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: ContainerCorner(
        borderWidth: 0,
        height: size.height,
        width: size.width,
        color: QuickHelp.isDarkMode(context)
            ? kContentColorLightTheme
            : kContentColorDarkTheme,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Lottie.asset(
            "assets/lotties/ic_live_animation.json",
            width: size.width / 4.5,
            height: size.width / 4.5,
          ),
          TextWithTap(
            "coins_and_points_screen.live_streaming".tr(),
            textAlign: TextAlign.center,
            alignment: Alignment.center,
          ),
        ]),
        //color: Colors.blue,
      ),
    );
  }
}
