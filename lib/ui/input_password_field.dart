import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';

class InputPasswordField extends StatefulWidget {

  const InputPasswordField({
    this.fieldKey,
    this.inputBorder,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.autovalidateMode,
    this.onFieldSubmitted,
    this.textInputAction,
    this.isNodeNext,
    this.visible,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.width,
    this.height,
  });

  final Key? fieldKey;
  final TextEditingController? controller;
  final InputBorder? inputBorder;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onFieldSubmitted;
  final bool? isNodeNext;
  final TextInputAction? textInputAction;
  final bool? visible;
  final double? width;
  final double? height;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;

  @override
  _InputPasswordFieldState createState() => new _InputPasswordFieldState();
}

class _InputPasswordFieldState extends State<InputPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      margin: EdgeInsets.only(left: widget.marginLeft!, top: widget.marginTop!, bottom: widget.marginBottom!, right: widget.marginRight!),
      child: TextFormField(
          key: widget.fieldKey,
          obscureText: _obscureText,
          //maxLength: 8,
          controller: widget.controller,
          cursorColor: kPrimaryColor,
          onSaved: widget.onSaved,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          onEditingComplete: () =>
          widget.isNodeNext! ? node.nextFocus() : node.unfocus(),
          style: TextStyle(color: QuickHelp.isDarkMode(context) ? Colors.white : Colors.black, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: QuickHelp.isDarkMode(context) ? kColorsGrey500 : kColorsGrey500),
            /*icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),*/
            suffixIcon: new GestureDetector(
              onTap: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
              child: new Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: kPrimaryColor,
              ),
            ),
            border: widget.inputBorder,
          )),
    );
  }
}
