import 'package:flutter/cupertino.dart';

class Responsive{
  static const double MAX_MOBILE_WIDTH =  600.0;
  static const double MAX_TABLET_WIDTH =  1024.0;
  static const double MAX_DESKTOP_WIDTH =  1024.0;

  static bool isMobile(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if(width <= MAX_MOBILE_WIDTH){
      return true;
    }else{
      return false;
    }
  }

  static bool isTablet(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if(width > MAX_MOBILE_WIDTH && width <= MAX_TABLET_WIDTH){
      return true;
    }else{
      return false;
    }
  }

  static bool isWebOrDeskTop(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if(width > MAX_DESKTOP_WIDTH){
      return true;
    }else{
      return false;
    }
  }

}