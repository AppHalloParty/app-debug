// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class SelectReceiver extends StatefulWidget {
  UserModel? currentUser;

  SelectReceiver({this.currentUser, super.key});

  @override
  State<SelectReceiver> createState() => _SelectReceiverState();
}

class _SelectReceiverState extends State<SelectReceiver> {
  TextEditingController searchController = TextEditingController();

  String textOnSearchField = "";
  bool showSearchList = false;
  bool showDefaultList = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          onPressed: () => QuickHelp.goBackToPreviousPage(context),
        ),
        title: TextWithTap(
          "coins_trading_screen.recent_transactions".tr(),
          color: QuickHelp.isDarkMode(context)
              ? Colors.white
              : kContentColorLightTheme,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(55),
          child: Row(
            children: [
              Expanded(child: searchInputField()),
              ContainerCorner(
                color: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : Colors.white,
                shadowColor: kGrayColor,
                shadowColorOpacity: 0.3,
                height: 50,
                width: 50,
                marginTop: 5,
                marginBottom: 5,
                marginLeft: 10,
                marginRight: 5,
                borderRadius: 50,
                onTap: () {
                  print("search_kombo ${searchController.text}");
                  setState(() {
                    QuickHelp.removeFocusOnTextField(context);
                    if (searchController.text.isNotEmpty) {
                      textOnSearchField = searchController.text;
                      showSearchList = true;
                      showDefaultList = false;
                    }
                  });
                },
                child: const Icon(
                  Icons.search,
                  color: Colors.green,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        child: showUserList(),
      ),
    );
  }

  Widget showUserList() {
    if(showSearchList) {
      return showUserFromSearch();
    }else {
      return recentReceivers();
    }
  }

  Widget searchInputField() {
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      marginLeft: 10,
      borderRadius: 50,
      color: isDark ? kContentDarkShadow : kGrayColor.withOpacity(0.05),
      child: ContainerCorner(
        color: isDark ? kContentDarkShadow : kGrayColor.withOpacity(0.05),
        borderRadius: 50,
        child: TextFormField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.multiline,
          controller: searchController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value!.isEmpty) {
              return "coins_trading_screen.enter_id_nickname".tr();
            }
            return null;
          },
          onChanged: (text) {
            setState(() {
              if (searchController.text.isEmpty) {
                showDefaultList = true;
                showSearchList = false;
              }
            });
          },
          decoration: InputDecoration(
            hintText: "coins_trading_screen.enter_id_nickname".tr(),
            hintStyle: GoogleFonts.nunito(color: kGrayColor),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  ParseLiveListWidget recentReceivers() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryBuilder =
    QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereContainedIn(UserModel.keyObjectId, widget.currentUser!.getTradingCoinsReceivers!);

    queryBuilder.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);

    return ParseLiveListWidget<UserModel>(
        query: queryBuilder,
        reverse: false,
        lazyLoading: false,
        shrinkWrap: true,
        duration: const Duration(milliseconds: 200),
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<UserModel> snapshot) {
          if (snapshot.hasData) {
            UserModel user = snapshot.loadedData as UserModel;
            return ContainerCorner(
              borderRadius: 4,
              borderWidth: 0,
              marginBottom: 10,
              onTap: () {
                QuickHelp.goBackToPreviousPage(context, result: user);
              },
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
                            const SizedBox(
                              width: 5,
                            ),
                            QuickActions.giftReceivedLevel(
                              receivedGifts: user.getDiamondsTotal!,
                              width: 35,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
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
                              user.getUid!.toString(),
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
            );
          } else {
            return QuickActions.noContentFound(context);
          }
        },
        listLoadingElement: ContainerCorner(
          width: size.width,
          height: (size.width) / 3,
          child: QuickHelp.appLoading(),
        ),
        queryEmptyElement: Padding(
          padding: const EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(context),
        ));
  }

  ParseLiveListWidget showUserFromSearch() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<UserModel> queryByID =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryByID.whereEqualTo(UserModel.keyUid, searchController.text);

    QueryBuilder<UserModel> queryByNickname =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryByNickname.whereContains(UserModel.keyUsername, searchController.text);

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder.or(UserModel.forQuery(), [
      queryByID,
      queryByNickname,
    ]);

    queryBuilder.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);

    return ParseLiveListWidget<UserModel>(
        query: queryBuilder,
        reverse: false,
        key: Key(textOnSearchField),
        lazyLoading: false,
        shrinkWrap: true,
        duration: const Duration(milliseconds: 200),
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<UserModel> snapshot) {
          if (snapshot.hasData) {
            UserModel user = snapshot.loadedData as UserModel;
            return ContainerCorner(
              borderRadius: 4,
              borderWidth: 0,
              marginBottom: 10,
              onTap: () {
                QuickHelp.goBackToPreviousPage(context, result: user);
              },
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
                            const SizedBox(
                              width: 5,
                            ),
                            QuickActions.giftReceivedLevel(
                              receivedGifts: user.getDiamondsTotal!,
                              width: 35,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
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
                              user.getUid!.toString(),
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
            );
          } else {
            return QuickActions.noContentFound(context);
          }
        },
        listLoadingElement: ContainerCorner(
          width: size.width,
          height: (size.width) / 3,
          child: QuickHelp.appLoading(),
        ),
        queryEmptyElement: Padding(
          padding: const EdgeInsets.all(8.0),
          child: QuickActions.noContentFound(context),
        ));
  }
}
