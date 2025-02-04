import 'package:flutter/material.dart';

class ButtonRounded extends StatelessWidget {
  final Function? onTap;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final String text;
  final TextAlign? textAlign;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? borderRadius;
  final Color? textColor;
  final Color? color;
  final FontWeight? fontWeight;

  const ButtonRounded({
    Key? key,
    required this.text,
    this.fontWeight,
    this.textAlign,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.fontSize,
    this.width,
    this.height,
    this.borderRadius,
    this.textColor,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(left: marginLeft!, top: marginTop!, bottom: marginBottom!, right: marginRight!),
      child: ElevatedButton(
        onPressed: onTap as void Function()?,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(color != null ? color! : Colors.grey),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  borderRadius != null ? borderRadius! : 0))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text,
                textAlign: textAlign,
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
