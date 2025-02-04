// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/AgencyInvitationModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class InvitationReportScreen extends StatefulWidget {
  UserModel? currentUser;

  InvitationReportScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<InvitationReportScreen> createState() => _InvitationReportScreenState();
}

class _InvitationReportScreenState extends State<InvitationReportScreen> {
  bool showTempAlert = false;

  showTemporaryAlert() {
    setState(() {
      showTempAlert = true;
    });
    hideTemporaryAlert();
  }

  hideTemporaryAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showTempAlert = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Scaffold(
          appBar: AppBar(
            elevation: 0.5,
            automaticallyImplyLeading: false,
            leading: BackButton(
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
            centerTitle: true,
            title: TextWithTap(
              "add_host_screen.add_host".tr(),
              fontWeight: FontWeight.w600,
            ),
          ),
          body: Column(
            children: [
              Table(
                columnWidths: {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10),
                        ),
                      ),
                      children: [
                        TextWithTap(
                          "invitation_report.user_".tr(),
                          alignment: Alignment.center,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          marginTop: 15,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        TextWithTap(
                          "invitation_report.add_time".tr(),
                          alignment: Alignment.center,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          marginTop: 15,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                        TextWithTap(
                          "invitation_report.status_".tr(),
                          alignment: Alignment.center,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          marginTop: 15,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.7),
                        ),
                      ]),
                ],
              ),
              Flexible(
                child: sentInvitations(),
              ),
            ],
          ),
        ),
        Visibility(
          visible: showTempAlert,
          child: ContainerCorner(
            color: Colors.black.withOpacity(0.5),
            height: 50,
            marginRight: 50,
            marginLeft: 50,
            borderRadius: 50,
            width: size.width / 2,
            shadowColor: kGrayColor,
            shadowColorOpacity: 0.3,
            child: TextWithTap(
              "copied_".tr(),
              color: Colors.white,
              marginBottom: 5,
              marginTop: 5,
              marginLeft: 20,
              marginRight: 20,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget sentInvitations() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<AgencyInvitationModel> queryBuilder =
        QueryBuilder<AgencyInvitationModel>(AgencyInvitationModel());
    queryBuilder.whereEqualTo(
        AgencyInvitationModel.keyAgentId, widget.currentUser!.objectId!);
    queryBuilder.includeObject([
      AgencyInvitationModel.keyAgent,
      AgencyInvitationModel.keyHost,
    ]);

    return ParseLiveListWidget<AgencyInvitationModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      listeningIncludes: [
        AgencyInvitationModel.keyAgent,
        AgencyInvitationModel.keyHost,
      ],
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<AgencyInvitationModel> snapshot) {
        if (snapshot.hasData) {
          AgencyInvitationModel invitationSent = snapshot.loadedData!;
          UserModel invitedHost = invitationSent.getHost!;
          return Table(
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        QuickActions.avatarWidget(
                          invitedHost,
                          height: 40,
                          width: 40,
                          margin: EdgeInsets.only(left: 10),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWithTap(
                                invitedHost.getFullName!,
                                fontWeight: FontWeight.w600,
                                marginBottom: 4,
                                marginRight: 4,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWithTap(
                                    "tab_profile.id_".tr(),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  TextWithTap(
                                    invitedHost.getUid!.toString(),
                                    fontSize: 11,
                                    marginLeft: 3,
                                    marginRight: 3,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      QuickHelp.copyText(
                                          textToCopy: "${invitedHost.getUid!}");
                                      showTemporaryAlert();
                                    },
                                    child: Icon(
                                      Icons.copy,
                                      color: kGrayColor,
                                      size: 15,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextWithTap(
                    QuickHelp.getMessageListTime(invitationSent.createdAt!),
                    alignment: Alignment.center,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    marginTop: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                  TextWithTap(
                    invitationSent.getInvitationStatus!,
                    alignment: Alignment.center,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    marginTop: 15,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                  ),
                ],
              ),
            ],
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(
          child: Image.asset("assets/images/szy_kong_icon.png"),
        ),
      ),
    );
  }
}
