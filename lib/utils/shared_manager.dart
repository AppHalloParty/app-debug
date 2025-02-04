import 'package:shared_preferences/shared_preferences.dart';
import 'package:trace/app/constants.dart';

import '../app/setup.dart';

class SharedManager {

  static final String _dynamicInvitee = 'invitee';

  void setInvitee(SharedPreferences? preferences, String objectId){
     preferences!.setString(_dynamicInvitee, objectId);
  }

  String? getInvitee(SharedPreferences? preferences){
    return preferences!.getString(_dynamicInvitee) ?? "";
  }

   void clearInvitee(SharedPreferences? preferences){
     preferences!.setString(_dynamicInvitee, "");
  }

  String getStreamProviderKey(SharedPreferences? preferences){
    return preferences!.getString(Constants.streamKeyConfig) ?? Setup.streamingProviderKey;
  }

  bool isStreamProviderAgora(SharedPreferences? preferences){
    return preferences!.getString(Constants.streamTypeConfig) == "agora"? true : false;
  }

  bool isStreamProviderWebRtc(SharedPreferences? preferences){
    return preferences!.getString(Constants.streamTypeConfig) == "webrtc"? true : false;
  }

  bool isWithdrawIbanEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.withdrawIbanConfig) ?? Setup.isWithdrawIbanEnabled;
  }

  bool isWithdrawPayoneerEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.withdrawPayoneerConfig) ?? Setup.isWithdrawPayoneerEnabled;
  }

  bool isWithdrawPaypalEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.withdrawPaypalConfig) ?? Setup.isWithdrawPaypalEnabled;
  }

  bool isWithdrawUSDTEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.withdrawUSDTConfig) ?? Setup.isWithdrawUSDTlEnabled;
  }

  bool isGoogleLoginEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.googleLoginConfig) ?? Setup.isGoogleLoginEnabled;
  }

  bool isFacebookLoginEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.facebookLoginConfig) ?? Setup.isFacebookLoginEnabled;
  }

  bool isAppleLoginEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.appleLoginConfig) ?? Setup.isAppleLoginEnabled;
  }

  bool isPhoneLoginEnabled(SharedPreferences? preferences){
    return preferences!.getBool(Constants.phoneLoginConfig) ?? Setup.isPhoneLoginEnabled;
  }

  int getDiamondsEarnPercent(SharedPreferences? preferences){
    return preferences!.getInt(Constants.diamondsEarnPercentConfig) ?? Setup.diamondsEarnPercent;
  }

  int getWithDrawPercent(SharedPreferences? preferences){
    return preferences!.getInt(Constants.withDrawPercentConfig) ?? Setup.withDrawPercent;
  }

  int getAgencyPercent(SharedPreferences? preferences){
    return preferences!.getInt(Constants.agencyPercentConfig) ?? Setup.agencyPercent;
  }

  int getDiamondsNeededToRedeem(SharedPreferences? preferences){
    return preferences!.getInt(Constants.diamondsNeededToRedeemConfig) ?? Setup.diamondsNeededToRedeem;
  }

  String getS3Region(SharedPreferences? preferences){
    return preferences!.getString(Constants.s3RegionConfig) ?? "";
  }

  String getS3Bucket(SharedPreferences? preferences){
    return preferences!.getString(Constants.s3BucketConfig) ?? "";
  }

  String getS3Url(SharedPreferences? preferences){
    return preferences!.getString(Constants.s3UrlConfig) ?? "";
  }

  String getS3AccessKey(SharedPreferences? preferences){
    return preferences!.getString(Constants.s3AccessKeyConfig) ?? "";
  }

  String getS3SecretKey(SharedPreferences? preferences){
    return preferences!.getString(Constants.s3SecretKeyConfig) ?? "";
  }

  bool isBannerAdsOnHomeReelsEnabled(SharedPreferences? preferences){
    if(preferences != null){
      return preferences.getBool(Constants.bannerAdsOnHomeReelsEnabledConfig)!;
    }
    return Setup.isBannerAdsOnHomeReelsEnabled;
  }
}