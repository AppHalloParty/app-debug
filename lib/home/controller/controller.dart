import 'package:get/get.dart';
import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/UserModel.dart';

import '../../app/Config.dart';

class Controller extends GetxController {
  var countryCode = Config.initialCountry.obs;
  var emptyField = true.obs;
  var shareMediaFiles = false.obs;
  var isBattleLive = false.obs;
  var searchText = "".obs;
  var diamondsCounter = "0".obs;
  var battleTimer = 0.obs;
  var hisBattlePoints = 0.obs;
  var myBattlePoints = 0.obs;
  var myBattleVictories = 0.obs;
  var hisBattleVictories = 0.obs;
  var showBattleWinner = false.obs;
  var isPrivateLive = false.obs;

  var receivedGiftList = <GiftsModel>[].obs;
  var giftSenderList = <UserModel>[].obs;
  var giftReceiverList = <UserModel>[].obs;

  updateCountryCode (String code) {
    countryCode.value = code;
  }

  updateSearchField (String text) {
    emptyField.value = text.isEmpty;
  }
}