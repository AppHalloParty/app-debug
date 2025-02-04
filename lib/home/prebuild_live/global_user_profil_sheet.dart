
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

showUserProfileBottomSheet({
  required UserModel currentUser,
  required String userId,
  required BuildContext context,
}) {
  showModalBottomSheet(
    context: (context),
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
    builder: (context) {
      return getResume(context: context, currentUser: currentUser, userId: userId);
    },
  );
}


Widget getResume({
  required UserModel currentUser,
  required String userId,
  required BuildContext context,
}) {
  Size size = MediaQuery.sizeOf(context);

  var numbersCaptions = [
    "tab_profile.followings_".tr(),
    "tab_profile.followers_".tr(),
    "agent_screen.earnings_".tr(),
  ];

  return FutureBuilder(
    future: fetchUser(userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError || !snapshot.hasData) {
        return QuickActions.noContentFound(context);
      }

      UserModel? user = snapshot.data;
      if(user != null) {
        var numbers = [
          user.getFollowing!.length,
          user.getFollowers!.length,
          user.getDiamondsTotal!,
        ];
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0),
              topRight: Radius.circular(25.0),
            ),
          ),
          child: ContainerCorner(
            radiusTopRight: 20.0,
            radiusTopLeft: 20.0,
            color: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kWhitenDark,
            width: size.width,
            borderWidth: 0,
            child: Scaffold(
              backgroundColor: kTransparentColor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                surfaceTintColor: kTransparentColor,
                backgroundColor: kTransparentColor,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWithTap(
                      "tab_profile.id_".tr(),
                      fontSize: size.width / 25,
                      fontWeight: FontWeight.w900,
                      color: kGrayColor,
                    ),
                    TextWithTap(
                      user.getUid!.toString(),
                      fontSize: size.width / 23,
                      marginLeft: 3,
                      marginRight: 3,
                      color: kGrayColor,
                      fontWeight: FontWeight.w900,
                    ),
                    GestureDetector(
                      onTap: () {
                        QuickHelp.copyText(
                            textToCopy: "${user.getUid!}");
                        //showTemporaryAlert();
                      },
                      child: Icon(
                        Icons.copy,
                        color: kGrayColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                      onPressed: ()=> QuickHelp.hideLoadingDialog(context),
                      icon: Icon(Icons.clear, color: earnCashColor,),
                  )],
              ),
              body: StatefulBuilder(
                builder: (BuildContext context,
                    void Function(void Function()) setState) {
                  return ContainerCorner(
                    width: size.width,
                    borderWidth: 0,
                    child: ListView(
                      children: [
                        SizedBox(height: 20,),
                        QuickActions.avatarWidget(
                            user,
                            height: size.width / 3,
                            width: size.width / 3,
                            hideAvatarFrame: true
                        ),
                        TextWithTap(
                          user.getFullName!,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                        SizedBox(height: 7,),
                        QuickHelp.usersMoreInfo(
                          context,
                          user,
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        SizedBox(height: 7,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(
                            numbersCaptions.length,
                                (index) =>
                                captionAndNumber(
                                  caption: numbersCaptions[index],
                                  number: numbers[index],
                                  context: context,
                                ),
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ContainerCorner(
                    colors: [kProfileStarsColorSecondary, earnCashColor],
                    borderRadius: 10,
                    borderWidth: 0,
                    marginBottom: 20,
                    marginTop: 10,
                    width: size.width / 2.7,
                    height: 50,
                    onTap: () {
                      QuickHelp.goBackToPreviousPage(context);
                    },
                    child: TextWithTap(
                      "cancel".tr(),
                      color: Colors.white,
                      alignment: Alignment.center,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Visibility(
                    visible: false,
                    child: ContainerCorner(
                      colors: [kPrimaryColor, kVioletColor],
                      borderRadius: 10,
                      borderWidth: 0,
                      marginBottom: 20,
                      marginTop: 10,
                      width: size.width / 2.7,
                      height: 50,
                      onTap: () {

                      },
                      child: TextWithTap(
                        "accept_".tr(),
                        color: Colors.white,
                        alignment: Alignment.center,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return SizedBox();
    },
  );
}

Widget captionAndNumber({
  required String caption,
  required int number,
  required BuildContext context,
}) {
  Size size = MediaQuery.of(context).size;
  return ContainerCorner(
    child: Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          clipBehavior: Clip.none,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWithTap(
                  QuickHelp.convertToK(number),
                  fontWeight: FontWeight.w600,
                  marginBottom: 4,
                  marginLeft: 4,
                  fontSize: 15,
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: -5,
              child: ContainerCorner(
                height: 5,
                width: 5,
                color: Colors.red,
                borderRadius: 50,
              ),
            )
          ],
        ),
        TextWithTap(
          caption,
          color: kGrayColor,
          fontSize: size.width / 35,
        ),
      ],
    ),
  );
}

Future<UserModel?> fetchUser(String userId) async{
  QueryBuilder queryUser = QueryBuilder(UserModel.forQuery());
  queryUser.whereEqualTo(UserModel.keyObjectId, userId);
  queryUser.setLimit(1);
  ParseResponse response = await queryUser.query();
  if (response.success && response.results != null) {
    UserModel userModel = response.results!.first;
    return userModel;
  }
  return null;
}