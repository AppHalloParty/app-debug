// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class AgencyScreen extends StatefulWidget {
  UserModel? currentUser;

  AgencyScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AgencyScreen> createState() => _AgencyScreenState();
}

class _AgencyScreenState extends State<AgencyScreen> {
  TextEditingController agentIdController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var notes = [
    "my_agency_screen.note_1".tr(),
    "my_agency_screen.note_2".tr(),
    "my_agency_screen.note_3".tr(),
  ];

  bool showTempAlert = false;

  showTemporaryAlert() {
    setState(() {
      showTempAlert = true;
    });
    hideTemporaryAlert();
  }

  hideTemporaryAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showTempAlert = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);

    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          centerTitle: true,
          title: TextWithTap(
            "my_agency_screen.my_agent".tr(),
            fontWeight: FontWeight.w900,
          ),
        ),
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ContainerCorner(
              height: size.height,
              width: size.width,
              borderWidth: 0,
              imageDecoration: "assets/images/agency_bg.png",
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextWithTap(
                      "my_agency_screen.choose_method".tr(),
                      color: Colors.white,
                      textAlign: TextAlign.center,
                      alignment: Alignment.center,
                      marginTop: 20,
                      fontSize: size.width / 10,
                      fontWeight: FontWeight.w900,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextWithTap(
                          "my_agency_screen.method_count"
                              .tr(namedArgs: {"number": "1"}),
                          color: kOrangeColor,
                          textAlign: TextAlign.center,
                          alignment: Alignment.center,
                          marginTop: 10,
                          fontSize: size.width / 13,
                          fontWeight: FontWeight.w900,
                        ),
                        TextWithTap(
                          "or_".tr(),
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          alignment: Alignment.center,
                          marginTop: 10,
                          marginLeft: 10,
                          marginRight: 10,
                          fontSize: size.width / 14,
                          fontWeight: FontWeight.w900,
                        ),
                        TextWithTap(
                          "my_agency_screen.method_count"
                              .tr(namedArgs: {"number": "2"}),
                          color: kOrangeColor,
                          textAlign: TextAlign.center,
                          alignment: Alignment.center,
                          marginTop: 10,
                          fontSize: size.width / 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 130,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 10,
                      ),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/agency_method.png",
                          ),
                          Column(
                            children: [
                              TextWithTap(
                                "my_agency_screen.method_count"
                                    .tr(namedArgs: {"number": "1"}),
                                color: kOrangeColor,
                                textAlign: TextAlign.center,
                                alignment: Alignment.center,
                                marginTop: 30,
                                fontSize: size.width / 15,
                                fontWeight: FontWeight.w900,
                              ),
                              TextWithTap(
                                "my_agency_screen.agent_join".tr(),
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w900,
                                marginTop: 40,
                              ),
                              TextWithTap(
                                "my_agency_screen.id_provided_by_agent".tr(),
                                color: kGrayColor,
                                marginTop: 20,
                              ),
                              ContainerCorner(
                                color: kGrayColor.withOpacity(0.1),
                                borderWidth: 1,
                                borderColor: kPrimaryColor,
                                borderRadius: 10,
                                marginBottom: 15,
                                marginTop: 10,
                                height: 45,
                                marginRight: 30,
                                marginLeft: 30,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    autocorrect: false,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    controller: agentIdController,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                    // validator: (text) {},
                                    decoration: InputDecoration(
                                      hintText:
                                          "my_agency_screen.please_enter_id"
                                              .tr(),
                                      border: InputBorder.none,
                                      hintStyle: GoogleFonts.roboto(
                                        color: kGrayColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ContainerCorner(
                                color: kPrimaryColor,
                                borderWidth: 0,
                                borderRadius: 50,
                                marginBottom: 15,
                                marginTop: 10,
                                height: 45,
                                marginRight: 30,
                                marginLeft: 30,
                                child: TextWithTap(
                                  "my_agency_screen.please_enter_id".tr(),
                                  alignment: Alignment.center,
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 10),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/agency_method.png",
                          ),
                          Column(
                            children: [
                              TextWithTap(
                                "my_agency_screen.method_count"
                                    .tr(namedArgs: {"number": "2"}),
                                color: kOrangeColor,
                                textAlign: TextAlign.center,
                                alignment: Alignment.center,
                                marginTop: 30,
                                fontSize: size.width / 15,
                                fontWeight: FontWeight.w900,
                              ),
                              TextWithTap(
                                "my_agency_screen.wait_invitation".tr(),
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w900,
                                marginTop: 40,
                              ),
                              TextWithTap(
                                "my_agency_screen.wait_invitation_explain".tr(),
                                color: kGrayColor,
                                marginTop: 20,
                                marginRight: 30,
                                marginLeft: 30,
                              ),
                              ContainerCorner(
                                marginTop: 20,
                                marginRight: 30,
                                marginLeft: 30,
                                height: 100,
                                width: size.width,
                                borderRadius: 10,
                                borderColor: kOrangeColor,
                                color: kOrangeColor.withOpacity(0.3),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWithTap(
                                            "my_agency_screen.user_id".tr(),
                                            color:
                                                Colors.black.withOpacity(0.6),
                                          ),
                                          TextWithTap(
                                            "${widget.currentUser!.getUid!}",
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            marginRight: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              QuickHelp.copyText(
                                                  textToCopy:
                                                      "${widget.currentUser!.getUid!}");
                                              showTemporaryAlert();
                                            },
                                            child: Icon(
                                              Icons.copy,
                                              color: kOrangeColor,
                                              size: 23,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextWithTap(
                                            "my_agency_screen.host_code".tr(),
                                            color:
                                                Colors.black.withOpacity(0.6),
                                          ),
                                          TextWithTap(
                                            "${widget.currentUser!.objectId!}",
                                            color: kOrangeColor,
                                            fontWeight: FontWeight.w900,
                                            marginLeft: 3,
                                            fontSize: 15,
                                            marginRight: 5,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              QuickHelp.copyText(
                                                  textToCopy:
                                                      "${widget.currentUser!.objectId!}");
                                              showTemporaryAlert();
                                            },
                                            child: Icon(
                                              Icons.copy,
                                              color: kOrangeColor,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30, right: 30, bottom: 10),
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/images/agenccy_rules_bg.png",
                          ),
                          Column(
                            children: [
                              TextWithTap(
                                "my_agency_screen.note".tr(),
                                fontWeight: FontWeight.w900,
                                marginBottom: 10,
                                marginTop: 10,
                                alignment: Alignment.center,
                                textAlign: TextAlign.center,
                                color: kContentColorLightTheme,
                                fontSize: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  notes.length,
                                  (index) => TextWithTap(
                                    notes[index],
                                    marginLeft: 15,
                                    marginRight: 15,
                                    marginTop: 10,
                                    color: kContentColorLightTheme,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showTempAlert,
              child: ContainerCorner(
                color: Colors.black.withOpacity(0.5),
                height: 50,
                marginRight: 50,
                marginLeft: 50,
                borderRadius: 50,
                width: size.width / 2,
                shadowColor: kGrayColor,
                shadowColorOpacity: 0.3,
                child: TextWithTap(
                  "copied_".tr(),
                  color: Colors.white,
                  marginBottom: 5,
                  marginTop: 5,
                  marginLeft: 20,
                  marginRight: 20,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  alignment: Alignment.center,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
