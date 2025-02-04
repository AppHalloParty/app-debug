import 'package:trace/models/UserModel.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class PictureModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Picture";

  PictureModel() : super(keyTableName);
  PictureModel.clone() : this();

  @override
  PictureModel clone(Map<String, dynamic> map) => PictureModel.clone()..fromJson(map);

  @override
  PictureModel fromJson(Map<String, dynamic> objectData) {
    super.fromJson(objectData);
    if (objectData.containsKey(keyAuthor)) {
      setAuthor = UserModel.clone().fromJson(objectData[keyAuthor]);
    }
    return this;
  }

  static final String keyFileStatusPending = "pending";
  static final String keyFileStatusApproved = "approved";
  static final String keyFileStatusRejected = "rejected";

  static final String keyFileTypeImage = "image";
  static final String keyFileTypeVideo = "video";
  static final String keyFileTypeGif = "gif";
  static final String keyFileTypeJson = "json";

  static final String keyCreatedAt = "createdAt";

  static final String keyAuthor = "author";
  static final String keyAuthorId = "authorId";

  static final String keyFile = "file";
  static final String keyFileType = "fileType";
  static final String keyFileStatus = "fileStatus";

  UserModel? get getAuthor => get<UserModel>(keyAuthor);
  set setAuthor(UserModel author) => set<UserModel>(keyAuthor, author);

  String? get getAuthorId => get<String>(keyAuthorId);
  set setAuthorId(String authorId) => set<String>(keyAuthorId, authorId);

  ParseFileBase? get getFile => get<ParseFileBase>(keyFile);
  set setFile(ParseFileBase file) => set<ParseFileBase>(keyFile, file);

  String? get getFileType => get<String>(keyFileType);
  set setFileType(String fileType) => set<String>(keyFileType, fileType);

  String? get getFileStatus => get<String>(keyFileStatus);
  set setFileStatus(String fileStatus) => set<String>(keyFileStatus, fileStatus);
}