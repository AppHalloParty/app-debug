import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'GiftSendersModel.dart';

class LiveStreamingModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Streaming";

  LiveStreamingModel() : super(keyTableName);
  LiveStreamingModel.clone() : this();

  @override
  LiveStreamingModel clone(Map<String, dynamic> map) => LiveStreamingModel.clone()..fromJson(map);

  static final String privacyTypeAnyone = "anyone";
  static final String privacyTypeFriends = "friends";
  static final String privacyTypeNoOne = "none";

  static final String liveTypeParty = "party";
  static final String liveTypeLive = "live";
  static final String liveTypeBattle = "battle";

  static final String livePrefixAudioRoom = "audio_room";
  static final String livePrefixLive = "single_live";
  static final String livePrefixParty = "party_live";


  static const String liveSubAll = "All";
  static const String liveSubTalking = "talk";
  static const String liveSubSinging = "sing";
  static const String liveSubDancing = "dance";
  static const String liveSubFriends = "friend";
  static const String liveSubGame = "game";
  static const String tagMusic = "music";
  static const String tagDancing = "dancing";
  static const String tagCosplay = "cosplay";
  static const String tagTalkShow = "talk_show";
  static const String tagModel = "model";
  static const String tagGossip = "gossip";
  static const String tagGameplay = "gameplay";
  static const String tagMakeup = "makeup";
  static const String tagFitness = "fitness";
  static const String tagMimicryShow = "mimicry_show";
  static const String tagCharming = "charming";
  static const String tagDJ = "dj";
  static const String tagTarot = "tarot";
  static const String tagPoleDance = "pole_dance";
  static const String tagRadio = "radio";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorId = "AuthorId";
  static String keyAuthorUid = "AuthorUid";
  static String keyAuthorUserName = "username";

  static String keyViewsCount = "viewsCount";

  static String keyAuthorInvited = "AuthorInvited";
  static String keyAuthorInvitedUid = "AuthorInvitedUid";

   static final String keyViewersUid = "viewers_uid";
   static final String keyViewersId = "viewers_id";

  static final String keyViewersCountLive = "viewersCountLive";
  static final String keyStreamingPrivate = "private";

   static final String keyLiveImage = "image";
  static final String keyLiveGeoPoint = "geoPoint";
  static final String keyLiveTags = "live_tag";

   static final String keyStreaming = "streaming";
   static final String keyStreamingTime = "streaming_time";
   static final String keyStreamingDiamonds = "streaming_diamonds";
  static final String keyAuthorTotalDiamonds = "author_total_diamonds";


  static final String keyStreamingChannel = "streaming_channel";

  static final String keyStreamingCategory = "streaming_category";

  static final String keyCoHostAvailable = "coHostAvailable";
  static final String keyCoHostAuthor = "coHostAuthor";
  static final String keyCoHostAuthorUid = "coHostAuthorUid";

  static final String keyHashTags = "hash_tags";
  static final String keyHashTagsId = "hash_tags_id";

  static final String keyPrivateLiveGift = "privateLivePrice";
  static final String keyPrivateViewers = "privateViewers";

  static final String keyFirstLive = "firstLive";

  static final String keyGiftSenders = "giftSenders";
  static final String keyGiftSendersAuthor = "giftSenders.author";

  static final String keyGiftSendersPicture = "giftSendersPicture";

  static final String keyInvitedBroadCasterId = "invitedBroadCasterId";

  static final String keyInvitationAccepted = "InvitationAccepted";

  static final String keyCoHostUID = "coHostUID";
  static final String keyEndByAdmin = "endByAdmin";

  static final String keyInvitedPartyUid = "invitedPartyUid";
  static final String keyInvitedPartyLive = "invitedPartyLive";
  static final String keyInvitedPartyLiveAuthor = "invitedPartyLive.Author";

  static final String liveAudio = "audio";
  static final String liveVideo = "video";

  static final String keyLiveType = "liveType";

  static final String keyAudioHostsList = "audioHostsList";

  static final String keyRemovedUserIds = "removed_users_id";

  static final String keyMutedUserIds = "muted_users_id";
  static final String keyUnMutedUserIds = "un_muted_users_id";
  static final String keyUserSelfMutedAudioIds = "user_self_muted_audio";

  static final String keyAudioRoomTitle = "audio_room_title";
  static final String keyLiveSubType = "live_sub_type";

  static final String keyFollowers = "new_followers";
  static final String keyReachedPeople = "reached_people";

  static final String keyPartyType = "party_type";

  static final String keyNumberOfChairs = "number_of_chairs";

  static final String keyPartyTheme = "party_theme";
  static final String keyShareMedia = "share_media";

  static final String keyBattle = "is_battle";
  static final String keyBattleStatus = "battle_status";
  static final String battlePaused = "battle_paused";
  static final String battleEnded = "battle_ended";
  static final String battleAlive = "battle_alive";
  static final String keyBattleLiveId = "battle_liveID";

  static final String keyMyBattlePoints = "my_points";
  static final String keyHisBattlePoints = "his_points";

  static final String keyMyBattleVictory = "my_victories";
  static final String keyHisBattleVictory = "his_victories";
  static final String keyRepeatBattleTimes = "repeat_battle_times";

  int? get getRepeatBattleTimes {
    int? number = get<int>(keyRepeatBattleTimes);
    if(number != null) {
      return number;
    }else{
      return 0;
    }
  }
  set addRepeatBattleTimes(int number) => setIncrement(keyRepeatBattleTimes, number);
  set setRepeatBattleTimes(int number) => set(keyRepeatBattleTimes, number);

  int? get getHisBattleVictory {
    int? number = get<int>(keyHisBattleVictory);
    if(number != null) {
      return number;
    }else{
      return 0;
    }
  }
  set addHisBattleVictory(int number) => setIncrement(keyHisBattleVictory, number);
  set setHisBattleVictory(int number) => set(keyHisBattleVictory, number);

  int? get getMyBattleVictory {
    int? number = get<int>(keyMyBattleVictory);
    if(number != null) {
      return number;
    }else{
      return 0;
    }
  }
  set addMyBattleVictory(int number) => setIncrement(keyMyBattleVictory, number);
  set setMyBattleVictory(int number) => set(keyMyBattleVictory, number);

  int? get getMyBattlePoints {
    int? battlePoints = get<int>(keyMyBattlePoints);
    if(battlePoints != null) {
      return battlePoints;
    }else{
      return 0;
    }
  }
  set addMyBattlePoints(int diamonds) => setIncrement(keyMyBattlePoints, diamonds);
  set setMyBattlePoints(int diamonds) => set(keyMyBattlePoints, diamonds);

  int? get getHisBattlePoints {
    int? battlePoints = get<int>(keyHisBattlePoints);
    if(battlePoints != null) {
      return battlePoints;
    }else{
      return 0;
    }
  }
  set addHisBattlePoints(int diamonds) => setIncrement(keyHisBattlePoints, diamonds);
  set setHisBattlePoints(int diamonds) => set(keyHisBattlePoints, diamonds);

  String? get getBattleLiveId {
    String? battleLiveId = get<String>(keyBattleLiveId);
    if(battleLiveId != null){
      return battleLiveId;
    } else {
      return "";
    }
  }

  set setBattleLiveId(String battleLiveId) => set<String>(keyBattleLiveId, battleLiveId);

  String? get getBattleStatus {
    String? battleStatus = get<String>(keyBattleStatus);
    if(battleStatus != null){
      return battleStatus;
    } else {
      return "";
    }
  }

  set setBattleStatus(String battleStatus) => set<String>(keyBattleStatus, battleStatus);

  bool? get getBattle {
    bool? isBattle = get<bool>(keyBattle);
    if(isBattle != null) {
      return isBattle;
    }else{
      return false;
    }
  }
  set setBattle(bool isBattle) => set<bool>(keyBattle, isBattle);

  bool? get getSharingMedia {
    bool? isSharingMedia = get<bool>(keyShareMedia);
    if(isSharingMedia != null) {
      return isSharingMedia;
    }else{
      return false;
    }
  }
  set setSharingMedia(bool isSharingMedia) => set<bool>(keyShareMedia, isSharingMedia);

  String? get getAuthorUserName {
    String? username = get<String>(keyAuthorUserName);
    if(username != null) {
      return username;
    }else {
      return "";
    }
  }
  set setAuthorUserName(String username) => set<String>(keyAuthorUserName, username);

  ParseFileBase? get getPartyTheme => get<ParseFileBase>(keyPartyTheme);
  set setPartyTheme(ParseFileBase file) => set<ParseFileBase>(keyPartyTheme, file);

  int? get getNumberOfChairs {
    int? number = get<int>(keyNumberOfChairs);
    if(number != null) {
      return number;
    }else{
      return 0;
    }
  }
  set setNumberOfChairs(int partyType) => set<int>(keyNumberOfChairs, partyType);

  String? get getPartyType => get<String>(keyPartyType);
  set setPartyType(String partyType) => set<String>(keyPartyType, partyType);

  List<dynamic>? get getReachedPeople{
    List<dynamic>? users = get<List<dynamic>>(keyReachedPeople);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addReachedPeople(String userId) => setAddUnique(keyReachedPeople, userId);

  List<dynamic>? get getFollower{
    List<dynamic>? users = get<List<dynamic>>(keyFollowers);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addFollower(String userId) => setAddUnique(keyFollowers, userId);
  set removeFollower(String userId) => setRemove(keyFollowers, userId);


  String? get getLiveSubType => get<String>(keyLiveSubType);
  set setLiveSubType(String audioRoomTitle) => set<String>(keyLiveSubType, audioRoomTitle);

  String? get getLiveTitle => get<String>(keyAudioRoomTitle);
  set setLiveTitle(String audioRoomTitle) => set<String>(keyAudioRoomTitle, audioRoomTitle);

  List<dynamic>? get getUserSelfMutedAudioIds{
    List<dynamic>? users = get<List<dynamic>>(keyUserSelfMutedAudioIds);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addUserSelfMutedAudioIds(String userId) => setAddUnique(keyUserSelfMutedAudioIds, userId);
  set removeUserSelfMutedAudioIds(String userId) => setRemove(keyUserSelfMutedAudioIds, userId);

  List<dynamic>? get getUnMutedUserIds{
    List<dynamic>? users = get<List<dynamic>>(keyUnMutedUserIds);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addUnMutedUserIds(String userId) => setAddUnique(keyUnMutedUserIds, userId);
  set removeUnMutedUserIds(String userId) => setRemove(keyUnMutedUserIds, userId);

  List<dynamic>? get getMutedUserIds{
    List<dynamic>? users = get<List<dynamic>>(keyMutedUserIds);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addMutedUserIds(String userId) => setAddUnique(keyMutedUserIds, userId);
  set removeMutedUserIds(String userId) => setRemove(keyMutedUserIds, userId);

  List<dynamic>? get getRemovedUserIds{
    List<dynamic>? users = get<List<dynamic>>(keyRemovedUserIds);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addRemovedUserIds(String userId) => setAddUnique(keyRemovedUserIds, userId);
  set removeRemovedUserIds(String userId) => setRemove(keyRemovedUserIds, userId);

  List<dynamic>? get getAudioHostsList{
    List<dynamic>? users = get<List<dynamic>>(keyAudioHostsList);
    if(users != null && users.length > 0){
      return users;
    } else {
      return [];
    }
  }
  set addAudioHostToList(UserModel user) => setAddUnique(keyAudioHostsList, user);
  set removeAudioHostToList(UserModel user) => setRemove(keyAudioHostsList, user);

  String? get getLiveType => get<String>(keyLiveType);
  set setLiveType(String liveType) => set<String>(keyLiveType, liveType);

  set removeViewersId(String viewerAuthorId) => setRemove(keyViewersId, viewerAuthorId);

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  int? get getAuthorUid => get<int>(keyAuthorUid);
  set setAuthorUid(int authorUid) => set<int>(keyAuthorUid, authorUid);

  UserModel? get getCoHostAuthor => get<UserModel>(keyCoHostAuthor);
  set setCoHostAuthor(UserModel author) => set<UserModel>(keyCoHostAuthor, author);

  int? get getCoHostAuthorUid => get<int>(keyCoHostAuthorUid);
  set setCoHostAuthorUid(int authorUid) => set<int>(keyCoHostAuthorUid, authorUid);

  bool? get getCoHostAuthorAvailable => get<bool>(keyCoHostAvailable);
  set setCoHostAvailable(bool coHostAvailable) => set<bool>(keyCoHostAvailable, coHostAvailable);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getInvitedBroadCasterId => get<String>(keyInvitedBroadCasterId);
  set setInvitedBroadCasterId(String authorId) => set<String>(keyInvitedBroadCasterId, authorId);

  UserModel? get getAuthorInvited => get<UserModel>(keyAuthorInvited);
  set setAuthorInvited(UserModel invitedAuthor) => set<UserModel>(keyAuthorInvited, invitedAuthor);

  int? get getAuthorInvitedUid => get<int>(keyAuthorInvitedUid);
  set setAuthorInvitedUid(int invitedAuthorUid) => set<int>(keyAuthorInvitedUid, invitedAuthorUid);

  int? get getViewersCount{

    int? viewersCount = get<int>(keyViewersCountLive);
    if(viewersCount != null){
      return viewersCount;
    } else {
      return 0;
    }
  }
  set addViewersCount(int viewersCount) => setIncrement(keyViewersCountLive, viewersCount);
  set removeViewersCount(int viewersCount) {

    if(getViewersCount! > 0){
      setDecrement(keyViewersCountLive, viewersCount);
    }
  }


  ParseFileBase? get getImage => get<ParseFileBase>(keyLiveImage);
  set setImage(ParseFileBase imageFile) => set<ParseFileBase>(keyLiveImage, imageFile);


  set setGifSenderImage(ParseFileBase imageFile) => setAddUnique(keyGiftSendersPicture, imageFile);

  List<dynamic>? get getGifSenderImage {

    List<dynamic>? images = get<List<dynamic>>(keyGiftSendersPicture);
    if(images != null && images.length > 0){
      return images;
    }else{
      return [];
    }
  }

  List<dynamic>? get getCoHostUiD{

    List<dynamic>? coHostUiD = get<List<dynamic>>(keyCoHostUID);
    if(coHostUiD != null && coHostUiD.length > 0){
      return coHostUiD;
    } else {
      return [];
    }
  }
  set setCoHostUID(int coHostUiD) => setAddUnique(keyCoHostUID, coHostUiD);


  List<dynamic>? get getViewers{

    List<dynamic>? viewers = get<List<dynamic>>(keyViewersUid);
    if(viewers != null && viewers.length > 0){
      return viewers;
    } else {
      return [];
    }
  }
  set setViewers(int viewerUid) => setAddUnique(keyViewersUid, viewerUid);

  List<dynamic>? get getViewersId{

    List<dynamic>? viewersId = get<List<dynamic>>(keyViewersId);
    if(viewersId != null && viewersId.length > 0){
      return viewersId;
    } else {
      return [];
    }
  }
  set setViewersId(String viewerAuthorId) => setAddUnique(keyViewersId, viewerAuthorId);

  int? get getDiamonds => get<int>(keyStreamingDiamonds);
  set addDiamonds(int diamonds) => setIncrement(keyStreamingDiamonds, diamonds);

  int? get getAuthorTotalDiamonds => get<int>(keyAuthorTotalDiamonds);
  set addAuthorTotalDiamonds(int diamonds) => setIncrement(keyAuthorTotalDiamonds, diamonds);

  bool? get getStreaming => get<bool>(keyStreaming);
  set setStreaming(bool isStreaming) => set<bool>(keyStreaming, isStreaming);

  bool? get getFirstLive {
    var isFirstTime = get<bool>(keyFirstLive);

    if(isFirstTime != null){
      return isFirstTime;
    }else{
      return false;
    }
  }

  set setFirstLive(bool isFirstLive) => set<bool>(keyFirstLive, isFirstLive);



  String? get getStreamingTime => get<String>(keyStreamingTime);
  set setStreamingTime(String streamingTime) => set<String>(keyStreamingTime, streamingTime);

  String? get getStreamingCategory => get<String>(keyStreamingCategory);
  set setStreamingCategory(String streamingCategory) => set<String>(keyStreamingCategory, streamingCategory);

  String? get getStreamingTags {
    String? text = get<String>(keyLiveTags);
    if(text != null){
      return text;
    } else {
      return "";
    }
  }

  set setStreamingTags(String text) => set<String>(keyLiveTags, text);

  String? get getStreamingChannel => get<String>(keyStreamingChannel);
  set setStreamingChannel(String streamingChannel) => set<String>(keyStreamingChannel, streamingChannel);

  ParseGeoPoint? get getStreamingGeoPoint => get<ParseGeoPoint>(keyLiveGeoPoint);
  set setStreamingGeoPoint(ParseGeoPoint liveGeoPoint) => set<ParseGeoPoint>(keyLiveGeoPoint, liveGeoPoint);

  bool? get getPrivate{
    bool? private = get<bool>(keyStreamingPrivate);
    if(private != null){
      return private;
    } else {
      return false;
    }
  }
  set setPrivate(bool private) => set<bool>(keyStreamingPrivate, private);

  bool? get getInvitationAccepted{
    bool? accepted = get<bool>(keyInvitationAccepted);
    if(accepted != null){
      return accepted;
    } else {
      return false;
    }
  }
  set setInvitationAccepted(bool accepted) => set<bool>(keyInvitationAccepted, accepted);




  List<String>? get getHashtags{

    var arrayString =  get<List<dynamic>>(keyHashTagsId);

    if(arrayString != null){
      List<String> users = new List<String>.from(arrayString);
      return users;
    } else {
      return [];
    }

  }

  List<dynamic>? get getHashtagsForQuery{

    var arrayString =  get<List<dynamic>>(keyHashTags);

    if(arrayString != null){
      List<String> users = new List<String>.from(arrayString);
      return users;
    } else {
      return [];
    }

  }

  set setHashtags(List hashtags) {

    List<String> hashTagsList = [];

    /*for(HashTagModel hashTag in hashtags){
      hashTagsList.add(hashTag.objectId!);
    }*/

    setAddAllUnique(keyHashTags, hashtags);
    setAddAllUnique(keyHashTagsId, hashTagsList);
  }

  GiftsModel? get getPrivateGift => get<GiftsModel>(keyPrivateLiveGift);
  set setPrivateLivePrice(GiftsModel privateLivePrice) => set<GiftsModel>(keyPrivateLiveGift, privateLivePrice);
  set removePrice(GiftsModel privateLivePrice) => setRemove(keyPrivateLiveGift, privateLivePrice);

  List<dynamic>? get getPrivateViewersId{

    List<dynamic>? viewersId = get<List<dynamic>>(keyPrivateViewers);
    if(viewersId != null && viewersId.length > 0){
      return viewersId;
    } else {
      return [];
    }
  }
  set setPrivateViewersId(String viewerAuthorId) => setAddUnique(keyPrivateViewers, viewerAuthorId);

  set setPrivateListViewersId(List viewersId) {

    List<String> listViewersId = [];

    for(String privateViewer in viewersId){
      listViewersId.add(privateViewer);
    }
    setAddAllUnique(keyPrivateViewers, listViewersId);
  }

  List<dynamic>? get getGiftsSenders{

    List<dynamic>? giftSenders = get<List<dynamic>>(keyGiftSenders);
    if(giftSenders != null && giftSenders.length > 0){
      return giftSenders;
    } else {
      return [];
    }
  }
  set addGiftsSenders(GiftsSenderModel giftsSenderModel) => setAddUnique(keyGiftSenders, giftsSenderModel);

  bool? get isLiveCancelledByAdmin{
    bool? cancelled = get<bool>(keyEndByAdmin);
    if(cancelled != null){
      return cancelled;
    } else {
      return false;
    }
  }

  set setTerminatedByAdmin(bool yes) => set<bool>(keyEndByAdmin, yes);

  List<dynamic>? get getInvitedPartyUid{

    List<dynamic>? invitedUid = get<List<dynamic>>(keyInvitedPartyUid);
    if(invitedUid != null && invitedUid.length > 0){
      return invitedUid;
    } else {
      return [];
    }
  }
  set addInvitedPartyUid(List<dynamic> uidList) => setAddAllUnique(keyInvitedPartyUid, uidList);

  set removeInvitedPartyUid(int uid) => setRemove(keyInvitedPartyUid, uid);

  LiveStreamingModel? get getInvitationLivePending => get<LiveStreamingModel>(keyInvitedPartyLive);

  set setInvitationLivePending(LiveStreamingModel live) => set<LiveStreamingModel>(keyInvitedPartyLive, live);

  removeInvitationLivePending() => unset(keyInvitedPartyLive);
}