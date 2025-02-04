// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/utils/colors.dart';

class ButtonWithIcon extends StatelessWidget {
  final Function? onTap;
  final String? text;
  final IconData? icon;
  final double? width;
  final double? height;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final double? fontSize;
  final double? borderRadius;
  final double? radiusTopRight;
  final double? radiusBottomRight;
  final double? radiusTopLeft;
  final double? radiusBottomLeft;
  final Color? textColor;
  final Color? iconColor;
  final double? borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final FontWeight? fontWeight;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final String? iconURL;
  final Color? urlIconColor;
  final double? iconSize;

  const ButtonWithIcon({
    Key? key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.icon,
    this.width,
    this.height,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.onTap,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.iconColor = Colors.black,
    this.iconURL,
    this.urlIconColor = kPrimaryColor,
    this.radiusTopRight = 0,
    this.radiusBottomRight = 0,
    this.radiusTopLeft = 0,
    this.radiusBottomLeft = 0,
    this.iconSize = 24.0,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
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
      child: TextButton(
        onPressed: onTap as void Function()?,
        style: ButtonStyle(
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(width: borderWidth!, color: borderColor!),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
              backgroundColor != null ? backgroundColor! : Colors.grey),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                      borderRadius != null ? borderRadius! : radiusTopRight!),
                  bottomRight: Radius.circular(borderRadius != null
                      ? borderRadius!
                      : radiusBottomRight!),
                  topLeft: Radius.circular(
                      borderRadius != null ? borderRadius! : radiusTopLeft!),
                  bottomLeft: Radius.circular(borderRadius != null
                      ? borderRadius!
                      : radiusBottomLeft!)))),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: mainAxisAlignment!,
          crossAxisAlignment: crossAxisAlignment!,
          children: [
            iconURL != null
                ? iconURL!.endsWith(".svg")
                    ? SvgPicture.asset(iconURL!,
                        color: urlIconColor != null ? urlIconColor : null,
                        height: iconSize,
                        width: iconSize)
                    : Image.asset(iconURL!,
                        color: urlIconColor != null ? urlIconColor : null,
                        height: iconSize,
                        width: iconSize)
                : Container(),
            icon != null
                ? Icon(
                    icon!,
                    color: iconColor,
                    size: iconSize,
                  )
                : Container(),
            text != null ? Container(
              width: 10,
            ) : Container(),
            text != null ? Text(
              text!,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontWeight: fontWeight,
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
