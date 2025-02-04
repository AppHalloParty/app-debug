
import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AvatarService {
  final Map<String, String?> _avatarCache = {};

  Future<void> loadAllAvatars() async {

    final query = QueryBuilder<UserModel>(UserModel.forQuery());

    final response = await query.query();

    if (response.success && response.results != null) {
      for (UserModel user in response.results!) {
        final userID = user.objectId;
        String? avatarUrl = user.getAvatar!.url;
        if (userID != null) {
          _avatarCache[userID] = avatarUrl ?? 'NO_AVATAR';
        }
      }
    }
  }

  String? getAvatarUrl(String userID) {
    return _avatarCache[userID] != 'NO_AVATAR' ? _avatarCache[userID] : null;
  }

  Future<String?> fetchUserAvatar(String userID) async {
    final Map<String, String?> _avatarCache = {};

    if (_avatarCache.containsKey(userID)) {
      return _avatarCache[userID];
    }

    final query = QueryBuilder<UserModel>(UserModel.forQuery())
      ..whereEqualTo(UserModel.keyObjectId, userID);

    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      UserModel user = response.results!.first;
      _avatarCache[userID] = user.getAvatar!.url!;
      return user.getAvatar!.url!;
    }

    _avatarCache[userID] = null;
    return null;
  }
}