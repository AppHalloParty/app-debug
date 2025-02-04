import 'package:flutter/material.dart';

class BackAndFront extends StatelessWidget {
  final Widget? firstChild;
  final Widget? secondChild;
  final double? secondChildTop;
  final double? secondChildBottom;
  final double? secondChildRight;
  final double? secondChildLeft;
  final double? secondChildHeight;
  final double? secondChildWidth;
  final Color? backGround;



  const BackAndFront({
    Key? key,
    this.firstChild,
    this.secondChild,
    this.secondChildTop = 0.0,
    this.secondChildBottom = 0.0,
    this.secondChildRight = 0.0,
    this.secondChildLeft = 0.0,
    this.secondChildHeight = 20.0,
    this.secondChildWidth= 20.0,
    this.backGround = Colors.grey,

    
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: kBottomNavigationBarHeight,
      padding: const EdgeInsets.all(0.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(0.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      firstChild!,

                      Positioned(
                        top: secondChildTop,
                        bottom: secondChildBottom,
                        right: secondChildRight,
                        left: secondChildLeft,

                        child: Container(
                          padding: const EdgeInsets.only(top: 2.0),

                          height: secondChildHeight,
                          width: secondChildWidth,

                          constraints: const BoxConstraints(
                            maxHeight: 45,
                            maxWidth: 45,
                          ),

                          decoration: BoxDecoration(
                            
                            color: backGround,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                                style: BorderStyle.solid),
                          ),

                          child: Center(
                            child: secondChild,
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
