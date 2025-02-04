// ignore_for_file: deprecated_member_use

import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ToolBar extends StatelessWidget {
  final Function? onLeftButtonTap;
  final IconData? leftButtonIcon;
  final Widget? leftButtonWidget;
  final Widget? rightButtonWidget;
  final Widget? rightButtonTwoWidget;
  final Function? rightButtonPress;
  final Function? rightButtonTwoPress;
  final IconData? rightButtonIcon;
  final String? rightButtonAsset;
  final IconData? rightButtonTwoIcon;
  final String? rightButtonTwoAsset;
  final Color? rightIconColor;
  final double? iconWidth;
  final double? iconHeight;
  final Color? iconColor;
  final String? title;
  final Widget? titleChild;
  final Widget child;
  final double? elevation;
  final bool? centerTitle;
  final bool ? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool? extendBodyBehindAppBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  const ToolBar({
    Key? key,
    this.leftButtonIcon,
    this.onLeftButtonTap,
    this.iconColor,
    this.elevation,
    this.title,
    this.titleChild,
    this.centerTitle,
    this.rightButtonPress,
    this.rightButtonIcon,
    this.iconWidth,
    this.iconHeight,
    this.leftButtonWidget,
    this.rightButtonWidget,
    this.rightButtonAsset,
    this.rightIconColor,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.floatingActionButtonAnimator,
    this.floatingActionButtonLocation,
    required this.child,
    this.rightButtonTwoWidget,
    this.rightButtonTwoPress,
    this.rightButtonTwoIcon,
    this.rightButtonTwoAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Color titleColor = QuickHelp.isDarkModeNoContext()
        ? kContentColorDarkTheme
        : kContentColorLightTheme;

    Color bgColor = QuickHelp.isDarkModeNoContext()
        ? kContentColorLightTheme
        : kContentColorDarkTheme;

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar!,
      resizeToAvoidBottomInset : resizeToAvoidBottomInset,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        centerTitle: centerTitle,
        leading: IconButton(
          icon: leftButtonWidget!= null ? leftButtonWidget! : Icon(leftButtonIcon, color: iconColor != null ? iconColor : titleColor),
          onPressed: onLeftButtonTap as void Function()?,
        ),
        backgroundColor: backgroundColor != null ? backgroundColor : bgColor,
        title: titleChild != null ? titleChild : Text(title != null ? title! : "", style: TextStyle(color: titleColor),),
        bottomOpacity: 10,
        elevation: elevation,
        actions: [
          rightButtonWidget != null ?
          Container(
            width: 100,
            height: 40,
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            child: rightButtonWidget,
          ) : IconButton(
            icon: rightButtonAsset != null
                ? SvgPicture.asset("assets/svg/$rightButtonAsset",
                width: iconWidth,
                height: iconHeight,
                color: rightIconColor != null ? rightIconColor : titleColor)
                : Icon(rightButtonIcon,
                color:
                rightIconColor != null ? rightIconColor : titleColor),
            onPressed: rightButtonPress as void Function()?,
          ),
          rightButtonTwoWidget != null ?
          Container(
            width: 100,
            height: 40,
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            child: rightButtonTwoWidget,
          ) : IconButton(
            icon: rightButtonTwoAsset != null
                ? SvgPicture.asset("assets/svg/$rightButtonTwoAsset",
                width: iconWidth,
                height: iconHeight,
                color: rightIconColor != null ? rightIconColor : titleColor,)
                : Icon(rightButtonTwoIcon,
                color:
                rightIconColor != null ? rightIconColor : titleColor,),
            onPressed: rightButtonTwoPress as void Function()?,
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return child;
      }),
    );
  }
}