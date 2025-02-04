import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class CommentsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Comments";

  CommentsModel() : super(keyTableName);
  CommentsModel.clone() : this();

  @override
  CommentsModel clone(Map<String, dynamic> map) => CommentsModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";


  static String keyText = "text";
  static String keyPost = "post";
  static String keyPostId = "postId";


  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getText => get<String>(keyText);
  set setText(String text) => set<String>(keyText, text);

  String? get getPostId => get<String>(keyPostId);
  set setPostId(String postId) => set<String>(keyPostId, postId);

  PostsModel? get getPost => get<PostsModel>(keyPost);
  set setPost(PostsModel post) => set<PostsModel>(keyPost, post);


}