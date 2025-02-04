import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:flutter/material.dart';


class Component {

  static Widget buildNavIcon(

      dynamic icon, int index, bool withBage, BuildContext context,
      {int badge = 0, int color = 0xFFFA3967}) {

    if (withBage) {

      return Container(

        width: MediaQuery.of(context).size.width,
        height: kBottomNavigationBarHeight,
        padding:  EdgeInsets.all(0.0),
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
                    padding:  EdgeInsets.all(0.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        icon,
                        Positioned(
                          right: -13,
                          top: -8,
                          child: ContainerCorner(
                            height: 17,
                            width: 17,
                            color: Color(color),
                            borderWidth: 0,
                            borderRadius: 4,
                            child: Center(
                              child: AutoSizeText(
                                "${QuickHelp.convertToK(badge)}",
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                                minFontSize: 5,
                                stepGranularity: 1,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
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
    } else {
      return icon;
    }
  }

  Widget button() {
    return ElevatedButton(onPressed: () {}, child:  Text(""));
  }
}
