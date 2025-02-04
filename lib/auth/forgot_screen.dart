import 'package:trace/app/config.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/app_bar_center_logo.dart';
import 'package:trace/ui/button_rounded.dart';
import 'package:trace/ui/input_text_field.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/utils/colors.dart';
import 'package:trace/utils/datoo_exeption.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class ForgotScreen extends StatefulWidget {
  static const String route = '/forgot';

  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailOrAccountEditingController = TextEditingController();

  String _emailOrAccountText = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailOrAccountEditingController.dispose();
    super.dispose();
  }

  String? _validateEmail(String value){

    if(value.isEmpty){

      return "auth.no_email_account".tr();

    } else if(!value.contains("@")){

      if(value.length < 4){
        return "auth.short_username".tr();
      } else{
        return null;
      }

    } else if(!QuickHelp.isValidEmail(value)){

      return "auth.invalid_email".tr();

    } else {
      return null;
    }

  }

  // Login button clicked
  Future<void> _doLogin() async {

    _emailOrAccountText = emailOrAccountEditingController.text;

    QuickHelp.showLoadingDialog(context);

    if(!_emailOrAccountText.contains('@')){

      QueryBuilder<UserModel> queryBuilder = QueryBuilder<UserModel>(UserModel.forQuery());
      queryBuilder.whereEqualTo(UserModel.keyUsername, _emailOrAccountText);
      ParseResponse apiResponse = await queryBuilder.query();

      if (apiResponse.success && apiResponse.results != null) {

        UserModel userModel = apiResponse.results!.first;
        _processLogin(userModel.getEmailPublic);

      } else {

        showError(apiResponse.error!.code);
      }

    } else {

      _processLogin(_emailOrAccountText);
    }
  }

  Future<void> _processLogin(String? email) async {

    final user = ParseUser(null, null, email);


    var response = await user.requestPasswordReset();

    if (response.success) {
      showSuccess();
    } else {
      showError(response.error!.code);
    }
  }

  Future<void> showSuccess() async {

    QuickHelp.hideLoadingDialog(context);

    QuickHelp.showAppNotificationAdvanced(context: context, title: "auth.forgot_sent".tr(), message: "auth.email_explain".tr(), isError: false);
  }

  void showError(int error) {
    QuickHelp.hideLoadingDialog(context);

    if(error == DatooException.connectionFailed){
      // Internet problem
      QuickHelp.showAppNotificationAdvanced(context: context, title: "error".tr(), message: "not_connected".tr(), isError: true);
    } /*else if(error == DatooException.accountBlocked){
      // Internet problem
      QuickHelp.showAlertError(context: context, title: "error".tr(), message: "auth.account_blocked".tr());
    }*/ else {
      // Invalid credentials
      QuickHelp.showAppNotificationAdvanced(context: context, title: "error".tr(), message: "auth.invalid_credentials".tr(), isError: true);
    }

  }

  @override
  Widget build(BuildContext context) {

    QuickHelp.setWebPageTitle(context, "page_title.forgot_title".tr());

    return ToolBarCenterLogo(
        leftButtonIcon: Icons.arrow_back_ios,
        leftButtonPress: () => QuickHelp.goBackToPreviousPage(context),
        logoName: "ic_logo.png",
        logoHeight: 24,
        elevation: 2,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputTextField(
                controller: emailOrAccountEditingController,
                hintText: "auth.email_or_username".tr(),
                marginRight: 20,
                marginLeft: 20,
                marginTop: 10,
                marginBottom: 20,
                //inputBorder: InputBorder.none,
                isNodeNext: true,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value){
                  return _validateEmail(value!);
                },
              ),
              ButtonRounded(
                textColor: Colors.white,
                text: "auth.forgot_btn".tr(),
                color: kPrimaryColor,
                fontSize: 16,
                height: 45,
                borderRadius: 10,
                marginLeft: 20,
                marginRight: 20,
                marginBottom: 20,
                textAlign: TextAlign.center,
                onTap: (){
                  if(_formKey.currentState!.validate()) {
                    _doLogin();
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWithTap(
                    "auth.privacy_policy".tr(),
                    marginRight: 5,
                    fontSize: 12,
                    onTap: (){
                      if(QuickHelp.isMobile()){
                        QuickHelp.goToWebPage(context, pageType: QuickHelp.pageTypePrivacy);
                      } else {
                        _launchInWebViewWithJavaScript(Config.privacyPolicyUrl);
                      }
                    },
                  ),
                  TextWithTap("•", fontSize: 16,),
                  TextWithTap("auth.terms_of_use".tr(),
                    marginLeft: 5,
                    fontSize: 12,
                    onTap: (){
                      if(QuickHelp.isMobile()){
                        QuickHelp.goToWebPage(context, pageType: QuickHelp.pageTypeTerms);
                      } else {
                        _launchInWebViewWithJavaScript(Config.termsOfUseUrl);
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        )
    );
  }
}
