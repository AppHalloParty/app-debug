import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/models/FanClubModel.dart';

import 'UserModel.dart';

class FanClubMembersModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "FanClubMembers";

  FanClubMembersModel() : super(keyTableName);
  FanClubMembersModel.clone() : this();

  @override
  FanClubMembersModel clone(Map<String, dynamic> map) => FanClubMembersModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyMember = "member";
  static String keyMemberId = "member_id";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";

  static String keyFanClub = "fun_club";
  static String keyFanClubId = "fun_club_id";

  static String keyIntimacy = "intimacy";

  static String keyExpirationDate = "expiration_date";

  UserModel? get geAuthor => get(keyAuthor);
  set setAuthor(UserModel user) => set<UserModel>(keyAuthor, user);

  String? get getAuthorId => get(keyAuthorId);
  set setAuthorId(String userId) => set<String>(keyAuthorId, userId);

  DateTime? get getExpirationDate => get(keyExpirationDate);
  set setExpirationDate(DateTime date) => set<DateTime>(keyExpirationDate, date);

  int? get getIntimacy {
    int? credit = get<int>(keyIntimacy);
    if(credit != null) {
      return credit;
    }else{
      return 0;
    }
  }

  set addIntimacy(int credits) => setIncrement(keyIntimacy, credits);
  set removeIntimacy(int credits){
    setDecrement(keyIntimacy, credits);
  }

  UserModel? get getMember => get(keyMember);
  set setMember(UserModel user) => set<UserModel>(keyMember, user);

  FanClubModel? get getFanClub => get(keyFanClub);
  set setFanClub(FanClubModel fanClub) => set<FanClubModel>(keyFanClub, fanClub);

  String? get getMemberId => get(keyMemberId);
  set setMemberId(String userId) => set<String>(keyMemberId, userId);

  String? get getFanClubId => get(keyFanClubId);
  set setFanClubId(String fanClubId) => set<String>(keyFanClubId, fanClubId);

}
