import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';

class RoundedGradientBg extends StatelessWidget {
  final Widget? child;
  const RoundedGradientBg({
    Key? key,
    this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        height: 50.0,
        width: size.width,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Ink(
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kPrimaryColor, kColorsBlue400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),

        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(40)),
      ),
      child: Container(
        width: size.width,
        constraints: BoxConstraints(maxWidth: 300.0, minHeight: 50.0),
        alignment: Alignment.center,
        child: child
      ),
    ),
    );
  }
}