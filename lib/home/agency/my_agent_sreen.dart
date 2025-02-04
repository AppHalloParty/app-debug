// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'leave_agency_screen.dart';

class MyAgentScreen extends StatefulWidget {
  UserModel? currentUser;

  MyAgentScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<MyAgentScreen> createState() => _MyAgentScreenState();
}

class _MyAgentScreenState extends State<MyAgentScreen> {
  UserModel? agent;

  @override
  void initState() {
    super.initState();
    getAgent();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "my_agent_screen.my_agent".tr(),
          fontWeight: FontWeight.w900,
        ),
      ),
      body: ContainerCorner(
        height: size.height,
        width: size.width,
        borderWidth: 0,
        imageDecoration: "assets/images/bg_my_agent.png",
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15, bottom: 5),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.asset("assets/images/img_envelope.png"),
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width / 7, right: size.width / 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "my_agent_screen.congratulations_".tr(),
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: size.width / 18,
                        marginBottom: 40,
                      ),
                      Row(
                        children: [
                          TextWithTap(
                            "my_agent_screen.dear_".tr(),
                            color: kContentColorLightTheme,
                            fontWeight: FontWeight.w600,
                          ),
                          TextWithTap(
                            widget.currentUser!.getFullName!,
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                      TextWithTap(
                        "my_agent_screen.glad_you_join_agency".tr(),
                        color: kContentColorLightTheme,
                        fontWeight: FontWeight.w600,
                        marginTop: 20,
                        marginBottom: 20,
                      ),
                      showAgentInfo(),
                      SizedBox(
                        height: size.width / 4,
                        width: size.width / 4,
                        child: Image.asset("assets/images/ic_gold_done.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: agent != null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWithTap(
              "my_agent_screen.i_want_leave_agency".tr(),
              color: kPrimaryColor,
              marginBottom: 20,
              onTap: () => QuickHelp.goToNavigatorScreen(
                context,
                LeaveAgencyScreen(
                  currentUser: widget.currentUser,
                  agent: agent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getAgent() async {
    QueryBuilder<UserModel> query =
        QueryBuilder<UserModel>(UserModel.forQuery());
    query.whereEqualTo(UserModel.keyObjectId, widget.currentUser!.getMyAgentId);
    ParseResponse response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        agent = response.results!.first;
      });
    }
  }

  Widget showAgentInfo() {
    Size size = MediaQuery.of(context).size;
    if (agent != null) {
      return agentInfo();
    } else {
      return SizedBox(
        height: size.width / 7,
      );
    }
  }

  Widget agentInfo() {
    Size size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickActions.avatarWidget(
          agent!,
          width: size.width / 10,
          height: size.width / 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWithTap(
                agent!.getFirstName!,
                color: kContentColorLightTheme,
                fontWeight: FontWeight.w600,
              ),
              TextWithTap(
                "face_authentication_screen.id_"
                    .tr(namedArgs: {"id": "${agent!.getUid}"}),
                color: kContentColorLightTheme,
                marginTop: 10,
              ),
              TextWithTap(
                QuickHelp.getMessageListTime(agent!.updatedAt!),
                color: kContentColorLightTheme,
                marginTop: 10,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
        )
      ],
    );
  }
}
