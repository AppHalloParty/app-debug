// ignore_for_file: must_be_immutable

import 'package:trace/app/config.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  String? pageType, receivedURL, receivedTitle;

  WebViewScreen({this.receivedTitle, this.receivedURL, Key? key, required this.pageType}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {

  late WebViewController controller;
  String? pageUrl;
  String? pageTitle;

  int position = 1;

  final key = UniqueKey();

  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  @override
  void initState() {

    if (widget.pageType == QuickHelp.pageTypePrivacy) {
      pageUrl = Config.privacyPolicyUrl;
      pageTitle = "page_title.privacy_policy".tr();
    } else if (widget.pageType == QuickHelp.pageTypeTerms) {
      pageUrl = Config.termsOfUseUrl;
      pageTitle = "page_title.terms_of_use".tr();

    } else if (widget.pageType == QuickHelp.pageTypeHelpCenter) {
      pageUrl = Config.helpCenterUrl;
      pageTitle = "page_title.help_center_title".tr();

    } else if (widget.pageType == QuickHelp.pageTypeOpenSource) {
      pageUrl = Config.openSourceUrl;
      pageTitle = "page_title.open_source_title".tr();

    } else if (widget.pageType == QuickHelp.pageTypeSafety) {
      pageUrl = Config.dataSafetyUrl;
      pageTitle = "page_title.date_safety_title".tr();

    } else if (widget.pageType == QuickHelp.pageTypeCommunity) {
      pageTitle = "page_title.community_title".tr();
    }else if (widget.pageType == QuickHelp.pageTypeWhatsapp) {
      pageTitle = "page_title.whatsapp_title".tr();
    }else if (widget.pageType == QuickHelp.pageTypeInstructions) {
      pageUrl = Config.instructionsUrl;
      pageTitle = "page_title.instructions_title".tr();
    }else if (widget.pageType == QuickHelp.pageTypeSupport) {
      pageUrl = Config.supportUrl;
      pageTitle = "page_title.support_title".tr();
    }else if (widget.pageType == QuickHelp.pageTypeCashOut) {
      pageUrl = Config.cashOutUrl;
      pageTitle = "page_title.cash_out_title".tr();
    }else{
      pageUrl = widget.receivedURL;
      pageTitle = widget.receivedTitle;
    }

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: startLoading,
          onPageFinished: doneLoading,
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(pageUrl!));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ToolBar(
        leftButtonIcon: Icons.arrow_back,
        centerTitle: true,
        onLeftButtonTap: (){
          QuickHelp.goBackToPreviousPage(context);
        },
        title: pageTitle!,
        elevation: 2,
        child: IndexedStack(
          index: position,
          children: [
            WebViewWidget(
              controller: controller,
              key: key,
            ),
            Container(
              color: QuickHelp.isDarkMode(context)
                  ? kContentColorLightTheme
                  : kContentColorDarkTheme,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        )
    );
  }
}
