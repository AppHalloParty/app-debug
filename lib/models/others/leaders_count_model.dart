import 'package:trace/models/UserModel.dart';

class LeadersCountModel {

  String? objectId;
  int? amountTotal;
  UserModel? leader;


  LeadersCountModel({this.objectId, this.amountTotal, this.leader});

  String? getId() {
    return objectId;
  }

  void setId(String id) {
    this.objectId = id;
  }

  int? getCredit() {
    return amountTotal;
  }

  void setCredit(int credit) {
    this.amountTotal = credit;
  }

  UserModel? getAuthor() {
    return leader;
  }

  void setLeader(UserModel leader) {
    this.leader = leader;
  }
}