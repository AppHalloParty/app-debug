import 'package:parse_server_sdk/parse_server_sdk.dart';

import 'UserModel.dart';

class EventsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Events";

  EventsModel() : super(keyTableName);
  EventsModel.clone() : this();

  @override
  EventsModel clone(Map<String, dynamic> map) => EventsModel.clone()..fromJson(map);


  static String eventCategoryTypeFeatured = "featured";
  static String eventCategoryTypeGaming = "gaming";
  static String eventCategoryTypeTalent = "talent";
  static String eventCategoryTypeBeauty = "beauty";
  static String eventCategoryTypeMusic = "music";
  static String eventCategoryTypeArt = "art";

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "author";
  static String keyAuthorId = "author_id";

  static String keyName = "name";
  static String keyDescription = "description";

  static String keyImage = "image";
  static String keyBannerImage = "banner_image";

  static String keyEventID = "event_id";
  static String keyTags = "tags";
  static String keyCategory = "category";
  static String keyDate = "date";

  static String keyParticipants = "participants";
  static String keyParticipantID = "participants_ids";

  static String keyFollowers = "followers";
  static String keyBgImage = "background_image";

  ParseFileBase? get getBgImage => get<ParseFileBase>(keyBgImage);
  set setBgImage(ParseFileBase imageFile) => set<ParseFileBase>(keyBgImage, imageFile);

  List<dynamic>? get getFollowers {

    List<dynamic>? followers = get<List<dynamic>>(keyFollowers);
    if (followers != null && followers.length > 0) {
      return followers;
    } else {
      return [];
    }
  }
  set setFollowers(String authorId) => setAddUnique(keyFollowers, authorId);

  DateTime? get getExpireDate => get<DateTime>(keyDate);
  set setExpireDate(DateTime expireDate) =>
      set<DateTime>(keyDate, expireDate);

  UserModel? get getAuthor => get(keyAuthor);
  set setAuthor(UserModel user) => set<UserModel>(keyAuthor, user);

  String? get getAuthorId => get(keyAuthorId);
  set setAuthorId(String userId) => set<String>(keyAuthorId, userId);

  String? get getCategory {
    String? category = get(keyCategory);
    if(category != null) {
      return category;
    }else{
      return "";
    }
  }
  set setCategory(String category) => set<String>(keyCategory, category);

  String? get getName {
    String? name = get(keyName);
    if(name != null) {
      return name;
    }else{
      return "";
    }
  }
  set setName(String name) => set<String>(keyName, name);

  String? get getDescription {
    String? description = get(keyDescription);
    if(description != null) {
      return description;
    }else{
      return "";
    }
  }
  set setDescription(String description) => set<String>(keyDescription, description);

  String? get getEventID {
    String? eventID = get(keyEventID);
    if(eventID != null) {
      return eventID;
    }else{
      return "";
    }
  }
  set setEventID(String eventID) => set<String>(keyEventID, eventID);

  String? get getTags {
    String? text = get<String>(keyTags);
    if(text != null){
      return text;
    } else {
      return "";
    }
  }

  set setTags(String text) => set<String>(keyTags, text);

  List<UserModel>? get getParticipants {

    List<UserModel>? participants = get<List<UserModel>>(keyParticipants);
    if(participants != null && participants.length > 0){
      return participants;
    } else {
      return [];
    }
  }
  set setParticipant (UserModel user) => setAddUnique(keyParticipants, user);
  set removeParticipant (UserModel user) => setRemove(keyParticipants, user);

  List<dynamic>? get getParticipantIDs {

    List<dynamic>? participantsIDs = get<List<dynamic>>(keyParticipantID);
    if (participantsIDs != null && participantsIDs.length > 0) {
      return participantsIDs;
    } else {
      return [];
    }
  }
  set setParticipantID(String authorId) => setAddUnique(keyParticipantID, authorId);

  ParseFileBase? get getImage => get<ParseFileBase>(keyImage);
  set setImage(ParseFileBase imageFile) => set<ParseFileBase>(keyImage, imageFile);

  ParseFileBase? get getBannerImage => get<ParseFileBase>(keyBannerImage);
  set setBannerImage(ParseFileBase imageFile) => set<ParseFileBase>(keyBannerImage, imageFile);

}
