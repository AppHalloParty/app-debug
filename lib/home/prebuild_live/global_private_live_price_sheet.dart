import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trace/models/GiftsModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class PrivateLivePriceWidget {
  PrivateLivePriceWidget(
      {required BuildContext context,
        Function(GiftsModel giftsModel)? onGiftSelected,
        Function()? onCancel,
        bool isDismissible = false,
        bool enableDrag = false,
        bool isScrollControlled = false,
        bool showOnlyCoinsPurchase = false,
        Color backgroundColor = Colors.transparent}) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        builder: (context) {
          return _PricesListWidget(
            onCancel: onCancel,
            onGiftSelected: onGiftSelected,
          );
        });
  }
}

// ignore: must_be_immutable
class _PricesListWidget extends StatefulWidget {
  final Function? onCancel;
  final Function? onGiftSelected;

  _PricesListWidget({
    this.onCancel,
    this.onGiftSelected,
  });

  @override
  State<_PricesListWidget> createState() => _PricesListWidgetState();
}

class _PricesListWidgetState extends State<_PricesListWidget>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  int bottomSheetCurrentIndex = 0;


  final selectedGiftItemNotifier = ValueNotifier<GiftsModel?>(null);
  final countNotifier = ValueNotifier<String>('1');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController.unbounded(vsync: this);

  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  _showGiftList();
  }

  Widget _showGiftList() {
    Size size = MediaQuery.sizeOf(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: ContainerCorner(
        radiusTopRight: 20.0,
        radiusTopLeft: 20.0,
        color: kWhitenDark,
        width: size.width,
        borderWidth: 0,
        child: Scaffold(
          backgroundColor: kTransparentColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            surfaceTintColor: kTransparentColor,
            backgroundColor: kTransparentColor,
            title: Column(
              children: [
                TextWithTap(
                  "set_price_live".tr(),
                  fontSize: 14,
                  color: Colors.black,
                  alignment: Alignment.centerLeft,
                  marginBottom: 10,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
          body: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) setState) {
              return getGifts();
            },
          ),
          bottomNavigationBar: ContainerCorner(
            colors: [earnCashColor, kRedColor1],
            borderRadius: 20,
            borderWidth: 0,
            marginLeft: 40,
            marginRight: 40,
            marginBottom: 20,
            marginTop: 10,
            width: size.width,
            height: 50,
            onTap: widget.onCancel,
            child: TextWithTap(
              "cancel".tr(),
              color: Colors.white,
              alignment: Alignment.center,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget getGifts() {

    QueryBuilder<GiftsModel> giftQuery = QueryBuilder<GiftsModel>(GiftsModel());
    giftQuery.whereValueExists(GiftsModel.keyGiftCategories, true);
    giftQuery.whereEqualTo(
        GiftsModel.keyGiftCategories, GiftsModel.categorySvgaGifts);
    giftQuery.orderByAscending(GiftsModel.keyCoins,);

    return ContainerCorner(
      color: kTransparentColor,
      marginTop: 15,
      child: ParseLiveGridWidget<GiftsModel>(
        query: giftQuery,
        crossAxisCount: 4,
        reverse: false,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        lazyLoading: false,
        shrinkWrap: true,
        listenOnAllSubItems: true,
        duration: Duration(seconds: 0),
        animationController: _animationController,
        childBuilder: (BuildContext context,
            ParseLiveListElementSnapshot<GiftsModel> snapshot) {
          GiftsModel gift = snapshot.loadedData!;
          return GestureDetector(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => widget.onGiftSelected!(gift),
                    child: Column(
                      children: [
                        ValueListenableBuilder<GiftsModel?>(
                          valueListenable: selectedGiftItemNotifier,
                          builder: (context, selectedGiftItem, _) {
                            return Container(
                              width: 50,
                              height: 50,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: QuickActions.photosWidget(
                                    gift.getPreview!.url),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  ContainerCorner(
                    color: kTransparentColor,
                    marginTop: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/ic_coin_with_star.svg",
                          width: 16,
                          height: 16,
                        ),
                        TextWithTap(
                          gift.getCoins.toString(),
                          fontSize: 14,
                          marginLeft: 5,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        queryEmptyElement: QuickActions.noContentFound(context),
        gridLoadingElement: Container(
          margin: EdgeInsets.only(top: 50),
          alignment: Alignment.topCenter,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }


}
