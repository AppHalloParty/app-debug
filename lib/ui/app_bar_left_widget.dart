// ignore_for_file: deprecated_member_use

import 'package:flutter_svg/svg.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';

class ToolBarLeftWidget extends StatelessWidget {
  final Widget? leftWidget;
  final Widget child;
  final List<dynamic>? actionsIcons;
  final String? coinsIcon;
  final double coinIconSize;
  final double actionsIconsSize;
  final Color? actionsColor;
  final double? elevation;
  final Widget? coins;
  final Function? coinsTap;
  final Function? avatarTap;
  final BottomNavigationBar? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? extendBodyBehindAppBar;
  final bool? enableAppBar;
  final List<Function?>? onTapActions;

  const ToolBarLeftWidget({
    Key? key,
    this.leftWidget,
    required this.child,
    this.elevation,
    this.actionsIcons = const [],
    this.bottomNavigationBar,
    this.actionsColor = kDisabledGrayColor,
    this.onTapActions = const [],
    this.actionsIconsSize = 20,
    this.coinIconSize = 20,
    this.coinsTap,
    this.avatarTap,
    this.coinsIcon,
    this.coins,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.enableAppBar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor = QuickHelp.isDarkModeNoContext()
        ? kContentColorLightTheme
        : kContentColorDarkTheme;

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar!,
      appBar: enableAppBar! ? AppBar(
        leading: GestureDetector(child: leftWidget,
        onTap: avatarTap as void Function(),
        ),
        backgroundColor: backgroundColor != null ? backgroundColor : bgColor,
        title: coins,
        centerTitle: false,
        elevation: elevation,
        actions: List.generate(actionsIcons!.length, (index) {
          return TextButton(
              onPressed: onTapActions![index] as void Function()?,
              child: getIcon(actionsIcons![index]));
        }),
      ) : null,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }

  Widget getIcon(dynamic icon){
    if(icon is String){

      if(icon.endsWith(".svg")){

        return SvgPicture.asset(
          icon,
          width: actionsIconsSize,
          height: actionsIconsSize,
          color: actionsColor,
        );
      } else {

        return Image.asset(icon,
          width: actionsIconsSize,
          height: actionsIconsSize,
          color: actionsColor,
        );
      }

    } else if(icon is Widget){
      return icon;
    } else {
      return Container();
    }
  }
}
