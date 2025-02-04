import 'package:parse_server_sdk/parse_server_sdk.dart';

class OfficialAnnouncementModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "OfficialAnnouncement";

  OfficialAnnouncementModel() : super(keyTableName);
  OfficialAnnouncementModel.clone() : this();

  @override
  OfficialAnnouncementModel clone(Map<String, dynamic> map) => OfficialAnnouncementModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyPreviewImage = "preview_image";
  static String keyTitle = "title";
  static String keySubTitle = "sub_title";
  static String keyWebViewURL = "web_view_url";

  static String keyViewedBy = "viewed_by";

  ParseFileBase? get getPreviewImage => get<ParseFileBase>(keyPreviewImage);
  set setPreviewImage(ParseFileBase previewImage) => set<ParseFileBase>(keyPreviewImage, previewImage);

  String? get getTitle => get<String>(keyTitle);
  set setTitle(String title) => set<String>(keyTitle, title);

  String? get getSubTitle => get<String>(keySubTitle);
  set setSubTitle(String title) => set<String>(keySubTitle, title);

  String? get getWebViewURL => get<String>(keyWebViewURL);
  set setWebViewURL(String webViewURL) => set<String>(keyWebViewURL, webViewURL);

  List<dynamic>? get getViewedBy {
    List<dynamic> usersIdList = [];

    List<dynamic>? users = get<List<dynamic>>(keyViewedBy);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return usersIdList;
    }
  }
  set setViewedBy(List<dynamic> usersId) =>
      setAddAllUnique(keyViewedBy, usersId);

  set removeViewedBy(String usersId) =>
      setRemove(keyViewedBy, usersId);

}