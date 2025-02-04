
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? hintText;
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

  const InputTextField({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(left: marginLeft!, top: marginTop!, bottom: marginBottom!, right: marginRight!),
      child: TextFormField(
        key: fieldKey,
        //onTap: onTap as void Function()?,
        keyboardType: textInputType,
        //inputFormatters: inputFormatters,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: autovalidateMode,
        validator: validator,
        cursorColor: kPrimaryColor,
        textInputAction: textInputAction,
        onEditingComplete: () => isNodeNext!? node.nextFocus() : node.unfocus(), // Move focus to next
        style: QuickHelp.isDarkMode(context) ? TextStyle(color: Colors.white, fontSize: 16) : TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          /*icon: Icon(
            icon,
            color: kPrimaryColor,
          ),*/
          hintText: hintText,
          errorText: errorText,
          helperText: helperText,
          labelText: labelText,
          hintStyle: QuickHelp.isDarkMode(context) ? TextStyle(color: kColorsGrey500): TextStyle(color: kColorsGrey500),
          border: inputBorder,
        ),
      ),
    );
  }
}