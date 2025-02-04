import 'package:trace/ui/text_field_container.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundedInputField extends StatelessWidget {
  final Key? fieldKey;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? hintText;
  final String? labelText;
  final bool? isNodeNext;
  final IconData? icon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool? visible;
  final Function? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  final InputBorder? inputBorder;
  final Color? iconColor;
  final int? maxLines;
  final int? maxLength;
  const RoundedInputField({
    Key? key,
    this.fieldKey,
    this.controller,
    this.validator,
    this.autovalidateMode,
    this.hintText,
    this.labelText,
    this.textInputAction,
    this.isNodeNext,
    this.icon,
    this.onChanged,
    this.visible,
    this.onTap,
    this.inputFormatters,
    this.textInputType,
    this.inputBorder,
    this.iconColor,
    this.maxLines,
    this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return TextFieldContainer(
      visible: visible,
      child: TextFormField(
        key: fieldKey,
        onTap: onTap as void Function()?,
        keyboardType: textInputType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        controller: controller,
        autovalidateMode: autovalidateMode,
        validator: validator,
        cursorColor: kPrimaryColor,
        textInputAction: textInputAction,
        maxLines: maxLines,
        maxLength: maxLength,
        onEditingComplete: () => isNodeNext!? node.nextFocus() : node.unfocus(), // Move focus to next
        //style: QuickHelp.isDarkMode(context) ? TextStyle(color: Colors.black, fontSize: 16) : TextStyle(color: Colors.black, fontSize: 16),
        decoration: InputDecoration(
          icon: icon != null ? Icon(
            icon,
            color: iconColor,
          ) : null,
          hintText: hintText,
          //hintStyle: QuickHelp.isDarkMode(context) ? TextStyle(color: kColorsGrey500): TextStyle(color: kColorsGrey500),
          border: inputBorder,
          labelText: labelText != null ? labelText! : null,
        ),
      ),
    );
  }
}