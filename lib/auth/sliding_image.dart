import 'dart:async';

import 'package:flutter/material.dart';

class SlidingImage extends StatefulWidget {
  final String imagePath;
  final double slideDuration;
  final double stayDuration;

  const SlidingImage({
    Key? key,
    required this.imagePath,
    this.slideDuration = 20000,
    this.stayDuration = 1000,
  }) : super(key: key);

  @override
  _SlidingImageState createState() => _SlidingImageState();
}

class _SlidingImageState extends State<SlidingImage>
    with SingleTickerProviderStateMixin {
  PageController? _pageController;
  Timer? _timer;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: pageIndex);

    _timer = Timer.periodic(
      Duration(milliseconds: 100),
          (Timer timer) {

            if (_pageController!.page == _pageController!.page!.roundToDouble()) {
              if (_pageController!.page!.toInt() == 3) {
                _pageController!.jumpToPage(0);
              } else {
                _pageController!.animateToPage(
                  _pageController!.page!.toInt() + 1,
                  duration: Duration(seconds: 20),
                  curve: Curves.linear,
                );
              }
            }
      },
    );
  }

  @override
  void dispose() {
    _pageController!.dispose();
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: PageView(
        controller: _pageController,
        children: [
          Image.asset("assets/images/img_1.png", fit: BoxFit.cover),
          Image.asset("assets/images/img_2.png", fit: BoxFit.cover),
          Image.asset("assets/images/img_3.png", fit: BoxFit.cover),
          Image.asset("assets/images/img_4.png", fit: BoxFit.cover),
        ]
      ),
    );
  }
}
