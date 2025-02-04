import 'package:flutter/material.dart';

class ButtonRoundedOutline extends StatelessWidget {
  final Function? onTap;
  final String text;
  final double? fontSize;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final double? width;
  final double? height;
  final double? borderRadius;
  final double? borderWidth;
  final Color? textColor;
  final Color? borderColor;
  final FontWeight? fontWeight;

  const ButtonRoundedOutline({
    Key? key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.width,
    this.height,
    this.borderRadius,
    this.textColor,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(
          left: marginLeft!,
          top: marginTop!,
          bottom: marginBottom!,
          right: marginRight!),
      child: OutlinedButton(
        onPressed: onTap as void Function()?,
        style: ButtonStyle(
          side: WidgetStateProperty.all<BorderSide>(
              BorderSide(width: borderWidth!, color: borderColor!)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  borderRadius != null ? borderRadius! : 0),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor,
                  fontWeight: fontWeight,
                ))
          ],
        ),
      ),
    );
  }
}
