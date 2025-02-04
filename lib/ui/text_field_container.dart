import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget? child;
  final bool? visible;

  const TextFieldContainer({
    Key? key,
    this.child,
    this.visible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return Visibility(
        visible: this.visible != null ? visible! : true,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          //width: size.width * 0.8,
          decoration: BoxDecoration(
            //color: kPrimaryLightColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: child,
        ));
  }
}
