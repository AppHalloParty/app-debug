import 'package:flutter/material.dart';
import 'package:trace/utils/colors.dart';

class PrimaryButton extends StatelessWidget {

  final String text;
  final VoidCallback press;
  final Color color;
  final EdgeInsets padding;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = kPrimaryColor,
    this.padding = const EdgeInsets.all(20 * 0.75),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape:const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(40)),
      ),
      padding: padding,
      color: color,
      minWidth: double.infinity,
      onPressed: press,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
