import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class GiftsSentModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "GiftsSent";

  GiftsSentModel() : super(keyTableName);
  GiftsSentModel.clone() : this();

  @override
  GiftsSentModel clone(Map<String, dynamic> map) => GiftsSentModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "authorId";

  static String keyDiamondsQuantity = "diamondsQuantity";

  static String keyReceiver = "receiver";
  static String keyReceiverId = "receiverId";

  static String keyGift = "gift";
  static String keyGiftId = "giftId";

  static String keyQuantity = "quantity";
  static String keyLiveId = "live_id";

  String? get getLiveId {
    String? liveId = get<String>(keyLiveId);
    if(liveId != null) {
      return liveId;
    }else{
      return "";
    }
  }
  set setLiveId(String liveID) => set<String>(keyLiveId, liveID);

  int? get getQuantity => get<int>(keyQuantity);
  set setQuantity(int count) => set<int>(keyQuantity, count);
  set incrementQuantity(int count) => setIncrement(keyQuantity, count);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  int? get getDiamondsQuantity => get<int>(keyDiamondsQuantity);
  set setCounterDiamondsQuantity(int count) => set<int>(keyDiamondsQuantity, count);
  set incrementDiamondsQuantity(int count) => setIncrement(keyDiamondsQuantity, count);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String authorId) => set<String>(keyReceiverId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel author) => set<UserModel>(keyReceiver, author);

  String? get getGiftId => get<String>(keyGiftId);
  set setGiftId(String giftId) => set<String>(keyGiftId, giftId);

  GiftsModel? get getGift => get<GiftsModel>(keyGift);
  set setGift(GiftsModel gift) => set<GiftsModel>(keyGift, gift);


}