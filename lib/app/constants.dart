import 'dart:convert';

import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/app/setup.dart';

import '../helpers/quick_help.dart';
import 'config.dart';

class Constants {

  static String facebookLoginConfig = "facebook_login";
  static String phoneLoginConfig = "phone_login";
  static String appleLoginConfig = "apple_login";
  static String googleLoginConfig = "google_login";

  static String callsConfig = "calls_enabled";
  static String streamKeyConfig = "stream_key";
  static String streamTypeConfig = "stream_type";

  static String withdrawPaypalConfig = "withdraw_paypal";
  static String withdrawPayoneerConfig = "withdraw_payoneer";
  static String withdrawIbanConfig = "withdraw_bank";
  static String withdrawUSDTConfig = "withdraw_usdt";

  static String agencyPercentConfig = "agency_percent";
  static String diamondsEarnPercentConfig = "diamonds_earn_percent";
  static String diamondsNeededToRedeemConfig = "diamonds_needed_to_redeem";
  static String withDrawPercentConfig = "withdraw_percent";

  static String s3RegionConfig = "s3_region";
  static String s3BucketConfig = "s3_bucket";
  static String s3UrlConfig = "s3_url";
  static String s3AccessKeyConfig = "s3_access_key";
  static String s3SecretKeyConfig = "s3_secret_key";

  static String bannerAdsOnHomeReelsEnabledConfig = "banner_ads_reels";

  static String appPackageName() {
    if (QuickHelp.isIOSPlatform()) {
      return Config.packageNameiOS;
    } else if (QuickHelp.isAndroidPlatform()) {
      return Config.packageNameAndroid;
    } else {
      return Config.packageNameAndroid;
    }
  }

  static String getAdmobOpenAppUnit() {
    if (Setup.isDebug) {
      return QuickHelp.admobOpenAppAdTest;
    } else {
      if (QuickHelp.isIOSPlatform()) {
        return Config.admobIOSOpenAppAd;
      } else {
        return Config.admobAndroidOpenAppAd;
      }
    }
  }

  static String getAdmobHomeBannerUnit() {
    if (Setup.isDebug) {
      return QuickHelp.admobBannerAdTest;
    } else {
      if (QuickHelp.isIOSPlatform()) {
        return Config.admobIOSHomeBannerAd;
      } else {
        return Config.admobAndroidHomeBannerAd;
      }
    }
  }

  static String getAdmobFeedNativeUnit() {
    if (Setup.isDebug) {
      return QuickHelp.admobBannerAdTest;
    } else {
      if (QuickHelp.isIOSPlatform()) {
        return Config.admobIOSFeedBannerAd;
        //return Config.admobIOSFeedNativeAd;
      } else {
        return Config.admobAndroidFeedBannerAd;
        //return Config.admobAndroidFeedNativeAd;
      }
    }
  }

  static String getAdmobChatListBannerUnit() {
    if (Setup.isDebug) {
      return QuickHelp.admobBannerAdTest;
    } else {
      if (QuickHelp.isIOSPlatform()) {
        return Config.admobIOSChatListBannerAd;
      } else {
        return Config.admobAndroidChatListBannerAd;
      }
    }
  }

  static String getAdmobLiveBannerUnit() {
    if (Setup.isDebug) {
      return QuickHelp.admobBannerAdTest;
    } else {
      if (QuickHelp.isIOSPlatform()) {
        return Config.admobIOSLiveBannerAd;
      } else {
        return Config.admobAndroidLiveBannerAd;
      }
    }
  }

