import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import 'UserModel.dart';

class MvpCoinsRewardModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "MvpCoinsReward";

  MvpCoinsRewardModel() : super(keyTableName);
  MvpCoinsRewardModel.clone() : this();

  @override
  MvpCoinsRewardModel clone(Map<String, dynamic> map) => MvpCoinsRewardModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";
  static final String keyCoinAmount = "coins_amount";

  int? get getCoinAmount => get<int>(keyCoinAmount);

  set setCoinAmount(int mvpEndDate) =>
      set<int>(keyCoinAmount, mvpEndDate);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);
}