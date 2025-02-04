// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/coins_trading/select_receiver_screen.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/TradingCoinsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../coins/refill_coins_screen.dart';
import '../exchange_coins/exchange_coins_screen.dart';
import 'details_screen.dart';

class CoinsTradingScreen extends StatefulWidget {
  UserModel? currentUser;

  CoinsTradingScreen({this.currentUser, super.key});

  @override
  State<CoinsTradingScreen> createState() => _CoinsTradingScreenState();
}

class _CoinsTradingScreenState extends State<CoinsTradingScreen> {
  TextEditingController userIdTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();

  UserModel? receiver;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          centerTitle: true,
          title: TextWithTap(
            "coins_trading_screen.agent_account".tr(),
            fontSize: 15,
          ),
          actions: [
            TextButton(
              onPressed: () {
                QuickHelp.goToNavigatorScreen(
                  context,
                  TradingDetailsScreen(
                    currentUser: widget.currentUser!,
                  ),
                );
              },
              child: TextWithTap(
                "coins_trading_screen.details_".tr(),
                color: isDark ? Colors.white : kContentColorLightTheme,
              ),
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.only(left: 10, right: 10, top: 20),
          children: [
            ContainerCorner(
              imageDecoration: "assets/images/trading_coins_bg.png",
              width: size.width,
              borderRadius: 10,
              marginBottom: 60,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/icon_jinbi.png",
                          height: 25,
                          width: 25,
                        ),
                        TextWithTap(
                          "coins_trading_screen.coins_trading".tr(),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          marginLeft: 6,
                          fontSize: size.width / 20,
                        )
                      ],
                    ),
                    TextWithTap(
                      QuickHelp.checkFundsWithString(
                          amount: "${widget.currentUser!.getCredits!}"),
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: size.width / 16,
                      alignment: Alignment.centerLeft,
                      marginTop: 10,
                      marginBottom: 60,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ContainerCorner(
                          borderRadius: 50,
                          borderWidth: 1.2,
                          borderColor: Colors.white,
                          height: 35,
                          marginRight: 10,
                          onTap: () => QuickHelp.goToNavigatorScreen(
                              context,
                              ExchangeCoinsScreen(
                                currentUser: widget.currentUser,
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 8,
                              ),
                              Image.asset(
                                "assets/images/ic_jifen_wode.webp",
                                height: 15,
                                width: 15,
                              ),
                              TextWithTap(
                                "coins_trading_screen.exchange_".tr(),
                                color: Colors.white,
                                marginLeft: 5,
                                alignment: Alignment.center,
                                fontWeight: FontWeight.w800,
                                marginRight: 15,
                              ),
                            ],
                          ),
                        ),
                        ContainerCorner(
                          color: Colors.white,
                          borderRadius: 50,
                          height: 35,
                          onTap: () => QuickHelp.goToNavigatorScreen(
                              context,
                              RefillCoinsScreen(
                                currentUser: widget.currentUser,
                              )),
                          child: TextWithTap(
                            "coins_trading_screen.top_up".tr(),
                            color: kOrangeColor,
                            alignment: Alignment.center,
                            fontWeight: FontWeight.w800,
                            marginRight: 15,
                            marginLeft: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    legend(text: "coins_trading_screen.transfer_to".tr()),
                    ContainerCorner(
                      color: isDark
                          ? kContentDarkShadow
                          : kGrayColor.withOpacity(0.05),
                      borderRadius: 10,
                      marginTop: 5,
                      width: size.width / 1.7,
                      marginBottom: 30,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (text) {},
                                maxLines: 1,
                                controller: userIdTextController,
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return "coins_trading_screen.user_id".tr();
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "coins_trading_screen.user_id".tr(),
                                  border: InputBorder.none,
                                  hintStyle:
                                      TextStyle(fontSize: size.width / 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: IconButton(
                                onPressed: () async {
                                  UserModel? user = await QuickHelp
                                      .goToNavigatorScreenForResult(
                                          context,
                                          SelectReceiver(
                                            currentUser: widget.currentUser,
                                          ));

                                  if (user != null) {
                                    setState(() {
                                      receiver = user;
                                      userIdTextController.text =
                                          receiver!.getUid!.toString();
                                    });
                                  }
                                },
                                icon: Icon(
                                  Icons.perm_contact_calendar_outlined,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    legend(
                      text: "coins_trading_screen.transfer_amount".tr(),
                      fontSize: size.width / 20,
                    ),
                    ContainerCorner(
                      color: isDark
                          ? kContentDarkShadow
                          : kGrayColor.withOpacity(0.05),
                      borderRadius: 10,
                      marginTop: 5,
                      width: size.width / 1.7,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Image.asset(
                                "assets/images/icon_jinbi.png",
                                height: 20,
                                width: 20,
                              ),
                            ),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                onChanged: (text) {},
                                maxLines: 1,
                                controller: amountTextController,
                                validator: (text) {
                                  if (text!.isEmpty) {
                                    return "coins_trading_screen.enter_coins_amount"
                                        .tr();
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      "coins_trading_screen.enter_coins_amount"
                                          .tr(),
                                  border: InputBorder.none,
                                  hintStyle:
                                      TextStyle(fontSize: size.width / 23),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
        bottomNavigationBar: ContainerCorner(
          height: 45,
          borderRadius: 50,
          color: kPrimaryColor,
          marginLeft: 15,
          marginRight: 15,
          onTap: () {
            if (formKey.currentState!.validate()) {
              transferCoins();
            }
          },
          child: TextWithTap(
            "coins_trading_screen.transfer_".tr(),
            color: Colors.white,
            alignment: Alignment.center,
            fontWeight: FontWeight.w500,
            fontSize: size.width / 20,
          ),
        ),
      ),
    );
  }

  Widget legend({required String text, double fontSize = 12}) {
    return Row(
      children: [
        TextWithTap(
          "*",
          color: Colors.red,
        ),
        TextWithTap(
          text,
          fontSize: fontSize,
        ),
      ],
    );
  }

  transferCoins() {
    if (widget.currentUser!.getCredits! >=
        int.parse(amountTextController.text)) {
      if (receiver == null) {
        getReceiver();
      } else {
        saveTransfer(receiver: receiver!);
      }
    } else {
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        message: "guardian_and_vip_screen.coins_not_enough".tr(),
        context: context,
      );
    }
  }

  getReceiver() async {
    QuickHelp.showLoadingDialog(context);

    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());

    queryBuilder.whereEqualTo(UserModel.keyObjectId, userIdTextController.text);
    queryBuilder.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);

    ParseResponse response = await queryBuilder.query();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        receiver = response.results!.first;
      });
      saveTransfer(receiver: receiver!);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "qr_code.user_not_found".tr(),
      );
    }
  }

  saveTransfer({required UserModel receiver}) async {
    QuickHelp.showLoadingDialog(context);

    TradingCoinsModel tradingCoins = TradingCoinsModel();

    int senderResult =
        widget.currentUser!.getCredits! - int.parse(amountTextController.text);
    int receiverResult =
        receiver.getCredits! + int.parse(amountTextController.text);

    tradingCoins.setAuthor = widget.currentUser!;
    tradingCoins.setAuthorId = widget.currentUser!.objectId!;

    tradingCoins.setReceiver = receiver;
    tradingCoins.setReceiverId = receiver.objectId!;

    tradingCoins.setAmount = int.parse(amountTextController.text);

    tradingCoins.setSenderResultCredit = senderResult;
    tradingCoins.setReceiverResultCredit = receiverResult;

    ParseResponse response = await tradingCoins.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      updateMyCredit();
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  updateMyCredit() async {

    QuickHelp.showLoadingDialog(context);
    widget.currentUser!.removeCredit = int.parse(amountTextController.text);
    widget.currentUser!.setTradingCoinsReceivers = receiver!.objectId!;

    ParseResponse response = await widget.currentUser!.save();
    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        widget.currentUser = response.results!.first;
        userIdTextController.text = "";
        amountTextController.text = "";
      });
      QuickHelp.showAppNotificationAdvanced(
        title: "done".tr(),
        context: context,
        message: "operation_completed_successfully".tr(),
        isError: false,
      );
    } else {
      QuickHelp.showLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }
}