  static void queryParseConfig(SharedPreferences prefs) async {
    final ParseConfig parseConfig = ParseConfig();

    final ParseResponse response = await parseConfig.getConfigs();
    if (response.success) {
      var config = getParseConfigResults(response.result);

      var facebookLogin = config[facebookLoginConfig];
      var phoneLogin = config[phoneLoginConfig];
      var appleLogin = config[appleLoginConfig];
      var googleLogin = config[googleLoginConfig];

      var calls = config[callsConfig];
      var steamingProvider = config[streamTypeConfig];
      var streamerProviderKey = config[streamKeyConfig];

      var withdrawPaypal = config[withdrawPaypalConfig];
      var withdrawPayoneer = config[withdrawPayoneerConfig];
      var withdrawIban = config[withdrawIbanConfig];
      var withdrawUsdt = config[withdrawUSDTConfig];

      var agencyPercent = config[agencyPercentConfig];
      var diamondsEarnPercent = config[diamondsEarnPercentConfig];
      var diamondsNeededToRedeem = config[diamondsNeededToRedeemConfig];
      var withDrawPercent = config[withDrawPercentConfig];

      var s3Bucket = config[s3BucketConfig];
      var s3Region = config[s3RegionConfig];
      var s3Url = config[s3UrlConfig];
      var s3SecretKey = config[s3SecretKeyConfig];
      var s3AccessKey = config[s3AccessKeyConfig];

      var bannerAdsOnHomeReelsEnabled = config[bannerAdsOnHomeReelsEnabledConfig];

      prefs.setBool(facebookLoginConfig, facebookLogin != null ? facebookLogin : Setup.isFacebookLoginEnabled);
      prefs.setBool(phoneLoginConfig, phoneLogin != null ? phoneLogin : Setup.isPhoneLoginEnabled);
      prefs.setBool(appleLoginConfig, appleLogin != null ? appleLogin : Setup.isAppleLoginEnabled);
      prefs.setBool(googleLoginConfig, googleLogin != null ? googleLogin : Setup.isGoogleLoginEnabled);

      prefs.setBool(callsConfig, calls != null ? calls : Setup.isCallsEnabled);
      prefs.setString(streamTypeConfig, steamingProvider != null ? steamingProvider : Setup.streamingProviderType);
      prefs.setString(streamKeyConfig, streamerProviderKey != null ? streamerProviderKey : Setup.streamingProviderKey);

      prefs.setBool(withdrawPaypalConfig, withdrawPaypal != null ? withdrawPaypal : Setup.isWithdrawPaypalEnabled);
      prefs.setBool(withdrawPayoneerConfig, withdrawPayoneer != null ? withdrawPayoneer : Setup.isWithdrawPayoneerEnabled);
      prefs.setBool(withdrawIbanConfig, withdrawIban != null ? withdrawIban : Setup.isWithdrawIbanEnabled);
      prefs.setBool(withdrawUSDTConfig, withdrawUsdt != null ? withdrawUsdt : Setup.isWithdrawUSDTlEnabled);

      prefs.setInt(agencyPercentConfig, agencyPercent != null ? agencyPercent : Setup.agencyPercent);
      prefs.setInt(diamondsEarnPercentConfig, diamondsEarnPercent != null ? diamondsEarnPercent : Setup.diamondsEarnPercent);
      prefs.setInt(diamondsNeededToRedeemConfig, diamondsNeededToRedeem != null ? diamondsNeededToRedeem : Setup.diamondsNeededToRedeem);
      prefs.setInt(withDrawPercentConfig, withDrawPercent != null ? withDrawPercent : Setup.withDrawPercent);

      prefs.setString(s3BucketConfig, s3Bucket != null ? s3Bucket : "");
      prefs.setString(s3RegionConfig, s3Region != null ? s3Region : "");
      prefs.setString(s3UrlConfig, s3Url != null ? s3Url : "");
      prefs.setString(s3SecretKeyConfig, s3SecretKey != null ? s3SecretKey : "");
      prefs.setString(s3AccessKeyConfig, s3AccessKey != null ? s3AccessKey : "");

      prefs.setBool(bannerAdsOnHomeReelsEnabledConfig, bannerAdsOnHomeReelsEnabled != null ? bannerAdsOnHomeReelsEnabled : Setup.isBannerAdsOnHomeReelsEnabled);

    } else {
      if (prefs.getBool(facebookLoginConfig) == null)
        prefs.setBool(facebookLoginConfig, Setup.isFacebookLoginEnabled);
      if (prefs.getBool(phoneLoginConfig) == null)
        prefs.setBool(phoneLoginConfig, Setup.isPhoneLoginEnabled);
      if (prefs.getBool(appleLoginConfig) == null)
        prefs.setBool(appleLoginConfig, Setup.isAppleLoginEnabled);
      if (prefs.getBool(googleLoginConfig) == null)
        prefs.setBool(googleLoginConfig, Setup.isGoogleLoginEnabled);
      if (prefs.getBool(callsConfig) == null)
        prefs.setBool(callsConfig, Setup.isCallsEnabled);
      if (prefs.getString(streamTypeConfig) == null)
        prefs.setString(streamTypeConfig, Setup.streamingProviderType);
      if (prefs.getString(streamKeyConfig) == null)
        prefs.setString(streamKeyConfig, Setup.streamingProviderKey);
      if (prefs.getBool(withdrawPaypalConfig) == null)
        prefs.setBool(withdrawPaypalConfig, Setup.isWithdrawPaypalEnabled);
      if (prefs.getBool(withdrawPayoneerConfig) == null)
        prefs.setBool(withdrawPayoneerConfig, Setup.isWithdrawPayoneerEnabled);
      if (prefs.getBool(withdrawIbanConfig) == null)
        prefs.setBool(withdrawIbanConfig, Setup.isWithdrawIbanEnabled);
      if (prefs.getBool(withdrawUSDTConfig) == null)
        prefs.setBool(withdrawUSDTConfig, Setup.isWithdrawUSDTlEnabled);
      if (prefs.getInt(agencyPercentConfig) == null)
        prefs.setInt(agencyPercentConfig, Setup.agencyPercent);
      if (prefs.getInt(diamondsEarnPercentConfig) == null)
        prefs.setInt(diamondsEarnPercentConfig, Setup.diamondsEarnPercent);
      if (prefs.getInt(diamondsNeededToRedeemConfig) == null)
        prefs.setInt(diamondsNeededToRedeemConfig, Setup.diamondsNeededToRedeem);
      if (prefs.getInt(withDrawPercentConfig) == null)
        prefs.setInt(withDrawPercentConfig, Setup.withDrawPercent);
      if (prefs.getString(s3BucketConfig) == null)
        prefs.setString(s3BucketConfig, "");
      if (prefs.getString(s3RegionConfig) == null)
        prefs.setString(s3RegionConfig, "");
      if (prefs.getString(s3UrlConfig) == null)
        prefs.setString(s3UrlConfig, "");
      if (prefs.getString(s3SecretKeyConfig) == null)
        prefs.setString(s3SecretKeyConfig, "");
      if (prefs.getString(s3AccessKeyConfig) == null)
        prefs.setString(s3AccessKeyConfig, "");
      if (prefs.getBool(bannerAdsOnHomeReelsEnabledConfig) == null)
        prefs.setBool(bannerAdsOnHomeReelsEnabledConfig, Setup.isBannerAdsOnHomeReelsEnabled);
    }
  }

  static Map getParseConfigResults(Map response) {
    var body = {};
    body.addAll(response);

    var config = {};
    //uncomment to add object before results
    config = body; // config["config"] = body;
    String result = json.encode(config);

    Map map = json.decode(result);
    return map;
  }
}
