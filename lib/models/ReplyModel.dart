// ignore_for_file: file_names

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/CommentsModel.dart';
import 'package:trace/models/UserModel.dart';

class ReplyModel extends ParseObject implements ParseCloneable {
  static const String keyTableName = "ReplyComment";

  ReplyModel() : super(keyTableName);
  ReplyModel.clone() : this();

  @override
  ReplyModel clone(Map<String, dynamic> map) =>
      ReplyModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyText = "text";
  static String keyComment = "comment";
  static String keyCommentId = "commentID";

  static String keyLikes = "likes";
  static String keyLoves = "loves";
  static String keyAngry = "angry";
  static String keySad = "sad";

  List<dynamic>? get getLikes {
    List<dynamic> like = [];

    List<dynamic>? likes = get<List<dynamic>>(keyLikes);
    if (likes != null && likes.isNotEmpty) {
      return likes;
    } else {
      return like;
    }
  }

  set setLikes(String likeAuthorId) => setAddUnique(keyLikes, likeAuthorId);
  set removeLike(String likeAuthorId) => setRemove(keyLikes, likeAuthorId);

  List<dynamic>? get getLoves {
    List<dynamic> loves = [];

    List<dynamic>? lovesList = get<List<dynamic>>(keyLoves);
    if (lovesList != null && lovesList.isNotEmpty) {
      return lovesList;
    } else {
      return loves;
    }
  }

  set setLove(String likeAuthorId) => setAddUnique(keyLoves, likeAuthorId);
  set removeLove(String likeAuthorId) => setRemove(keyLoves, likeAuthorId);

  List<dynamic>? get getAngryList {
    List<dynamic> angry = [];

    List<dynamic>? angryList = get<List<dynamic>>(keyAngry);
    if (angryList != null && angryList.isNotEmpty) {
      return angryList;
    } else {
      return angry;
    }
  }

  set setAngry(String likeAuthorId) => setAddUnique(keyAngry, likeAuthorId);
  set removeAngry(String likeAuthorId) => setRemove(keyAngry, likeAuthorId);

  List<dynamic>? get getSadList {
    List<dynamic> sad = [];

    List<dynamic>? sadList = get<List<dynamic>>(keySad);
    if (sadList != null && sadList.isNotEmpty) {
      return sadList;
    } else {
      return sad;
    }
  }

  set setSad(String likeAuthorId) => setAddUnique(keySad, likeAuthorId);
  set removeSad(String likeAuthorId) => setRemove(keySad, likeAuthorId);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getText => get<String>(keyText);
  set setText(String text) => set<String>(keyText, text);

  String? get getCommentId => get<String>(keyCommentId);
  set setCommentId(String commentID) => set<String>(keyCommentId, commentID);

  CommentsModel? get getComment => get<CommentsModel>(keyComment);
  set setComment(CommentsModel comment) =>
      set<CommentsModel>(keyComment, comment);
}
