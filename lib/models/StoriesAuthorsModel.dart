// ignore_for_file: file_names

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/StoriesModel.dart';
import 'package:trace/models/UserModel.dart';

class StoriesAuthorsModel extends ParseObject implements ParseCloneable {
  static const String keyTableName = "StoriesAuthors";

  StoriesAuthorsModel() : super(keyTableName);
  StoriesAuthorsModel.clone() : this();

  @override
  StoriesAuthorsModel clone(Map<String, dynamic> map) =>
      StoriesAuthorsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";
  static String keyUpdatedAt = "updatedAt";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";

  static String keyLastStory = "lastStory";
  static String keyLastStoryExpiration = "lastStory_Expiration";

  static String keyStoriesList = "toriesList";
  static String keyLastStorySeen = "lastStorySeen";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  StoriesModel? get getLastStory => get<StoriesModel>(keyLastStory);
  set setLastStory(StoriesModel author) =>
      set<StoriesModel>(keyLastStory, author);

  List<dynamic>? get getStoriesList {
    List<dynamic> storyList = [];

    List<dynamic>? stories = get<List<dynamic>>(keyStoriesList);
    if (stories != null && stories.isNotEmpty) {
      return stories;
    } else {
      return storyList;
    }
  }

  set setStoriesList(String storyId) => setAddUnique(keyStoriesList, storyId);
  set setRemoveStory(String storyId) {
    List<String> stories = [];
    stories.add(storyId);
    setRemoveAll(keyStoriesList, stories);
  }

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  DateTime? get getUpdatedAt => get<DateTime>(keyUpdatedAt);

  DateTime? get getLastStoryExpireDate => get<DateTime>(keyLastStoryExpiration);
  set setLastStoryExpireDate(DateTime expireDate) =>
      set<DateTime>(keyLastStoryExpiration, expireDate);

  bool? get getLastStorySeen => get<bool>(keyLastStorySeen);
  set setLastStorySeen(bool lastStorySeen) =>
      set<bool>(keyLastStorySeen, lastStorySeen);
}
