// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/ui/button_widget.dart';

import '../../auth/welcome_screen.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class CancelAccountScreen extends StatefulWidget {
  UserModel? currentUser;

  CancelAccountScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<CancelAccountScreen> createState() => _CancelAccountScreenState();
}

class _CancelAccountScreenState extends State<CancelAccountScreen> {
  TextEditingController userIdTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var advicesTitle = [
    "cancel_account_screen.account_cancellation_explain".tr(),
    "cancel_account_screen.after_canceling_advice".tr(),
    "cancel_account_screen.vip_advice".tr(),
    "cancel_account_screen.attention_advice".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "cancel_account_screen.cancel_account".tr(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 15,
          ),
          Column(
            children: List.generate(advicesTitle.length, (index) {
              return advices(text: advicesTitle[index]);
            }),
          ),
        ],
      ),
      bottomNavigationBar: ContainerCorner(
        width: size.width,
        marginBottom: 20,
        color: kPrimaryColor,
        height: 45,
        marginLeft: 20,
        marginRight: 20,
        borderRadius: 10,
        child: ButtonWidget(
          onTap: () => confirmAccountCancellation(),
          child: TextWithTap(
            "cancel_account_screen.confirm_delete_account".tr(),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget advices({required String text}) {
    return TextWithTap(
      text,
      marginLeft: 20,
      marginRight: 15,
      marginBottom: 30,
      fontSize: 16,
    );
  }

  confirmAccountCancellation() {
    bool isDark = QuickHelp.isDarkMode(context);
    bool activateHeight = true;
    showDialog(context: context,
        builder: (BuildContext context) {
          Size size = MediaQuery.of(context).size;
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "cancel_account_screen.confirm_to_cancel".tr(),
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center,
                      ),
                      TextWithTap(
                        "${widget.currentUser!.getUsername!}?",
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w900,
                        marginTop: 5,
                        color: Colors.red,
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      TextWithTap(
                        "cancel_account_screen.enter_id".tr(),
                        textAlign: TextAlign.center,
                        color: kGrayColor,
                      ),
                      ContainerCorner(
                        color: kGrayColor.withOpacity(0.2),
                        borderWidth: 0.3,
                        borderColor: kGrayColor,
                        borderRadius: 4,
                        marginBottom: 15,
                        marginTop: 5,
                        height: activateHeight ? 35 : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            autocorrect: false,
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            controller: userIdTextController,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                            validator: (text) {
                              if (text!.isEmpty) {
                                newState(() {
                                  activateHeight = false;
                                });
                                return "cancel_account_screen.id_needed".tr();
                              } else {
                                newState(() {
                                  activateHeight = true;
                                });
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText:
                                  "cancel_account_screen.please_enter".tr(),
                              border: InputBorder.none,
                              hintStyle: GoogleFonts.roboto(
                                color: kGrayColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red,
                            size: 15,
                          ),
                          SizedBox(
                            width: size.width / 1.6,
                            child: TextWithTap(
                              "cancel_account_screen.you_will_lose_all_data"
                                  .tr(),
                              color: isDark
                                  ? Colors.white
                                  : kContentColorLightTheme,
                              fontSize: 11,
                              marginRight: 10,
                              marginLeft: 5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                            child: TextWithTap(
                              "cancel".tr(),
                              color: kGrayColor,
                              marginRight: 15,
                              marginLeft: 15,
                            ),
                            onPressed: () =>
                                QuickHelp.goBackToPreviousPage(context),
                          ),
                          TextButton(
                            child: TextWithTap(
                              "ok_".tr(),
                              color: kPrimaryColor,
                              marginRight: 20,
                              marginLeft: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (widget.currentUser!.getUid.toString() ==
                                    userIdTextController.text) {
                                  deleteAccount();
                                } else {
                                  QuickHelp.showAppNotificationAdvanced(
                                      title: "error".tr(),
                                      context: context,
                                      message: "cancel_account_screen.wrong_id"
                                          .tr(),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  deleteAccount() async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setAccountDeleted = true;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      widget.currentUser = response.results!.first;
      doUserLogout(widget.currentUser);
    } else {
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  void doUserLogout(UserModel? userModel) async {
    ParseResponse response = await userModel!.logout(deleteLocalUserData: true);
    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goToNavigatorScreen(context, WelcomeScreen(),
          finish: true, back: false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showError(context: context, message: response.error!.message);
    }
  }
}
