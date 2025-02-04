// ignore_for_file: deprecated_member_use

import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ToolBarReels extends StatelessWidget {
  final Function? onLeftWidgetTap;
  final IconData? leftButtonIcon;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Widget? rightWidgetTwo;
  final Function? rightButtonPress;
  final IconData? rightButtonIcon;
  final String? rightButtonAsset;
  final Color? rightIconColor;
  final double? iconWidth;
  final double? iconHeight;
  final Color? iconColor;
  final String? title;
  final Widget? titleChild;
  final Widget child;
  final double? elevation;
  final bool? centerTitle;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final bool? extendBodyBehindAppBar;
  final FloatingActionButton? floatingActionButton;
  final bool? bottomAppBar;
  final bool? showAppBar;
  final AppBar? appBar;

  const ToolBarReels({
    Key? key,
    this.leftButtonIcon,
    this.onLeftWidgetTap,
    this.iconColor,
    this.elevation,
    this.title,
    this.titleChild,
    this.centerTitle,
    this.rightButtonPress,
    this.rightButtonIcon,
    this.iconWidth,
    this.iconHeight,
    this.leftWidget,
    this.rightWidget,
    this.rightWidgetTwo,
    this.rightButtonAsset,
    this.rightIconColor,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.bottomAppBar = false,
    this.showAppBar = true,
    this.appBar,
    required this.child,
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
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      appBar: showAppBar!
          ? appBar != null
              ? appBar!
              : AppBar(
                  centerTitle: centerTitle,
                  surfaceTintColor: Colors.transparent,
                  leading: leftWidget != null
                      ? leftWidget!
                      : IconButton(
                          icon: Icon(leftButtonIcon,
                              color:
                                  iconColor != null ? iconColor : titleColor),
                          onPressed: onLeftWidgetTap as void Function()?,
                        ),
                  backgroundColor:
                      backgroundColor != null ? backgroundColor : bgColor,
                  title: titleChild != null
                      ? titleChild
                      : Text(
                          title != null ? title! : "",
                          style: TextStyle(color: titleColor),
                        ),
                  bottomOpacity: 10,
                  elevation: elevation,
                  actions: [
                    rightWidget != null
                        ? Container(
                            width: 100,
                            height: 40,
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            child: rightWidget,
                          )
                        : IconButton(
                            icon: rightButtonAsset != null
                                ? SvgPicture.asset(
                                    "assets/svg/$rightButtonAsset",
                                    width: iconWidth,
                                    height: iconHeight,
                                    color: rightIconColor != null
                                        ? rightIconColor
                                        : titleColor)
                                : Icon(rightButtonIcon,
                                    color: rightIconColor != null
                                        ? rightIconColor
                                        : titleColor),
                            onPressed: rightButtonPress as void Function()?,
                          ),
                    rightWidgetTwo != null
                        ? Container(
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.centerRight,
                            child: rightWidgetTwo,
                          )
                        : Container(),
                  ],
                )
          : null,
      body: Builder(builder: (BuildContext context) {
        return child;
      }),
    );
  }
}
