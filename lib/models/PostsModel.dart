import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../app/setup.dart';

class PostsModel extends ParseObject implements ParseCloneable {
  static final String keyTableName = "Posts";

  PostsModel() : super(keyTableName);

  PostsModel.clone() : this();

  @override
  PostsModel clone(Map<String, dynamic> map) =>
      PostsModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyAuthor = "Author";
  static String keyAuthorName = "Author.name";
  static String keyAuthorId = "AuthorId";

  static String postTypeVideo = "video";
  static String postTypeImage = "image";
  static String postTypeAudio = "audio";

  static String keyLastLikeAuthor = "LastLikeAuthor";
  static String keyLastDiamondAuthor = "LastDiamondAuthor";

  static String keyText = "text";
  static String keyImage = "image";
  static String keyVideo = "video";
  static String keyVideoThumbnail = "thumbnail";
  static String keyComments = "comments";
  static String keyLikes = "likes";
  static String keySaves = "saves";
  static String keyShare = "share";
  static String keyDiamonds = "diamonds";
  static String keyPaidUsers = "paidBy";
  static String keyPaidAmount = "paidAmount";

  static String keyExclusive = "exclusive";
  static String keyPostType = "type";

  static String keyViews = "views";
  static String keyViewers = "viewers";

  static String keyImagesList = "list_of_images";
  static String keyNumberOfPictures = "numer_of_pictures";

  static String keyTargetPeopleID = "target_people_ids";
  static String keyTargetPeople = "target_people";

  static String keyTextColor = "text_color";
  static String keyBackgroundColor = "background_color";

  String? get getTextColors => get<String>(keyTextColor);
  set setTextColors(String textColor) => set<String>(keyTextColor, textColor);

  String? get getBackgroundColor => get<String>(keyBackgroundColor);
  set setBackgroundColor(String backgroundColor) =>
      set<String>(keyBackgroundColor, backgroundColor);

  List<dynamic>? get getTargetPeople {
    List<dynamic> usersList = [];

    List<dynamic>? users = get<List<dynamic>>(keyTargetPeople);
    if (users != null && users.length > 0) {
      return users;
    } else {
      return usersList;
    }
  }
  set setTargetPeople(List<UserModel> usersId) =>
      setAddAll(keyTargetPeople, usersId);

  List<dynamic>? get getTargetPeopleID {
    List<dynamic> ids = [];

    List<dynamic>? usersId = get<List<dynamic>>(keyTargetPeopleID);
    if (usersId != null && usersId.length > 0) {
      return usersId;
    } else {
      return ids;
    }
  }
  set setTargetPeopleID(List<dynamic> usersId) =>
      setAddAll(keyTargetPeopleID, usersId);

  int get getNumberOfPictures {
    int? number = get(keyNumberOfPictures);
    if(number != null) {
      return number;
    }else{
      return 0;
    }
  }

  set setNumberOfPictures(int numberOfPictures) => set(keyNumberOfPictures, numberOfPictures);

  List<dynamic>? get getImagesList {
    List<dynamic> save = [];

    List<dynamic>? images = get<List<dynamic>>(keyImagesList);
    if (images != null && images.length > 0) {
      return images;
    } else {
      return save;
    }
  }
  set setImagesList(List<ParseFileBase> imagesList) =>
      setAddAll(keyImagesList, imagesList);

