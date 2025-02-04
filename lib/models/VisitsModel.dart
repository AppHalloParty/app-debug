import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class VisitsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "VisitsModel";

  VisitsModel() : super(keyTableName);
  VisitsModel.clone() : this();

  @override
  VisitsModel clone(Map<String, dynamic> map) => VisitsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyVisitor = "visitor";
  static String keyVisitorId = "visitorId";

  static String keyVisited = "visited";
  static String keyVisitedId = "visitedId";

  static String keyViewed = "viewed";

  UserModel? get getVisitor => get<UserModel>(keyVisitor);
  set setVisitor(UserModel visitor) => set<UserModel>(keyVisitor, visitor);

  String? get getVisitorId => get<String>(keyVisitorId);
  set setVisitorId(String visitorId) => set<String>(keyVisitorId, visitorId);

  String? get getVisitedId => get<String>(keyVisitedId);
  set setVisitedId(String visitedId) => set<String>(keyVisitedId, visitedId);

  UserModel? get getVisited => get<UserModel>(keyVisited);
  set setVisited(UserModel visited) => set<UserModel>(keyVisited, visited);

  bool? get getViewed => get<bool>(keyViewed);
  set setViewed(bool viewed) => set<bool>(keyViewed, viewed);

}