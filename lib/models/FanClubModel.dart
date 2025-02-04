import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class FanClubModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "FanClub";

  FanClubModel() : super(keyTableName);
  FanClubModel.clone() : this();

  @override
  FanClubModel clone(Map<String, dynamic> map) => FanClubModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";

  static String keyName = "name";

  static String keyFansId = "fans_id";
  static String keyFans = "fans";

  UserModel? get getAuthor => get(keyAuthor);
  set setAuthor(UserModel user) => set<UserModel>(keyAuthor, user);

  String? get getAuthorId => get(keyAuthorId);
  set setAuthorId(String userId) => set<String>(keyAuthorId, userId);

  String? get getName => get(keyName);
  set setName(String name) => set<String>(keyName, name);

  List<dynamic>? get getFansId {

    List<dynamic>? fansId = get<List<dynamic>>(keyFansId);
    if(fansId != null && fansId.length > 0){
      return fansId;
    } else {
      return [];
    }
  }
  set setFansId (String userID) => setAddUnique(keyFansId, userID);
  set removeFansId (String userID) => setRemove(keyFansId, userID);

  List<UserModel>? get getFans {

    List<UserModel>? fansId = get<List<UserModel>>(keyFans);
    if(fansId != null && fansId.length > 0){
      return fansId;
    } else {
      return [];
    }
  }
  set setFans (UserModel user) => setAddUnique(keyFans, user);
  set removeFans (UserModel user) => setRemove(keyFans, user);

}
