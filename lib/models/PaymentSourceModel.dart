import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class PaymentSourceModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "PaymentSource";

  PaymentSourceModel() : super(keyTableName);
  PaymentSourceModel.clone() : this();

  @override
  PaymentSourceModel clone(Map<String, dynamic> map) => PaymentSourceModel.clone()..fromJson(map);

  static String paymentMethodPayoneer = "payoneer";
  static String paymentMethodBNBSmartChainWallet = "BNB_smart_chain_wallet";
  static String paymentMethodPaypal = "paypal";
  static String paymentMethodUSDT = "udst";

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyPaymentMethod = "payment_method";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyPayoneerName = "payoneer_name";
  static String keyPayoneerEmail = "payoneer_email";

  static String keyPayPalName = "paypal_name";
  static String keyPayPalEmail = "paypal_email";

  static String keyWalletAddress = "wallet_address";
  static String keyUsdtContactAddress = "usdt_contact_address";

  String? get getUsdtContactAddress => get<String>(keyUsdtContactAddress);
  set setUsdtContactAddress(String usdtAddress) => set<String>(keyUsdtContactAddress, usdtAddress);

  String? get getWalletAddress => get<String>(keyWalletAddress);
  set setWalletAddress(String walletAddress) => set<String>(keyWalletAddress, walletAddress);

  String? get getPayPalEmail => get<String>(keyPayPalEmail);
  set setPayPalEmail(String email) => set<String>(keyPayPalEmail, email);

  String? get getPayoneerEmail => get<String>(keyPayoneerEmail);
  set setPayoneerEmail(String email) => set<String>(keyPayoneerEmail, email);

  String? get getPayPalName => get<String>(keyPayPalName);
  set setPayPalName(String name) => set<String>(keyPayPalName, name);

  String? get getPayoneerName => get<String>(keyPayoneerName);
  set setPayoneerName(String name) => set<String>(keyPayoneerName, name);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getPaymentMethod => get<String>(keyPaymentMethod);
  set setPaymentMethod(String platform) => set<String>(keyPaymentMethod, platform);
}