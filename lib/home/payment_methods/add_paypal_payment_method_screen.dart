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

class AddPaypalMethodScreen extends StatefulWidget {
  UserModel? currentUser;

  AddPaypalMethodScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AddPaypalMethodScreen> createState() =>
      _AddPaypalMethodScreenState();
}

class _AddPaypalMethodScreenState extends State<AddPaypalMethodScreen> {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController nameTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  initializeInput() {
    emailTextController.text = widget.currentUser!.getPayPalEmail ?? "";
    nameTextController.text = widget.currentUser!.getPayPalName ?? "";
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
            ContainerCorner(
              height: 45,
              borderRadius: 50,
              marginLeft: 15,
              marginRight: 15,
              marginTop: 40,
              color: kPrimaryColor,
              onTap: () {
                if(formKey.currentState!.validate()) {
                  saveUserPaypalMethod();
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
        PaymentSourceModel.paymentMethodPaypal;
    paymentSourceModel.setPayPalEmail = emailTextController.text;
    paymentSourceModel.setPayPalName = nameTextController.text;
    await paymentSourceModel.save();
  }

  saveUserPaypalMethod() async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setPayPalName = nameTextController.text;
    widget.currentUser!.setPayPalEmail = emailTextController.text;
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
