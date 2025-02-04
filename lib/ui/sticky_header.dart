// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';

class StickyHeader extends StatelessWidget {
  Widget? widget;

  StickyHeader({this.widget,});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: Delegate(widget: widget),
    );
  }
}

class Delegate extends SliverPersistentHeaderDelegate {
  Widget? widget;

  Delegate({this.widget});

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    bool isDark = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      height: 40,
      color: isDark ? kContentColorLightTheme : kGrayWhite,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: widget!,
        ),
    );
  }
}