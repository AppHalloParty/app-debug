// ignore_for_file: must_be_immutable, close_sinks

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../app/Config.dart';
import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/button_with_icon.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/phone_number_field.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../../utils/datoo_exeption.dart';
import '../../widgets/CountDownTimer.dart';

class BindPoneNumberScreen extends StatefulWidget {
  UserModel? currentUser;

  BindPoneNumberScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<BindPoneNumberScreen> createState() => _BindPoneNumberScreenState();
}

FirebaseAuth _auth = FirebaseAuth.instance;
late ConfirmationResult confirmationResult;
late UserCredential userCredential;

class _BindPoneNumberScreenState extends State<BindPoneNumberScreen> {
  String titlePage = "";

  GlobalKey<FormState> phoneNumberKey = GlobalKey<FormState>();
  GlobalKey<FormState> verificationCodeKey = GlobalKey<FormState>();

  String countryIsoCode = Config.initialCountry;
  String countryDialCode = QuickHelp.getCountryDialCode(Config.initialCountry);
  List<String> languagesIso =  QuickHelp.getLanguageByCountryIso(code: Config.initialCountry);
  bool isEmptyPhoneField =  false;

  TextEditingController phoneNumberEditingController = TextEditingController();
  TextEditingController pinCodeEditingController = TextEditingController();

  StreamController<ErrorAnimationType>? errorController;

  String phoneNumber = "";
  String _pinCode = "";
  bool validPhoneNumber = false;
  bool isPinSet = false;

