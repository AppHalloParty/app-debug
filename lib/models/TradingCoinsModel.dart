import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class TradingCoinsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "TradingCoins";

  TradingCoinsModel() : super(keyTableName);
  TradingCoinsModel.clone() : this();

  @override
  TradingCoinsModel clone(Map<String, dynamic> map) => TradingCoinsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static final String keyAuthor = "author";
  static final String keyAuthorId = "author_id";

  static final String keyReceiver = "receiver";
  static final String keyReceiverId = "receiver_id";

  static final String keyAmount = "amount";
  static final String keySenderResultCredit = "sender_result_credit";
  static final String keyReceiverResultCredit = "receiver_result_credit";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel receiver) => set<UserModel>(keyReceiver, receiver);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String receiverId) => set<String>(keyReceiverId, receiverId);

  set setAmount(int amount) => setIncrement(keyAmount, amount);
  dynamic get getAmount {
    dynamic amount = get<dynamic>(keyAmount);
    if(amount != null){
      return amount;
    } else {
      return 0;
    }
  }

  set setSenderResultCredit(int amount) => setIncrement(keySenderResultCredit, amount);
  dynamic get getSenderResultCredit {
    dynamic amount = get<dynamic>(keySenderResultCredit);
    if(amount != null){
      return amount;
    } else {
      return 0;
    }
  }

  set setReceiverResultCredit(int amount) => setIncrement(keyReceiverResultCredit, amount);
  dynamic get getReceiverResultCredit {
    dynamic amount = get<dynamic>(keyReceiverResultCredit);
    if(amount != null){
      return amount;
    } else {
      return 0;
    }
  }

}