  set removeImageFromList(ParseFileBase image) => setRemove(keyImagesList, image);
  set removeImageListFromList(List<dynamic> imagesList) => setRemoveAll(keyImagesList, imagesList);


  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);

  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  String? get getText {
    String? existingText = get<String>(keyText);
    if(existingText != null) {
      return existingText;
    }else{
      return "";
    }
  }

  set setText(String text) => set<String>(keyText, text);

  ParseFileBase? get getImage => get<ParseFileBase>(keyImage);

  set setImage(ParseFileBase imageFile) =>
      set<ParseFileBase>(keyImage, imageFile);

  ParseFileBase? get getVideo => get<ParseFileBase>(keyVideo);

  set setVideo(ParseFileBase videoFile) =>
      set<ParseFileBase>(keyVideo, videoFile);

  ParseFileBase? get getVideoThumbnail => get<ParseFileBase>(keyVideoThumbnail);

  set setVideoThumbnail(ParseFileBase videoFile) =>
      set<ParseFileBase>(keyVideoThumbnail, videoFile);

  List<dynamic>? get getComments {
    List<dynamic>? comments = get<List<dynamic>>(keyComments);
    if (comments != null && comments.length > 0) {
      return comments;
    } else {
      return [];
    }
  }

  set setComments(String commentId) => setAddUnique(keyComments, commentId);

  List<dynamic>? get getLikes {
    List<dynamic> like = [];

    List<dynamic>? likes = get<List<dynamic>>(keyLikes);
    if (likes != null && likes.length > 0) {
      return likes;
    } else {
      return like;
    }
  }

  set setLikes(String likeAuthorId) => setAddUnique(keyLikes, likeAuthorId);

  set removeLike(String likeAuthorId) => setRemove(keyLikes, likeAuthorId);

  List<dynamic>? get getSaves {
    List<dynamic> save = [];

    List<dynamic>? saves = get<List<dynamic>>(keySaves);
    if (saves != null && saves.length > 0) {
      return saves;
    } else {
      return save;
    }
  }

  set setSaved(String likeAuthorId) => setAddUnique(keySaves, likeAuthorId);

  set removeSave(String likeAuthorId) => setRemove(keySaves, likeAuthorId);

  List<dynamic>? get getViewers {
    List<dynamic> save = [];

    List<dynamic>? viewers = get<List<dynamic>>(keyViewers);
    if (viewers != null && viewers.length > 0) {
      return viewers;
    } else {
      return save;
    }
  }

  set setViewer(String authorId) => setAddUnique(keyViewers, authorId);

  int get getViews {
    int? views = get<int>(keyViews);
    if (views != null) {
      return views;
    } else {
      return 0;
    }
  }

  set addView(int view) => setIncrement(keyViews, view);

  UserModel? get getLastLikeAuthor => get<UserModel>(keyLastLikeAuthor);

  set setLastLikeAuthor(UserModel author) =>
      set<UserModel>(keyLastLikeAuthor, author);

  UserModel? get getLastDiamondAuthor => get<UserModel>(keyLastDiamondAuthor);

  set setLastDiamondAuthor(UserModel author) =>
      set<UserModel>(keyLastDiamondAuthor, author);

  List<dynamic>? get getShares => get<List<dynamic>>(keyShare);

  set setShares(String shareAuthorId) => setAdd(keyShare, shareAuthorId);

  int? get getDiamonds => get<int>(keyDiamonds);

  set addDiamonds(int diamonds) => setIncrement(keyDiamonds, diamonds);

  bool? get getExclusive {
    bool? exclusive = get<bool>(keyExclusive);
    if (exclusive != null) {
      return exclusive;
    } else {
      return false;
    }
  }

  set setExclusive(bool exclusive) => set<bool>(keyExclusive, exclusive);

  String? get getPostId => get<String>(keyObjectId);

  bool? get isVideo {
    String? video = get<String>(keyPostType);
    if (video != null && video == postTypeVideo) {
      return true;
    } else {
      return false;
    }
  }

  int? get getPostType => get<int>(keyPostType);

  set setPostType(String postType) => set<String>(keyPostType, postType);

  List<dynamic>? get getPaidBy {
    List<dynamic> paidIds = [];

    List<dynamic>? payers = get<List<dynamic>>(keyPaidUsers);
    if (payers != null && payers.length > 0) {
      return payers;
    } else {
      return paidIds;
    }
  }

  set setPaidBy(String paidAuthorId) =>
      setAddUnique(keyPaidUsers, paidAuthorId);

  set setPaidAmount(int coins) => set<int>(keyPaidAmount, coins);

  int? get getPaidAmount {
    int? amount = get<int>(keyPaidAmount);
    if (amount != null) {
      return amount;
    } else {
      return Setup.coinsNeededToForExclusivePost;
    }
  }
}
