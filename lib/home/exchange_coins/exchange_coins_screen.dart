// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class ExchangeCoinsScreen extends StatefulWidget {
  UserModel? currentUser;

  ExchangeCoinsScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<ExchangeCoinsScreen> createState() => _ExchangeCoinsScreenState();
}

class _ExchangeCoinsScreenState extends State<ExchangeCoinsScreen> {
  int minCoinAmount = 90000;
  int maxCoinAmount = 450000;
  int minPointAmount = 100000;
  int maxPointAmount = 500000;

  int maxAmountPerDay = 500000;

  int verificationCode = QuickHelp.generateShortUId();

  var selectedAmount = [0];

  var coinAmounts = [];
  var pointAMounts = [];

  TextEditingController verificationCodeTextController =
      TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    coinAmounts = [minCoinAmount, maxCoinAmount];
    pointAMounts = [minPointAmount, maxPointAmount];
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
            onPressed: ()=> selectUser(),
          ),
          title: TextWithTap(
            "exchange_coins_screen.exchange_coins".tr(),
            fontWeight: FontWeight.bold,
          ),
        ),
        body: ListView(
          children: [
            ContainerCorner(
              borderWidth: 0,
              marginBottom: 25,
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Image.asset("assets/images/points_image.png"),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                          amount: widget.currentUser!.getDiamonds.toString(),
                        ),
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: size.width / 13,
                      ),
                      Image.asset(
                        "assets/images/ic_jifen_wode.webp",
                        height: 20,
                      ),
                    ],
                  ),
                ],
              ),
              marginRight: 15,
              marginLeft: 15,
            ),
            TextWithTap(
              "exchange_coins_screen.number_exchanges".tr(),
              fontWeight: FontWeight.bold,
              fontSize: 17,
              marginLeft: 15,
              marginBottom: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(coinAmounts.length, (index) {
                return ContainerCorner(
                  color: isDark
                      ? kContentDarkShadow
                      : kGrayColor.withOpacity(0.05),
                  borderRadius: 10,
                  width: size.width / 2.3,
                  height: 80,
                  borderColor: selectedAmount.contains(index)
                      ? earnCashColor
                      : kTransparentColor,
                  onTap: () {
                    setState(() {
                      selectedAmount.clear();
                      selectedAmount.add(index);
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            width: size.width / 20,
                            height: size.width / 20,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                              amount: "${coinAmounts[index]}",
                            ),
                            fontWeight: FontWeight.w900,
                            fontSize: size.width / 17,
                            marginLeft: 5,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/ic_jifen_wode.webp",
                            width: size.width / 25,
                            height: size.width / 25,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                              amount: "${pointAMounts[index]}",
                            ),
                            marginLeft: 5,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ),
            TextWithTap(
              "exchange_coins_screen.verification_code".tr(),
              fontWeight: FontWeight.bold,
              fontSize: 17,
              marginLeft: 15,
              marginBottom: 20,
              marginTop: 40,
            ),
            Form(
              key: formKey,
              child: Row(
                children: [
                  ContainerCorner(
                    color: isDark
                        ? kContentDarkShadow
                        : kGrayColor.withOpacity(0.05),
                    borderRadius: 10,
                    width: size.width / 1.7,
                    marginLeft: 15,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: (text) {},
                        maxLines: 1,
                        controller: verificationCodeTextController,
                        validator: (text) {
                          if (text!.isEmpty) {
                            return "exchange_coins_screen.verification_code_needed"
                                .tr();
                          } else if (verificationCodeTextController.text !=
                              "$verificationCode") {
                            return "exchange_coins_screen.wrong_code".tr();
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText:
                              "exchange_coins_screen.enter_verification_code"
                                  .tr(),
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  ContainerCorner(
                    color: kPrimaryColor.withOpacity(0.4),
                    borderRadius: 10,
                    marginLeft: 5,
                    onTap: () => newVerificationCode(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextWithTap(
                            "$verificationCode",
                            color: Colors.white,
                            marginLeft: 10,
                            fontSize: 17,
                          ),
                          Icon(
                            Icons.update,
                            color: Colors.white,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ContainerCorner(
              color: kPrimaryColor,
              borderRadius: 50,
              marginTop: 30,
              marginBottom: 20,
              marginLeft: 20,
              marginRight: 20,
              height: 50,
              child: ButtonWidget(
                onTap: () {
                  if (formKey.currentState!.validate()) {
                    confirmToRedeem();
                  }
                },
                child: TextWithTap(
                  "exchange_coins_screen.exchange_coins".tr(),
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            TextWithTap(
              "exchange_coins_screen.rule_description".tr(),
              fontWeight: FontWeight.bold,
              fontSize: 17,
              marginLeft: 15,
              marginBottom: 5,
            ),
            TextWithTap(
              "exchange_coins_screen.redeem_up_amount_day".tr(namedArgs: {
                "amount":
                    QuickHelp.checkFundsWithString(amount: "$maxAmountPerDay")
              }),
              marginLeft: 15,
            ),
          ],
        ),
      ),
    );
  }

  newVerificationCode() {
    setState(() {
      verificationCode = QuickHelp.generateShortUId();
      verificationCodeTextController.text = "";
    });
  }

  confirmToRedeem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "exchange_coins_screen.confirm_redeem".tr(namedArgs: {
                      "amount": QuickHelp.checkFundsWithString(
                          amount: "${pointAMounts[selectedAmount[0]]}")
                    }),
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
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
                          "confirm_".tr(),
                          color: kPrimaryColor,
                          marginRight: 20,
                          marginLeft: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () {
                          exchangeCoins();
                          QuickHelp.hideLoadingDialog(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }

  exchangeCoins() async {
    if (widget.currentUser!.getDiamonds! < pointAMounts[selectedAmount[0]]) {
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        message: "exchange_coins_screen.insufficient_point".tr(),
        context: context,
      );
    } else {
      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.removeDiamonds = pointAMounts[selectedAmount[0]];
      widget.currentUser!.addCredit = coinAmounts[selectedAmount[0]];

      ParseResponse response = await widget.currentUser!.save();
      if (response.success && response.results != null) {
        QuickHelp.hideLoadingDialog(context);
        setState(() {
          widget.currentUser = response.results!.first;
        });
        QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "done".tr(),
          isError: false,
          message: "operation_completed_successfully".tr(),
        );
        QuickHelp.saveCoinTransaction(
            author: widget.currentUser!,
            amountTransacted: coinAmounts[selectedAmount[0]]);
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
  selectUser() {
    QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);
  }
}
