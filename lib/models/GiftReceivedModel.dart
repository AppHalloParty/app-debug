import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class GiftsReceivedModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "GiftsReceived";

  GiftsReceivedModel() : super(keyTableName);
  GiftsReceivedModel.clone() : this();

  @override
  GiftsReceivedModel clone(Map<String, dynamic> map) => GiftsReceivedModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String sourceLiveStreaming = "video_live";
  static String sourceAudioLive = "audio_live";
  static String sourceAppReward = "app_reward";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiverId";

  static String keyGift = "gift";
  static String keyGiftId = "giftId";

  static String keyQuantity = "quantity";

  int? get getQuantity => get<int>(keyQuantity);
  set setQuantity(int count) => set<int>(keyQuantity, count);
  set incrementQuantity(int count) => setIncrement(keyQuantity, count);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String authorId) => set<String>(keyReceiverId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getGiftId => get<String>(keyGiftId);
  set setGiftId(String giftId) => set<String>(keyGiftId, giftId);

  GiftsModel? get getGift => get<GiftsModel>(keyGift);
  set setGift(GiftsModel gift) => set<GiftsModel>(keyGift, gift);

}