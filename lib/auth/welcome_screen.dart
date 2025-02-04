import 'dart:async';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/app/config.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/auth/phone_login_screen.dart';
import 'package:trace/auth/social_login.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  static const String route = '/welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  bool hasError = false;
  late VideoPlayerController videoController;

  late SharedPreferences preferences;

  bool agreeWithTerms = false;
  bool showAgreeAlert = false;

  showAgreeWithTermsAlert() {
    setState(() {
      showAgreeAlert = true;
    });
    hideAgreeWithTermsAlert();
  }

  hideAgreeWithTermsAlert() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showAgreeAlert = false;
      });
    });
  }

  @override
  void initState() {
    initSharedPref();
    videoController = VideoPlayerController.asset("assets/video/welcome_flash_bg.mp4");

    videoController.addListener(() {
      setState(() {});
    });
    videoController.setLooping(true);
    videoController.initialize().then((_) => setState(() {}));
    videoController.play();
    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }


  initSharedPref() async {
    preferences = await SharedPreferences.getInstance();
  }

  Future<void> googleLogin() async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await account!.authentication;

      QuickHelp.showLoadingDialog(context);

      var allName = account.displayName!.split(" ");
      String firstName = allName[0];
      String secondName = allName.length >= 1 ? allName[1] : "";

      final ParseResponse response = await ParseUser.loginWith(
          'google',
          google(authentication.accessToken!, _googleSignIn.currentUser!.id,
              authentication.idToken!),
        email: account.email,
        username: firstName.toLowerCase() + secondName.toLowerCase(),
      );
      if (response.success) {
        UserModel? user = await ParseUser.currentUser();

        if (user != null) {
          if (user.getUid == null) {
            getGoogleUserDetails(user, account, authentication.idToken!);
          } else {
            SocialLogin.goHome(context, user);
          }
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              context: context, title: "auth.gg_login_error".tr());
          await _googleSignIn.signOut();
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: response.error!.message);
        await _googleSignIn.signOut();
      }
    } catch (error) {
      if (error == GoogleSignIn.kSignInCanceledError) {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_cancelled".tr());
      } else if (error == GoogleSignIn.kNetworkError) {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "not_connected".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_error".tr());
      }

      await _googleSignIn.signOut();
    }
  }

  void getGoogleUserDetails(
      UserModel user, GoogleSignInAccount googleUser, String idToken) async {
    Map<String, dynamic>? idMap = QuickHelp.getInfoFromToken(idToken);

    String firstName = idMap!["given_name"];
    String lastName = idMap["family_name"];

    String username =
        lastName.replaceAll(" ", "") + firstName.replaceAll(" ", "");

    user.setFullName = googleUser.displayName!;
    user.setGoogleId = googleUser.id;
    user.setFirstName = firstName;
    user.setLastName = lastName;
    user.username = username.toLowerCase().trim();
    user.setEmail = googleUser.email;
    user.setEmailPublic = googleUser.email;
    //user.setGender = await getGender();
    user.setUid = QuickHelp.generateUId();
    user.setPopularity = 0;
    user.setUserRole = UserModel.roleUser;
    user.setPrefMinAge = Setup.minimumAgeToRegister;
    user.setPrefMaxAge = Setup.maximumAgeToRegister;
    user.setLocationTypeNearBy = true;
    user.addCredit = Setup.welcomeCredit;
    user.setBio = Setup.bio;
    user.setHasPassword = false;
    //user.setBirthday = QuickHelp.getDateFromString(user['birthday'], QuickHelp.dateFormatFacebook);
    ParseResponse response = await user.save();

    if (response.success) {
      SocialLogin.getPhotoFromUrl(
          context, user, googleUser.photoUrl!);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    QuickHelp.setWebPageTitle(context,
        "page_title.welcome_title".tr(namedArgs: {"app_name": Config.appName}));
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white])),
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                //SlidingImage(imagePath: "assets/images/background.png",),
                ContainerCorner(
                  width: size.width,
                  height: size.height,
                  borderWidth: 0,
                  child: VideoPlayer(videoController),
                ),
                ContainerCorner(
                  width: size.width,
                  height: size.height,
                  borderWidth: 0,
                  color: Colors.black.withOpacity(0.7),
                ),
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20, left: 30),
                        child: Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/ic_logo_legend.png",
                            height: size.width / 2.2,
                            width: size.width / 2.2,
                            //color: kPrimaryColor,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          ContainerCorner(
                            height: 48,
                            marginLeft: 50,
                            marginRight: 50,
                            color: Colors.white,
                            borderRadius: 50,
                            marginBottom: 10,
                            onTap: (){
                              if(agreeWithTerms){
                                googleLogin();
                              }else{
                                showAgreeWithTermsAlert();
                              }
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 25),
                                  child: SvgPicture.asset(
                                    "assets/svg/ic_google_logo.svg",
                                    height: 25,
                                    width: 25,
                                  ),
                                ),
                                TextWithTap(
                                  "login_screen.connect_google".tr(),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.blueAccent,
                                  textAlign: TextAlign.center,
                                  marginRight: 20,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: QuickHelp.isAndroidLogin(),
                            child: ContainerCorner(
                              height: 48,
                              marginLeft: 50,
                              marginRight: 50,
                              color: Colors.white,
                              borderRadius: 50,
                              marginBottom: 50,
                              onTap: () {
                                if(agreeWithTerms) {
                                  SocialLogin.loginApple(
                                      context, preferences);
                                }else{
                                  showAgreeWithTermsAlert();
                                }
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 25),
                                    child: SvgPicture.asset(
                                      "assets/svg/ic_apple_logo.svg",
                                      height: 25,
                                      width: 25,
                                    ),
                                  ),
                                  TextWithTap(
                                    "login_screen.sign_apple".tr(),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    textAlign: TextAlign.center,
                                    marginRight: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextWithTap(
                            "login_screen.more_methods".tr(),
                            fontSize: 9,
                            color: kGrayColor,
                            marginBottom: 10,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Visibility(
                                visible: false,
                                child: ContainerCorner(
                                  color: Colors.white,
                                  height: 40,
                                  width: 40,
                                  borderRadius: 50,
                                  borderWidth: 0,
                                  marginRight: 30,
                                  onTap: (){
                                    if(agreeWithTerms) {
                                      SocialLogin.loginFacebook(
                                          context);
                                    }else{
                                      showAgreeWithTermsAlert();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                        "assets/svg/ic_facebook_logo.svg"),
                                  ),
                                ),
                              ),
                              ContainerCorner(
                                color: Colors.white,
                                height: 40,
                                width: 40,
                                borderRadius: 50,
                                borderWidth: 0,
                                onTap: (){
                                  if(agreeWithTerms){
                                    QuickHelp.goToNavigatorScreen(context, PhoneLoginScreen());
                                  }else{
                                    showAgreeWithTermsAlert();
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SvgPicture.asset(
                                      "assets/svg/ic_phone_login.svg"),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                agreeWithTerms = !agreeWithTerms;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  agreeWithTerms
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: agreeWithTerms ? Colors.blueAccent : Colors.white,
                                  size: 14,
                                ),
                                TextWithTap(
                                  "login_screen.by_using".tr(namedArgs: {
                                    "app_name": Config.appName
                                  }),
                                  color: Colors.white,
                                  fontSize: 11,
                                  marginLeft: 5,
                                ),
                              ],
                            ),
                          ),
                          ContainerCorner(
                            marginLeft: 20,
                            marginRight: 20,
                            marginBottom: 40,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: [
                                  TextSpan(
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.lightBlueAccent,
                                        decoration:
                                        TextDecoration.underline,
                                      ),
                                      text:
                                      "login_screen.terms_of_service"
                                          .tr(),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (QuickHelp.isMobile()) {
                                            debugPrint("o_que_esta_vend0???");
                                            QuickHelp.goToWebPage(context,
                                                pageType: QuickHelp
                                                    .pageTypeTerms);
                                          } else {
                                            QuickHelp
                                                .launchInWebViewWithJavaScript(
                                                Config.termsOfUseUrl);
                                          }
                                        }),
                                  TextSpan(
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal),
                                    text: "login_screen.and_"
                                        .tr()
                                        .toLowerCase(),
                                  ),
                                  TextSpan(
                                      style: TextStyle(
                                        fontSize:11,
                                        color: Colors.lightBlueAccent,
                                        decoration:
                                        TextDecoration.underline,
                                      ),
                                      text: "login_screen.privacy_".tr(),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          if (QuickHelp.isMobile()) {
                                            debugPrint("o_que_esta_vend0???");
                                            QuickHelp.goToWebPage(context,
                                                pageType: QuickHelp
                                                    .pageTypePrivacy);
                                          } else {
                                            QuickHelp
                                                .launchInWebViewWithJavaScript(
                                                Config
                                                    .privacyPolicyUrl);
                                          }
                                        }),
                                ])),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showAgreeAlert,
                  child: ContainerCorner(
                    color: Colors.black.withOpacity(0.5),
                    height: 50,
                    marginRight: 50,
                    marginLeft: 50,
                    borderRadius: 50,
                    shadowColor: kGrayColor,
                    shadowColorOpacity: 0.3,
                    child: Center(
                      child: TextWithTap(
                        "login_screen.please_tick_option".tr(),
                        color: Colors.white,
                        marginBottom: 5,
                        marginTop: 5,
                        marginLeft: 15,
                        marginRight: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

}
