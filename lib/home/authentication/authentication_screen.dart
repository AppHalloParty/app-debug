// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../bind_phone_number/bind_phone_number_screen.dart';
import '../face_authentication/face_authentication_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  UserModel? currentUser;

  AuthenticationScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  var images = [
    "assets/images/ic_auth_real.webp",
    "assets/images/ic_auth_phone.webp"
  ];

  var btnText = [];
  var titles = [];
  var explains = [];
  var screenToGo = [];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    btnText = [
      widget.currentUser!.getIsFaceAuthenticated!
          ? "auth_screen.certified_".tr()
          : "reward_screen.go_".tr(),
      widget.currentUser!.getPhoneNumber!.isNotEmpty
          ? "auth_screen.modify_".tr()
          : "withdrawal_method_screen.bind_".tr(),
    ];

    titles = [
      "auth_screen.face_authentication".tr(),
      widget.currentUser!.getPhoneNumber!.isNotEmpty
          ? "auth_screen.bind_successfully".tr()
          : "auth_screen.bind_phone".tr()
    ];

    explains = [
      "auth_screen.face_authentication_explain".tr(),
      widget.currentUser!.getPhoneNumberFull!.isNotEmpty
          ? widget.currentUser!.getPhoneNumberFull!
          : "auth_screen.bind_phone_explain".tr(),
    ];

    screenToGo = [
      FaceAuthenticationScreen(
        currentUser: widget.currentUser,
      ),
      BindPoneNumberScreen(
        currentUser: widget.currentUser,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
        elevation: 1.5,
        centerTitle: true,
        title: TextWithTap(
          "auth_screen.auth_".tr(),
          fontWeight: FontWeight.w900,
        ),
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 15, right: 15, top: 15),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "auth_screen.my_authentication".tr(),
                    fontWeight: FontWeight.w700,
                    marginBottom: 15,
                    fontSize: size.width / 20,
                  ),
                  SizedBox(
                    width: size.width / 1.7,
                    child: TextWithTap(
                      "auth_screen.my_authentication_explain".tr(),
                      color: kGrayColor,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
              Image.asset(
                "assets/images/ic_authentication.png",
                height: size.width / 3.6,
                width: size.width / 3.6,
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Column(
            children: List.generate(
              titles.length,
              (index) => ContainerCorner(
                borderColor: kGrayColor.withOpacity(0.2),
                borderRadius: 10,
                marginTop: 10,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            images[index],
                            height: 40,
                            width: 40,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWithTap(
                                titles[index],
                                fontWeight: FontWeight.w900,
                              ),
                              SizedBox(
                                width: size.width / 2,
                                child: TextWithTap(
                                  explains[index],
                                  color: kGrayColor,
                                  marginTop: 10,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      ContainerCorner(
                        borderRadius: 50,
                        height: 25,
                        color: kPrimaryColor,
                        onTap: () async {
                          UserModel? user =
                              await QuickHelp.goToNavigatorScreenForResult(
                            context,
                            screenToGo[index],
                          );
                          if (user != null) {
                            setState(() {
                              widget.currentUser = user;
                            });
                          }
                        },
                        child: TextWithTap(
                          btnText[index],
                          color: Colors.white,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          marginLeft: 10,
                          marginRight: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
