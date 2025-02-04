import 'package:trace/models/GiftsSentModel.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class LiveMessagesModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "StreamingMessage";

  LiveMessagesModel() : super(keyTableName);
  LiveMessagesModel.clone() : this();

  @override
  LiveMessagesModel clone(Map<String, dynamic> map) => LiveMessagesModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static final String messageTypeComment = "COMMENT";
  static final String messageTypeFollow = "FOLLOW";
  static final String messageTypeGift = "GIFT";
  static final String messageTypeSystem = "SYSTEM";
  static final String messageTypeJoin = "JOIN";
  static final String messageTypeCoHost = "HOST";
  static final String messageTypeLeave = "LEAVE";
  static final String messageTypeRemoved = "REMOVED";

  static final String keySenderAuthor = "author";
  static final String keySenderAuthorId = "authorId";

  static final String keyLiveStreaming = "liveStream";
  static final String keyLiveStreamingId = "liveStreamId";

  static final String keyGiftSent = "giftLive";
  static final String keyGiftSentGift = "giftLive.gift";
  static final String keyGiftSentId = "giftLiveId";
  static final String keyGiftId = "giftId";

  static final String keyMessage = "message";
  static final String keyMessageType = "messageType";

  static final String keyCoHostAvailable = "coHostAvailable";
  static final String keyCoHostAuthor = "coHostAuthor";
  static final String keyCoHostAuthorUid = "coHostAuthorUid";


  UserModel? get getAuthor => get<UserModel>(keySenderAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keySenderAuthor, author);

  String? get getAuthorId => get<String>(keySenderAuthorId);
  set setAuthorId(String authorId) => set<String>(keySenderAuthorId, authorId);

  UserModel? get getCoHostAuthor => get<UserModel>(keyCoHostAuthor);
  set setCoHostAuthor(UserModel author) => set<UserModel>(keyCoHostAuthor, author);

  int? get getCoHostAuthorUid => get<int>(keyCoHostAuthorUid);
  set setCoHostAuthorUid(int authorUid) => set<int>(keyCoHostAuthorUid, authorUid);

  bool? get getCoHostAuthorAvailable => get<bool>(keyCoHostAvailable);
  set setCoHostAvailable(bool coHostAvailable) => set<bool>(keyCoHostAvailable, coHostAvailable);

  String? get getMessage => get<String>(keyMessage);
  set setMessage(String message) => set<String>(keyMessage, message);

  String? get getMessageType => get<String>(keyMessageType);
  set setMessageType(String messageType) => set<String>(keyMessageType, messageType);

  LiveStreamingModel? get getLiveStreaming => get<LiveStreamingModel>(keyLiveStreaming);
  set setLiveStreaming(LiveStreamingModel liveStreaming) => set<LiveStreamingModel>(keyLiveStreaming, liveStreaming);

  String? get getLiveStreamingId => get<String>(keyLiveStreamingId);
  set setLiveStreamingId(String liveStreamingId) => set<String>(keyLiveStreamingId, liveStreamingId);

  GiftsSentModel? get getGiftSent => get<GiftsSentModel>(keyGiftSent);
  set setGiftSent(GiftsSentModel giftsSent) => set<GiftsSentModel>(keyGiftSent, giftsSent);

  String? get getGiftSentId => get<String>(keyGiftSentId);
  set setGiftSentId(String giftSentId) => set<String>(keyGiftSentId, giftSentId);

  String? get getGiftId => get<String>(keyGiftId);
  set setGiftId(String giftId) => set<String>(keyGiftId, giftId);

}