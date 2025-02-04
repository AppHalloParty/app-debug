// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:faker/faker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/auth/dispache_screen.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:easy_localization/easy_localization.dart';


class SocialLogin {
  static Future<void> loginFacebook(BuildContext context) async {
    /*final result = await FacebookAuth.i.login(
      permissions: [
        'email',
        'public_profile',
        //'user_birthday',
        'user_gender',
      ],
    );

    if (result.status == LoginStatus.success) {
      QuickHelp.showLoadingDialog(context);

      final ParseResponse response = await ParseUser.loginWith(
          "facebook",
          facebook(
            result.accessToken!.tokenString,
            "result.accessToken!.userId",
            DateTime.now(),
          ));

      if (response.success) {
        UserModel? user = await ParseUser.currentUser();

        if (user != null) {
          if (user.getUid == null) {
            getFbUserDetails(user, context);
          } else {
            goHome(context, user);
          }
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              context: context, title: "auth.fb_login_error".tr());
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.fb_login_error".tr());
      }
    } else if (result.status == LoginStatus.cancelled) {
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "auth.fb_login_canceled".tr());
    } else if (result.status == LoginStatus.failed) {
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "auth.fb_login_error".tr());
    } else if (result.status == LoginStatus.operationInProgress) {
      print("facebook login in progress");
    }*/
  }

