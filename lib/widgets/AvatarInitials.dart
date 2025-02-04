import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'dart:math' show min;

class AvatarInitials extends StatelessWidget {
  final String? name;
  final Color? textColor;
  final Color? backgroundColor;
  final double? textSize;
  final double? avatarRadius;
  AvatarInitials({
    this.name,
    this.textColor,
    this.backgroundColor,
    this.textSize,
    this.avatarRadius,
  });

  String _getInitials() {
    var nameParts = name!.split(" ").map((elem) {
      return elem[0];
    });

    if (nameParts.length == 0) {
      return "";
    }

    int numberOfParts = min(2, nameParts.length);
    return nameParts.join().substring(0, numberOfParts);
  }

  CircleAvatar _makeInitialsAvatar() {
    return CircleAvatar(
      backgroundColor: backgroundColor != null ? backgroundColor : kPrimaryColor,
      radius: avatarRadius != null ? avatarRadius : 10,
      child: Text(
        _getInitials(),
        style: TextStyle(color: textColor != null ? textColor : Colors.white, fontSize: textSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _makeInitialsAvatar();
  }
}
