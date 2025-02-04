// ignore_for_file: must_be_immutable

import 'package:auto_size_text/auto_size_text.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/ui/container_with_corner.dart';

import '../../helpers/quick_help.dart';
import '../../models/CoinsTransactionsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../coins/refill_coins_screen.dart';

class CoinsAndPointsScreen extends StatefulWidget {
  UserModel? currentUser;
  int? initialIndex;

  CoinsAndPointsScreen(
      {this.initialIndex, this.currentUser, Key? key})
      : super(key: key);

  @override
  State<CoinsAndPointsScreen> createState() => _CoinsAndPointsScreenState();
}

class _CoinsAndPointsScreenState extends State<CoinsAndPointsScreen>
    with TickerProviderStateMixin {
  DateTime dateTime = DateTime.now();
  DateTime? filterCoinsByDate;

  int tabIndex = 0;
  int tabsLength = 2;
  String defaultOption = "coins_and_points_screen.all_".tr();

  String coinTransactionTypeForQuery = "";
  String updateCoinsList = "coins_and_points_screen.all_".tr();

  late TabController generalTabControl;

  var optionTitles = [
    "coins_and_points_screen.all_".tr(),
    "coins_and_points_screen.expenses_".tr(),
    "coins_and_points_screen.gains".tr(),
  ];

  @override
  void initState() {
    super.initState();
    tabIndex = widget.initialIndex ?? 0;
    generalTabControl = TabController(
        vsync: this, length: tabsLength, initialIndex: widget.initialIndex ?? 0)
      ..addListener(() {
        setState(() {
          tabIndex = generalTabControl.index;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    generalTabControl.dispose();
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
          "coins_and_points_screen.coins_".tr(),
        ),
        /*title: TabBar(
          isScrollable: true,
          enableFeedback: false,
          controller: generalTabControl,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: kTransparentColor,
          unselectedLabelColor: kGrayColor,
          indicatorWeight: 2.0,
          labelPadding: EdgeInsets.symmetric(
            horizontal: 7.0,
          ),
          automaticIndicatorColorAdjustment: false,
          labelColor: isDark ? Colors.white : kContentColorLightTheme,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
                width: 3.0,
                color: isDark ? Colors.white : kContentColorLightTheme),
            borderRadius: BorderRadius.all(Radius.circular(50)),
            insets: EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
          ),
          labelStyle: TextStyle(fontSize: 18),
          unselectedLabelStyle: TextStyle(fontSize: 16),
          tabs: [
            TextWithTap(
              "coins_and_points_screen.coins_".tr(),
              marginBottom: 7,
            ),
            TextWithTap(
              "coins_and_points_screen.p_coin".tr(),
              marginBottom: 7,
            ),
          ],
        ),*/
        /*actions: [
          TextButton(
            onPressed: () => QuickHelp.goToNavigatorScreen(
                context,
                PointsScreen(
                  currentUser: widget.currentUser,
                )),
            child: TextWithTap(
              "coins_and_points_screen.points_".tr(),
              color: isDark ? Colors.white : kContentColorLightTheme,
            ),
          ),
        ],*/
      ),
      body: coinsHistory(
        coinBgImageUrl: "assets/images/top_up_image.png",
        btnText: "coins_and_points_screen.top_up".tr(),
        coinsBalance: widget.currentUser!.getCredits!,
        coinsBalanceCaption: "coins_and_points_screen.remaining_coins".tr(),
        coinsBalanceCaptionColor: kOrangeColor,
        transactionList: coinsTransactions(),
        dropDownList: coinsDropDownFilter(),
        screenToGo: RefillCoinsScreen(
          currentUser: widget.currentUser,
        ),
      ),
      /*body: TabBarView(
        controller: generalTabControl,
        children: [
          coinsHistory(
            coinBgImageUrl: "assets/images/top_up_image.png",
            btnText: "coins_and_points_screen.top_up".tr(),
            coinsBalance: widget.currentUser!.getCredits!,
            coinsBalanceCaption: "coins_and_points_screen.remaining_coins".tr(),
            coinsBalanceCaptionColor: kOrangeColor,
            transactionList: coinsTransactions(),
            dropDownList: coinsDropDownFilter(),
            screenToGo: RefillCoinsScreen(
              currentUser: widget.currentUser,
            ),
          ),
          coinsHistory(
            coinBgImageUrl: "assets/images/pcoins_image.png",
            btnText: "coins_and_points_screen.get_for_free".tr(),
            coinsBalance: widget.currentUser!.getCredits!,
            coinsBalanceCaption: "coins_and_points_screen.p_coin_balance".tr(),
            coinsBalanceCaptionColor: kBlueColor,
            transactionList: coinsTransactions(),
            dropDownList: pCoinsDropDownFilter(),
            screenToGo: RewardScreen(
              currentUser: widget.currentUser,
            ),
          ),
        ],
      ),*/
    );
  }

  Widget coinsTransactions() {
    QueryBuilder<CoinsTransactionsModel> queryBuilder =
        QueryBuilder<CoinsTransactionsModel>(CoinsTransactionsModel());
    queryBuilder.whereEqualTo(
        CoinsTransactionsModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.includeObject(
        [CoinsTransactionsModel.keyAuthor, CoinsTransactionsModel.keyReceiver]);
    queryBuilder.orderByDescending(CoinsTransactionsModel.keyCreatedAt);

    if (coinTransactionTypeForQuery ==
        CoinsTransactionsModel.transactionTypeTopUP) {
      queryBuilder.whereEqualTo(CoinsTransactionsModel.keyTransactionType,
          CoinsTransactionsModel.transactionTypeTopUP);
    } else if (coinTransactionTypeForQuery ==
        CoinsTransactionsModel.transactionTypeSent) {
      queryBuilder.whereEqualTo(CoinsTransactionsModel.keyTransactionType,
          CoinsTransactionsModel.transactionTypeSent);
    } else if (filterCoinsByDate != null) {
      queryBuilder.whereEqualTo(
          CoinsTransactionsModel.keyCreatedAt, filterCoinsByDate);
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: ParseLiveListWidget<CoinsTransactionsModel>(
        query: queryBuilder,
        key: Key(updateCoinsList),
        reverse: false,
        lazyLoading: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        duration: const Duration(milliseconds: 200),
        scrollPhysics: NeverScrollableScrollPhysics(),
        listeningIncludes: [
          CoinsTransactionsModel.keyAuthor,
          CoinsTransactionsModel.keyReceiver
        ],
        padding: EdgeInsets.zero,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<CoinsTransactionsModel> snapshot) {
          if (snapshot.hasData) {
            CoinsTransactionsModel transaction = snapshot.loadedData!;
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
                        coinTransactionTitle(
                          isTopUp: transaction.getTransactionType ==
                              CoinsTransactionsModel.transactionTypeTopUP,
                          name: transaction.getReceiver != null
                              ? transaction.getReceiver!.getUsername!
                              : "",
                        ),
                        fontWeight: FontWeight.w900,
                        marginBottom: 5,
                        fontSize: 15,
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
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount: transaction.getTransactedAmount.toString()),
                        fontWeight: FontWeight.w900,
                        marginBottom: 5,
                        fontSize: 15,
                      ),
                      TextWithTap(
                        QuickHelp.checkFundsWithString(
                            amount: "${transaction.getAmountAfterTransaction}"),
                        fontSize: 12,
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

  String coinTransactionTitle({required bool isTopUp, required String name}) {
    if (isTopUp) {
      return "coins_and_points_screen.top_up".tr();
    } else {
      return "coins_and_points_screen.gave_it_to".tr(namedArgs: {"name": name});
    }
  }

  Widget coinsHistory({
    required String coinBgImageUrl,
    required String btnText,
    required int coinsBalance,
    required String coinsBalanceCaption,
    required Color coinsBalanceCaptionColor,
    required Widget transactionList,
    required Widget dropDownList,
    required Widget screenToGo,
  }) {
    Size size = MediaQuery.of(context).size;
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        ContainerCorner(
          borderWidth: 0,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Image.asset(coinBgImageUrl),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Visibility(
                              visible: tabIndex == 0,
                              child: Image.asset(
                                "assets/images/icon_jinbi.png",
                                width: size.width / 13,
                                height: size.width / 13,
                              ),
                            ),
                            TextWithTap(
                              QuickHelp.checkFundsWithString(
                                amount: coinsBalance.toString(),
                              ),
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: size.width / 13,
                              marginLeft: 10,
                            ),
                          ],
                        ),
                        TextWithTap(
                          coinsBalanceCaption,
                          color: Colors.white,
                        )
                      ],
                    ),
                    ContainerCorner(
                      color: Colors.white,
                      borderRadius: 50,
                      onTap: () {
                        QuickHelp.goToNavigatorScreen(context, screenToGo);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 8, bottom: 8),
                        child: AutoSizeText(
                          btnText,
                          maxFontSize: 14.0,
                          minFontSize: 5.0,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: coinsBalanceCaptionColor,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          marginRight: 15,
          marginLeft: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerCorner(
              marginLeft: 15,
              width: size.width / 3,
              child: dropDownList,
            ),
            /*TextButton(
                onPressed: () => showCalendar(),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: isDark ? Colors.white : kContentColorLightTheme,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: AutoSizeText(
                        "coins_and_points_screen.select_date".tr(),
                        maxFontSize: 14.0,
                        minFontSize: 5.0,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark ? Colors.white : kContentColorLightTheme,
                        ),
                        maxLines: 2,
                      ),
                    )
                  ],
                )),*/
          ],
        ),
        transactionList
      ],
    );
  }

  Widget coinsDropDownFilter() {
    return DropdownButton(
      isExpanded: true,
      underline: const SizedBox(),
      value: defaultOption,
      items: optionTitles.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: TextWithTap(items),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          defaultOption = newValue!;
          if (defaultOption == optionTitles[1]) {
            coinTransactionTypeForQuery =
                CoinsTransactionsModel.transactionTypeSent;
          } else if (defaultOption == optionTitles[2]) {
            coinTransactionTypeForQuery =
                CoinsTransactionsModel.transactionTypeTopUP;
          } else {
            coinTransactionTypeForQuery = "";
          }
          updateCoinsList = newValue;
          filterCoinsByDate = null;
        });
      },
    );
  }

  Widget pCoinsDropDownFilter() {
    return DropdownButton(
      isExpanded: true,
      underline: const SizedBox(),
      value: defaultOption,
      items: optionTitles.map((String items) {
        return DropdownMenuItem(
          value: items,
          child: TextWithTap(items),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          if (tabIndex == 0) {
            if (defaultOption == optionTitles[1]) {
              coinTransactionTypeForQuery =
                  CoinsTransactionsModel.transactionTypeSent;
            } else if (defaultOption == optionTitles[2]) {
              coinTransactionTypeForQuery =
                  CoinsTransactionsModel.transactionTypeTopUP;
            } else {
              coinTransactionTypeForQuery = "";
            }
          }
        });
      },
    );
  }

  showCalendar() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
                isDarkMode ? kContentColorLightTheme : Colors.white,
            insetPadding: EdgeInsets.only(left: 10, right: 10),
            content: ContainerCorner(
              height: 400,
              width: size.width,
              child: CalendarDatePicker2WithActionButtons(
                config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDayOfWeek: 1,
                  firstDate: widget.currentUser!.createdAt,
                  lastDate: DateTime.now(),
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  selectedDayHighlightColor: Colors.purple[800],
                ),
                onValueChanged: (dates) => setState(() {
                  if (dates.isNotEmpty) {
                    dateTime = dates[0]!;
                    filterCoinsByDate = dateTime = dates[0]!;
                  } else {
                    dateTime = DateTime.now();
                  }
                }),
                onOkTapped: () {
                  setState(() {
                    updateCoinsList = filterCoinsByDate.toString();
                  });
                  QuickHelp.hideLoadingDialog(context);
                },
                onCancelTapped: () {
                  QuickHelp.hideLoadingDialog(context);
                },
                value: [],
              ),
            ),
          );
        });
  }
}
