// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../helpers/quick_help.dart';
import '../../models/PaymentSourceModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../web/web_url_screen.dart';

class AddPayoneerMethodScreen extends StatefulWidget {
  UserModel? currentUser;

  AddPayoneerMethodScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AddPayoneerMethodScreen> createState() =>
      _AddPayoneerMethodScreenState();
}

class _AddPayoneerMethodScreenState extends State<AddPayoneerMethodScreen> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String payoneerUrl =
      "http://share.payoneer.com/nav/_437l45jS7lTyVUMHPsC61ZMQX0_b2cYO2hun3x-Y9U7mylyk7NADTqo5hs3YYxhYn6739c48PxuDK9wqau3qg2";

  initializeInput() {
    emailTextController.text = widget.currentUser!.getPayoneerEmail ?? "";
    nameTextController.text = widget.currentUser!.getPayoneerName ?? "";
  }

  @override
  void initState() {
    super.initState();
    initializeInput();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          title: TextWithTap(
            "withdrawal_method_screen.bind_".tr(),
            fontWeight: FontWeight.bold,
          ),
        ),
        body: ListView(
          children: [
            ContainerCorner(
              width: size.width,
              color: Colors.orange.withOpacity(0.1),
              borderWidth: 0,
              marginBottom: 10,
              height: 35,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: TextScroll(
                    "withdrawal_method_screen.bind_warming".tr(),
                    mode: TextScrollMode.bouncing,
                    velocity: Velocity(pixelsPerSecond: Offset(50, 0)),
                    delayBefore: Duration(milliseconds: 500),
                    numberOfReps: 100,
                    pauseBetween: Duration(milliseconds: 50),
                    style: TextStyle(color: Colors.orange),
                    textAlign: TextAlign.right,
                    selectable: true,
                  ),
                ),
              ),
            ),
            Form(key: formKey,
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWithTap(
                    "bind_payoneer_account_screen.name_".tr(),
                    marginLeft: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        onChanged: (text) {},
                        maxLines: 1,
                        controller: nameTextController,
                        textAlign: TextAlign.end,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "bind_payoneer_account_screen.name_".tr();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText:
                          "bind_payoneer_account_screen.please_enter".tr(),
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWithTap(
                    "bind_payoneer_account_screen.account_".tr(),
                    marginLeft: 15,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (text) {},
                        maxLines: 1,
                        controller: emailTextController,
                        textAlign: TextAlign.end,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "bind_payoneer_account_screen.account_".tr();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "bind_payoneer_account_screen.email_ex".tr(),
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(
                height: 2,
              ),
            ],)),
            TextWithTap(
              "bind_payoneer_account_screen.notice_".tr(),
              marginLeft: 15,
              fontSize: size.width / 20,
              fontWeight: FontWeight.w900,
              marginBottom: 30,
              marginTop: 15,
            ),
            TextWithTap(
              "bind_payoneer_account_screen.register_to_payoneer".tr(),
              color: kPrimaryColor,
              marginLeft: 15,
              fontSize: 12,
              onTap: () {
                QuickHelp.goToNavigatorScreen(
                  context,
                  WebViewScreen(
                    pageType: 'etc',
                    receivedTitle: "Payoneer",
                    receivedURL: payoneerUrl,
                  ),
                );
              },
            ),
            ContainerCorner(
              height: 45,
              borderRadius: 50,
              marginLeft: 15,
              marginRight: 15,
              marginTop: 40,
              color: kPrimaryColor,
              onTap: () {
                if(formKey.currentState!.validate()) {
                  saveUserPayoneerMethod();
                }
              },
              child: TextWithTap(
                "submit_".tr(),
                color: Colors.white,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  createPaymentSource() async {
    PaymentSourceModel paymentSourceModel = PaymentSourceModel();
    paymentSourceModel.setAuthor = widget.currentUser!;
    paymentSourceModel.setAuthorId = widget.currentUser!.objectId!;
    paymentSourceModel.setPaymentMethod =
        PaymentSourceModel.paymentMethodPayoneer;
    paymentSourceModel.setPayoneerEmail = emailTextController.text;
    paymentSourceModel.setPayoneerName = nameTextController.text;
    await paymentSourceModel.save();
  }

  saveUserPayoneerMethod() async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setPayoneerName = nameTextController.text;
    widget.currentUser!.setPayoneerEmail = emailTextController.text;
    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      createPaymentSource();
      QuickHelp.hideLoadingDialog(context);
      widget.currentUser = response.results!.first!;
      QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

}
