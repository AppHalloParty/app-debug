// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/models/UserModel.dart';

import '../../helpers/quick_help.dart';
import '../../models/ReportModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../feed/video_player_network_screen.dart';
import '../feed/visualize_multiple_pictures_screen.dart';
import '../report/report_screen.dart';

class ContactCustomerServiceScreen extends StatefulWidget {
  UserModel? currentUser;
  ReportModel? reportModel;

  ContactCustomerServiceScreen(
      {required this.reportModel, this.currentUser, Key? key})
      : super(key: key);

  @override
  State<ContactCustomerServiceScreen> createState() =>
      _ContactCustomerServiceScreenState();
}

class _ContactCustomerServiceScreenState
    extends State<ContactCustomerServiceScreen> {
  int clickedImageIndex = 0;
  bool showResolveBtn = true;

  verifyResolved() {
    if(widget.reportModel!.getState == ReportModel.stateResolved) {
      showResolveBtn = false;
    }else{
      showResolveBtn = true;
    }
    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    verifyResolved();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    int picturesCount = widget.reportModel!.getImagesList!.length;
    List pictures = widget.reportModel!.getImagesList!;

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
        ),
        centerTitle: true,
        title: TextWithTap(
          "contact_customer_service_screen.customer_service".tr(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ContainerCorner(
                  color: kPrimaryColor.withOpacity(0.1),
                  radiusBottomLeft: 10,
                  radiusTopLeft: 10,
                  radiusTopRight: 10,
                  marginRight: 5,
                  width: size.width / 1.5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ContainerCorner(
                        child: TextWithTap(
                          widget.reportModel!.getMessage!,
                          marginTop: 10,
                          marginBottom: 15,
                          marginLeft: 10,
                          marginRight: 10,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        color: kPrimaryColor,
                        radiusTopLeft: 10,
                        radiusTopRight: 10,
                        marginBottom: 10,
                        width: size.width / 1.5,
                      ),
                      if (widget.reportModel!.getImagesList != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Wrap(
                            children: List.generate(
                              picturesCount,
                              (index) => ContainerCorner(
                                width: size.width / 5,
                                height: size.width / 5,
                                borderWidth: 0,
                                marginRight: 5,
                                marginBottom: 5,
                                borderRadius: 8,
                                onTap: () {
                                  setState(() {
                                    clickedImageIndex = index;
                                  });
                                  QuickHelp.goToNavigatorScreen(
                                      context,
                                      VisualizeMultiplePicturesScreen(
                                        picturesFromDataBase: pictures,
                                        initialIndex: clickedImageIndex,
                                      ));
                                },
                                child: QuickActions.photosWidget(
                                    pictures[index].url),
                              ),
                            ),
                          ),
                        ),
                      if (widget.reportModel!.getVideo != null)
                        ContainerCorner(
                          width: 100,
                          height: 120,
                          borderRadius: 10,
                          borderWidth: 0,
                          marginBottom: 10,
                          marginLeft: 15,
                          onTap: () {
                            QuickHelp.goToNavigatorScreen(
                              context,
                              VideoPlayerNetworkScreen(
                                currentUser: widget.currentUser,
                               videoURL: widget.reportModel!.getVideo!.url!,
                              ),
                            );
                          },
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              QuickActions.photosWidget(
                                  widget.reportModel!.getVideoThumbnail!.url),
                              ContainerCorner(
                                height: 40,
                                width: 40,
                                borderRadius: 50,
                                borderWidth: 0,
                                color: Colors.black.withOpacity(0.7),
                                child: Center(
                                    child: Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.white,
                                )),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                QuickActions.avatarWidget(
                  widget.currentUser!,
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.only(right: 15),
                )
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ContainerCorner(
                  borderRadius: 50,
                  color: kPrimaryColor,
                  marginLeft: 10,
                  height: 45,
                  width: 45,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, left: 5, right: 5, bottom: 10),
                    child: SvgPicture.asset(
                      "assets/svg/ic_system_msg.svg",
                    ),
                  ),
                ),
                ContainerCorner(
                  color: isDark ? kContentColorLightTheme : Colors.white,
                  width: size.width / 1.7,
                  marginLeft: 5,
                  marginTop: 15,
                  radiusTopRight: 10,
                  radiusTopLeft: 10,
                  radiusBottomRight: 10,
                  child: TextWithTap(
                      "contact_customer_service_screen.thanks_feedback".tr(),
                    marginLeft: 5,
                    marginRight: 10,
                    marginTop: 10,
                    marginBottom: 10,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: showResolveBtn,
        child: ContainerCorner(
          width: size.width,
          marginBottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ContainerCorner(
                color: kPrimaryColor.withOpacity(0.3),
                height: 45,
                borderRadius: 10,
                width: size.width / 2.3,
                onTap: () => showAlert(),
                child: Center(
                  child: TextWithTap(
                    "contact_customer_service_screen.solved_".tr(),
                    color: isDark ? Colors.white : kPrimaryColor,
                  ),
                ),
              ),
              ContainerCorner(
                color: kPrimaryColor,
                height: 45,
                borderRadius: 10,
                width: size.width / 2.3,
                onTap: () => QuickHelp.goToNavigatorScreen(
                  context,
                  ReportScreen(
                    currentUser: widget.currentUser,
                  ),
                ),
                child: Center(
                  child: TextWithTap(
                    "contact_customer_service_screen.continue_questions".tr(),
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showAlert() {
    bool isDark = QuickHelp.isDarkMode(context);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWithTap(
                    "contact_customer_service_screen.tips_".tr(),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  marginBottom: 10,
                  marginTop: 10,
                ),
                TextWithTap(
                  "contact_customer_service_screen.confirmation_msg".tr(),
                  textAlign: TextAlign.center,
                  fontSize: 17,
                  color: kGrayColor,
                  alignment: Alignment.center,
                  marginBottom: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: ()=> QuickHelp.goBackToPreviousPage(context),
                        child: TextWithTap("cancel".tr(),
                          marginRight: 25,
                          marginLeft: 25,
                        ),
                    ),
                    TextButton(
                        onPressed: (){
                          QuickHelp.goBackToPreviousPage(context);
                          resolveReport();
                        },
                        child: TextWithTap(
                          "confirm_".tr(),
                          color: Colors.red,
                          marginRight: 25,
                          marginLeft: 25,
                        ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  resolveReport() async{
    QuickHelp.showLoadingDialog(context);

    widget.reportModel!.setState = ReportModel.stateResolved;
    ParseResponse response =  await widget.reportModel!.save();

    if(response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      setState(() {
        showResolveBtn = false;
      });
    }else{
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }

  }
}
