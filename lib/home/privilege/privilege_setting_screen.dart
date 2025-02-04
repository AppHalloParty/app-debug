// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'package:flutter/cupertino.dart' as cupertino;

import '../guardian_vip/guardian_and_vip_store_screen.dart';

class PrivilegeSettingScreen extends StatefulWidget {
  UserModel? currentUser;

  PrivilegeSettingScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<PrivilegeSettingScreen> createState() => _PrivilegeSettingScreenState();
}

class _PrivilegeSettingScreenState extends State<PrivilegeSettingScreen> {
  var titles = [
    "privilege_screen.invisible_visitor".tr(),
    "privilege_screen.mysterious_man".tr(),
    "privilege_screen.mystery_man".tr(),
    "privilege_screen.hide_profile_cover_frame".tr(),
  ];

  var explains = [
    "privilege_screen.invisible_visitor_explain".tr(),
    "privilege_screen.mysterious_man_explain".tr(),
    "privilege_screen.mystery_man_explain".tr(),
    ""
  ];

  bool invisible = false;
  bool mysterious = false;
  bool mystery = false;
  bool coverFrame = false;

  initialize() {
    invisible = widget.currentUser!.getInvisibleVisitor!;
    mysterious = widget.currentUser!.getMysteriousMan!;
    mystery = widget.currentUser!.getMysteryMan!;
    coverFrame = widget.currentUser!.getProfileCoverFrame!;
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? kContentDarkShadow : kGrayWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: isDark ? Colors.white : kContentColorLightTheme,
          onPressed: (){
            updateUserPrivilegeSettings();
            QuickHelp.goBackToPreviousPage(context);
          },
        ),
        centerTitle: true,
        title: TextWithTap("privilege_screen.privilege_setting".tr()),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(
            height: 8,
          ),
          Column(
            children: List.generate(titles.length, (index) {
              return Visibility(
                visible: widget.currentUser!.getIsUserVip! ? true : index != 3,
                child: option(
                  title: titles[index],
                  index: index,
                  subTitle: explains[index],
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget option({
    required String title,
    required String subTitle,
    required int index,
  }) {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      borderWidth: 0,
      marginTop: 2,
      color: QuickHelp.getColorStandard(inverse: true),
      child: Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerCorner(
              width: size.width / 1.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    title,
                    fontSize: 15,
                    marginBottom: 10,
                  ),
                  TextWithTap(
                    subTitle,
                    color: kGreyColor1,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),
            cupertino.CupertinoSwitch(
              value: index == 0
                  ? invisible
                  : index == 1
                  ? mysterious
                  : index == 2
                  ? mystery
                  : index == 3
                  ? coverFrame
                  : false,
              onChanged: (value) {
                setState(() {
                  if (index == 0) {
                    if (widget.currentUser!.isSuperVip!) {
                      invisible = value;
                    } else {
                      activateInvisible(
                          msg: "privilege_screen.super_vip_can_enjoy".tr());
                    }
                  } else if (index == 1) {
                    if (widget.currentUser!.isDiamondVip!) {
                      mysterious = value;
                    } else {
                      activateInvisible(
                          msg: "privilege_screen.super_diamond_can_enjoy".tr());
                    }
                  } else if (index == 2) {
                    if (widget.currentUser!.isDiamondVip!) {
                      mystery = value;
                    } else {
                      activateInvisible(
                          msg: "privilege_screen.super_diamond_can_enjoy".tr());
                    }
                  }else if(index == 3){
                    coverFrame = value;
                  }
                });
              },
              activeColor: kPrimaryColor,
            ),
          ],
        ),
      ),
    );
  }

  activateInvisible({required String msg}) {
    QuickHelp.showDialogWithButtonCustom(
      context: context,
      title: "",
      message: msg,
      cancelButtonText: "cancel".tr(),
      confirmButtonText: "privilege_screen.open_vip".tr(),
      onPressed: () {
        QuickHelp.goBackToPreviousPage(context);
        QuickHelp.goToNavigatorScreen(
            context,
            GuardianAndVipStoreScreen(
              currentUser: widget.currentUser,
            ));
      },
    );
  }

  updateUserPrivilegeSettings() async {
    if (invisible != widget.currentUser!.getInvisibleVisitor ||
        mysterious != widget.currentUser!.getMysteriousMan ||
        mystery != widget.currentUser!.getMysteryMan ||
        coverFrame != widget.currentUser!.getProfileCoverFrame) {

      widget.currentUser!.setInvisibleVisitor = invisible;
      widget.currentUser!.setMysteriousMan = mysterious;
      widget.currentUser!.setMysteryMan = mystery;
      widget.currentUser!.setProfileCoverFrame = coverFrame;

      await widget.currentUser!.save();
    }
  }
}
