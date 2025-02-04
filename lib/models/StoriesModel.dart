// ignore_for_file: file_names

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';

class StoriesModel extends ParseObject implements ParseCloneable {
  static const String keyTableName = "Stories";

  StoriesModel() : super(keyTableName);
  StoriesModel.clone() : this();

  @override
  StoriesModel clone(Map<String, dynamic> map) =>
      StoriesModel.clone()..fromJson(map);

  static const privacyPublic = "PBL";
  static const privacyFollowers = "FLW";
  static const privacyOnlyMe = "PRV";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";

  static String keyLegend = "legend";
  static String keyImage = "image";

  static String keyExpiration = "expiration_date";
  static String keyPrivacy = "privacy";

  static String keyViews = "views";
  static String keyTextBgColor = "text_bg_color";
  static String keyTextColor = "text_color";

  DateTime? get getExpireDate => get<DateTime>(keyExpiration);
  set setExpireDate(DateTime expireDate) =>
      set<DateTime>(keyExpiration, expireDate);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getTextBgColors => get<String>(keyTextBgColor);
  set setTextBgColors(String textBgColors) =>
      set<String>(keyTextBgColor, textBgColors);

  String? get getTextColors => get<String>(keyTextColor);
  set setTextColors(String textColors) => set<String>(keyTextColor, textColors);

  String? get getText => get<String>(keyLegend);
  set setText(String text) => set<String>(keyLegend, text);

  ParseFileBase? get getImage => get<ParseFileBase>(keyImage);
  set setImage(ParseFileBase imageFile) =>
      set<ParseFileBase>(keyImage, imageFile);

  String? get getPrivacy => get<String>(keyPrivacy);
  set setPrivacy(String privacy) => set<String>(keyPrivacy, privacy);

  List<dynamic>? get geViewsIDs {
    List<dynamic> viewId = [];

    List<dynamic>? viewersId = get<List<dynamic>>(keyViews);

    if (viewersId != null && viewersId.isNotEmpty) {
      return viewersId;
    } else {
      return viewId;
    }
  }

  set setViewersId(String viewersId) => setAddUnique(keyViews, viewersId);
}
