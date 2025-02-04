import 'package:parse_server_sdk/parse_server_sdk.dart';

class HashTagModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "HashTag";

  HashTagModel() : super(keyTableName);
  HashTagModel.clone() : this();

  @override
  HashTagModel clone(Map<String, dynamic> map) => HashTagModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyTag = "hashtag";
  static String keyCount = "used";
  static String keyIsActive = "isActive";

  String? get getCount => get<String>(keyCount);
  set setCount(int count) => setIncrement(keyCount, count);
  set removeCount(int count) => setDecrement(keyCount, count);

  String? get getHashTag => get<String>(keyTag);
  set setHashTag(String hashtag) => set<String>(keyTag, hashtag.toLowerCase());

  set setActive(bool isActive) => set<bool>(keyIsActive, isActive);

  bool? get getGameNotification{
    bool? isActive = get<bool>(keyIsActive);
    if(isActive != null){
      return isActive;
    }else{
      return false;
    }
  }
}