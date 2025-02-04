// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/CoinsTransactionsModel.dart';

import '../../helpers/quick_help.dart';
import '../../models/TradingCoinsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class TradingDetailsScreen extends StatefulWidget {
  UserModel? currentUser;

  TradingDetailsScreen({this.currentUser, super.key});

  @override
  State<TradingDetailsScreen> createState() => _TradingDetailsScreenState();
}

class _TradingDetailsScreenState extends State<TradingDetailsScreen>
    with TickerProviderStateMixin {
  late TabController tabControl;
  int tabsLength = 3;
  int initialTab = 0;
  int tabIndex = 0;

  var tabsTitles = [
    "trading_details_screen.all_".tr(),
    "trading_details_screen.gains_".tr(),
    "trading_details_screen.expenses_".tr(),
  ];

  String updateCoinsTradingList = "";

  @override
  void initState() {
    super.initState();
    tabControl =
        TabController(vsync: this, length: tabsLength, initialIndex: initialTab)
          ..addListener(() {
            setState(() {
              tabIndex = tabControl.index;
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    tabControl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "trading_details_screen.details_".tr(),
          fontSize: 15,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: TabBar(
            isScrollable: true,
            enableFeedback: false,
            controller: tabControl,
            dividerColor: kTransparentColor,
            unselectedLabelColor: kGrayColor,
            dragStartBehavior: DragStartBehavior.down,
            indicatorWeight: 0.0,
            labelPadding: EdgeInsets.symmetric(
              horizontal: 25.0,
            ),
            automaticIndicatorColorAdjustment: false,
            labelColor: isDark ? Colors.white : Colors.black,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            labelStyle: TextStyle(fontSize: 16),
            unselectedLabelStyle: TextStyle(fontSize: 14),
            tabs: List.generate(
              tabsTitles.length,
              (index) {
                return TextWithTap(tabsTitles[index]);
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
        child: TabBarView(
          controller: tabControl,
          children: [
            getAllCoinsTrading(),
            getGainsCoinsTrading(),
            getExpensesCoinsTrading(),
          ],
        ),
      ),
    );
  }

  Widget getExpensesCoinsTrading() {

    QueryBuilder<TradingCoinsModel> queryBuilder =
    QueryBuilder<TradingCoinsModel>(TradingCoinsModel());

    queryBuilder.whereEqualTo(
        CoinsTransactionsModel.keyAuthorId, widget.currentUser!.objectId);

    queryBuilder.orderByDescending(TradingCoinsModel.keyCreatedAt);
    queryBuilder.includeObject(
        [TradingCoinsModel.keyAuthor, TradingCoinsModel.keyReceiver]);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ParseLiveListWidget<TradingCoinsModel>(
        query: queryBuilder,
        key: Key(updateCoinsTradingList),
        reverse: false,
        lazyLoading: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        duration: const Duration(milliseconds: 200),
        scrollPhysics: NeverScrollableScrollPhysics(),
        listeningIncludes: [
          TradingCoinsModel.keyAuthor,
          TradingCoinsModel.keyReceiver
        ],
        padding: EdgeInsets.zero,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<TradingCoinsModel> snapshot) {
          if (snapshot.hasData) {
            TradingCoinsModel transaction = snapshot.loadedData!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        coinTransactionTitle(transaction),
                        fontWeight: FontWeight.w700,
                        marginBottom: 5,
                        fontSize: 15,
                      ),
                      TextWithTap(
                        "trading_details_screen.id_account_type".tr(namedArgs: {
                          "id": transaction.objectId!,
                          "account_type": accountType(transaction),
                        }),
                        fontSize: 12,
                        color: kGrayColor,
                        marginBottom: 5,
                      ),
                      TextWithTap(
                        QuickHelp.getTimeAgoForFeed(transaction.createdAt!),
                        fontSize: 12,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 15,
                            width: 15,
                          ),
                          TextWithTap(
                            "-",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            marginRight: 5,
                            marginLeft: 10,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                                amount: transaction.getAmount.toString()),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ],
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount:
                            "${transaction.getSenderResultCredit}"),
                        fontSize: 15,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
        listLoadingElement: QuickHelp.appLoading(),
        queryEmptyElement: TextWithTap(
          "no_more".tr(),
          fontSize: 13,
          marginTop: 15,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getGainsCoinsTrading() {

    QueryBuilder<TradingCoinsModel> queryBuilder =
    QueryBuilder<TradingCoinsModel>(TradingCoinsModel());

    queryBuilder.whereEqualTo(
        CoinsTransactionsModel.keyReceiverId, widget.currentUser!.objectId);

    queryBuilder.orderByDescending(TradingCoinsModel.keyCreatedAt);
    queryBuilder.includeObject(
        [TradingCoinsModel.keyAuthor, TradingCoinsModel.keyReceiver]);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ParseLiveListWidget<TradingCoinsModel>(
        query: queryBuilder,
        key: Key(updateCoinsTradingList),
        reverse: false,
        lazyLoading: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        duration: const Duration(milliseconds: 200),
        scrollPhysics: NeverScrollableScrollPhysics(),
        listeningIncludes: [
          TradingCoinsModel.keyAuthor,
          TradingCoinsModel.keyReceiver
        ],
        padding: EdgeInsets.zero,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<TradingCoinsModel> snapshot) {
          if (snapshot.hasData) {
            TradingCoinsModel transaction = snapshot.loadedData!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        coinTransactionTitle(transaction),
                        fontWeight: FontWeight.w700,
                        marginBottom: 5,
                        fontSize: 15,
                      ),
                      TextWithTap(
                        "trading_details_screen.id_account_type".tr(namedArgs: {
                          "id": transaction.objectId!,
                          "account_type": accountType(transaction),
                        }),
                        fontSize: 12,
                        color: kGrayColor,
                        marginBottom: 5,
                      ),
                      TextWithTap(
                        QuickHelp.getTimeAgoForFeed(transaction.createdAt!),
                        fontSize: 12,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 15,
                            width: 15,
                          ),
                          TextWithTap(
                            "+",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            marginRight: 5,
                            marginLeft: 10,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                                amount: transaction.getAmount.toString()),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ],
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount:
                            "${transaction.getReceiverResultCredit}"),
                        fontSize: 15,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
        listLoadingElement: QuickHelp.appLoading(),
        queryEmptyElement: TextWithTap(
          "no_more".tr(),
          fontSize: 13,
          marginTop: 15,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget getAllCoinsTrading() {
    QueryBuilder<TradingCoinsModel> queryAuthor =
        QueryBuilder<TradingCoinsModel>(TradingCoinsModel());

    queryAuthor.whereEqualTo(
        CoinsTransactionsModel.keyAuthorId, widget.currentUser!.objectId);

    QueryBuilder<TradingCoinsModel> queryReceiver =
        QueryBuilder<TradingCoinsModel>(TradingCoinsModel());

    queryReceiver.whereEqualTo(
        CoinsTransactionsModel.keyReceiverId, widget.currentUser!.objectId);

    QueryBuilder<TradingCoinsModel> queryBuilder =
        QueryBuilder<TradingCoinsModel>(TradingCoinsModel());

    queryBuilder =
        QueryBuilder.or(TradingCoinsModel(), [queryAuthor, queryReceiver]);
    queryBuilder.orderByDescending(TradingCoinsModel.keyCreatedAt);
    queryBuilder.includeObject(
        [TradingCoinsModel.keyAuthor, TradingCoinsModel.keyReceiver]);

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ParseLiveListWidget<TradingCoinsModel>(
        query: queryBuilder,
        key: Key(updateCoinsTradingList),
        reverse: false,
        lazyLoading: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        duration: const Duration(milliseconds: 200),
        scrollPhysics: NeverScrollableScrollPhysics(),
        listeningIncludes: [
          TradingCoinsModel.keyAuthor,
          TradingCoinsModel.keyReceiver
        ],
        padding: EdgeInsets.zero,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<TradingCoinsModel> snapshot) {
          if (snapshot.hasData) {
            TradingCoinsModel transaction = snapshot.loadedData!;
            bool iSend =
                transaction.getAuthorId == widget.currentUser!.objectId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                        coinTransactionTitle(transaction),
                        fontWeight: FontWeight.w700,
                        marginBottom: 5,
                        fontSize: 15,
                      ),
                      TextWithTap(
                        "trading_details_screen.id_account_type".tr(namedArgs: {
                          "id": transaction.objectId!,
                          "account_type": accountType(transaction),
                        }),
                        fontSize: 12,
                        color: kGrayColor,
                        marginBottom: 5,
                      ),
                      TextWithTap(
                        QuickHelp.getTimeAgoForFeed(transaction.createdAt!),
                        fontSize: 12,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/icon_jinbi.png",
                            height: 15,
                            width: 15,
                          ),
                          TextWithTap(
                            transactionSymbol(transaction),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            marginRight: 5,
                            marginLeft: 10,
                          ),
                          TextWithTap(
                            QuickHelp.checkFundsWithString(
                                amount: transaction.getAmount.toString()),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ],
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount:
                                "${iSend ? transaction.getSenderResultCredit : transaction.getReceiverResultCredit}"),
                        fontSize: 15,
                        color: kGrayColor,
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
        listLoadingElement: QuickHelp.appLoading(),
        queryEmptyElement: TextWithTap(
          "no_more".tr(),
          fontSize: 13,
          marginTop: 15,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String transactionSymbol(TradingCoinsModel coinsTrading) {
    if (coinsTrading.getReceiverId == widget.currentUser!.objectId) {
      return "+";
    } else {
      return "-";
    }
  }

  String accountType(TradingCoinsModel coinsTrading) {
    if (coinsTrading.getReceiver!.getAgencyRole == UserModel.agencyAgentRole) {
      return "coins_trading_screen.agent_account".tr();
    } else {
      return "coins_trading_screen.coins_account".tr();
    }
  }

  String coinTransactionTitle(TradingCoinsModel coinsTrading) {
    if (coinsTrading.getAuthorId == widget.currentUser!.objectId) {
      return "trading_details_screen.transfer_to_receiver"
          .tr(namedArgs: {"receiver": coinsTrading.getReceiver!.getUsername!});
    } else {
      return "trading_details_screen.transfer_to_me"
          .tr(namedArgs: {"sender": coinsTrading.getAuthor!.getUsername!});
    }
  }
}
