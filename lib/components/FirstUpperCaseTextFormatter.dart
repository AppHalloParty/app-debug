import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class FirstUpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: toBeginningOfSentenceCase(newValue.text)!,
      selection: newValue.selection,
    );
  }
}