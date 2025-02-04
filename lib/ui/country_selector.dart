// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../home/controller/controller.dart';
import '../models/others/CountryModel.dart';

class CountrySelector extends StatelessWidget {
  final Key? fieldKey;
  String? initialCountryIso;
  final Function? onTap;
  final double? width;
  final double? height;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? radiusTopRight;
  final double? radiusBottomRight;
  final double? radiusTopLeft;
  final double? radiusBottomLeft;
  final double? borderWidth;
  final String? countrySearchHint;
  final ValueChanged<CountryModel>? onCountryChanged;

  TextEditingController searchTextController = TextEditingController();

  CountrySelector({
    Key? key,
    this.fieldKey,
    this.onTap,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.width,
    this.height,
    this.countrySearchHint = "",
    this.initialCountryIso = "",
    this.backgroundColor,
    this.radiusTopRight = 0,
    this.radiusBottomRight = 0,
    this.radiusTopLeft = 0,
    this.radiusBottomLeft = 0,
    this.onCountryChanged,
    this.borderColor,
    this.borderWidth,
  }) : super(key: key);

  Controller control = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      width: width,
      height: height,
      marginTop: marginTop!,
      marginLeft: marginLeft!,
      marginRight: marginRight!,
      marginBottom: marginBottom!,
      color: backgroundColor,
      radiusBottomLeft: radiusBottomLeft,
      radiusBottomRight: radiusBottomRight,
      radiusTopLeft: radiusTopLeft,
      radiusTopRight: radiusTopRight,
      borderWidth: borderWidth,
      borderColor: borderColor,
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: Colors.black12,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, newState) {
                return GestureDetector(
                  onTap: () => QuickHelp.removeFocusOnTextField(context),
                  child: AlertDialog(
                    contentPadding: EdgeInsets.zero,
                    backgroundColor:
                    isDark ? kDarkColorsTheme : Colors.white,
                    alignment: Alignment.topCenter,
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: size.height / 10,
                    ),
                    titlePadding:
                    EdgeInsets.only(top: 10, left: 10, right: 10),
                    title: ContainerCorner(
                      color: kGrayColor.withOpacity(0.2),
                      height: 50,
                      borderRadius: 10,
                      borderWidth: 0,
                      width: size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 10, left: 15, right: 15),
                        child: TextFormField(
                          controller: searchTextController,
                          autocorrect: false,
                          onChanged: (text) {
                            control.updateSearchField(text);
                            control.searchText.value = text;
                          },
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: countrySearchHint!,
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    content: ContainerCorner(
                      borderRadius: 10,
                      borderWidth: 0,
                      width: size.width,
                      height: size.height / 1.5,
                      child: Obx(() {
                        return ListView(
                          padding: EdgeInsets.only(left: 15, right: 15),
                          shrinkWrap: true,
                          children: [
                            Visibility(
                              visible: !control.emptyField.value,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: List.generate(
                                    QuickHelp.countriesIsoList.length,
                                        (index) {
                                      if (QuickHelp.getCountryName(
                                          code: QuickHelp
                                              .countriesIsoList[
                                          index])
                                          .toLowerCase()
                                          .contains(control
                                          .searchText.value
                                          .toLowerCase())) {
                                        return TextButton(
                                          onPressed: () {
                                            QuickHelp.hideLoadingDialog(
                                                context);
                                            control.updateCountryCode(
                                                QuickHelp
                                                    .countriesIsoList[index]);
                                            if (onCountryChanged != null) {
                                              onCountryChanged!(CountryModel(
                                                dialCode: QuickHelp.getCountryDialCode(
                                                    QuickHelp
                                                        .countriesIsoList[
                                                    index]),
                                                isoCode: QuickHelp
                                                    .countriesIsoList[index],
                                                languagesIso: QuickHelp.getLanguageByCountryIso(code: QuickHelp
                                                    .countriesIsoList[index]),
                                              ));
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                QuickHelp.getCountryFlag(
                                                    code: QuickHelp
                                                        .countriesIsoList[
                                                    index]),
                                                height: 25,
                                                width: 25,
                                              ),
                                              TextWithTap(
                                                QuickHelp.getCountryName(
                                                    code: QuickHelp
                                                        .countriesIsoList[
                                                    index]),
                                                fontSize: 12,
                                                fontWeight:
                                                FontWeight.bold,
                                                marginLeft: 10,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return SizedBox();
                                    }),
                              ),
                            ),
                            Visibility(
                              visible: control.emptyField.value,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: List.generate(
                                    QuickHelp.countriesIsoList.length,
                                        (index) {
                                      return TextButton(
                                        onPressed: () {
                                          QuickHelp.hideLoadingDialog(
                                              context);
                                          control.updateCountryCode(QuickHelp
                                              .countriesIsoList[index]);
                                          if (onCountryChanged != null) {
                                            onCountryChanged!(CountryModel(
                                              dialCode: QuickHelp.getCountryDialCode(
                                                  QuickHelp
                                                      .countriesIsoList[
                                                  index]),
                                              isoCode: QuickHelp
                                                  .countriesIsoList[index],
                                              languagesIso: QuickHelp.getLanguageByCountryIso(code: QuickHelp
                                                  .countriesIsoList[index]),
                                            ),
                                            );
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              QuickHelp.getCountryFlag(
                                                  code: QuickHelp
                                                      .countriesIsoList[
                                                  index]),
                                              height: 25,
                                              width: 25,
                                            ),
                                            TextWithTap(
                                              QuickHelp.getCountryName(
                                                  code: QuickHelp
                                                      .countriesIsoList[
                                                  index]),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              marginLeft: 10,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                );
              });
            },
          );
        },
        child: ContainerCorner(
          height: 40,
          marginBottom: 4,
          child: Obx(() {
            return Row(
              children: [
                Image.asset(
                  QuickHelp.getCountryFlag(code: control.countryCode.value),
                  height: 25,
                  width: 25,
                ),
                TextWithTap(
                  QuickHelp.getCountryName(
                      code: control.countryCode.value),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  marginLeft: 10,
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
