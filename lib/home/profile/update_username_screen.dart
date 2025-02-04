// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class UpdateUsernameScreen extends StatefulWidget {
  UserModel? currentUser;

  UpdateUsernameScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<UpdateUsernameScreen> createState() => _UpdateUsernameScreenState();
}

class _UpdateUsernameScreenState extends State<UpdateUsernameScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController usernameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    usernameEditingController.text = widget.currentUser!.getFullName!;
  }

  @override
  void dispose() {
    super.dispose();
    usernameEditingController.dispose();
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
          title: TextWithTap("edit_data_screen.username_".tr()),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  updateUsername();
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
                    controller: usernameEditingController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.currentUser!.getFullName!,
                      hintStyle: GoogleFonts.roboto(
                        color: kGrayColor,
                      ),
                    ),
                    autovalidateMode: AutovalidateMode.disabled,
                    validator: (value) {
                      return validateUsername(value!);
                    },
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  updateUsername() async {

      QuickHelp.showLoadingDialog(context);
      var names = usernameEditingController.text.split(" ");
      String username = "";
      for (String name in names) {
        username = username + name.toLowerCase();
      }

      widget.currentUser!.setFullName = usernameEditingController.text;
      widget.currentUser!.setFirstName = names[0];
      widget.currentUser!.setLastName = names[names.length - 1];
      widget.currentUser!.setUsername = username;

      ParseResponse response = await widget.currentUser!.save();

      if (response.success && response.results != null) {
        QuickHelp.hideLoadingDialog(context);

        widget.currentUser = response.results!.first;
        usernameEditingController.text = widget.currentUser!.getFullName!;

        QuickHelp.showAppNotificationAdvanced(
          title: "edit_data_screen.updated_success_title".tr(),
          message: "edit_data_screen.updated_success_explain".tr(),
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

  String? validateUsername(String value) {
    String text = value;
    String textWithoutSpaces = text.replaceAll(" ", "");
    var words = text.split(" ");

    if (text.isEmpty) {
      return "edit_data_screen.username_needed".tr();
    } else if (textWithoutSpaces.isEmpty) {
      return "edit_data_screen.empty_text".tr();
    } else if (words.length < 2) {
      return "edit_data_screen.full_name_needed".tr();
    } else if (text == widget.currentUser!.getFullName) {
      return "edit_data_screen.no_changes".tr();
    } else {
      return null;
    }
  }
}
