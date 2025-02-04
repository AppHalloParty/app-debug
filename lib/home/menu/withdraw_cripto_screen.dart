// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';

import '../../models/WithdrawModel.dart';
import '../../ui/text_with_tap.dart';

class WithdrawCryptoScreen extends StatefulWidget {
  static String route = "/withdraw/crypto";
  UserModel? currentUser;
  WithdrawCryptoScreen({ Key? key, this.currentUser}) : super(key: key);

  @override
  State<WithdrawCryptoScreen> createState() => _WithdrawCryptoScreenState();
}

class _WithdrawCryptoScreenState extends State<WithdrawCryptoScreen> {
  TextEditingController addressTextController = TextEditingController();
  TextEditingController amountTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String networkText = "withdraw_to_crypto.select_network".tr();
  String networkSelected = "";
  double totalMoney = 0.0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    totalMoney = QuickHelp.convertDiamondsToMoney(widget.currentUser!.getDiamonds!);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kTransparentColor,
          automaticallyImplyLeading: false,
          leading: BackButton(color: kGrayColor,),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                      "withdraw_to_crypto.send_usdt".tr(),
                    fontSize: size.width / 15,
                    fontWeight: FontWeight.w900,
                  ),
                  TextWithTap(
                      "withdraw_to_crypto.send_usdt_address".tr(),
                    marginTop: 3,
                  ),
                  addressTextField(),
                  network(),
                  amountTextField()
              ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 20, left: 15, right: 15),
          child: ContainerCorner(
            color: kGreenColor,
            borderRadius: 50,
            height: 50,
            child: Center(child: TextWithTap("withdraw_to_crypto.send_usdt".tr(), color: Colors.white,),),
            onTap: () {
              if (formKey.currentState!.validate()) {
                if(networkSelected.isEmpty){
                  openNetworkChooser();
                }else if(double.parse(amountTextController.text) > double.parse(totalMoney.toStringAsFixed(0))){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                "assets/svg/sad.svg",
                                height: 70,
                                width: 70,
                              ),
                              TextWithTap(
                                "get_money.not_enough".tr(namedArgs: {"money": totalMoney.toStringAsFixed(0)}),
                                textAlign: TextAlign.center,
                                color: Colors.red,
                                marginTop: 20,
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ContainerCorner(
                                    child: TextButton(
                                      child: TextWithTap("cancel".tr().toUpperCase(),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    color: kRedColor1,
                                    borderRadius: 10,
                                    marginLeft: 5,
                                    width: 125,
                                  ),
                                  ContainerCorner(
                                    child: TextButton(
                                      child: TextWithTap("get_money.try_again".tr().toUpperCase(),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      onPressed: ()=> Navigator.of(context).pop(),
                                    ),
                                    color: kGreenColor,
                                    borderRadius: 10,
                                    marginRight: 5,
                                    width: 125,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        );
                      });
                }else{
                  saveWithdraw();
                }
              }
            },
          ),
        ),
      ),
    );
  }

  void openNetworkChooser() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isDismissible: true,
        builder: (context) {
          return _showListOfNetWorks();
        });
  }

  Widget _showListOfNetWorks() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                Size size = MediaQuery.of(context).size;
                return Container(
                  decoration: const BoxDecoration(
                    color: kTransparentColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: Scaffold(
                    backgroundColor: kTransparentColor,
                    body: ContainerCorner(
                      borderRadius: 10,
                      color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            TextWithTap(
                                "withdraw_to_crypto.network_advise".tr(),
                              alignment: Alignment.center,
                              textAlign: TextAlign.center,
                              marginRight: 10,
                              marginLeft: 10,
                              marginTop: 20,
                              marginBottom: 20,
                            ),
                            ContainerCorner(
                              height: 50,
                              color: kGrayColor.withOpacity(0.1),
                              marginBottom: 10,
                              borderRadius: 4,
                              onTap: ()=> selectNetWork(WithdrawModel.ethereum),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.ethereum_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              color: kGrayColor.withOpacity(0.1),
                              marginBottom: 10,
                              borderRadius: 4,
                              onTap: ()=> selectNetWork(WithdrawModel.polygon),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.polygon_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              marginBottom: 10,
                              color: kGrayColor.withOpacity(0.1),
                              borderRadius: 4,
                              onTap: ()=> selectNetWork(WithdrawModel.solana),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.solana_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ContainerCorner(
                              height: 50,
                              marginBottom: 10,
                              color: kGrayColor.withOpacity(0.1),
                              borderRadius: 4,
                              onTap: () => selectNetWork(WithdrawModel.tron),
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10,
                                    right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextWithTap(
                                      "withdraw_to_crypto.tron_".tr(),
                                      color: kGrayColor,
                                      fontSize: size.width / 23,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  selectNetWork(String network) {
    setState(() {
      networkSelected = network;
    });
    QuickHelp.goBackToPreviousPage(context);
  }



  Widget addressTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.address_".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          child: Padding(
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
            child: TextFormField(
              controller: addressTextController,
              keyboardType: TextInputType.text,
              cursorColor: kGrayColor,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "withdraw_to_crypto.address_hint".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "withdraw_to_crypto.address_required".tr();
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget amountTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.amount".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          child: Padding(
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
            child: TextFormField(
              controller: amountTextController,
              keyboardType: TextInputType.number,
              cursorColor: kGrayColor,
              autocorrect: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "withdraw_to_crypto.amount_hint".tr(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "withdraw_to_crypto.amount_required".tr();
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget network() {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWithTap(
          "withdraw_to_crypto.network_".tr(),
          marginTop: 20,
          marginBottom: 5,
        ),
        ContainerCorner(
          height: 50,
          color: kGrayColor.withOpacity(0.3),
          borderRadius: 4,
          onTap: () => openNetworkChooser(),
          child: Padding(
            padding: EdgeInsets.only(
                left: 10,
                right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWithTap(networkSelected.isEmpty ?
                  networkText : networkSelected,
                  color: kGrayColor,
                  fontSize: size.width / 23,
                ),
                Icon(Icons.arrow_forward_ios, color: kGrayColor,)
              ],
            ),
          ),
        ),
      ],
    );
  }

  saveWithdraw() async{
    QuickHelp.showLoadingDialog(context);

    WithdrawModel withdraw = WithdrawModel();
    withdraw.setAddress = addressTextController.text;
    withdraw.setNetWork = networkSelected;
    withdraw.setCredit = double.parse(amountTextController.text);
    int diamonds = QuickHelp.convertMoneyToDiamonds(double.parse(amountTextController.text)).toInt();
    withdraw.setAuthor = widget.currentUser!;
    withdraw.setStatus = WithdrawModel.PENDING;

    withdraw.setCompleted = false;
    withdraw.setMethod = WithdrawModel.USDT;
    withdraw.setDiamonds = diamonds;
    withdraw.setCurrency = WithdrawModel.CURRENCY;

    ParseResponse response = await withdraw.save();

    if(response.success && response.result != null){
      //sentToCloudCode();
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "withdraw_to_crypto.withdraw_succeed_title".tr(),
        context: context,
        message: "withdraw_to_crypto.withdraw_succeed_explain".tr(),
        isError: false,
      );

    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "withdraw_to_crypto.withdraw_failed_title".tr(),
          context: context,
          message: "withdraw_to_crypto.withdraw_failed_explain".tr()
      );
    }
  }


  /*sentToCloudCode() async{
    ParseResponse response = await QuickCloudCode.sendToUSDT(
        user: widget.currentUser!, address: addressTextController.text,
        amount: amountTextController.text, network: networkSelected);

    if(response.success && response.result != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "withdraw_to_crypto.withdraw_succeed_title".tr(),
          context: context,
          message: "withdraw_to_crypto.withdraw_succeed_explain".tr(),
          isError: false,
      );
    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "withdraw_to_crypto.withdraw_failed_title".tr(),
          context: context,
          message: "withdraw_to_crypto.withdraw_failed_explain".tr()
      );
    }
  }*/
}
