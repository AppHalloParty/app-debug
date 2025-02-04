import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/models/UserModel.dart';

class CallsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Calls";

  CallsModel() : super(keyTableName);
  CallsModel.clone() : this();

  @override
  CallsModel clone(Map<String, dynamic> map) => CallsModel.clone()..fromJson(map);

  static const CALL_END_REASON_END = "TERMINATED";
  static const CALL_END_REASON_BUSY = "BUSY";
  static const CALL_END_REASON_GIVE_UP = "GIVE_UP";
  static const CALL_END_REASON_REFUSED = "REFUSED";
  static const CALL_END_REASON_NO_ANSWER = "NO_ANSWER";
  static const CALL_END_REASON_OFFLINE = "OFFLINE";
  static const CALL_END_REASON_CREDITS = "COINS";


  static String keyAuthor= "fromUser";
  static String keyAuthorId = "fromUserId";
  //toUser
  static String keyReceiver = "toUser";
  static String keyReceiverId = "toUserId";

  static String keyDuration = "duration";
  static String keyAccepted = "accepted";
  static String keyCallEndReason = "reason";
  static String keyCallTypeVoice = "isVoiceCall";
  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";
  static String keyCoins = "coins";

  int? get getCoins => get<int>(keyCoins);
  set setCoins(int count) => set<int>(keyCoins, count);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  UserModel? get getReceiver => get<UserModel>(keyReceiver);
  set setReceiver(UserModel receiver) => set<UserModel>(keyReceiver, receiver);

  String? get getReceiverId => get<String>(keyReceiverId);
  set setReceiverId(String receiverId) => set<String>(keyReceiverId, receiverId);


  String? get getDuration{
    String? duration = get<String>(keyDuration);
    if(duration != null){
      return duration;
    }else{
      return "00:00";
    }
  }

  set setDuration(String duration) => set<String>(keyDuration, duration);

  set setAccepted(bool accepted) => set<bool>(keyAccepted, accepted);

  bool? get getAccepted{
    bool? accepted = get<bool>(keyAccepted);
    if(accepted != null){
      return accepted;
    }else{
      return true;
    }
  }

  set setIsVoiceCall(bool accepted) => set<bool>(keyCallTypeVoice, accepted);

  bool? get getIsVoiceCall{
    bool? accepted = get<bool>(keyCallTypeVoice);
    if(accepted != null){
      return accepted;
    }else{
      return true;
    }
  }

  String? get getCallEndReason => get<String>(keyCallEndReason);
  set setCallEndReason(String callEndReason) => set<String>(keyCallEndReason, callEndReason);


}