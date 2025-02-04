
import 'package:flutter/material.dart';

// ignore_for_file: must_be_immutable
class ExpandableTextAnimation extends StatefulWidget {
  String? text;
  Color? color;
  double? size;

  bool isExpanded = false;

  ExpandableTextAnimation({this.text = "", this.size = 14, this.color = Colors.black38});

  @override
  _ExpandableTextAnimationState createState() => new _ExpandableTextAnimationState();
}

class _ExpandableTextAnimationState extends State<ExpandableTextAnimation>
    with TickerProviderStateMixin<ExpandableTextAnimation> {
  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      new AnimatedSize(
          duration: const Duration(milliseconds: 500),
          child: new ConstrainedBox(
              constraints: widget.isExpanded
                  ? new BoxConstraints()
                  : new BoxConstraints(maxHeight: 50.0),
              child: new Text(
                widget.text!,
                softWrap: true,
                style: TextStyle(
                  color: widget.color!,
                  fontSize: widget.size
                ),
                overflow: TextOverflow.fade,
              ))),
      widget.isExpanded
          ? new ConstrainedBox(constraints: new BoxConstraints())
          : new TextButton(
          child: const Text('...'),
          onPressed: () => setState(() => widget.isExpanded = true))
    ]);
  }
}