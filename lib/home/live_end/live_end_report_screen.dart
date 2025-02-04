// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_actions.dart';
import '../../models/LiveStreamingModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../home_screen.dart';

class LiveEndReportScreen extends StatefulWidget {
  UserModel? currentUser;
  LiveStreamingModel? live;

  LiveEndReportScreen({this.live, this.currentUser, Key? key})
      : super(key: key);

  @override
  State<LiveEndReportScreen> createState() => _LiveEndReportScreenState();
}

class _LiveEndReportScreenState extends State<LiveEndReportScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kTransparentColor,
        toolbarHeight: 50,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => goHome(),
        ),
      ),
      body: ContainerCorner(
        height: size.height,
        width: size.width,
        borderWidth: 0,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Image.asset(
              "assets/images/pic_switch_room_cover.webp",
              height: size.height,
              width: size.width,
              fit: BoxFit.fill,
            ),
            ListView(
              children: [
                SizedBox(
                  height: 30,
                ),
                Stack(
                  alignment: AlignmentDirectional.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    ContainerCorner(
                      borderRadius: 10,
                      height: 200,
                      width: size.width,
                      marginLeft: 15,
                      marginRight: 15,
                      color: Colors.white.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextWithTap(
                                widget.currentUser!.getFullName!,
                                fontSize: size.width / 23,
                                fontWeight: FontWeight.w600,
                                marginBottom: 4,
                                marginRight: 4,
                                color: Colors.white,
                              ),
                              QuickActions.getGender(
                                currentUser: widget.currentUser!,
                                context: context,
                              ),
                            ],
                          ),
                          TextWithTap(
                            "end_live_report_scree.live_ended".tr(),
                            fontSize: size.width / 26,
                            fontWeight: FontWeight.w500,
                            marginBottom: 30,
                            marginRight: 4,
                            color: Colors.white,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ContainerCorner(
                                    color: Colors.white.withOpacity(0.2),
                                    height: 40,
                                    width: 40,
                                    marginRight: 10,
                                    borderRadius: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.monetization_on,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextWithTap(
                                        "end_live_report_scree.earned_point".tr(),
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      TextWithTap(
                                        QuickHelp.convertToK(
                                            widget.live!.getDiamonds!,
                                        ),
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ContainerCorner(
                                    color: Colors.white.withOpacity(0.2),
                                    height: 40,
                                    width: 40,
                                    marginRight: 10,
                                    borderRadius: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextWithTap(
                                        "end_live_report_scree.new_followers".tr(),
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w700,
                                      ),
                                      TextWithTap(
                                        QuickHelp.convertToK(
                                            widget.live!.getFollower!.length),
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,)
                        ],
                      ),
                    ),
                    Positioned(
                      top: -40,
                      child: QuickActions.avatarBorder(
                        widget.currentUser!,
                        width: size.width / 4.3,
                        height: size.width / 4.3,
                        borderWidth: 2,
                        borderColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                ContainerCorner(
                  borderRadius: 10,
                  height: 200,
                  width: size.width,
                  marginLeft: 15,
                  marginRight: 15,
                  marginTop: 20,
                  colors: [Colors.white.withOpacity(0.1), kTransparentColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWithTap(
                                    "end_live_report_scree.earned_point".tr(),
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  TextWithTap(
                                    QuickHelp.getTimeByDate(
                                        date: widget.live!.createdAt!,
                                    ),
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWithTap(
                                    "end_live_report_scree.target".tr(),
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  TextWithTap(
                                    QuickHelp.convertToK(
                                        widget.live!.getReachedPeople!.length,
                                    ),
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20,)
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContainerCorner(
        color: kPrimaryColor,
        borderRadius: 50,
        marginBottom: 20,
        marginRight: 20,
        marginLeft: 20,
        height: 45,
        width: size.width,
        onTap: () => goHome(),
        child: TextWithTap(
          "continue".tr(),
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
