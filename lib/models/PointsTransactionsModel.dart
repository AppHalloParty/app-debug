import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class PointsTransactionsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "PointsTransactions";

  PointsTransactionsModel() : super(keyTableName);
  PointsTransactionsModel.clone() : this();

  @override
  PointsTransactionsModel clone(Map<String, dynamic> map) => PointsTransactionsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String transactionTypeLive = "live";
  static String transactionTypeParty = "party";
  static String transactionTypePlatformReward = "platform_reward";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";
  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiver_id";

  static String keyAmountAfter = "amount_after_send";

  static String keyTransactionType = "transaction_type";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String receiverId) => set<String>(keyReceiverId, receiverId);

  String? get getAmountAfter => get<String>(keyAmountAfter);
  set setAmountAfter(String receiverId) => set<String>(keyAmountAfter, receiverId);

  String? get getTransactionType => get<String>(keyTransactionType);
  set setTransactionType(String receiverId) => set<String>(keyTransactionType, receiverId);
}