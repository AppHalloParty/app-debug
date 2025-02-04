// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/services.dart';

import '../home/controller/controller.dart';
import '../models/others/CountryModel.dart';

class PhoneNumberTextField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? hintText, countrySearchHint;
  String? initialCountryIso;
  final String? helperText;
  final String? errorText;
  final String? labelText;
  final InputBorder? inputBorder;
  final bool? isNodeNext;
  final IconData? icon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool? visible;
  final Function? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
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
  final ValueChanged<CountryModel>? onCountryChanged;
  final TextStyle? errorTextField;

  TextEditingController searchTextController = TextEditingController();

  PhoneNumberTextField({
    Key? key,
    this.fieldKey,
    this.controller,
    this.validator,
    this.autovalidateMode,
    this.hintText,
    this.errorText,
    this.helperText,
    this.labelText,
    this.inputBorder,
    this.textInputAction,
    this.isNodeNext,
    this.icon,
    this.onChanged,
    this.visible,
    this.onTap,
    this.inputFormatters,
    this.textInputType,
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
    this.errorTextField
  }) : super(key: key);

  Controller control = Get.put(Controller());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    bool isDark = QuickHelp.isDarkMode(context);
    final node = FocusScope.of(context);
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ContainerCorner(
            height: 40,
            marginBottom: 4,
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
                                                    .toLowerCase()) ||
                                            QuickHelp.getCountryDialCode(
                                                    QuickHelp.countriesIsoList[
                                                        index])
                                                .contains(
                                                    control.searchText.value)) {
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
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
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
                                                    TextWithTap(
                                                      QuickHelp.getCountryDialCode(
                                                          QuickHelp
                                                                  .countriesIsoList[
                                                              index]),
                                                      fontSize: 10,
                                                      marginLeft: 10,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ],
                                                )
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
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
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
                                                  TextWithTap(
                                                    QuickHelp.getCountryDialCode(
                                                        QuickHelp
                                                                .countriesIsoList[
                                                            index]),
                                                    fontSize: 10,
                                                    marginLeft: 10,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  ),
                                                ],
                                              )
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
              child: Obx(() {
                return Row(
                  children: [
                    Image.asset(
                      QuickHelp.getCountryFlag(code: control.countryCode.value),
                      height: 25,
                      width: 25,
                    ),
                    TextWithTap(
                      QuickHelp.getCountryDialCode(control.countryCode.value),
                      marginLeft: 10,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                );
              }),
            ),
          ),
          Flexible(
            child: TextFormField(
              key: fieldKey,
              //onTap: onTap as void Function()?,
              keyboardType: TextInputType.phone,
              //inputFormatters: inputFormatters,
              onChanged: onChanged,
              controller: controller,
              autovalidateMode: autovalidateMode,
              validator: validator,
              cursorColor: kPrimaryColor,
              textInputAction: textInputAction,
              onEditingComplete: () =>
                  isNodeNext! ? node.nextFocus() : node.unfocus(),
              // Move focus to next
              style: QuickHelp.isDarkMode(context)
                  ? TextStyle(color: Colors.white, fontSize: 16)
                  : TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                /*icon: Icon(
                  icon,
                  color: kPrimaryColor,
                ),*/
                hintText: hintText,
                errorText: errorText,
                helperText: helperText,
                labelText: labelText,
                errorStyle: errorTextField,
                hintStyle: QuickHelp.isDarkMode(context)
                    ? TextStyle(color: kColorsGrey500)
                    : TextStyle(color: kColorsGrey500),
                border: inputBorder,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
