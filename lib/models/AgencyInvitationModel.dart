import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AgencyInvitationModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "AgencyInvitation";

  AgencyInvitationModel() : super(keyTableName);
  AgencyInvitationModel.clone() : this();

  @override
  AgencyInvitationModel clone(Map<String, dynamic> map) => AgencyInvitationModel.clone()..fromJson(map);


  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyStatusPending = "pending";
  static String keyStatusAccepted = "accepted";
  static String keyStatusDeclined = "declined";

  static final String keyAgent = "agent";
  static final String keyAgentId = "agent_id";

  static final String keyHost = "host";
  static final String keyHostId = "host_id";

  static final String keyInvitationStatus = "invitation_status";

  UserModel? get getAgent => get<UserModel>(keyAgent);
  set setAgent(UserModel agent) => set<UserModel>(keyAgent, agent);

  String? get getAgentId => get<String>(keyAgentId);
  set setAgentId(String agentId) => set<String>(keyAgentId, agentId);

  UserModel? get getHost => get<UserModel>(keyHost);
  set setHost(UserModel host) => set<UserModel>(keyHost, host);

  String? get getHostId => get<String>(keyHostId);
  set setHostId(String hostId) => set<String>(keyHostId, hostId);

  String? get getInvitationStatus => get<String>(keyInvitationStatus);
  set setInvitationStatus(String status) => set<String>(keyInvitationStatus, status);


}