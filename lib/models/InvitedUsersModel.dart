import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class InvitedUsersModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "InvitedUsers";

  InvitedUsersModel() : super(keyTableName);
  InvitedUsersModel.clone() : this();

  @override
  InvitedUsersModel clone(Map<String, dynamic> map) => InvitedUsersModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyInvitedBy = "invitedBy";
  static String keyInvitedById = "invitedById";

  static String keyValidUntil = "validUntil";

  static String keyDiamonds = "diamonds";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getInvitedBy => get<UserModel>(keyInvitedBy);
  set setInvitedBy(UserModel author) => set<UserModel>(keyInvitedBy, author);

  String? get getInvitedById => get<String>(keyInvitedById);
  set setInvitedById(String authorId) => set<String>(keyInvitedById, authorId);

  DateTime? get getValidUntil => get<DateTime>(keyValidUntil);
  set setValidUntil(DateTime valid) => set<DateTime>(keyValidUntil, valid);

  int? get getDiamonds {

    int? token = get<int>(keyDiamonds);
    if(token != null){
      return token;
    } else {
      return 0;
    }
  }
  set addDiamonds(int diamonds) => setIncrement(keyDiamonds, diamonds);

}