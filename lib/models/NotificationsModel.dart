import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/PostsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class NotificationsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Notifications";

  NotificationsModel() : super(keyTableName);
  NotificationsModel.clone() : this();

  @override
  NotificationsModel clone(Map<String, dynamic> map) => NotificationsModel.clone()..fromJson(map);

  static String notificationTypeFollowers = "followers";
  static String notificationTypeLikedPost = "postLiked";
  static String notificationTypeCommentPost = "postComment";
  static String notificationTypeReplyCommentPost = "replyPostComment";
  static String notificationTypeLiveInvite = "liveInvite";
  static String notificationTypeLikedReels = "reelsLiked";
  static String notificationTypeCommentReels = "reelsComment";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";

  static String keyReceiver = "Receiver";
  static String keyReceiverId = "ReceiverId";

  static String keyPost = "Post";
  static String keyPostAuthor = "Post.Author";

  static String keyNotificationType = "type";

  static String keyRead = "read";

  static String keyLive = "Live";
  static String keyLiveAuthor = "Live.Author";


  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  PostsModel? get getPost => get<PostsModel>(keyPost);
  set setPost(PostsModel postsModel) => set<PostsModel>(keyPost, postsModel);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String authorId) => set<String>(keyReceiverId, authorId);

  String? get getNotificationType => get<String>(keyNotificationType);
  set setNotificationType(String notificationType) => set<String>(keyNotificationType, notificationType);

  bool? get isRead {
    bool? read = get<bool>(keyRead);
    if(read != null){
      return read;
    } else {
      return false;
    }
  }
  set setRead(bool read) => set<bool>(keyRead, read);

  LiveStreamingModel? get getLive => get<LiveStreamingModel>(keyLive);
  set setLive(LiveStreamingModel live) => set<LiveStreamingModel>(keyLive, live);

}