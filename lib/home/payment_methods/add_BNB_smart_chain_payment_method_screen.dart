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

class AddBNBSmartChainMethodScreen extends StatefulWidget {
  UserModel? currentUser;

  AddBNBSmartChainMethodScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AddBNBSmartChainMethodScreen> createState() =>
      _AddBNBSmartChainMethodScreenState();
}

class _AddBNBSmartChainMethodScreenState
    extends State<AddBNBSmartChainMethodScreen> {
  TextEditingController walletTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  initializeInput() {
    walletTextController.text = widget.currentUser!.getWalletAddress ?? "";
  }

  var noticeTitles = [
    "bind_bnb_smart_chain_screen.wallet_address".tr(),
    "bind_bnb_smart_chain_screen.rule_1".tr(),
    "bind_bnb_smart_chain_screen.rule_2".tr(),
    "bind_bnb_smart_chain_screen.rule_3".tr(),
    "bind_bnb_smart_chain_screen.rule_4".tr(),
    "bind_bnb_smart_chain_screen.rule_5".tr(),
  ];

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
            Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithTap(
                          "bind_bnb_smart_chain_screen.wallet_address".tr(),
                          marginLeft: 15,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (text) {},
                              maxLines: 1,
                              controller: walletTextController,
                              textAlign: TextAlign.end,
                              validator: (text) {
                                if (text!.isEmpty) {
                                  return "bind_bnb_smart_chain_screen.wallet_address"
                                      .tr();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText:
                                    "bind_bnb_smart_chain_screen.please_enter"
                                        .tr(),
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
                  ],
                )),
            TextWithTap(
              "bind_payoneer_account_screen.notice_".tr(),
              marginLeft: 15,
              fontSize: size.width / 20,
              fontWeight: FontWeight.w900,
              marginBottom: 30,
              marginTop: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                  noticeTitles.length,
                  (index) => TextWithTap(
                        noticeTitles[index],
                        fontSize: 12,
                    marginBottom: 3,
                    marginLeft: 15,
                      )),
            ),
            ContainerCorner(
              height: 45,
              borderRadius: 50,
              marginLeft: 15,
              marginRight: 15,
              marginTop: 40,
              color: kPrimaryColor,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  saveUserBNBSmartChainMethod();
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
        PaymentSourceModel.paymentMethodBNBSmartChainWallet;
    paymentSourceModel.setWalletAddress = walletTextController.text;
    await paymentSourceModel.save();
  }

  saveUserBNBSmartChainMethod() async {
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setWalletAddress = walletTextController.text;
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
