import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/models/WithdrawModel.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

// ignore: must_be_immutable
class WithdrawHistoryScreen extends StatefulWidget {
  static const String route = '/money/withdraw';

  UserModel? currentUser;

  WithdrawHistoryScreen({this.currentUser});

  @override
  _WithdrawHistoryScreenState createState() => _WithdrawHistoryScreenState();
}

class _WithdrawHistoryScreenState extends State<WithdrawHistoryScreen> {

  var _future;

  @override
  void initState() {

    _future = _loadHistory();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ToolBar(
        title: "page_title.withdraw_history_title".tr(),
        centerTitle: QuickHelp.isAndroidPlatform() ? false : true,
        leftButtonIcon: Icons.arrow_back_ios,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
        elevation: QuickHelp.isAndroidPlatform() ? 2 : 1,
        child: SafeArea(
          child: Container(child: getHistory()),
        ));
  }

  Widget getHistory() {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return QuickHelp.appLoading();
          } else if (snapshot.hasData) {
            var results = snapshot.data as List<dynamic>;

            if (results.isNotEmpty) {
              
              
              return Column(
                children: [

                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        WithdrawModel withdrawModel = results[index];

                        return ContainerCorner(
                          width: MediaQuery.of(context).size.width,
                          marginAll: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                children: [
                                  ContainerCorner(
                                    borderRadius: 50,
                                    borderWidth: 2,
                                    borderColor: QuickHelp.isDarkMode(context)
                                        ? kContentColorDarkTheme.withOpacity(0.5)
                                        : kContentColorLightTheme.withOpacity(0.5),
                                    height: 50,
                                    width: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: SvgPicture.asset(
                                          getMethodIcon(withdrawModel.getMethod!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          TextWithTap(
                                            getMethodStatus(withdrawModel),
                                            fontSize: 14,
                                            marginLeft: 5,
                                            marginRight: 5,
                                            color: getMethodStatusColor(withdrawModel),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          Visibility(
                                              visible: getMethodStatusColorPay(withdrawModel),
                                              child: TextWithTap("-")),
                                          Visibility(
                                            visible: getMethodStatusColorPay(withdrawModel),
                                            child: TextWithTap(
                                              "withdraw_history.withdraw_pay_date".tr(namedArgs: {
                                                "date" : QuickHelp.getMessageTime(getPaymentDate(withdrawModel), time: false),
                                              }),
                                              fontSize: 14,
                                              marginLeft: 5,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      TextWithTap(
                                        getMethodAccount(withdrawModel),
                                        fontSize: 14,
                                        marginLeft: 5,
                                        color: kDisabledGrayColor,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWithTap(
                                    "- ${withdrawModel.getCredit!.toStringAsFixed(2)} ${withdrawModel.getCurrency}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextWithTap(
                                    "withdraw_history.withdraw_diamonds"
                                        .tr(namedArgs: {
                                      "diamonds": withdrawModel.getDiamonds.toString()
                                    }),
                                    fontSize: 14,
                                    color: kDisabledGrayColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  ContainerCorner(
                    color: kDisabledGrayColor,
                    borderRadius: 20,
                    child: TextWithTap(
                      "withdraw_history.withdraw_paid_note".tr(),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      marginRight: 10,
                      marginLeft: 10,
                      marginBottom: 5,
                      marginTop: 5,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            } else {
              return ContainerCorner(
                width: size.width,
                height: size.height,
                borderWidth: 0,
                child: Center(child: Image.asset("assets/images/szy_kong_icon.png")),
              );
            }
          } else {
            return ContainerCorner(
              width: size.width,
              height: size.height,
              borderWidth: 0,
              child: Center(child: Image.asset("assets/images/szy_kong_icon.png")),
            );
          }
        });
  }


  DateTime getPaymentDate(WithdrawModel withdraw){
    DateTime createdDate = withdraw.createdAt!;

    var finalDate;

    if(createdDate.day <= 15){

      finalDate = createdDate.add(Duration(days: 35 - createdDate.day));

    } else if(createdDate.day > 15){

      finalDate = createdDate.add(Duration(days: 21));
    }

    return finalDate;
  }

  String getMethodIcon(String method) {
    if (method == WithdrawModel.PAYPAL) {
      return "assets/svg/ic_paypal_icon.svg";
    } else if (method == WithdrawModel.PAYONEER) {
      return "assets/svg/ic_payoneer_icon.svg";
    } else if (method == WithdrawModel.IBAN) {
      return "assets/svg/ic_bank_icon.svg";
    }

    return "";
  }

  String getMethodAccount(WithdrawModel withdraw) {
    if (withdraw.getMethod == WithdrawModel.PAYPAL) {
      return "${withdraw.getEmail}";
    } else if (withdraw.getMethod == WithdrawModel.PAYONEER) {
      return "${withdraw.getEmail}";
    } else if (withdraw.getMethod == WithdrawModel.IBAN) {
      return "${withdraw.getIBAN}";
    }

    return "";
  }

  String getMethod(WithdrawModel withdraw) {
    if (withdraw.getMethod == WithdrawModel.PAYPAL) {
      return "PayPal";
    } else if (withdraw.getMethod == WithdrawModel.PAYONEER) {
      return "Payoneer";
    } else if (withdraw.getMethod == WithdrawModel.IBAN) {
      return "Bank";
    }

    return "";
  }

  String getMethodStatus(WithdrawModel withdraw) {
    if (withdraw.getStatus == WithdrawModel.PENDING) {
      return "withdraw_history.withdraw_pending".tr();
    } else if (withdraw.getStatus == WithdrawModel.PROCESSING) {
      return "withdraw_history.withdraw_processing".tr();
    } else if (withdraw.getStatus == WithdrawModel.COMPLETED) {
      return "withdraw_history.withdraw_completed".tr();
    } else if (withdraw.getStatus == WithdrawModel.REFUSED) {
      return "withdraw_history.withdraw_refused".tr();
    }

    return withdraw.getMethod!;
  }

  Color? getMethodStatusColor(WithdrawModel withdraw) {
    if (withdraw.getStatus == WithdrawModel.PENDING) {
      return null;
    } else if (withdraw.getStatus == WithdrawModel.PROCESSING) {
      return Colors.orangeAccent;
    } else if (withdraw.getStatus == WithdrawModel.COMPLETED) {
      return Colors.green;
    } else if (withdraw.getStatus == WithdrawModel.REFUSED) {
      return Colors.redAccent;
    }

    return null;
  }

  bool getMethodStatusColorPay(WithdrawModel withdraw) {
    if (withdraw.getStatus == WithdrawModel.PENDING) {
      return false;
    } else if (withdraw.getStatus == WithdrawModel.PROCESSING) {
      return true;
    } else if (withdraw.getStatus == WithdrawModel.COMPLETED) {
      return true;
    } else if (withdraw.getStatus == WithdrawModel.REFUSED) {
      return false;
    }
    return false;
  }

  Future<List<dynamic>?> _loadHistory() async {
    QueryBuilder<WithdrawModel> queryBuilder =
        QueryBuilder<WithdrawModel>(WithdrawModel());
    queryBuilder.whereEqualTo(WithdrawModel.keyAuthor, widget.currentUser);
    queryBuilder.setLimit(50);

    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success) {
      if (apiResponse.results != null) {
        return apiResponse.results;
      } else {
        return [];
      }
    } else {
      return null;
    }
  }
}
