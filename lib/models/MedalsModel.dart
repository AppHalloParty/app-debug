import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/PostsModel.dart';

import 'UserModel.dart';

class MedalsModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Medals";

  MedalsModel() : super(keyTableName);
  MedalsModel.clone() : this();

  @override
  MedalsModel clone(Map<String, dynamic> map) => MedalsModel.clone()..fromJson(map);

  static String keyAccuser = "accuser";
  static String keyAccuserId = "accuserId";

  static String keyAccused = "accused";
  static String keyAccusedId = "accusedId";

  static String keyMessage = "message";

  static String keyDescription = "description";

  static String keyState = "state";
  static String keyReportType = "reportType";

  static String keyReportPost = "post";
  static String keyReportLiveStreaming = "live";

  static String keyImagesList = "list_of_images";
  static String keyVideo = "video";
  static String keyVideoThumbnail = "thumbnail";

  static String keyCategoryQuestion = "category_question";
  static String keyIssueDetail = "issue_detail";

  static String keyCategoryQuestionCode = "category_question_code";
  static String keyIssueDetailCode = "issue_detail_code";

  String? get getIssueDetailCode => get<String>(keyIssueDetailCode);
  set setIssueDetailCode(String issueCode) => set<String>(keyIssueDetailCode, issueCode);

  String? get getCategoryQuestionCode => get<String>(keyCategoryQuestionCode);
  set setCategoryQuestionCode(String categoryCode) => set<String>(keyCategoryQuestionCode, categoryCode);

  String? get getCategoryQuestion => get<String>(keyCategoryQuestion);
  set setCategoryQuestion(String category) => set<String>(keyCategoryQuestion, category);

  String? get getIssueDetail => get<String>(keyIssueDetail);
  set setIssueDetail(String issue) => set<String>(keyIssueDetail, issue);

  ParseFileBase? get getVideo => get<ParseFileBase>(keyVideo);

  set setVideo(ParseFileBase videoFile) =>
      set<ParseFileBase>(keyVideo, videoFile);

  ParseFileBase? get getVideoThumbnail => get<ParseFileBase>(keyVideoThumbnail);

  set setVideoThumbnail(ParseFileBase videoFile) =>
      set<ParseFileBase>(keyVideoThumbnail, videoFile);

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

  String? get getReportType => get<String>(keyReportType);
  set setReportType(String reportType) => set<String>(keyReportType, reportType);

  UserModel? get getAccuser => get<UserModel>(keyAccuser);
  set setAccuser(UserModel author) => set<UserModel>(keyAccuser, author);

  String? get getAccuserId => get<String>(keyAccuserId);
  set setAccuserId(String authorId) => set<String>(keyAccuserId, authorId);

  UserModel? get getAccused => get<UserModel>(keyAccused);
  set setAccused(UserModel user) => set<UserModel>(keyAccused, user);

  String? get getAccusedId => get<String>(keyAccusedId);
  set setAccusedId(String userId) => set<String>(keyAccusedId, userId);

  String? get getMessage => get<String>(keyMessage);
  set setMessage(String message) => set<String>(keyMessage, message);

  String? get getDescription {
    String? description = get<String>(keyDescription);
    if(description != null){
      return description;
    }else{
      return "";
    }
  }
  set setDescription(String description) => set<String>(keyDescription, description);

  String? get getState {
    String? state = get<String>(keyState);
    if(state != null){
      return state;
    }else{
      return "";
    }
  }


  set setState(String state) => set<String>(keyState, state);

  PostsModel? get getPost => get<PostsModel>(keyReportPost);
  set setPost(PostsModel postsModel) => set<PostsModel>(keyReportPost, postsModel);

  LiveStreamingModel? get getLiveStreaming => get<LiveStreamingModel>(keyReportLiveStreaming);
  set setLiveStreaming(LiveStreamingModel liveStreamingModel) => set<LiveStreamingModel>(keyReportLiveStreaming, liveStreamingModel);

}