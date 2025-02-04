import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'GiftsModel.dart';
import 'UserModel.dart';

class ObtainedItemsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "ObtainedItems";

  ObtainedItemsModel() : super(keyTableName);
  ObtainedItemsModel.clone() : this();

  @override
  ObtainedItemsModel clone(Map<String, dynamic> map) => ObtainedItemsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";

  static String keyItemId = "item_id";
  static String keyItem = "item";

  static String keyExpirationDate = "expiration_date";

  static String keyCategory= "category";

  String? get getCategory => get(keyCategory);
  set setCategory(String category) => set<String>(keyCategory, category);

  DateTime? get getExpirationDate => get(keyExpirationDate);
  set setExpirationDate(DateTime date) => set<DateTime>(keyExpirationDate, date);

  UserModel? get getAuthor => get(keyAuthor);
  set setAuthor(UserModel user) => set<UserModel>(keyAuthor, user);

  String? get getAuthorId => get(keyAuthorId);
  set setAuthorId(String userId) => set<String>(keyAuthorId, userId);

  String? get getItemId => get(keyItemId);
  set setItemId(String itemId) => set<String>(keyItemId, itemId);

  GiftsModel? get getItem => get(keyItem);
  set setItem(GiftsModel item) => set<GiftsModel>(keyItem, item);

}
