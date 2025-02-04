import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class NewPaymentMethodRequest extends ParseObject implements ParseCloneable {

  static final String keyTableName = "NewPaymentMethodRequest";

  NewPaymentMethodRequest() : super(keyTableName);
  NewPaymentMethodRequest.clone() : this();

  @override
  NewPaymentMethodRequest clone(Map<String, dynamic> map) => NewPaymentMethodRequest.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";

  static String keyExplanation = "text_explain";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel user) => set<UserModel>(keyAuthor, user);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getExplanation => get<String>(keyExplanation);
  set setExplanation(String explain) => set<String>(keyExplanation, explain);


}