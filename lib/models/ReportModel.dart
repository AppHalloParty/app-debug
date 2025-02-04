import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:trace/models/LiveStreamingModel.dart';
import 'package:trace/models/PostsModel.dart';

import 'UserModel.dart';

class ReportModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "Report";

  ReportModel() : super(keyTableName);
  ReportModel.clone() : this();

  @override
  ReportModel clone(Map<String, dynamic> map) => ReportModel.clone()..fromJson(map);

  static String reportTypeProfile = "PROFILE";
  static String reportTypePost = "POST";
  static String reportTypeLiveStreaming = "LIVE";

  static String keyCreatedAt = "createdAt";
  static String keyUpdatedAt = "updatedAt";
  static String keyObjectId = "objectId";

  static String stateResolved = "resolved";
  static String statePending = "pending";

  static const THIS_POST_HAS_SEXUAL_CONTENTS = "SC";
  static const FAKE_PROFILE_SPAN = "FPS";
  static const INAPPROPRIATE_MESSAGE = "IM";
  static const UNDERAGE_USER = "UA";
  static const SOMEONE_IS_IN_DANGER = "SID";

  static const CATEGORY_CONSULT = "CAT_CON";
  static const CATEGORY_REPORT_COMPLAINT = "CAT_REP";
  static const CATEGORY_FEEDBACKS = "CAT_FED";
  static const CATEGORY_BUSINESS_COOPERATION = "CAT_BUS_COO";

  static const CONSULT_HOST_REWARD = "CON_HOT_REW";
  static const CONSULT_FAILURE_RECEIVING_COIN = "CON_FAIL_COI";
  static const CONSULT_FACE_AUTHENTICATION = "CON_FAC_AUT";
  static const CONSULT_CHANGE_GENDER = "CON_CHA_GEN";
  static const CONSULT_APPEAL_ACCOUNT_SUSPENSION = "CON_ACC_SUS";
  static const CONSULT_INVITATION_REWARD = "CON_INV_REW";
  static const CONSULT_OTHER = "CON_OTH";

  static const REPORT_COMPLAINT_REPORT = "REP_COM";
  static const REPORT_LIVE_VIOLATION = "REP_LIV_VIO";

  static const FEEDBACK_ACCOUNT_SECURE = "FEED_COM";
  static const FEEDBACK_GAME = "FEED_GAME";
  static const FEEDBACK_SOFTWARE_DEFECT = "FEED_SOF_DEF";
  static const FEEDBACK_FEATURE_REQUEST = "FEED_FEA_REQ";
  static const FEEDBACK_SPOT_ERROR_GET_COINS = "FEED_SPO_COI";

  static const BUSINESS_AGENCY_APPLICATION = "BUS_AGE_APP";
  static const BUSINESS_AGENCY_HOST = "BUS_AGE_HOST";

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
      return statePending;
    }
  }


  set setState(String state) => set<String>(keyState, state);

  PostsModel? get getPost => get<PostsModel>(keyReportPost);
  set setPost(PostsModel postsModel) => set<PostsModel>(keyReportPost, postsModel);

  LiveStreamingModel? get getLiveStreaming => get<LiveStreamingModel>(keyReportLiveStreaming);
  set setLiveStreaming(LiveStreamingModel liveStreamingModel) => set<LiveStreamingModel>(keyReportLiveStreaming, liveStreamingModel);

}