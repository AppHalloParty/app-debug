import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class LiveViewersModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "LiveViewers";

  LiveViewersModel() : super(keyTableName);
  LiveViewersModel.clone() : this();

  @override
  LiveViewersModel clone(Map<String, dynamic> map) => LiveViewersModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyLiveId = "liveId";
  static String keyLiveAuthorId = "live_author_id";

  static String keyWatching = "watching";

  String? get getLiveAuthorId => get<String>(keyLiveAuthorId);
  set setLiveAuthorId(String liveAuthorID) => set<String>(keyLiveAuthorId, liveAuthorID);

  bool? get getWatching {
    bool? isWatching = get<bool>(keyWatching);
    if(isWatching!) {
      return isWatching;
    }else{
      return false;
    }
  }
  set setWatching(bool isWatching) => set<bool>(keyWatching, isWatching);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getLiveId => get<String>(keyLiveId);
  set setLiveId(String liveId) => set<String>(keyLiveId, liveId);

}