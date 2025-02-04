// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/text_with_tap.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../utils/colors.dart';
import '../exchange_coins/exchange_coins_screen.dart';
import '../withdraw/witthdraw_screen.dart';

class PointsScreen extends StatefulWidget {
  UserModel? currentUser;

  PointsScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  String defaultOption =
      "coins_and_points_screen.last_days".tr(namedArgs: {"amount": "30"});

  var filterTitles = [
    "coins_and_points_screen.last_days".tr(namedArgs: {"amount": "30"}),
    "coins_and_points_screen.last_days".tr(namedArgs: {"amount": "7"}),
    "coins_and_points_screen.last_month".tr(),
    "coins_and_points_screen.this_month".tr(),
    "coins_and_points_screen.last_week".tr(),
    "coins_and_points_screen.current_week".tr()
  ];

  var incomeSourceTitle = [
    "coins_and_points_screen.live_streaming".tr(),
    "coins_and_points_screen.party_".tr(),
    "coins_and_points_screen.platform_rewards".tr()
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "coins_and_points_screen.points_".tr(),
          fontWeight: FontWeight.bold,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: TextWithTap(
              "coins_and_points_screen.details_".tr(),
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ContainerCorner(
            borderWidth: 0,
            marginBottom: 15,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.asset("assets/images/points_image.png"),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                          amount: widget.currentUser!.getDiamonds.toString(),
                        ),
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: size.width / 13,
                      ),
                      Row(
                        children: [
                          TextWithTap(
                            "coins_and_points_screen.remaining_points".tr(),
                            marginRight: 5,
                            color: Colors.white,
                          ),
                          Image.asset(
                            "assets/images/ic_jifen_wode.webp",
                            height: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            marginRight: 15,
            marginLeft: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWithTap(
                "coins_and_points_screen.income".tr(),
                marginLeft: 15,
                fontWeight: FontWeight.bold,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    color: isDark ? Colors.white : kContentColorLightTheme,
                    size: 20,
                  ),
                  ContainerCorner(
                    marginRight: 15,
                    marginLeft: 10,
                    width: size.width / 2.5,
                    child: pCoinsDropDownFilter(),
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: List.generate(
                incomeSourceTitle.length,
                (index) =>
                    options(title: incomeSourceTitle[index], amount: "0")),
          ),
          ContainerCorner(
            color: kPrimaryColor,
            borderRadius: 50,
            marginTop: 30,
            marginBottom: 20,
            marginLeft: 30,
            marginRight: 30,
            height: 50,
            child: ButtonWidget(
              onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  WithDrawScreen(
                    currentUser: widget.currentUser,
                  )),
              child: TextWithTap(
                "coins_and_points_screen.withdraw_now".tr(),
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          ContainerCorner(
            borderRadius: 50,
            borderColor: kPrimaryColor,
            marginLeft: 30,
            marginRight: 30,
            height: 50,
            child: ButtonWidget(
              onTap: () async {
                UserModel? user =
                await QuickHelp.goToNavigatorScreenForResult(
                  context,
                  ExchangeCoinsScreen(
                    currentUser: widget.currentUser,
                  ),
                );
                if (user != null) {
                  widget.currentUser = user;
                  setState(() {});
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/icon_jinbi.png",
                    height: 20,
                  ),
                  TextWithTap(
                    "coins_and_points_screen.exchange_point_for_coins".tr(),
                    marginLeft: 10,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pCoinsDropDownFilter() {
    return DropdownButton(
      isExpanded: true,
      underline: const SizedBox(),
      value: defaultOption,
      items: filterTitles.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: TextWithTap(items),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          defaultOption = newValue!;
        });
      },
    );
  }

  Widget options({
    required String title,
    required String amount,
  }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      color: isDark ? kContentDarkShadow : kGrayColor.withOpacity(0.1),
      height: 50,
      marginLeft: 15,
      marginRight: 15,
      borderRadius: 4,
      marginTop: 4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerCorner(
            width: size.width / 3,
            marginLeft: 10,
            child: AutoSizeText(
              title,
              maxFontSize: 14.0,
              minFontSize: 8.0,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : kContentColorLightTheme,
              ),
              maxLines: 2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/ic_jifen_wode.webp",
                height: 15,
              ),
              TextWithTap(
                QuickHelp.checkFundsWithString(amount: amount),
                marginRight: 10,
                marginLeft: 5,
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: kGrayColor,
                size: 15,
              ),
              const SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }
}