  bool _showResend = false;
  late String _verificationId;
  int? _tokenResend;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    if (widget.currentUser!.getPhoneNumber!.isNotEmpty) {
      titlePage = "bind_phone_number_screen.modify_the_phone".tr();
    } else {
      titlePage = "auth_screen.bind_phone".tr();
    }
  }

  @override
  void dispose() {
    super.dispose();
    errorController!.close();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? kContentColorLightTheme : Colors.white,
          elevation: 1.5,
          centerTitle: true,
          title: TextWithTap(
            titlePage,
            fontWeight: FontWeight.w900,
          ),
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
        ),
        body: ListView(
          children: [
            Visibility(
              visible: widget.currentUser!.getPhoneNumberFull!.isNotEmpty,
              child: TextWithTap("bind_phone_number_screen.original_phone".tr(
                  namedArgs: {
                    "number": widget.currentUser!.getPhoneNumberFull!
                  }),
                marginLeft: 15,
                marginTop: 10,
                color: kGrayColor,
              ),
            ),
            TextWithTap(
              "bind_phone_number_screen.phone_number".tr(),
              fontWeight: FontWeight.w700,
              marginLeft: 15,
              fontSize: 16,
              marginTop: 10,
              marginBottom: 5,
            ),
            Form(
              key: phoneNumberKey,
              child: phoneNumberInput(),
            ),
            TextWithTap(
              "bind_phone_number_screen.verification_code".tr(),
              fontWeight: FontWeight.w700,
              marginLeft: 15,
              fontSize: 16,
              marginTop: 30,
              marginBottom: 5,
            ),
            Form(
              key: verificationCodeKey,
              child: Row(
                children: [
                  Flexible(
                    child: ContainerCorner(
                      borderRadius: 10,
                      marginLeft: 15,
                      height: 55,
                      color: isDark
                          ? Colors.blueAccent.withOpacity(0.3)
                          : Colors.blueAccent.withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: PinCodeTextField(
                          appContext: context,
                          length: Setup.verificationCodeDigits,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          autoFocus: true,
                          pinTheme: PinTheme(
                            borderWidth: 2.0,
                            shape: PinCodeFieldShape.underline,
                            borderRadius: BorderRadius.zero,
                            fieldHeight: 50,
                            fieldWidth: 45,
                            activeFillColor: Colors.transparent,
                            inactiveFillColor: Colors.transparent,
                            selectedFillColor: Colors.transparent,
                            activeColor: kPrimaryColor,
                            inactiveColor: kDisabledColor,
                            selectedColor: kDisabledGrayColor,
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          backgroundColor: Colors.transparent,
                          errorAnimationController: errorController,
                          enableActiveFill: true,
                          controller: pinCodeEditingController,
                          autovalidateMode: AutovalidateMode.always,
                          validator: (value) {
                            return null;
                          },
                          useHapticFeedback: true,
                          hapticFeedbackTypes: HapticFeedbackTypes.selection,
                          onChanged: (value) {
                            print(value);
                          },
                          onCompleted: (pin) {
                            _pinCode = pin;
                            setState(() {
                              if (pin.isNotEmpty && pin.length > 5) {
                                isPinSet = true;
                              } else {
                                isPinSet = false;
                              }
                            });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            return true;
                          },
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (phoneNumberKey.currentState!.validate()) {
                        if (widget.currentUser!.getPhoneNumberFull ==
                            countryDialCode+phoneNumberEditingController.text) {
                          QuickHelp.showAppNotificationAdvanced(
                            title: "error".tr(),
                            message:
                                "bind_phone_number_screen.already_linked_number"
                                    .tr(),
                            context: context,
                          );
                        } else {
                          _checkUsedNumber();
                        }
                      }
                    },
                    child: TextWithTap(
                      "bind_phone_number_screen.get_".tr(),
                      color: kPrimaryColor,
                      marginLeft: 10,
                      marginRight: 15,
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ContainerCorner(
                      marginTop: 3,
                      marginRight: 4,
                      color: Colors.transparent,
                      child: Visibility(
                        visible: _showResend,
                        child: CountDownTimer(
                          countDownTimerStyle: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                          text: "auth.resend_in".tr(),
                          secondsRemaining: 30,
                          whenTimeExpires: () {
                            setState(() {
                              _showResend = true;
                            });
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _showResend,
                      child: TextWithTap(
                        "auth.resend_now".tr(),
                        marginTop: 10,
                        marginBottom: 5,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        onTap: () =>
                            _showResend ? _sendVerificationCode(true) : null,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ButtonWithIcon(
              mainAxisAlignment: MainAxisAlignment.center,
              height: 45,
              marginTop: 30,
              marginBottom: 10,
              borderRadius: 60,
              marginLeft: 30,
              marginRight: 30,
              fontSize: 14,
              textColor: Colors.white,
              backgroundColor: validPhoneNumber
                  ? kPrimaryColor
                  : kPrimaryColor.withOpacity(0.4),
              text: "ok_".tr(),
              fontWeight: FontWeight.normal,
              onTap: !isPinSet
                  ? null
                  : () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (verificationCodeKey.currentState!.validate()) {
                        verifyCode(_pinCode);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode(bool resend) async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);

      print('Verified automatically');
    };

    PhoneVerificationFailed verificationFailed = (FirebaseAuthException e) {
      QuickHelp.hideLoadingDialog(context);

      print(
          'Phone number verification failed. Code: ${e.code}. Message: ${e.message}');

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else if (e.code == "invalid-phone-number") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_phone_number".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      QuickHelp.hideLoadingDialog(context);
      // Check your phone for the sms code
      _verificationId = verificationId;
      _tokenResend = forceResendingToken;

      print('Verification code sent');

      setState(() {
        _showResend = true;
      });
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      print('PhoneCodeAutoRetrievalTimeout');
    };

    try {
      if (QuickHelp.isWebPlatform()) {
        confirmationResult =
            await _auth.signInWithPhoneNumber(countryDialCode+phoneNumberEditingController.text);
        //userCredential = await confirmationResult.confirm('123456');
      } else {
        await _auth.verifyPhoneNumber(
            phoneNumber: countryDialCode+phoneNumberEditingController.text,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            forceResendingToken: _tokenResend,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
      }
    } on FirebaseAuthException catch (e) {
      QuickHelp.hideLoadingDialog(context);

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else if (e.code == "invalid-phone-number") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_phone_number".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    }
  }

  Future<void> verifyCode(String pinCode) async {
    _pinCode = pinCode;
    QuickHelp.showLoadingDialog(context);

    try {
      if (QuickHelp.isWebPlatform()) {
        userCredential = await confirmationResult.confirm(_pinCode);

        final User? user =
            (await _auth.signInWithCredential(userCredential.credential!)).user;

        if (user != null) {
          bindUserPhoneNumber();
        }
      } else {
        final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: _pinCode,
        );

        final User? user = (await _auth.signInWithCredential(credential)).user;

        if (user != null) {
          bindUserPhoneNumber();
        }
      }

      //return;
    } on FirebaseAuthException catch (e) {
      QuickHelp.hideLoadingDialog(context);

      if (e.code == "web-context-cancelled") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.canceled_phone".tr());
      } else if (e.code == "invalid-verification-code") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "auth.invalid_code".tr());
      } else if (e.code == "network-request-failed") {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "no_internet_connection".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context,
            title: "error".tr(),
            message: "try_again_later".tr());
      }
    }
  }

  Widget phoneNumberInput() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          PhoneNumberTextField(
            marginRight: 15,
            countrySearchHint: "auth.country_input_hint".tr(),
            hintText: "auth.enter_phone_num".tr(),
            marginBottom: 15,
            marginLeft: 15,
            controller: phoneNumberEditingController,
            inputBorder: InputBorder.none,
            radiusBottomRight: 10,
            radiusTopRight: 10,
            radiusTopLeft: 10,
            radiusBottomLeft: 10,
            borderWidth: isEmptyPhoneField ? 1 : 0,
            borderColor: isEmptyPhoneField ? kRedColor1 : kTransparentColor,
            errorTextField: TextStyle(fontSize: 0.0),
            validator: (text) {
              if(text!.isEmpty) {
                isEmptyPhoneField = true;
                setState(() {});
                return "";
              }
              isEmptyPhoneField = false;
              setState(() {});
              return null;
            },
            onChanged: (text) {
              if(text.isEmpty) {
                isEmptyPhoneField = true;
                setState(() {});
              }else{
                isEmptyPhoneField = false;
                setState(() {});
              }
            },
            backgroundColor: isDarkMode
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.blueAccent.withOpacity(0.05),
            onCountryChanged: (country) {
              countryIsoCode = country.isoCode;
              countryDialCode = country.dialCode;
              languagesIso =  country.languagesIso;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkUsedNumber() async {
    QuickHelp.showLoadingDialog(context);
    QueryBuilder<UserModel> queryBuilder =
        QueryBuilder<UserModel>(UserModel.forQuery());
    queryBuilder.whereEqualTo(UserModel.keyPhoneNumber, phoneNumberEditingController.text);
    queryBuilder.whereNotEqualTo(
        UserModel.keyObjectId, widget.currentUser!.objectId);
    ParseResponse apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.results != null) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          title: "error".tr(),
          context: context,
          message:
              "bind_phone_number_screen.the_phone_bounded_to_another_account"
                  .tr());
      setState(() {
        phoneNumberEditingController.text = "";
      });
    } else if (apiResponse.success && apiResponse.results == null) {
      QuickHelp.hideLoadingDialog(context);
      _sendVerificationCode(false);
    } else {
      QuickHelp.hideLoadingDialog(context);
      showError(apiResponse.error!.code);
    }
  }

  void showError(int error) {
    QuickHelp.hideLoadingDialog(context);

    if (error == DatooException.connectionFailed) {
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr());
    } else if (error == DatooException.accountBlocked) {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.account_blocked".tr());
    } else if (error == DatooException.accountDeleted) {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.account_deleted".tr());
    } else {
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "auth.invalid_credentials".tr());
    }
  }

  bindUserPhoneNumber() async {
    widget.currentUser!.setCountryCode = countryIsoCode;
    widget.currentUser!.setCountryDialCode = countryDialCode;
    widget.currentUser!.setPhoneNumber = phoneNumberEditingController.text;
    widget.currentUser!.setPhoneNumberFull = countryDialCode+phoneNumberEditingController.text;

    ParseResponse response = await widget.currentUser!.save();

    if (response.success && response.results != null) {
      QuickHelp.hideLoadingDialog(context);
      widget.currentUser = response.results!.first;
      QuickHelp.goBackToPreviousPage(context, result: widget.currentUser!);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }
}
