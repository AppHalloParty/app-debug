import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AudioChatUsersModel extends ParseObject implements ParseCloneable {
  static final String keyTableName = "AudioChatUsers";

  AudioChatUsersModel() : super(keyTableName);

  AudioChatUsersModel.clone() : this();

  @override
  AudioChatUsersModel clone(Map<String, dynamic> map) =>
      AudioChatUsersModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static final String keyLiveStreaming = "liveStream";
  static final String keyLiveStreamingId = "liveStreamId";

  static final String keyJoinedUser = "joined_user";
  static final String keyJoinedUserId = "joined_user_id";
  static final String keyJoinedUserUID = "joined_user_uid";

  static final String keyCanTalk = "can_talk";

  static final String keyLeftRoom = "left_room";
  static final String keyUserSelfMutedAudioIds = "user_self_muted_audio";

  static final String keyUserMutedByHostIds = "users_muted_by_host_audio";

  static final String keySeatIndex = "co_host_seat_index";

  static final String keyEnabledVideo = "enabled_video";
  static final String keyEnabledAudio = "enabled_audio";

  bool? get getEnabledAudio {
    bool? enabledAudio = get<bool>(keyEnabledAudio);
    if (enabledAudio != null) {
      return enabledAudio;
    } else {
      return true;
    }
  }

  set setEnabledAudio(bool enabledAudio) =>
      set<bool>(keyEnabledAudio, enabledAudio);

  bool? get getEnabledVideo {
    bool? enabledVideo = get<bool>(keyEnabledVideo);
    if (enabledVideo != null) {
      return enabledVideo;
    } else {
      return false;
    }
  }

  set setEnabledVideo(bool enabledVideo) =>
      set<bool>(keyEnabledVideo, enabledVideo);

  int? get getSeatIndex => get<int>(keySeatIndex);

  set setSeatIndex(int seatIndex) => set<int>(keySeatIndex, seatIndex);

  List<dynamic>? get getUserMutedByHostIds {
    List<dynamic>? users = get<List<dynamic>>(keyUserMutedByHostIds);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return [];
    }
  }

  set addUserMutedByHostIds(String userId) =>
      setAddUnique(keyUserMutedByHostIds, userId);

  set removeUserMutedByHostIds(String userId) =>
      setRemove(keyUserMutedByHostIds, userId);

  List<dynamic>? get getUserSelfMutedAudioIds {
    List<dynamic>? users = get<List<dynamic>>(keyUserSelfMutedAudioIds);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return [];
    }
  }

  set addUserSelfMutedAudioIds(String userId) =>
      setAddUnique(keyUserSelfMutedAudioIds, userId);

  set removeUserSelfMutedAudioIds(String userId) =>
      setRemove(keyUserSelfMutedAudioIds, userId);

  UserModel? get getJoinedUser => get<UserModel>(keyJoinedUser);

  set setJoinedUser(UserModel author) => set<UserModel>(keyJoinedUser, author);

  removeJoinedUser() => set(keyJoinedUser, null);

  String? get getJoinedUserId => get<String>(keyJoinedUserId);

  set setJoinedUserId(String authorId) =>
      set<String>(keyJoinedUserId, authorId);

  removeJoinedUserId() => set(keyJoinedUserId, null);

  int? get getJoinedUserUid => get<int>(keyJoinedUserUID);

  set setJoinedUserUid(int authorUid) => set<int>(keyJoinedUserUID, authorUid);

  removeJoinedUserUid() => set(keyJoinedUserUID, null);

  LiveStreamingModel? get getLiveStreaming =>
      get<LiveStreamingModel>(keyLiveStreaming);

  set setLiveStreaming(LiveStreamingModel liveStreaming) =>
      set<LiveStreamingModel>(keyLiveStreaming, liveStreaming);

  String? get getLiveStreamingId => get<String>(keyLiveStreamingId);

  set setLiveStreamingId(String liveStreamingId) =>
      set<String>(keyLiveStreamingId, liveStreamingId);

  bool? get getCanUserTalk {
    bool? canTalk = get<bool>(keyCanTalk);
    if (canTalk != null) {
      return canTalk;
    } else {
      return false;
    }
  }

  set setCanUserTalk(bool canTalk) => set<bool>(keyCanTalk, canTalk);

  bool? get getLetTheRoom {
    bool? leftRoom = get<bool>(keyLeftRoom);
    if (leftRoom != null) {
      return leftRoom;
    } else {
      return false;
    }
  }

  set setLetTheRoom(bool leftRoom) => set<bool>(keyLeftRoom, leftRoom);
}
