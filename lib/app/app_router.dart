import 'package:trace/auth/forgot_screen.dart';
import 'package:trace/auth/welcome_screen.dart';
import 'package:trace/home/web/web_url_screen.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      case WelcomeScreen.route:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case ForgotScreen.route:
        return MaterialPageRoute(builder: (_) => ForgotScreen());
      case QuickHelp.pageTypeTerms:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypeTerms));
      case QuickHelp.pageTypePrivacy:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypePrivacy));
      case QuickHelp.pageTypeWhatsapp:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypeWhatsapp));
      case QuickHelp.pageTypeInstructions:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypeInstructions));
      case QuickHelp.pageTypeSupport:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypeSupport));
      case QuickHelp.pageTypeCashOut:
        return MaterialPageRoute(builder: (_) => WebViewScreen(pageType: QuickHelp.pageTypeCashOut));

      //case HomeScreen.route:return MaterialPageRoute(builder: (_) => HomeScreen());


      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                  child: Text('No route defined for ${settings.name}')),
            ));
    }
  }
}