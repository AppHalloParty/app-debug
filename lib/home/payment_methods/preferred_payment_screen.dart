// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_help.dart';
import '../../models/NewPaymentMethodResquestModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class PreferredPaymentScreen extends StatefulWidget {
  UserModel? currentUser;

  PreferredPaymentScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<PreferredPaymentScreen> createState() => _PreferredPaymentScreenState();
}

class _PreferredPaymentScreenState extends State<PreferredPaymentScreen> {
  TextEditingController textController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Color inputBorderColor = kTransparentColor;

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          title: TextWithTap(
            "payment_method_screen.payment_method".tr(),
            fontWeight: FontWeight.bold,
          ),
        ),
        body: ListView(
          children: [
            Form(
                key: formKey,
                child: ContainerCorner(
                  borderRadius: 8,
                  marginLeft: 15,
                  marginRight: 15,
                  marginTop: 10,
                  borderColor: inputBorderColor,
                  color: kGrayColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      controller: textController,
                      validator: (text) {
                        if (text!.isEmpty) {
                          setState(() {
                            inputBorderColor = Colors.red;
                          });
                          return "payment_method_screen.input_hint_text".tr();
                        } else {
                          setState(() {
                            inputBorderColor = kTransparentColor;
                          });
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "payment_method_screen.input_hint_text".tr(),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )),
            ContainerCorner(
              height: 45,
              borderRadius: 50,
              marginLeft: 15,
              marginRight: 15,
              marginTop: 40,
              color: kPrimaryColor,
              onTap: () {
                if (formKey.currentState!.validate()) {
                  saveNewPaymentMethodRequest();
                }
              },
              child: TextWithTap(
                "submit_".tr(),
                color: Colors.white,
                alignment: Alignment.center,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveNewPaymentMethodRequest() async {
    QuickHelp.showLoadingDialog(context);
    NewPaymentMethodRequest newPaymentMethodRequest = NewPaymentMethodRequest();

    newPaymentMethodRequest.setAuthor = widget.currentUser!;
    newPaymentMethodRequest.setAuthorId = widget.currentUser!.objectId!;
    newPaymentMethodRequest.setExplanation = textController.text;
    ParseResponse response = await newPaymentMethodRequest.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "done".tr(),
        isError: false,
        message: "operation_completed_successfully".tr(),
      );
      setState(() {
        textController.text = "";
      });
    } else {
      QuickHelp.hideLoadingDialog(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }
}
