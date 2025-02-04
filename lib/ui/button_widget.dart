import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final Function? onTap;
  final double? marginTop;
  final double? marginLeft;
  final double? marginRight;
  final double? marginBottom;
  final double? paddingTop;
  final double? paddingLeft;
  final double? paddingRight;
  final double? paddingBottom;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final double? borderRadiusAll;
  final double? borderWidth;
  final Color? borderColor;
  final Color? color;
  final Widget? child;

  const ButtonWidget({
    Key? key,
    this.marginTop = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.paddingTop = 0,
    this.paddingLeft = 0,
    this.paddingRight = 0,
    this.paddingBottom = 0,
    this.width,
    this.height,
    this.borderRadiusAll = 0,
    this.borderRadius,
    this.borderColor = Colors.transparent,
    this.color = Colors.transparent,
    this.borderWidth = 0,
    this.onTap,
    this.child,
    this.elevation = 0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusAll!),
      ),
      margin: EdgeInsets.only(
          left: marginLeft!,
          right: marginRight!,
          top: marginTop!,
          bottom: marginBottom!),
      elevation: elevation!,
      child: OutlinedButton(
        onPressed: onTap as void Function()?,
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding != null ? padding! : EdgeInsets.only(
              left: paddingLeft!,
              right: paddingRight!,
              top: paddingTop!,
              bottom: paddingBottom!),),
          backgroundColor: WidgetStateProperty.all<Color>(color!),
          side: WidgetStateProperty.all<BorderSide>(
            BorderSide(width: borderWidth!, color: borderColor!),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius != null ? borderRadius! : BorderRadius.circular(borderRadiusAll!),
            ),
          ),
        ),
        child: child!,
      ),
    );
  }
}
