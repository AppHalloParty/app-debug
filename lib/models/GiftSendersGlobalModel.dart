import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class GiftsSenderGlobalModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "GiftsSendersGlobal";

  GiftsSenderGlobalModel() : super(keyTableName);
  GiftsSenderGlobalModel.clone() : this();

  @override
  GiftsSenderGlobalModel clone(Map<String, dynamic> map) => GiftsSenderGlobalModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyAuthorName = "name";

  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiverId";

  static String keyDiamonds = "diamonds";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getAuthorName => get<String>(keyAuthorName);
  set setAuthorName(String authorName) => set<String>(keyAuthorName, authorName);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel receiver) => set<UserModel>(keyReceiver, receiver);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String receiverId) => set<String>(keyReceiverId, receiverId);

  int? get getDiamonds => get<int>(keyDiamonds);
  set addDiamonds(int diamonds) => setIncrement(keyDiamonds, diamonds);

}