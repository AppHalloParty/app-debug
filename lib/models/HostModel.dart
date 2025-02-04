import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class HostModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "HostModel";

  HostModel() : super(keyTableName);
  HostModel.clone() : this();

  @override
  HostModel clone(Map<String, dynamic> map) => HostModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyHost = "host";
  static String keyHostId = "host_id";

  static String keyEarnedCoins = "earned_coins";

  UserModel? get getHost => get<UserModel>(keyHost);
  set setHost(UserModel user) => set<UserModel>(keyHost, user);

  int? get getEarnedCoins => get<int>(keyEarnedCoins);
  set addEarnedCoins(int credits) => setIncrement(keyEarnedCoins, credits);

}