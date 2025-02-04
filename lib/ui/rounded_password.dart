import 'package:trace/ui/text_field_container.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';

class PasswordFieldRounded extends StatefulWidget {

  const PasswordFieldRounded({
    this.fieldKey,
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
  });

  final Key? fieldKey;
  final TextEditingController? controller;
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

  @override
  _PasswordFieldRoundedState createState() => new _PasswordFieldRoundedState();
}

class _PasswordFieldRoundedState extends State<PasswordFieldRounded> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return new TextFieldContainer(
      visible: widget.visible,
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
          //style: TextStyle(color: QuickHelp.isDarkMode(context) ? Colors.black : Colors.black, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            //hintStyle: TextStyle(color: QuickHelp.isDarkMode(context) ? kColorsGrey500 : kColorsGrey500),
           /* icon: Icon(
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
            //border: InputBorder.none,
          )),
    );
  }
}
