import 'package:flutter/material.dart';

class ButtonWithImage extends StatelessWidget {
  final Function? press;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final String text;
  final double? width;
  final double? height;
  final double? imageWidth;
  final double? imageHeight;
  final String imageName;
  final double? fontSize;
  final double? borderRadius;
  final Color? textColor;
  final Color? imageColor;
  final Color? color;
  final double? imageRightSpace;
  final FontWeight? fontWeight;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;

  const ButtonWithImage({
    Key? key,
    required this.text,
    required this.imageName,
    this.fontWeight,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.fontSize,
    this.width,
    this.height,
    this.imageHeight,
    this.imageWidth,
    this.borderRadius,
    this.textColor,
    this.imageColor,
    this.color,
    this.press,
    this.imageRightSpace = 10,
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
          backgroundColor: WidgetStateProperty.all<Color>(color != null ? color! : Colors.grey),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  borderRadius != null ? borderRadius! : 0))),
        ),
        child: Row(
          mainAxisSize: mainAxisSize!,
          mainAxisAlignment: mainAxisAlignment!,
          crossAxisAlignment: crossAxisAlignment!,
          children: [
            Padding(
              padding: EdgeInsets.only(right: imageRightSpace!),
              child: Image.asset("assets/images/$imageName", color: imageColor, width: imageWidth, height: imageHeight,),
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
