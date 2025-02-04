// ignore_for_file: file_names

import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/UserModel.dart';

class MessageGroupModel extends ParseObject implements ParseCloneable {
  static const String keyTableName = "MessageGroup";

  MessageGroupModel() : super(keyTableName);
  MessageGroupModel.clone() : this();

  @override
  MessageGroupModel clone(Map<String, dynamic> map) =>
      MessageGroupModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyUpdatedAt = "updatedAt";

  static String keyCreator = "Creator";
  static String keyCreatorID = "CreatorID";

  static String keyAdmins = "Admins";

  static String keyGroupName = "groupName";
  static String keyGroupCover = "groupCover";

  static String keyMember = "members";
  static String keyMembersIDs = "membersIDs";

  static String keyGroupType = "group_type";

  static String keyAgencyGroupType = "agency_group";
  static String keyNormalGroupType = "normal_group";

  String? get getGroupType {
    String? groupType = get<String>(keyGroupType);

    if(groupType != null) {
      return groupType;
    }else{
      return MessageGroupModel.keyNormalGroupType;
    }
  }
  set setGroupType(String groupType) => set<String>(keyGroupType, groupType);

  UserModel? get getAuthor => get<UserModel>(keyCreator);
  set setAuthor(UserModel author) => set<UserModel>(keyCreator, author);

  String? get getAuthorId => get<String>(keyCreatorID);
  set setAuthorId(String authorId) => set<String>(keyCreatorID, authorId);

  List<dynamic>? get getMembersIDs {
    List<dynamic> members = [];

    List<dynamic>? membersIDs = get<List<dynamic>>(keyMembersIDs);
    if (membersIDs != null && membersIDs.isNotEmpty) {
      return membersIDs;
    } else {
      return members;
    }
  }

  set setMemberID(String memberId) => setAddUnique(keyMembersIDs, memberId);
  set setMemberIDs(List<dynamic> memberIDs) =>
      setAddAll(keyMembersIDs, memberIDs);
  set removeMemberID(String memberId) => setRemove(keyMembersIDs, memberId);

  List<dynamic>? get getMembers {
    List<UserModel> members = [];

    List<dynamic>? member = get<List<dynamic>>(keyMember);

    if (member != null && member.isNotEmpty) {
      return member;
    } else {
      return members;
    }
  }

  set setMember(UserModel member) => setAddUnique(keyMember, member);
  set setMembers(List<UserModel> member) => setAddAll(keyMember, member);
  set removeMember(UserModel member) => setRemove(keyMember, member);

  List<dynamic>? get getAdmins {
    List<dynamic> admins = [];

    List<dynamic>? adminIDs = get<List<dynamic>>(keyAdmins);
    if (adminIDs != null && adminIDs.isNotEmpty) {
      return adminIDs;
    } else {
      return admins;
    }
  }

  set setAdmin(String adminID) => setAddUnique(keyAdmins, adminID);
  set removeAdmin(String adminID) => setRemove(keyAdmins, adminID);

  String? get getGroupName => get<String>(keyGroupName);
  set setGroupName(String groupName) => set<String>(keyGroupName, groupName);

  ParseFileBase? get getGroupCover => get<ParseFileBase>(keyGroupCover);
  set setGroupCover(ParseFileBase groupCover) =>
      set<ParseFileBase>(keyGroupCover, groupCover);
}
