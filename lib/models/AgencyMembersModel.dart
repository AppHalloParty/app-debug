import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AgencyMembersModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "AgencyMember";

  AgencyMembersModel() : super(keyTableName);
  AgencyMembersModel.clone() : this();

  @override
  AgencyMembersModel clone(Map<String, dynamic> map) => AgencyMembersModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";
  static String keyStatusJoined = "joined";
  static String keyStatusPending = "pending";
  static String keyStatusLeft = "left";

  static final String keyAgent = "agent";
  static final String keyAgentId = "agent_id";

  static final String keyHost = "host";
  static final String keyHostId = "host_id";

  static final String keyClientStatus = "client_status";
  static final String keyLevel = "level";

  static final String keyLiveDuration = "live_duration";
  static final String keyPartyHostDuration = "party_host_duration";
  static final String keyPartyCrownDuration = "party_crown_duration";
  static final String keyMatchingDuration = "matching_duration";

  static final String keyTotalEarningPoints = "total_points_earnings";
  static final String keyLiveEarning = "live_earnings";
  static final String keyMatchEarning = "match_earnings";
  static final String keyPartyEarning = "party_earnings";
  static final String keyGameGratuities = "game_gratuities";
  static final String keyPlatformReward = "platform_reward";
  static final String keyPCoinEarnings = "p_coin_earnings";

  int? get getMatchingDuration {

    int? partyCrownDuration = get<int>(keyMatchingDuration);
    if(partyCrownDuration != null){
      return partyCrownDuration;
    } else {
      return 0;
    }
  }
  set setMatchingDuration(int matchingDuration) => setIncrement(keyMatchingDuration, matchingDuration);
  set removeMatchingDuration(int matchingDuration) => setDecrement(keyMatchingDuration, matchingDuration);

  int? get getPartyCrownDuration {

    int? partyCrownDuration = get<int>(keyPartyCrownDuration);
    if(partyCrownDuration != null){
      return partyCrownDuration;
    } else {
      return 0;
    }
  }
  set setPartyCrownDuration(int partyCrownDuration) => setIncrement(keyPartyCrownDuration, partyCrownDuration);
  set removePartyCrownDuration(int partyCrownDuration) => setDecrement(keyPartyCrownDuration, partyCrownDuration);

  int? get getPartyHostDuration {

    int? partyHostDuration = get<int>(keyPartyHostDuration);
    if(partyHostDuration != null){
      return partyHostDuration;
    } else {
      return 0;
    }
  }
  set setPartyHostDuration(int partyHostDuration) => setIncrement(keyPartyHostDuration, partyHostDuration);
  set removePartyHostDuration(int partyHostDuration) => setDecrement(keyPartyHostDuration, partyHostDuration);

  int? get getLiveDuration {

    int? liveDuration = get<int>(keyLiveDuration);
    if(liveDuration != null){
      return liveDuration;
    } else {
      return 0;
    }
  }
  set setLiveDuration(int liveDuration) => setIncrement(keyLiveDuration, liveDuration);
  set removeLiveDuration(int liveDuration) => setDecrement(keyLiveDuration, liveDuration);

  int? get getPCoinEarnings {

    int? totalEarningPoints = get<int>(keyPCoinEarnings);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setPCoinEarnings(int pCoinEarnings) => setIncrement(keyPCoinEarnings, pCoinEarnings);
  set removePCoinEarnings(int pCoinEarnings) => setDecrement(keyPCoinEarnings, pCoinEarnings);

  int? get getPlatformReward {

    int? totalEarningPoints = get<int>(keyPlatformReward);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setPlatformReward(int platformReward) => setIncrement(keyPlatformReward, platformReward);
  set removePlatformReward(int platformReward) => setDecrement(keyPlatformReward, platformReward);

  int? get getGameGratuities {

    int? totalEarningPoints = get<int>(keyGameGratuities);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setGameGratuities(int gameGratuities) => setIncrement(keyGameGratuities, gameGratuities);
  set removeGameGratuities(int gameGratuities) => setDecrement(keyGameGratuities, gameGratuities);

  int? get getPartyEarning {

    int? totalEarningPoints = get<int>(keyPartyEarning);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setPartyEarning(int partyEarning) => setIncrement(keyPartyEarning, partyEarning);
  set removePartyEarning(int partyEarning) => setDecrement(keyPartyEarning, partyEarning);

  int? get getMatchEarning {

    int? totalEarningPoints = get<int>(keyMatchEarning);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setMatchEarning(int matchEarning) => setIncrement(keyMatchEarning, matchEarning);
  set removeMatchEarning(int matchEarning) => setDecrement(keyMatchEarning, matchEarning);

  int? get getLiveEarning {

    int? totalEarningPoints = get<int>(keyLiveEarning);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setLiveEarning(int liveEarning) => setIncrement(keyLiveEarning, liveEarning);
  set removeLiveEarning(int liveEarning) => setDecrement(keyLiveEarning, liveEarning);

  int? get getTotalEarningPoints {

    int? totalEarningPoints = get<int>(keyTotalEarningPoints);
    if(totalEarningPoints != null){
      return totalEarningPoints;
    } else {
      return 0;
    }
  }
  set setTotalEarningPoints(int totalEarningPoints) => setIncrement(keyTotalEarningPoints, totalEarningPoints);
  set removeTotalEarningPoints(int totalEarningPoints) => setDecrement(keyTotalEarningPoints, totalEarningPoints);

  UserModel? get getAgent => get<UserModel>(keyAgent);
  set setAgent(UserModel agent) => set<UserModel>(keyAgent, agent);

  String? get getAgentId => get<String>(keyAgentId);
  set setAgentId(String agentId) => set<String>(keyAgentId, agentId);

  UserModel? get getHost => get<UserModel>(keyHost);
  set setHost(UserModel client) => set<UserModel>(keyHost, client);

  String? get getHostId => get<String>(keyHostId);
  set setHostId(String clientId) => set<String>(keyHostId, clientId);

  String? get getClientStatus => get<String>(keyClientStatus);
  set setClientStatus(String status) => set<String>(keyClientStatus, status);

  int? get getLevel {
    int? level = get<int>(keyLevel);
    if(level != null) {
      return level;
    }else{
      return 0;
    }
  }
  set setLevel(int level) => set<int>(keyLevel, level);

}