import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class CoinsTransactionsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "CoinsTransactions";

  CoinsTransactionsModel() : super(keyTableName);
  CoinsTransactionsModel.clone() : this();

  @override
  CoinsTransactionsModel clone(Map<String, dynamic> map) => CoinsTransactionsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String transactionTypeSent = "sent";
  static String transactionTypeTopUP = "TopUP";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";
  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiver_id";

  static String keyAmountAfterTransaction = "amount_after_transaction";
  static String keyTransactedAmount = "transacted_amount";

  static String keyTransactionType = "transaction_type";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String receiverId) => set<String>(keyReceiverId, receiverId);

  int? get getAmountAfterTransaction => get<int>(keyAmountAfterTransaction);
  set setAmountAfterTransaction(int amount) => set<int>(keyAmountAfterTransaction, amount);

  int? get getTransactedAmount => get<int>(keyTransactedAmount);
  set setTransactedAmount(int amount) => set<int>(keyTransactedAmount, amount);

  String? get getTransactionType => get<String>(keyTransactionType);
  set setTransactionType(String receiverId) => set<String>(keyTransactionType, receiverId);
}