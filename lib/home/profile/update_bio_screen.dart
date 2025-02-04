// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class UpdateBioScreen extends StatefulWidget {
  UserModel? currentUser;
  UpdateBioScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<UpdateBioScreen> createState() => _UpdateBioScreenState();
}

class _UpdateBioScreenState extends State<UpdateBioScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController bioTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.currentUser!.getBio!;
  }


  @override
  void dispose() {
    super.dispose();
    bioTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        backgroundColor: isDark ? kContentColorLightTheme : kGrayWhite,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          title: TextWithTap("edit_data_screen.self_presentation".tr()),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateBio();
                }
              },
              child: TextWithTap(
                "edit_data_screen.save_".tr(),
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Column(
                children: [
                  ContainerCorner(
                    width: size.width,
                    marginTop: 10,
                    color: isDark ? kContentDarkShadow : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        onChanged: (text) {},
                        maxLines: 5,
                        maxLength: 250,
                        validator: (text) {
                          return validateBio(text!);
                        },
                        controller: bioTextController,
                        decoration: InputDecoration(
                          hintText: widget.currentUser!.getBio,
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.roboto(
                            color: kGrayColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  String? validateBio(String value) {
    String text = value;
    String textWithoutSpaces = text.replaceAll(" ", "");

    if (text.isEmpty) {
      return "edit_data_screen.self_presentation_needed".tr();
    } else if (textWithoutSpaces.isEmpty) {
      return "edit_data_screen.empty_text".tr();
    } else if (text == widget.currentUser!.getBio) {
      return "edit_data_screen.no_changes".tr();
    } else {
      return null;
    }
  }

  updateBio() async {

      QuickHelp.showLoadingDialog(context);

      widget.currentUser!.setBio = bioTextController.text;

      ParseResponse response = await widget.currentUser!.save();

      if (response.success && response.results != null) {
        QuickHelp.hideLoadingDialog(context);

        widget.currentUser = response.results!.first;
        bioTextController.text = widget.currentUser!.getBio!;

        QuickHelp.showAppNotificationAdvanced(
          title: "edit_data_screen.updated_success_title".tr(),
          message: "edit_data_screen.bio_updated_success_explain".tr(),
          isError: false,
          context: context,
        );
      } else {
        QuickHelp.hideLoadingDialog(context);

        QuickHelp.showAppNotificationAdvanced(
          title: "edit_data_screen.updated_failed_title".tr(),
          message: "edit_data_screen.updated_failed_explain".tr(),
          context: context,
        );
      }
  }
}

