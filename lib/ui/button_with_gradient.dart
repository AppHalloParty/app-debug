// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/ui/text_with_tap.dart';

class ButtonWithGradient extends StatelessWidget {
  final Function? onTap;
  final String text;
  final String? svgURL;
  final double? fontSize;
  final double? marginLeft;
  final double? marginRight;
  final double? marginTop;
  final double? marginBottom;
  final double? height;
  final double? width;
  final double? borderRadius;
  final double? topLeftBorder;
  final double? topRightBorder;
  final double? bottomLeftBorder;
  final double? bottomRightBorder;
  final double? borderWidth;
  final Color? textColor;
  final Color? borderColor;
  final Color? beginColor;
  final Color? endColor;
  final FontWeight? fontWeight;
  final bool activeBoxShadow;
  final Color? shadowColor;
  final double? shadowColorOpacity;
  final double? blurRadius;
  final double? spreadRadius;
  final bool? setShadowToBottom;

   ButtonWithGradient({
    Key? key,
    required this.text,
    this.fontWeight,
    this.fontSize,
    this.height,
    this.width = 0,
    this.borderRadius = 0.0,
    this.textColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.activeBoxShadow = false,
    this.beginColor = Colors.white,
    this.endColor = Colors.black,
    this.onTap,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.topLeftBorder = 0,
    this.topRightBorder = 0,
    this.bottomLeftBorder = 0,
    this.bottomRightBorder = 0,
    this.shadowColor = Colors.transparent,
     this.blurRadius = 10,
     this.spreadRadius = 1,
     this.setShadowToBottom = false,
     this.shadowColorOpacity = 1,
     this.svgURL,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [beginColor!, endColor!];
    return Container(
      margin: EdgeInsets.only(
        top: marginTop!,
        left: marginLeft!,
        right: marginRight!,
        bottom: marginBottom!,
      ),
      height: height,
      width: width != 0 ? width : MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: borderRadius != 0
            ? BorderRadius.all(Radius.circular(borderRadius!))
            : BorderRadius.only(
                topLeft:
                    Radius.circular(topLeftBorder! != 0 ? topLeftBorder! : 0),
                topRight:
                    Radius.circular(topRightBorder! != 0 ? topRightBorder! : 0),
                bottomLeft: Radius.circular(
                    bottomLeftBorder! != 0 ? bottomLeftBorder! : 0),
                bottomRight: Radius.circular(
                    bottomRightBorder! != 0 ? bottomRightBorder! : 0),
              ),
        boxShadow: activeBoxShadow ?  [
          BoxShadow(
              color: shadowColor != null ? shadowColor!.withOpacity(shadowColorOpacity!) : Colors.transparent,
              blurRadius: blurRadius!,
              spreadRadius:spreadRadius!,
              offset: setShadowToBottom! ? Offset(0,5) : Offset(0.0, 0.75) //offset: Offset(0,10),
          )
          /*BoxShadow(color: shadowColor! , offset: Offset(5, 5), blurRadius: 15.0, spreadRadius: 1)*/
        ] : null,
      ),
      child: ElevatedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWithTap(text, color: textColor, fontSize: fontSize, marginRight: 10,),
            svgURL != null ? SvgPicture.asset(svgURL!, color: Colors.white, width: 20,) : Container()
          ],
        ),
        onPressed: onTap!= null ? onTap as void Function()? : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          shadowColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }
}
