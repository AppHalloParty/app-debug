// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_help.dart';
import '../../models/PaymentSourceModel.dart';
import '../../models/UserModel.dart';
import '../../models/WithdrawModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../exchange_coins/exchange_coins_screen.dart';
import '../menu/withdraw_history_screen.dart';
import '../payment_methods/payment_method_screen.dart';

class WithDrawScreen extends StatefulWidget {
  UserModel? currentUser;

  WithDrawScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<WithDrawScreen> createState() => _WithDrawScreenState();
}

class _WithDrawScreenState extends State<WithDrawScreen> {
  String totalAmountAvailable = "";

  int pCoinPercent = 30;
  int pointPercent = 70;

  int minimumAmountWithdrawal = 100000;
  int exchangeRatio = 10000;

  double pCoinAvailable = 0.0;
  double pointAvailable = 0.0;
  double money = 0.0;

  PaymentSourceModel? paymentSourceModel;

  var paymentMethodTitle = [
    "withdrawal_method_screen.bnb_smart".tr(),
    "withdrawal_method_screen.paypal_".tr(),
    "withdrawal_method_screen.usdt_".tr(),
    "withdrawal_method_screen.payoneer_".tr(),
  ];

  var paymentMethodIcon = [
    "assets/images/ic_logo_bnb_binance.png",
    "assets/images/ic_logo_paypal.png",
    "assets/images/ic_logo_usdt.png",
    "assets/images/ic_logo_payoneer.png",
  ];

  var paymentMethods = [
    WithdrawModel.BnbSmartChain,
    WithdrawModel.PAYPAL,
    WithdrawModel.USDT,
    WithdrawModel.PAYONEER,
  ];

  var showAddedPaymentAddress = [];

  @override
  void initState() {
    super.initState();
    maths();
  }

