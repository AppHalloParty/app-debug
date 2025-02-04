// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../home_screen.dart';

class LiveEndScreen extends StatefulWidget {
  UserModel? currentUser, liveAuthor;
  LiveEndScreen({this.liveAuthor, this.currentUser, Key? key}) : super(key: key);

  @override
  State<LiveEndScreen> createState() => _LiveEndScreenState();
}

class _LiveEndScreenState extends State<LiveEndScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: ContainerCorner(
        height: size.height,
        width: size.width,
        borderWidth: 0,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Image.asset("assets/images/pk_bg_fot.webp",
              height: size.height,
              width: size.width,
              fit: BoxFit.fill,
            ),
            ListView(
              children: [
                QuickActions.avatarBorder(
                  widget.liveAuthor!,
                  width: size.width / 3,
                  height: size.width / 3,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWithTap(
                      widget.liveAuthor!.getFullName!,
                      fontSize: size.width / 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    QuickActions.getGender(
                      currentUser: widget.liveAuthor!,
                      context: context,
                    ),
                  ],
                ),
                TextWithTap(
                  "end_live_report_scree.live_ended".tr(),
                  fontSize: size.width / 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.6),
                  alignment: Alignment.bottomCenter,
                  textAlign: TextAlign.center,
                  marginTop: 120,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContainerCorner(
        color: kRedColor1,
        borderRadius: 50,
        marginBottom: 20,
        marginRight: 20,
        marginLeft: 20,
        height: 45,
        width: size.width,
        onTap: () => goHome(),
        child: TextWithTap(
          "close_".tr(),
          color: Colors.white,
          alignment: Alignment.center,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  goHome() {
    QuickHelp.goToNavigatorScreen(
      context,
      HomeScreen(
        currentUser: widget.currentUser,
      ),
      finish: true,
      back: false,
    );
  }
}
