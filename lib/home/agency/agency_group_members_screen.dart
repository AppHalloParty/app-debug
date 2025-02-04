// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/GroupMessageModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../profile/user_profile_screen.dart';

class AgencyGroupMemberScreen extends StatefulWidget {
  UserModel? currentUser;
  MessageGroupModel? groupModel;
  AgencyGroupMemberScreen({Key? key, this.currentUser, this.groupModel})
      : super(key: key);

  @override
  State<AgencyGroupMemberScreen> createState() => _AgencyGroupMemberScreenState();
}

class _AgencyGroupMemberScreenState extends State<AgencyGroupMemberScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TextWithTap("official_services_screen.agency_group_members".tr()),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
      ),
      body: members(),
    );
  }

  Widget members() {
    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(UserModel.keyId, widget.groupModel!.getMembersIDs!);
    queryBuilder.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);

    Size size = MediaQuery.of(context).size;

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          UserModel user = snapshot.loadedData!;
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ContainerCorner(
              onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  UserProfileScreen(
                    currentUser: widget.currentUser,
                    mUser: user,
                    isFollowing: false,
                  )),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  QuickActions.avatarWidget(user,
                      width: size.width / 6, height: size.width / 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWithTap(
                          user.getFullName!,
                          fontSize: size.width / 23,
                          fontWeight: FontWeight.w600,
                          marginBottom: 4,
                        ),
                        Row(
                          children: [
                            QuickActions.getGender(
                                currentUser: user, context: context),
                            const SizedBox(width: 5,),
                            QuickActions.giftReceivedLevel(
                              receivedGifts: user.getDiamondsTotal!,
                              width: 35,
                            ),
                            const SizedBox(width: 5,),
                            QuickActions.wealthLevel(
                              credit: user.getCreditsSent!,
                              width: 35,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextWithTap(
                              "tab_profile.id_".tr(),
                              fontSize: size.width / 33,
                              fontWeight: FontWeight.w900,
                            ),
                            TextWithTap(
                              widget.currentUser!.getUid!.toString(),
                              fontSize: size.width / 33,
                              marginLeft: 3,
                              marginRight: 3,
                            ),
                            Icon(
                              Icons.copy,
                              color: kGrayColor,
                              size: size.width / 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement:  ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(
            child: Image.asset(
              "assets/images/szy_kong_icon.png",
              height: size.width / 2,
            )),
      ),
    );
  }
}
