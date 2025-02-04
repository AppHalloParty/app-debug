import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'UserModel.dart';

class MvpModels extends ParseObject implements ParseCloneable {

  static final String keyTableName = "MvpUsers";

  MvpModels() : super(keyTableName);
  MvpModels.clone() : this();

  @override
  MvpModels clone(Map<String, dynamic> map) => MvpModels.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";
  static final String keyMVPEndDate = "mvp_date";

  DateTime? get getMVPEndDate => get<DateTime>(keyMVPEndDate);

  set setMVPEndDate(DateTime mvpEndDate) =>
      set<DateTime>(keyMVPEndDate, mvpEndDate);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);
}