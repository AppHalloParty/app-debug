import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_cloud.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/NotificationsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:http/http.dart' as http;

import '../../ui/app_bar.dart';

// ignore: must_be_immutable
class LeadersPage extends StatefulWidget {
  UserModel? currentUser;

  LeadersPage({Key? key, this.currentUser}) : super(key: key);
  static String route = "/Leaders";

  @override
  _LeadersPageState createState() => _LeadersPageState();
}

class _LeadersPageState extends State<LeadersPage> {
  List usersList = [];
  List<Map<String, int>> usersListCount = [];
  List countrySelectedList = [];

  final request = "https://restcountries.com/v3.1/all";

  Future<List> getCountries() async {
    http.Response response = await http.get(Uri.parse(request));
    return json.decode(response.body);
  }

  void openSheet() async {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showCountrySelectorBottomSheet();
        });
  }

  bool selectCountry = false;
  bool bonga = false;

  @override
  Widget build(BuildContext context) {

    return ToolBar(
        title: "leaders.leader_".tr(),
        centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
        leftButtonIcon: Icons.arrow_back_ios,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
        elevation: QuickHelp.isAndroidPlatform() ? 2 : 1,
        //rightButtonAsset: "ic_settings_menu.svg",
        //rightButtonPress: () => QuickHelp.goToNavigator(context, SelectCountryScreen.route),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ContainerCorner(
              color: kTransparentColor,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TextWithTap("leaders.menu_all_times".tr()),
                          Expanded(
                            child: ContainerCorner(
                              height: MediaQuery.of(context).size.height,
                              marginBottom: 200,
                              color: kTransparentColor,
                              child: getLeaders(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }


  Widget getLeaders() {
    QueryBuilder<UserModel> queryBuilder = QueryBuilder(UserModel.forQuery());
    queryBuilder.whereGreaterThan(UserModel.keyDiamondsTotal, Setup.diamondsNeededForLeaders);
    queryBuilder.orderByDescending(UserModel.keyDiamondsTotal);

    return ParseLiveListWidget<UserModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(milliseconds: 30),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<UserModel> snapshot) {

        if (snapshot.hasData) {

          UserModel user = snapshot.loadedData as UserModel;
          usersList.add(user.objectId);

          return ContainerCorner(
            color: kTransparentColor,
            marginLeft: 20,
            marginRight: 10,
            marginTop: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Row(
                          children: [
                            TextWithTap(
                              "${usersList.indexOf(user.objectId,) + 1}",
                              color: kGrayColor,
                              marginRight: 10,
                              fontSize: 18,
                            ),
                            Stack(children: [
                              QuickActions.avatarWidget(user,
                                  width: 60, height: 60),
                              Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: ContainerCorner(
                                    width: 15,
                                    height: 15,
                                    borderRadius: 50,
                                    color: kRedColor1,
                                  )),
                            ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWithTap(
                                  user.getFullName!,
                                  marginLeft: 10,
                                  marginBottom: 5,
                                  fontWeight: FontWeight.bold,
                                  color: kGrayColor,
                                  fontSize: 16,
                                ),
                                ContainerCorner(
                                  color: kTransparentColor,
                                  marginLeft: 7,
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/svg/ic_diamond.svg",
                                        width: 25,
                                        height: 25,
                                      ),
                                      TextWithTap(
                                        user.getDiamondsTotal.toString(),
                                        marginLeft: 2,
                                        color: kGrayColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )),
                    ContainerCorner(
                      borderRadius: 50,
                      height: 40,
                      width: 40,
                      color: widget.currentUser!.getFollowing!.contains(user.objectId) ? kTicketBlueColor :  kRedColor1,
                      child: Icon(
                        widget.currentUser!.getFollowing!.contains(user.objectId) ? Icons.done : Icons.add,
                        color: Colors.white,
                      ),
                      onTap: (){
                        if(!widget.currentUser!.getFollowing!.contains(user.objectId)){
                          follow(user);
                        }
                      },
                    )
                  ],
                ),
                ContainerCorner(
                  color: kGrayColor.withOpacity(0.2),
                  height: 1,
                  marginLeft: 5,
                  marginRight: 5,
                  marginTop: 20,
                ),
              ],
            ),
          );

        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
      queryEmptyElement: QuickActions.noContentFound(context),
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void follow(UserModel mUser)  async{
    QuickHelp.showLoadingDialog(context);

    ParseResponse parseResponseUser;

    widget.currentUser!.setFollowing = mUser.objectId!;
    parseResponseUser = await widget.currentUser!.save();

    if(parseResponseUser.success){

      if(parseResponseUser.results != null){
        QuickHelp.hideLoadingDialog(context);
        setState(() {
          widget.currentUser = parseResponseUser.results!.first as UserModel;
        });
      }
    }

    ParseResponse parseResponse;
    parseResponse = await QuickCloudCode.followUser(
        author: widget.currentUser!,
        receiver: mUser);

    if (parseResponse.success) {
      QuickActions.createOrDeleteNotification(widget.currentUser!,
          mUser, NotificationsModel.notificationTypeFollowers);
    }

  }

  Widget _showCountrySelectorBottomSheet() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.67,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: QuickHelp.isDarkMode(context)
                        ? kContentColorDarkTheme
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    color: kTransparentColor,
                    child: Scaffold(
                      backgroundColor: kTransparentColor,
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: kGrayColor,
                          ),
                          onPressed: () =>
                              QuickHelp.goBackToPreviousPage(context),
                        ),
                        actions: [
                          TextWithTap(
                            "leaders.menu_clear_all".tr(),
                            color: kGrayColor,
                            marginTop: 20,
                            marginRight: 15,
                          )
                        ],
                        backgroundColor: kTransparentColor,
                        centerTitle: true,
                        title: TextWithTap(
                          "leaders.title_select_county".tr(),
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                      body: FutureBuilder<List>(
                        future: getCountries(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            default:
                              if (snapshot.hasError) {
                                return Center(
                                  child: TextWithTap(
                                    "Error ao carregar :( \n" +
                                        snapshot.toString(),
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                return Center(
                                  child: ListView.builder(
                                    itemCount: (snapshot.data as List).length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          print("Apertou $index");
                                          print(snapshot.data![index]["cca2"]);
                                          countrySelectedList.add(
                                              snapshot.data![index]["cca2"]);
                                        },
                                        child: Row(
                                          children: [
                                            ContainerCorner(
                                              color:
                                                  countrySelectedList.contains(
                                                          snapshot.data![index]
                                                              ["cca2"])
                                                      ? kGreenColor
                                                      : kTransparentColor,
                                              borderColor: kGreenColor,
                                              height: 15,
                                              width: 15,
                                              borderRadius: 50,
                                              marginBottom: 10,
                                              marginLeft: 10,
                                            ),
                                            ContainerCorner(
                                              width: 25,
                                              height: 25,
                                              marginBottom: 10,
                                              marginLeft: 10,
                                              child: SvgPicture.network(
                                                snapshot.data![index]["flags"]
                                                    ["svg"],
                                              ),
                                            ),
                                            Expanded(
                                              child: TextWithTap(
                                                snapshot.data![index]["name"]
                                                        ["common"]
                                                    .toString(),
                                                color: Colors.black,
                                                marginLeft: 10,
                                                marginBottom: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                          }
                        },
                      ),
                    ),
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
