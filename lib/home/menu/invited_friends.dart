import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/InvitedUsersModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/button_with_icon.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

// ignore: must_be_immutable
class InvitedUsers extends StatefulWidget {
  UserModel? currentUser;
  static final String route = "InvitedUsers";

  InvitedUsers({this.currentUser});

  @override
  _InvitedUsersState createState() => _InvitedUsersState();
}

class _InvitedUsersState extends State<InvitedUsers> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : Colors.white,
      appBar: AppBar(
        backgroundColor: QuickHelp.isDarkMode(context)
            ? kContentColorLightTheme
            : Colors.white,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: kGrayColor,
        ),
        title: TextWithTap(
          "invited_users.title_screen".tr(),
          color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => openSheet(),
            child: Icon(
              Icons.announcement_outlined,
              color: kRedColor1,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _invitedFriends(context),
            Column(
              children: [
                buttonsToInvite(),
                creditsToInvite(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _invitedFriends(BuildContext showContext) {
    QueryBuilder<InvitedUsersModel> query =
        QueryBuilder<InvitedUsersModel>(InvitedUsersModel());
    query.whereEqualTo(
        InvitedUsersModel.keyInvitedById, widget.currentUser!.objectId);

    query.includeObject([
      InvitedUsersModel.keyInvitedBy,
      InvitedUsersModel.keyAuthor,
    ]);

    return ParseLiveListWidget<InvitedUsersModel>(
      query: query,
      reverse: true,
      shrinkWrap: true,
      lazyLoading: false,
      duration: Duration(microseconds: 500),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<InvitedUsersModel> snapshot) {
        InvitedUsersModel invitedUsersModel = snapshot.loadedData!;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => QuickActions.showUserProfile(
                context, widget.currentUser!, invitedUsersModel.getAuthor!,
            ),
            child: Row(
              children: [
                QuickActions.avatarWidget(
                  invitedUsersModel.getAuthor!,
                  width: 50,
                  height: 50,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      invitedUsersModel.getAuthor!.getFullName!,
                      marginBottom: 5,
                      marginLeft: 10,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ContainerCorner(
                          marginRight: 10,
                          marginLeft: 10,
                          child: Row(
                            children: [
                              TextWithTap(
                                "invite_friends.exp_valid".tr(namedArgs: {
                                  "date": QuickHelp.getTimeAndDate(
                                      invitedUsersModel.getValidUntil!)
                                }),
                                fontSize: 14,
                                marginLeft: 3,
                                fontWeight: FontWeight.normal,
                                color: kGrayDark,
                              ),
                            ],
                          ),
                        ),
                        ContainerCorner(
                          marginRight: 10,
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/ic_diamond.svg",
                                height: 24,
                              ),
                              TextWithTap(
                                invitedUsersModel.getDiamonds.toString(),
                                fontSize: 14,
                                marginLeft: 3,
                                fontWeight: FontWeight.bold,
                                color: kGrayColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
      queryEmptyElement: QuickActions.noContentFound(context),
    );
  }

  Widget buttonsToInvite() {
    return ContainerCorner(
      child: Column(
        children: [
          ButtonWithIcon(
            text: "profile_screen.op_invite_friends".tr().toUpperCase(),
            fontSize: 17,
            textColor: Colors.white,
            backgroundColor: kPrimaryColor,
            borderRadius: 50,
            marginLeft: 20,
            marginRight: 20,
            height: 50,
            marginBottom: 20,
            marginTop: 10,
          ),
        ],
      ),
    );
  }

  Widget creditsToInvite() {
    return ContainerCorner(
      color: kPrimacyGrayColor,
      height: 50,
      borderRadius: 50,
      marginBottom: 20,
      marginLeft: 20,
      marginRight: 20,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWithTap(
            "invite_friends.turn_over_this_month".tr().toUpperCase(),
            fontSize: 14,
            color: Colors.white,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
          ),
          TextWithTap(
            "${QuickHelp.convertDiamondsToMoney(
                widget.currentUser!.getDiamondsAgency!).toStringAsFixed(2)} USD",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
            alignment: Alignment.center,
          ),
        ],
      ),
    );
  }

  void openSheet() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showInviteUserOptionsBottomSheet();
        });
  }

  Widget _showInviteUserOptionsBottomSheet() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorLightTheme
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          ContainerCorner(
                            color: kGrayColor,
                            height: 3,
                            width: 30,
                            borderRadius: 50,
                            marginTop: 10,
                          ),
                          TextWithTap(
                            "invite_friends.need_help".tr(),
                            marginTop: 20,
                            marginBottom: 20,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          TextWithTap(
                            "invite_friends.contact_us_via_whatsapp"
                                .tr(namedArgs: {"app_name": Setup.appName}),
                            fontSize: 16,
                            textAlign: TextAlign.center,
                            marginLeft: 20,
                            marginRight: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
