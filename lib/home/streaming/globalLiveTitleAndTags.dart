import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

TextEditingController liveTitleTextController = TextEditingController();
GlobalKey<FormState> formKey = GlobalKey<FormState>();
bool showErrorOnTitleInput = false;
var liveSubTypeSelected = [];
bool shuffled = false;

Widget titleAndTagsCard({
  required BuildContext context,
  required UserModel currentUser,
  required SharedPreferences preferences,
}) {
  Size size = MediaQuery.of(context).size;
  var liveTitle = [
    "random_live_title.live_chat".tr(),
    "random_live_title.playing_chat".tr(),
    "random_live_title.live_cooking".tr(),
    "random_live_title.live_with_me".tr(
      namedArgs: {"name":"${currentUser.getUsername}"},
    ),
    "random_live_title.leve_music".tr(),
    "random_live_title.live_meme".tr(),
    "random_live_title.relaxing_live".tr(),
    "random_live_title.complete_live".tr(),
    "random_live_title.drawing_live".tr(),
    "random_live_title.to_films".tr(),
  ];
  if(!shuffled) {
    shuffled = true;
    liveTitle.shuffle();
  }
  liveTitleTextController.text = liveTitle[3];
  return SafeArea(
    child: ContainerCorner(
      height: 110,
      width: size.width,
      marginLeft: 15,
      marginRight: 15,
      color: Colors.black.withOpacity(0.1),
      borderRadius: 20,
      borderWidth: 0,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerCorner(
              marginTop: 10,
              height: 40,
              width: size.width,
              borderRadius: 10,
              marginLeft: 10,
              marginRight: 10,
              borderColor: showErrorOnTitleInput
                  ? Colors.red
                  : kTransparentColor,
              child: Padding(
                padding:
                const EdgeInsets.only(left: 10),
                child: TextFormField(
                  controller: liveTitleTextController,
                  maxLines: 1,
                  autocorrect: false,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText:
                    "live_streaming.enter_title"
                        .tr(),
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    errorStyle: GoogleFonts.roboto(
                      fontSize: 0.0,
                    ),
                  ),
                  autovalidateMode:
                  AutovalidateMode.disabled,
                  validator: (value) {
                    if (value!.isEmpty) {
                      showErrorOnTitleInput = true;
                      return "";
                    } else {
                      showErrorOnTitleInput = false;
                      return null;
                    }
                  },
                ),
              ),
            ),
            ContainerCorner(
              marginTop: 15,
              height: 30,
              marginLeft: 10,
              child: ListView(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                children: List.generate(
                    QuickHelp.getLiveTagsList()
                        .length, (index) {
                  bool isSelected = liveSubTypeSelected
                      .contains(QuickHelp
                      .getLiveTagsList()[index]);
                  return ContainerCorner(
                    borderRadius: 10,
                    height: 25,
                    borderWidth: isSelected ? 0 : 1,
                    borderColor: isSelected
                        ? kTransparentColor
                        : Colors.white,
                    color: isSelected
                        ? kPrimaryColor
                        : kTransparentColor,
                    onTap: () {
                      liveSubTypeSelected.clear();
                      liveSubTypeSelected.add(QuickHelp
                          .getLiveTagsList()[
                      index]);
                    },
                    marginRight: 10,
                    child: TextWithTap(
                      QuickHelp.getLiveTagsByCode(
                          QuickHelp
                              .getLiveTagsList()[
                          index]),
                      color: Colors.white,
                      marginLeft: 8,
                      marginRight: 8,
                      alignment: Alignment.center,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    ),
  );
}