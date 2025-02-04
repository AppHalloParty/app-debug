import 'package:trace/models/GiftsSentModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class LeadersModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Leaders";

  LeadersModel() : super(keyTableName);
  LeadersModel.clone() : this();

  @override
  LeadersModel clone(Map<String, dynamic> map) => LeadersModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyDiamondsQuantity = "diamondsQuantity";

  static String keyGiftsSent = "giftsSent";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  int? get getDiamondsQuantity => get<int>(keyDiamondsQuantity);
  set setCounterDiamondsQuantity(int count) => set<int>(keyDiamondsQuantity, count);
  set incrementDiamondsQuantity(int count) => setIncrement(keyDiamondsQuantity, count);

  GiftsSentModel? get getGiftsSent => get<GiftsSentModel>(keyGiftsSent);
  set setGiftsSent(GiftsSentModel giftsSent) => addRelation(keyGiftsSent, [giftsSent]);


}