  static void getFbUserDetails(UserModel user, BuildContext context) async {
    dynamic _userData = [];
    /*final _userData = await FacebookAuth.i.getUserData(
      fields:
          "id,email,name,first_name,last_name,gender,birthday,picture.width(920).height(920),location",
    );*/

    String firstName = _userData['first_name'];
    String lastName = _userData['last_name'];

    String username =
        lastName.replaceAll(" ", "") + firstName.replaceAll(" ", "");

    user.setFullName = _userData['name'];
    user.setFacebookId = _userData['id'];
    user.setFirstName = firstName;
    user.setLastName = lastName;
    user.username = username+QuickHelp.generateShortUId().toString();

    if(_userData['email'] != null){
      user.setEmail = _userData['email'];
      user.setEmailPublic = _userData['email'];
    }

    if(_userData['gender'] != null){
      user.setGender = _userData['gender'];
    }

    if(_userData['location'] != null && _userData['location']['name'] != null){
      user.setLocation = _userData['location']['name'];
    }

    user.setUid = QuickHelp.generateUId();
    user.setPopularity = 0;
    user.setUserRole = UserModel.roleUser;
    user.setPrefMinAge = Setup.minimumAgeToRegister;
    user.setPrefMaxAge = Setup.maximumAgeToRegister;
    user.setLocationTypeNearBy = true;
    user.addCredit = Setup.welcomeCredit;
    user.setBio = Setup.bio;
    user.setHasPassword = false;

    if(_userData['birthday'] != null){
      user.setBirthday = QuickHelp.getDateFromString(
          _userData['birthday'], QuickHelp.dateFormatFacebook);
    }

    ParseResponse response = await user.save();

    if (response.success) {
      getPhotoFromUrl(context, user, _userData['picture']['data']['url']);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  static GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  static Future<void> googleLogin(BuildContext context, SharedPreferences preferences) async {
    try {
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      GoogleSignInAuthentication authentication = await account!.authentication;

      QuickHelp.showLoadingDialog(context);

      final ParseResponse response = await ParseUser.loginWith(
          'google',
          google(authentication.accessToken!, _googleSignIn.currentUser!.id,
              authentication.idToken!));
      if (response.success) {
        UserModel? user = await ParseUser.currentUser();

        if (user != null) {
          if (user.getUid == null) {
            getGoogleUserDetails(
                context, user, account, authentication.idToken!, preferences);
          } else {
            goHome(context, user);
          }
        } else {
          QuickHelp.hideLoadingDialog(context);
          QuickHelp.showAppNotificationAdvanced(
              context: context, title: "auth.gg_login_error".tr());
        }

      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(context: context, title: "auth.gg_login_error".tr());
        await _googleSignIn.signOut();
      }
    } catch (error) {
      if (error == GoogleSignIn.kSignInCanceledError) {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_cancelled".tr());
      } else if (error == GoogleSignIn.kNetworkError) {
        QuickHelp.showAppNotificationAdvanced(context: context, title: "not_connected".tr());
      } else {
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.gg_login_error".tr());
      }

      await _googleSignIn.signOut();
    }
  }

  static void getGoogleUserDetails(BuildContext context, UserModel user,
      GoogleSignInAccount googleUser, String idToken, SharedPreferences preferences) async {
    Map<String, dynamic>? idMap = QuickHelp.getInfoFromToken(idToken);

    String firstName = idMap!["given_name"];
    String lastName = idMap["family_name"];

    String username =
        lastName.replaceAll(" ", "") + firstName.replaceAll(" ", "");

    user.setFullName = googleUser.displayName!;
    user.setGoogleId = googleUser.id;
    user.setFirstName = firstName;
    user.setLastName = lastName;
    user.username = username.toLowerCase().trim()+QuickHelp.generateShortUId().toString();
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
    //user.setBirthday = QuickHelp.getDateFromString(_userData!['birthday'], QuickHelp.dateFormatFacebook);
    ParseResponse response = await user.save();

    if (response.success) {

      getPhotoFromUrl(context, user, googleUser.photoUrl!);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  static void loginApple(BuildContext context, SharedPreferences preferences) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    QuickHelp.showLoadingDialog(context);

    final ParseResponse response = await ParseUser.loginWith(
        'apple', apple(credential.identityToken!, credential.userIdentifier!));

    if (response.success) {
      UserModel? user = await ParseUser.currentUser();

      if (user != null) {
        if (user.getUid == null) {
          getAppleUserDetails(context, user, credential, preferences);
        } else {
          goHome(context, user);
        }
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            context: context, title: "auth.apple_login_error".tr());
      }
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "auth.apple_login_error".tr());
    }
  }

  static void getAppleUserDetails(BuildContext context, UserModel user, AuthorizationCredentialAppleID credentialAppleID, SharedPreferences preferences) async {

    var faker = Faker();

    String imageUrl = faker.image.image(
        width: 640, height: 640, keywords: ["people", "sexy", "models"], random: true);

    String? firstName = credentialAppleID.givenName != null ? credentialAppleID.givenName : ""; //faker.person.firstName();
    String? lastName = credentialAppleID.familyName != null ? credentialAppleID.familyName : "";
    String? fullName = '$firstName $lastName';

    String username =
        lastName!.replaceAll(" ", "") + firstName!.replaceAll(" ", "");

    /*if(credentialAppleID.givenName == null){
      user.setNeedsChangeName = true;
    }*/

    user.setFullName = fullName;
    user.setAppleId = credentialAppleID.userIdentifier!;
    user.setFirstName = firstName;
    user.setLastName = lastName;
    user.username = username.toLowerCase().trim()+QuickHelp.generateShortUId().toString();

    if(credentialAppleID.email != null){
      user.setEmail = credentialAppleID.email!;
      user.setEmailPublic = credentialAppleID.email!;
    }
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
    //user.setBirthday = QuickHelp.getDateFromString(_userData!['birthday'], QuickHelp.dateFormatFacebook);
    ParseResponse response = await user.save();

    if (response.success) {
      getPhotoFromUrl(context, user, imageUrl);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showErrorResult(context, response.error!.code);
    }
  }

  static void getPhotoFromUrl(
      BuildContext context, UserModel user, String url) async {
    File avatar = await QuickHelp.downloadFile(url, "avatar.jpeg") as File;

    ParseFileBase parseFile;
    if (QuickHelp.isWebPlatform()) {
      //Seems weird, but this lets you get the data from the selected file as an Uint8List very easily.
      ParseWebFile file =
          ParseWebFile(null, name: "avatar.jpeg", url: avatar.path);
      await file.download();
      parseFile = ParseWebFile(file.file, name: file.name);
    } else {
      parseFile = ParseFile(File(avatar.path));
    }

    user.setAvatar = parseFile;
    //user.setAvatar1 = parseFile;

    final ParseResponse response = await user.save();
    if (response.success) {
      saveAgencyEarn(context, user);
      goHome(context, user);
    } else {
      saveAgencyEarn(context, user);
      goHome(context, user);
    }
  }

  static saveAgencyEarn(BuildContext context, UserModel user){

  }

  static void goHome(BuildContext context, UserModel userModel,) {
    QuickHelp.hideLoadingDialog(context);
    QuickHelp.goToNavigatorScreen(
        context, DispacheScreen(currentUser: userModel,), finish: true, back: false);
  }
}
