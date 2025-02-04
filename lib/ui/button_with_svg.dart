// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonWithSvg extends StatelessWidget {
  final Function? press;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final String text;
  final double? width;
  final double? height;
  final double? svgWidth;
  final double? svgHeight;
  final String svgName;
  final double? fontSize;
  final double? borderRadius;
  final Color? textColor;
  final Color? svgColor;
  final Color? color;
  final double? svgRightSpace;
  final FontWeight? fontWeight;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;

  const ButtonWithSvg({
    Key? key,
    required this.text,
    required this.svgName,
    this.fontWeight,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.fontSize,
    this.width,
    this.height,
    this.svgHeight,
    this.svgWidth,
    this.borderRadius,
    this.textColor,
    this.svgColor,
    this.color,
    this.press,
    this.svgRightSpace = 10,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(left: marginLeft!, top: marginTop!, bottom: marginBottom!, right: marginRight!),
      child: ElevatedButton(
        onPressed: press as void Function()?,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color != null ? color! : Colors.grey),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  borderRadius != null ? borderRadius! : 0))),
        ),
        child: Row(
          mainAxisSize: mainAxisSize!,
          mainAxisAlignment: mainAxisAlignment!,
          crossAxisAlignment: crossAxisAlignment!,
          children: [
            Padding(
              padding: EdgeInsets.only(right: svgRightSpace!),
              child: SvgPicture.asset("assets/svg/$svgName.svg", color: svgColor, width: svgWidth, height: svgHeight,),
            ),
            Text(text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: fontWeight,
                )),
            Container(width: 10,),
          ],
        ),
      ),
    );
  }
}
