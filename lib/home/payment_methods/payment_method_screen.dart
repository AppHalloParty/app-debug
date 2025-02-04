// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/home/payment_methods/add_payoneer_payment_method_screen.dart';
import 'package:trace/home/payment_methods/preferred_payment_screen.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/PaymentSourceModel.dart';
import '../../models/UserModel.dart';
import '../../models/WithdrawModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'add_BNB_smart_chain_payment_method_screen.dart';
import 'add_paypal_payment_method_screen.dart';
import 'add_usdt_payment_method_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  UserModel? currentUser;

  PaymentMethodScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  var selectedMethod = [];
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

  var bindPaymentsMethodScreen = [];
  var showBindPayment = [];
  var showAddedPayment = [];
  var showAddedPaymentAddress = [];


  @override
  void initState() {
    super.initState();
    selectedMethod.add(widget.currentUser!.getSelectedPaymentMethod ?? "");
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    showBindPayment = [
      widget.currentUser!.getWalletAddress == null,
      widget.currentUser!.getPayPalEmail == null,
      widget.currentUser!.getUsdtContactAddress == null,
      widget.currentUser!.getPayoneerEmail == null,
    ];

    showAddedPayment = [
      widget.currentUser!.getWalletAddress != null,
      widget.currentUser!.getPayPalEmail != null,
      widget.currentUser!.getUsdtContactAddress != null,
      widget.currentUser!.getPayoneerEmail != null,
    ];

    showAddedPaymentAddress = [
      widget.currentUser!.getWalletAddress ?? "",
      widget.currentUser!.getPayPalEmail ?? "",
      widget.currentUser!.getUsdtContactAddress ?? "",
      widget.currentUser!.getPayoneerEmail ?? "",
    ];

    bindPaymentsMethodScreen = [
      AddBNBSmartChainMethodScreen(
        currentUser: widget.currentUser,
      ),
      AddPaypalMethodScreen(
        currentUser: widget.currentUser,
      ),
      AddUSTDMethodScreen(
        currentUser: widget.currentUser,
      ),
      AddPayoneerMethodScreen(
        currentUser: widget.currentUser,
      ),
    ];
    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        title: TextWithTap(
          "withdrawal_method_screen.withdrawal_method".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          Column(
            children: List.generate(
              paymentMethodTitle.length,
              (index) => addPaymentOptions(
                title: paymentMethodTitle[index],
                icon: paymentMethodIcon[index],
                bindPayment: bindPaymentsMethodScreen[index],
                showIt: showBindPayment[index],
              ),
            ),
          ),
          Column(
            children: List.generate(
              paymentMethodTitle.length,
              (index) => addedPaymentOptions(
                title: paymentMethodTitle[index],
                icon: paymentMethodIcon[index],
                bindPayment: bindPaymentsMethodScreen[index],
                showIt: showAddedPayment[index],
                address: showAddedPaymentAddress[index],
                payment: paymentMethods[index],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              QuickHelp.goToNavigatorScreen(
                  context,
                  PreferredPaymentScreen(
                    currentUser: widget.currentUser,
                  ));
            },
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWithTap(
                  "withdrawal_method_screen.my_preferred_way_for_payment".tr(),
                  marginTop: 20,
                  color: kPrimaryColor,
                  alignment: Alignment.center,
                  textAlign: TextAlign.center,
                  marginRight: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: kPrimaryColor,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addPaymentOptions(
      {required String title,
      required String icon,
      required Widget bindPayment,
      required bool showIt}) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Visibility(
      visible: showIt,
      child: ContainerCorner(
        borderRadius: 8,
        width: size.width,
        marginTop: 10,
        marginLeft: 10,
        marginRight: 10,
        color: isDark ? kContentColorLightTheme : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
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
              ContainerCorner(
                color: kPrimaryColor,
                borderRadius: 50,
                onTap: () async {
                  paymentSourceModel =
                      await QuickHelp.goToNavigatorScreenForResult(
                          context, bindPayment);
                  if (paymentSourceModel != null) {
                    setState(() {
                      paymentSourceModel = paymentSourceModel;
                    });
                  }
                },
                child: TextWithTap(
                  "withdrawal_method_screen.bind_".tr(),
                  color: Colors.white,
                  marginLeft: 8,
                  marginRight: 8,
                  marginTop: 3,
                  marginBottom: 3,
                  textAlign: TextAlign.center,
                  alignment: Alignment.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addedPaymentOptions(
      {required String title,
      required String icon,
      required Widget bindPayment,
      required bool showIt,
      required String address,
      required String payment,
      }) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    bool selected = selectedMethod.contains(payment);
    return Visibility(
      visible: showIt,
      child: ContainerCorner(
        borderRadius: 8,
        width: size.width,
        marginTop: 10,
        marginLeft: 10,
        marginRight: 10,
        color: kGrayColor.withOpacity(0.2),
        borderWidth: 2,
        borderColor: selected ? kPrimaryColor : kTransparentColor,
        onTap: (){
          selectedMethod.clear();
          setState(() {
            selectedMethod.add(payment);
          });
          selectPaymentMethod();
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
                    onPressed: () async {
                      paymentSourceModel =
                          await QuickHelp.goToNavigatorScreenForResult(
                              context, bindPayment);
                      if (paymentSourceModel != null) {
                        setState(() {
                          paymentSourceModel = paymentSourceModel;
                        });
                      }
                    },
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

  selectPaymentMethod() async{
    QuickHelp.showLoadingDialog(context);

    widget.currentUser!.setSelectedPaymentMethod = selectedMethod[0];
    ParseResponse response = await widget.currentUser!.save();
    if(response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      widget.currentUser = response.results!.first!;
      QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);
    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
      setState(() {
        selectedMethod.clear();
      });
    }
  }
}
