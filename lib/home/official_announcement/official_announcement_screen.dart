// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_help.dart';
import '../../models/OfficialAnnouncementModel.dart';
import '../../models/UserModel.dart';
import '../../ui/text_with_tap.dart';
import '../web/web_url_screen.dart';

class OfficialAnnouncementScreen extends StatefulWidget {
  static String route = "/official/announcement";
  UserModel? currentUser;

  OfficialAnnouncementScreen({ this.currentUser, Key? key})
      : super(key: key);

  @override
  State<OfficialAnnouncementScreen> createState() =>
      _OfficialAnnouncementScreenState();
}

class _OfficialAnnouncementScreenState
    extends State<OfficialAnnouncementScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:
          isDarkMode ? kContentDarkShadow : Colors.white.withOpacity(0.96),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDarkMode ? kContentColorLightTheme : Colors.white,
        leading: BackButton(
          color: kGrayDark,
        ),
        centerTitle: true,
        title: TextWithTap(
          "official_announcement_screen.official_announcement".tr(),
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ContainerCorner(
        borderWidth: 0,
        width: size.width,
        height: size.height,
        marginTop: 20,
        child: getAllAnnouncements(),
      ),
    );
  }

  Widget getAllAnnouncements() {
    QueryBuilder<OfficialAnnouncementModel> queryBuilder =
        QueryBuilder<OfficialAnnouncementModel>(OfficialAnnouncementModel());
    queryBuilder.orderByDescending(OfficialAnnouncementModel.keyCreatedAt);

    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);

    return ParseLiveListWidget<OfficialAnnouncementModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: Duration(milliseconds: 200),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<ParseObject> snapshot) {
        if (snapshot.failed) {
          return Text('not_connected'.tr());
        } else if (snapshot.hasData) {
          OfficialAnnouncementModel announcement =
              snapshot.loadedData! as OfficialAnnouncementModel;

          bool hasRead =
              announcement.getViewedBy!.contains(widget.currentUser!.objectId!);

          return ContainerCorner(
            width: size.width,
            marginLeft: 15,
            marginRight: 15,
            borderRadius: 10,
            color: isDarkMode ? kContentColorLightTheme : Colors.white,
            marginBottom: 15,
            onTap: () {
              QuickHelp.goToNavigatorScreen(
                  context,
                  WebViewScreen(
                    pageType: 'announcement',
                    receivedTitle: announcement.getTitle,
                    receivedURL: announcement.getWebViewURL,
                  ),
              );
              markAsRead(announcement: announcement);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    announcement.getTitle!,
                    fontWeight: FontWeight.bold,
                    marginTop: 10,
                  ),
                  TextWithTap(
                    QuickHelp.getTimeAgoForFeed(announcement.createdAt!),
                    color: kGrayColor,
                    marginTop: 10,
                    fontSize: 12,
                    marginBottom: 10,
                  ),
                  ContainerCorner(
                    borderRadius: 20,
                    height: 200,
                    child: QuickActions.photosWidget(
                        announcement.getPreviewImage!.url),
                  ),
                  TextWithTap(
                    announcement.getSubTitle!,
                    marginTop: 10,
                  ),
                  ContainerCorner(
                    height: 0.5,
                    width: size.width,
                    color: kGrayDark.withOpacity(0.4),
                    marginTop: 10,
                    marginBottom: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithTap(
                          "official_announcement_screen.check_details".tr(),
                          color: kGrayColor,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ContainerCorner(
                              height: 17,
                              borderRadius: 50,
                              marginRight: 3,
                              color: hasRead
                                  ? kGrayColor.withOpacity(0.3)
                                  : Colors.red,
                              child: TextWithTap(
                                hasRead
                                    ? "official_announcement_screen.read_".tr()
                                    : "official_announcement_screen.unread_".tr(),
                                fontSize: 9,
                                alignment: Alignment.center,
                                marginRight: 10,
                                marginLeft: 10,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: kGrayColor,
                              size: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: Center(
        child: CircularProgressIndicator(),
      ),
      queryEmptyElement: ContainerCorner(
        borderWidth: 0,
        width: size.width,
        height: size.height,
        child: TextWithTap(
          "official_announcement_screen.empty_announcements_message".tr(),
          fontSize: 12,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  markAsRead({required OfficialAnnouncementModel announcement}) {
    announcement.setViewedBy = [widget.currentUser!.objectId];
    announcement.save();
  }

}
