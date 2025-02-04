// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../bind_phone_number/bind_phone_number_screen.dart';
import '../cancel_account/cancel_account_screen.dart';

class AccountAndSecurityScreen extends StatefulWidget {
  UserModel? currentUser;

  AccountAndSecurityScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AccountAndSecurityScreen> createState() =>
      _AccountAndSecurityScreenState();
}

class _AccountAndSecurityScreenState extends State<AccountAndSecurityScreen> {
  var icons = [
    "assets/images/ic_email_48.png",
    "assets/images/ic_google_48.png",
    "assets/images/ic_facebook_48.png",
  ];

  var titles = [
    "account_and_security_screen.email_address".tr(),
    "account_and_security_screen.google_".tr(),
    "account_and_security_screen.facebook_".tr(),
  ];

  String phoneNumber = "";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    if(widget.currentUser!.getPhoneNumberFull!.isEmpty){
      phoneNumber = "account_and_security_screen.bind_".tr();
    }else{
      phoneNumber = widget.currentUser!.getPhoneNumberFull!;
    }

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "account_and_security_screen.account_and_security".tr(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          option(
              title: "account_and_security_screen.phone_number".tr(),
              iconUrl: "assets/images/ic_phone_48.png",
            info: phoneNumber,
            screen: BindPoneNumberScreen(
              currentUser: widget.currentUser,
            ),
          ),
          const SizedBox(height: 10,),
          Column(
            children: List.generate(icons.length, (index) {
              return option(
                  title: titles[index],
                  iconUrl: icons[index],
                info: "bind",
                screen: BindPoneNumberScreen(
                  currentUser: widget.currentUser,
                ),
              );
            }),
          ),
          ContainerCorner(
            width: size.width,
            marginTop: 10,
            height: 50,
            color: isDark ? kContentColorLightTheme : Colors.white,
            child: ButtonWidget(
              onTap: () {
                QuickHelp.goToNavigatorScreen(
                  context,
                  CancelAccountScreen(
                    currentUser: widget.currentUser,
                  ),
                );
              },
              child: TextWithTap(
                "account_and_security_screen.cancel_account".tr(),
                color: Colors.red,
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget option({
    required String title,
    required String iconUrl,
    required String info,
    required Widget screen,
  }) {
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      borderWidth: 0,
      marginTop: 1,
      color: QuickHelp.getColorStandard(inverse: true),
      child: ButtonWidget(
        onTap: () async {
          UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
            context,
            screen,
          );
          if(user != null){
            setState(() {
              widget.currentUser = user;
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    iconUrl,
                    height: 14,
                    width: 14,
                  ),
                  TextWithTap(
                    title,
                    color: isDark ? Colors.white : kContentColorLightTheme,
                    fontSize: 17,
                    marginLeft: 5,
                    marginTop: 10,
                    marginBottom: 10,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextWithTap(
                    info,
                    color: kGrayColor,
                    fontSize: 12,
                    marginRight: 5,
                    marginTop: 10,
                    marginBottom: 10,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: kGrayColor,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
