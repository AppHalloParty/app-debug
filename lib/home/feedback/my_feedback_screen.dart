// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_help.dart';
import '../../models/ReportModel.dart';
import '../../models/UserModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../customer_service/contact_customer_service_screen.dart';
import '../report/report_screen.dart';

class MyFeedbackScreen extends StatefulWidget {
  UserModel? currentUser;

  MyFeedbackScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<MyFeedbackScreen> createState() => _MyFeedbackScreenState();
}

class _MyFeedbackScreenState extends State<MyFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap("feedback_screen.my_feedback".tr()),
      ),
      body: feedbacks(),
      bottomNavigationBar: ContainerCorner(
        width: size.width,
        marginBottom: 20,
        color: kPrimaryColor,
        height: 45,
        marginLeft: 20,
        marginRight: 20,
        borderRadius: 10,
        onTap: () => QuickHelp.goToNavigatorScreen(
          context,
          ReportScreen(
            currentUser: widget.currentUser,
          ),
        ),
        child: Center(
          child: TextWithTap(
            "feedback_screen.questioning_".tr(),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget feedbacks() {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    QueryBuilder<ReportModel> queryBuilder =
    QueryBuilder<ReportModel>(ReportModel());
    queryBuilder.whereEqualTo(ReportModel.keyAccuserId, widget.currentUser!.objectId);
    queryBuilder.orderByDescending(ReportModel.keyCreatedAt);

    return ParseLiveListWidget<ReportModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ReportModel> snapshot) {
        if (snapshot.hasData) {
          ReportModel report = snapshot.loadedData!;
          return ButtonWidget(
            onTap: (){
              QuickHelp.goToNavigatorScreen(context, ContactCustomerServiceScreen(
                reportModel: report,
                currentUser: widget.currentUser,
              ));
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWithTap(
                          QuickHelp.getAnyIssueDetailByCode(report.getIssueDetailCode!),
                        fontSize: 16,
                        color: isDark ? Colors.white : kContentColorLightTheme,
                      ),
                      SizedBox(
                        width: size.width/ 1.3,
                        child: TextWithTap(
                          report.getMessage!,
                          marginTop: 8,
                          color: kGrayColor.withOpacity(0.8),
                          fontSize: 12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextWithTap(
                        QuickHelp.getMessageListTime(report.updatedAt!),
                        fontSize: 9,
                        color: kGrayColor,
                        marginTop: 8,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextWithTap(
                        report.getState!,
                        color: kPrimaryColor,
                        marginBottom: 30,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kGrayColor,
                        size: 9,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(child: Image.asset("assets/images/szy_kong_icon.png")),
      ),
    );
  }
}
