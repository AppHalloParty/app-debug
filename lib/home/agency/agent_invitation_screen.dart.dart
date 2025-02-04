// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/AgencyMembersModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../report/report_screen.dart';

class AgentInvitationScreen extends StatefulWidget {
  UserModel? currentUser, agent;

  AgentInvitationScreen(
      {this.currentUser, this.agent, Key? key})
      : super(key: key);

  @override
  State<AgentInvitationScreen> createState() => _AgentInvitationScreenState();
}

class _AgentInvitationScreenState extends State<AgentInvitationScreen> {
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
          "agent_invitation_screen.agent_invitation".tr(),
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
                        "agent_invitation_screen.hope_u_join_agency".tr(),
                        color: kPrimaryColor,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w900,
                        fontSize: size.width / 18,
                        marginBottom: 40,
                      ),
                      agentInfo(),
                      ContainerCorner(
                        height: 45,
                        color: kColorsAmber,
                        borderRadius: 50,
                        width: 150,
                        marginTop: size.width / 4,
                        onTap: () => confirmLeaveAgency(),
                        child: TextWithTap(
                          "agent_invitation_screen.to_enter".tr(),
                          color: Colors.white,
                          alignment: Alignment.center,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWithTap(
            "agent_invitation_screen.unknown_".tr(),
            color: kPrimaryColor,
            marginBottom: 20,
            onTap: () {
              QuickHelp.goToNavigatorScreen(
                context,
                ReportScreen(
                  currentUser: widget.currentUser,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  confirmLeaveAgency() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, newState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWithTap(
                  "agent_invitation_screen.tips_".tr(),
                  textAlign: TextAlign.center,
                  marginTop: 20,
                ),
                TextWithTap(
                  "agent_invitation_screen.reminder_".tr(),
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  marginTop: 5,
                  color: kGrayColor,
                ),
                TextWithTap(
                  "agent_invitation_screen.reminder_1".tr(),
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  color: kGrayColor,
                ),
                TextWithTap(
                  "agent_invitation_screen.reminder_2".tr(),
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  color: kGrayColor,
                ),
                TextWithTap(
                  "agent_invitation_screen.reminder_3".tr(),
                  textAlign: TextAlign.center,
                  fontSize: 12,
                  color: kGrayColor,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: TextWithTap(
                        "cancel".tr(),
                        color: kGrayColor,
                        marginRight: 15,
                        marginLeft: 15,
                      ),
                      onPressed: () => QuickHelp.goBackToPreviousPage(context),
                    ),
                    TextButton(
                      child: TextWithTap(
                        "confirm_".tr(),
                        color: kPrimaryColor,
                        marginRight: 20,
                        marginLeft: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () {
                        QuickHelp.hideLoadingDialog(context);
                        joinAgency();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  joinAgency() async{
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setAgencyRole = UserModel.agencyClientRole;
    widget.currentUser!.setMyAgentId = widget.agent!.objectId!;
    ParseResponse response = await widget.currentUser!.save();

    if(response.success && response.results != null) {
      setState(() {
        widget.currentUser = response.results!.first;
      });
      becomeAgencyMember();
    }else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "tab_feed.say_hell_failed_title".tr(),
        context: context,
        message: "tab_feed.say_hell_failed_explain".tr(),
      );
    }
  }

  becomeAgencyMember() async{
    QuickHelp.showLoadingDialog(context);

    AgencyMembersModel agencyMember = AgencyMembersModel();
    agencyMember.setHost = widget.currentUser!;
    agencyMember.setHostId = widget.currentUser!.objectId!;
    agencyMember.setAgent = widget.agent!;
    agencyMember.setAgentId = widget.agent!.objectId!;

    agencyMember.setLiveDuration = 0;
    agencyMember.setPartyHostDuration = 0;
    agencyMember.setPartyCrownDuration = 0;
    agencyMember.setMatchingDuration = 0;

    agencyMember.setTotalEarningPoints = 0;
    agencyMember.setLiveEarning = 0;
    agencyMember.setMatchEarning = 0;
    agencyMember.setPartyEarning = 0;
    agencyMember.setGameGratuities = 0;
    agencyMember.setPlatformReward = 0;
    agencyMember.setPCoinEarnings = 0;
    agencyMember.save();
  }



  Widget agentInfo() {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        QuickActions.avatarWidget(
          widget.agent!,
          width: size.width / 10,
          height: size.width / 10,
        ),
        TextWithTap(
          widget.agent!.getFirstName!,
          color: kContentColorLightTheme,
          fontSize: 16,
        ),
        TextWithTap(
          "face_authentication_screen.id_"
              .tr(namedArgs: {"id": "${widget.agent!.getUid}"}),
          color: kContentColorLightTheme,
          marginTop: 5,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
