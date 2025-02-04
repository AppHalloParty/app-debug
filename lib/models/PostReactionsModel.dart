// ignore_for_file: file_names

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';

import 'PostsModel.dart';

class PostReactionsModel extends ParseObject implements ParseCloneable {
  static const String keyTableName = "PostReactions";

  PostReactionsModel() : super(keyTableName);

  PostReactionsModel.clone() : this();

  @override
  PostReactionsModel clone(Map<String, dynamic> map) =>
      PostReactionsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyPost = "post";
  static String keyPostId = "post_Id";

  static String keyLikes = "likes";
  static String keyLoves = "loves";
  static String keyAngry = "angry";
  static String keySad = "sad";
  static String keyLaugh = "laugh";
  static String keyAdmire = "admire";
  static String keySupportive = "supportive";

  static String keyTotalReactions = "total_reactions";

  PostsModel? get getPost => get<PostsModel>(keyPost);
  set setPost(PostsModel post) => set<PostsModel>(keyPost, post);

  String? get getPostId => get<String>(keyPostId);
  set setPostId(String postId) => set<String>(keyPostId, postId);

  List<dynamic>? get getTotalReactions {
    List<dynamic> totalReaction = [];

    List<dynamic>? totalReactions = get<List<dynamic>>(keyTotalReactions);
    if (totalReactions != null && totalReactions.isNotEmpty) {
      return totalReactions;
    } else {
      return totalReaction;
    }
  }

  set setTotalReactions(String supportiveAuthorId) =>
      setAddUnique(keyTotalReactions, supportiveAuthorId);

  set removeTotalReactions(String supportiveAuthorId) =>
      setRemove(keyTotalReactions, supportiveAuthorId);

  List<dynamic>? get getSupportive {
    List<dynamic> supportive = [];

    List<dynamic>? supportives = get<List<dynamic>>(keySupportive);
    if (supportives != null && supportives.isNotEmpty) {
      return supportives;
    } else {
      return supportive;
    }
  }

  set setSupportive(String supportiveAuthorId) =>
      setAddUnique(keySupportive, supportiveAuthorId);

  set removeSupportive(String supportiveAuthorId) =>
      setRemove(keySupportive, supportiveAuthorId);

  List<dynamic>? get getAdmire {
    List<dynamic> admire = [];

    List<dynamic>? admires = get<List<dynamic>>(keyAdmire);
    if (admires != null && admires.isNotEmpty) {
      return admires;
    } else {
      return admire;
    }
  }

  set setAdmire(String admireAuthorId) =>
      setAddUnique(keyAdmire, admireAuthorId);

  set removeAdmire(String admireAuthorId) =>
      setRemove(keyAdmire, admireAuthorId);

  List<dynamic>? get getLaugh {
    List<dynamic> laugh = [];

    List<dynamic>? laughs = get<List<dynamic>>(keyLaugh);
    if (laughs != null && laughs.isNotEmpty) {
      return laughs;
    } else {
      return laugh;
    }
  }

  set setLaugh(String laughAuthorId) => setAddUnique(keyLaugh, laughAuthorId);

  set removeLaugh(String laughAuthorId) => setRemove(keyLaugh, laughAuthorId);

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

}