  maths() {
    pointAvailable = widget.currentUser!.getDiamonds! * (pointPercent / 100);
    pCoinAvailable = widget.currentUser!.getPCoins! * (pCoinPercent / 100);
    totalAmountAvailable = "${pointAvailable + pCoinAvailable}";
    money = (pointAvailable + pCoinAvailable) / exchangeRatio;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    showAddedPaymentAddress = [
      widget.currentUser!.getWalletAddress ?? "",
      widget.currentUser!.getPayPalEmail ?? "",
      widget.currentUser!.getUsdtContactAddress ?? "",
      widget.currentUser!.getPayoneerEmail ?? "",
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "withdraw_screen.withdraw_".tr(),
          fontWeight: FontWeight.bold,
        ),
        actions: [
          TextButton(
            onPressed: () {
              QuickHelp.goToNavigatorScreen(
                  context,
                  WithdrawHistoryScreen(
                    currentUser: widget.currentUser,
                  ));
            },
            child: TextWithTap(
              "withdraw_screen.record_".tr(),
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          ContainerCorner(
            width: size.width,
            color: Colors.orange.withOpacity(0.1),
            borderWidth: 0,
            marginBottom: 10,
            height: 35,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.orange,
                    size: 18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.orange,
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
          ContainerCorner(
            marginRight: 15,
            marginLeft: 15,
            marginBottom: 20,
            child: Stack(
              children: [
                Image.asset("assets/images/withdraw_bg_image.png"),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        "withdraw_screen.total_amount_withdraw".tr(),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      TextWithTap(
                        "\$${QuickHelp.checkFundsWithString(
                          amount: "$money",
                        )}",
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: size.width / 10,
                        marginTop: 5,
                        marginBottom: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWithTap(
                                "withdraw_screen.withdrawal_amount".tr(),
                                color: Colors.white,
                                marginBottom: 5,
                              ),
                              TextWithTap(
                                "\$${QuickHelp.checkFundsWithString(
                                  amount: "$money",
                                )}",
                                color: Colors.white,
                                fontSize: size.width / 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  TextWithTap(
                                    "withdraw_screen.points_to_confirm".tr(),
                                    color: Colors.white,
                                    marginRight: 3,
                                    marginBottom: 5,
                                  ),
                                  Icon(
                                    Icons.arrow_circle_right_outlined,
                                    color: Colors.white,
                                    size: 13,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    "assets/images/ic_jifen_wode.webp",
                                    height: 13,
                                  ),
                                  TextWithTap(
                                    "${QuickHelp.checkFundsWithString(
                                      amount: "0",
                                    )}",
                                    color: Colors.white,
                                    fontSize: 17,
                                    marginLeft: 5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          TextWithTap(
                            "\$${QuickHelp.checkFundsWithString(
                              amount: "$money",
                            )} = ",
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          Image.asset(
                            "assets/images/ic_jifen_wode.webp",
                            height: 13,
                          ),
                          TextWithTap(
                            "${QuickHelp.checkFundsWithString(amount: "$pointAvailable")} + ",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            marginLeft: 3,
                          ),
                          Image.asset(
                            "assets/images/icon_ppbi_do_task.png",
                            height: 13,
                          ),
                          TextWithTap(
                            "${QuickHelp.checkFundsWithString(amount: "$pCoinAvailable")}",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            marginLeft: 3,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextWithTap(
            "withdraw_screen.withdrawal_method".tr(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            marginLeft: 15,
          ),
          if (widget.currentUser!.getSelectedPaymentMethod != null)
            Column(
              children: List.generate(
                paymentMethodTitle.length,
                (index) => addedPaymentOptions(
                  title: paymentMethodTitle[index],
                  icon: paymentMethodIcon[index],
                  showIt: paymentMethods[index] ==
                      widget.currentUser!.getSelectedPaymentMethod!,
                  address: showAddedPaymentAddress[index],
                ),
              ),
            ),
          Visibility(
            visible: widget.currentUser!.getSelectedPaymentMethod == null,
            child: ContainerCorner(
              color: isDark ? kContentDarkShadow : kGrayColor.withOpacity(0.1),
              marginTop: 15,
              marginLeft: 15,
              marginRight: 15,
              borderRadius: 10,
              height: 40,
              onTap: () async {
                UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                  context,
                  PaymentMethodScreen(
                    currentUser: widget.currentUser,
                  ),
                );
                if (user != null) {
                  widget.currentUser = user;
                  setState(() {});
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWithTap(
                    "withdraw_screen.add_payment_method".tr(),
                    color: kGrayColor,
                    marginLeft: 10,
                    fontSize: 11,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: kGrayColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
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
              onTap: () {
                confirmWithdraw();
              },
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
                UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
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
              child: TextWithTap(
                "coins_and_points_screen.exchange_point_for_coins".tr(),
                marginLeft: 10,
                color: kPrimaryColor,
              ),
            ),
          ),
          TextWithTap(
            "withdraw_screen.withdraw_rules".tr(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            marginLeft: 15,
            marginTop: 20,
            marginBottom: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Table(
              border: TableBorder.all(
                  color: isDark ? Colors.white : kContentColorLightTheme),
              children: [
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: AutoSizeText(
                      "withdraw_screen.exchange_ratio".tr(),
                      maxFontSize: 12.0,
                      minFontSize: 6.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : kContentColorLightTheme,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_jifen_wode.webp",
                          height: 13,
                        ),
                        TextWithTap(
                          "${QuickHelp.checkFundsWithString(amount: "$exchangeRatio")} = 1USD",
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          marginLeft: 5,
                          fontSize: 12,
                          marginRight: 5,
                        ),
                      ],
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: AutoSizeText(
                      "withdraw_screen.minimum_withdrawal_amount".tr(),
                      maxFontSize: 12.0,
                      minFontSize: 6.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : kContentColorLightTheme,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_jifen_wode.webp",
                          height: 13,
                        ),
                        TextWithTap(
                          QuickHelp.checkFundsWithString(
                              amount: "$minimumAmountWithdrawal"),
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                          marginLeft: 5,
                          fontSize: 12,
                          marginRight: 5,
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
          TextWithTap(
            "withdraw_screen.first_rule".tr(namedArgs: {
              "p_coin_percent": "$pCoinPercent",
              "point_percent": "$pointPercent"
            }),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            marginLeft: 15,
            marginTop: 20,
          ),
          TextWithTap(
            "withdraw_screen.second_rule".tr(),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            marginLeft: 15,
            marginTop: 4,
          ),
          TextWithTap(
            "withdraw_screen.third_rule".tr(),
            fontWeight: FontWeight.bold,
            fontSize: 12,
            marginLeft: 15,
            marginTop: 4,
            marginBottom: 20,
          ),
        ],
      ),
    );
  }

  confirmWithdraw() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, newState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWithTap(
                    "withdrawal_method_screen.withdrawal_amount".tr(),
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                  TextWithTap(
                    "\$${QuickHelp.checkFundsWithString(
                      amount: "$money",
                    )}",
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    marginTop: 20,
                    marginBottom: 10,
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
                          if (widget.currentUser!.getDiamonds! <
                              minimumAmountWithdrawal) {
                            QuickHelp.showAppNotificationAdvanced(
                              context: context,
                              title: "error".tr(),
                              message:
                                  "withdrawal_method_screen.minimum_withdrawal_withdrawal"
                                      .tr(namedArgs: {
                                "amount": "\$${(minimumAmountWithdrawal/exchangeRatio)}"
                              }),
                            );
                          } else {
                            withdrawMoney();
                          }
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

  Widget addedPaymentOptions(
      {required String title,
      required String icon,
      required bool showIt,
      required String address}) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Visibility(
      visible: showIt,
      child: ContainerCorner(
        borderRadius: 8,
        width: size.width,
        marginTop: 10,
        marginLeft: 10,
        marginRight: 10,
        color: kGrayColor.withOpacity(0.1),
        onTap: () async {
          UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
            context,
            PaymentMethodScreen(
              currentUser: widget.currentUser,
            ),
          );
          if (user != null) {
            widget.currentUser = user;
            setState(() {});
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        icon,
                        height: 30,
                        width: 30,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            title,
                            marginBottom: 10,
                            fontSize: size.width / 23,
                          ),
                          Row(
                            children: [
                              ContainerCorner(
                                color: kPrimaryColor.withOpacity(0.2),
                                borderRadius: 2,
                                child: TextWithTap(
                                  "withdrawal_method_screen.fee_"
                                      .tr(namedArgs: {"amount": "1.5"}),
                                  color: kPrimaryColor,
                                  marginLeft: 5,
                                  marginRight: 5,
                                  marginTop: 2,
                                  marginBottom: 2,
                                  textAlign: TextAlign.center,
                                  alignment: Alignment.center,
                                  fontSize: 8,
                                ),
                              ),
                              ContainerCorner(
                                color: kPrimaryColor.withOpacity(0.2),
                                marginLeft: 5,
                                borderRadius: 2,
                                child: TextWithTap(
                                  "withdrawal_method_screen.arrival_time"
                                      .tr(namedArgs: {"amount": "24"}),
                                  color: kPrimaryColor,
                                  marginLeft: 5,
                                  marginRight: 5,
                                  marginTop: 2,
                                  marginBottom: 2,
                                  textAlign: TextAlign.center,
                                  alignment: Alignment.center,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.change_circle_outlined,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Divider(
                  height: 10,
                  color: isDark ? kContentDarkShadow : kGrayWhite,
                ),
              ),
              TextWithTap(
                address,
                color: kGrayColor,
                marginLeft: 15,
                marginTop: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  withdrawMoney() async {
    QuickHelp.showLoadingDialog(context);

    WithdrawModel withdraw = WithdrawModel();

    withdraw.setAuthor = widget.currentUser!;
    withdraw.setStatus = WithdrawModel.PENDING;

    withdraw.setCompleted = false;
    withdraw.setMethod = widget.currentUser!.getSelectedPaymentMethod!;
    withdraw.setDiamonds = widget.currentUser!.getDiamonds!;
    withdraw.setCredit = widget.currentUser!.getDiamonds! + 0.0;
    withdraw.setCurrency = WithdrawModel.CURRENCY;

    if (widget.currentUser!.getSelectedPaymentMethod ==
        WithdrawModel.BnbSmartChain) {
      withdraw.setWalletAddress = widget.currentUser!.getWalletAddress!;
    } else if (widget.currentUser!.getSelectedPaymentMethod ==
        WithdrawModel.PAYPAL) {
      withdraw.setPayPalName = widget.currentUser!.getPayPalName!;
      withdraw.setPayPalEmail = widget.currentUser!.getPayPalEmail!;
    } else if (widget.currentUser!.getSelectedPaymentMethod ==
        WithdrawModel.USDT) {
      withdraw.setAddress = widget.currentUser!.getUsdtContactAddress!;
    } else if (widget.currentUser!.getSelectedPaymentMethod ==
        WithdrawModel.PAYONEER) {
      withdraw.setPayoneerName = widget.currentUser!.getPayoneerName!;
      withdraw.setPayoneerEmail = widget.currentUser!.getPayoneerEmail!;
    }

    widget.currentUser!.removeDiamonds = widget.currentUser!.getDiamonds!;
    await widget.currentUser!.save().then((value) async {
      ParseResponse response = await withdraw.save();

      if (response.success) {
        setState(() {
          widget.currentUser = value.results!.first! as UserModel;
        });
        QuickHelp.hideLoadingDialog(context, result: widget.currentUser);
        Navigator.of(context).pop(widget.currentUser);
      }
    });
  }
}
