import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class GiftsSenderModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "GiftsSenders";

  GiftsSenderModel() : super(keyTableName);
  GiftsSenderModel.clone() : this();

  @override
  GiftsSenderModel clone(Map<String, dynamic> map) => GiftsSenderModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyAuthorName = "name";

  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiverId";

  static String keyLiveId = "liveId";
  static String keyCallId = "callId";

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

  String? get getLiveId => get<String>(keyLiveId);
  set setLiveId(String liveId) => set<String>(keyLiveId, liveId);

  String? get getCallId => get<String>(keyCallId);
  set setCallId(String callId) => set<String>(keyCallId, callId);

  int? get getDiamonds => get<int>(keyDiamonds);
  set addDiamonds(int diamonds) => setIncrement(keyDiamonds, diamonds);

}