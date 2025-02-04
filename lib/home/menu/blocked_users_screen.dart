import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

// ignore: must_be_immutable
class BlockedUsersScreen extends StatefulWidget {
  static const String route = '/users/blocked';

  UserModel? currentUser;
  BlockedUsersScreen({this.currentUser});

  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //QuickHelp.setWebPageTitle(context, "page_title.blocked_users_title".tr());

    return ToolBar(
        title: "page_title.blocked_users_title".tr(),
        centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
        leftButtonIcon: Icons.arrow_back_ios,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
        elevation: QuickHelp.isAndroidPlatform() ? 2 : 1,
        child: SafeArea(
          child: SingleChildScrollView(child: blockedUsers()),
        ));
  }

  Widget blockedUsers(){

    return FutureBuilder(
        future: _loadBlockedUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot){

          if(snapshot.connectionState == ConnectionState.waiting ){
            return ListView.builder(
              itemCount: 20,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: FadeShimmer(
                    height: 60,
                    width: 60,
                    radius: 4,
                    highlightColor: Color(0xffF9F9FB),
                    baseColor: Color(0xffE6E8EB),
                  ),
                );
              },
            );
          }
          if (snapshot.hasData) {
            var results = snapshot.data as List<dynamic>;
            return ListView.builder(
              itemCount: results.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              child: QuickActions.avatarWidget(results[index]),
                            ),
                            Expanded(child: TextWithTap(results[index].getFullName!, fontSize: 16, marginLeft: 10,)),
                            ContainerCorner(
                              height: 40,
                              width: 40,
                              borderRadius: 50,
                              color: kGreenColor,
                              child: Icon(Icons.vpn_key, color: Colors.white,),
                              onTap: (){
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(top: 15.0),
                                              child: QuickActions.avatarWidget(results[index],
                                                  width: 130, height: 130),
                                            ),
                                            TextWithTap(
                                              results[index].getFullName!,
                                              textAlign: TextAlign.center,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            TextWithTap(
                                              "feed.unlock_user_confirm".tr(),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              height: 35,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ContainerCorner(
                                                  child: TextButton(
                                                    child: TextWithTap("cancel".tr().toUpperCase(),
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    onPressed: (){
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  color: kRedColor1,
                                                  borderRadius: 10,
                                                  marginLeft: 5,
                                                  width: 125,
                                                ),
                                                ContainerCorner(
                                                  child: TextButton(
                                                    child: TextWithTap("confirm_".tr().toUpperCase(),
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    onPressed: ()=> _unlockUser(results[index]),
                                                  ),
                                                  color: kGreenColor,
                                                  borderRadius: 10,
                                                  marginRight: 5,
                                                  width: 125,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                        Divider()
                      ],
                    ),
                  );
              },
            );
          } else {
            return QuickActions.noContentFound(context);
          }
        });

  }

  Future<List<dynamic>?> _loadBlockedUsers() async {

    List<String> usersIds = [];

    for(UserModel userModel in widget.currentUser!.getBlockedUsers!){
      usersIds.add(userModel.objectId!);
    }

    QueryBuilder<UserModel> queryBuilder = QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(UserModel.keyId, usersIds);


    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success) {
      print("Lives count: ${apiResponse.results!.length}");
      if (apiResponse.results != null) {
        return apiResponse.results;
      } else {
        return AsyncSnapshot.nothing() as dynamic;
      }
    } else {
      return apiResponse.error as dynamic;
    }

  }

  _unlockUser(UserModel author) async{
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.removeBlockedUser = author;
    widget.currentUser!.removeBlockedUserIds = author.objectId!;

    ParseResponse response = await widget.currentUser!.save();
    if(response.success){
      Navigator.of(context).pop();
      QuickHelp.hideLoadingDialog(context);
      setState(() {});
    }
  }

}
