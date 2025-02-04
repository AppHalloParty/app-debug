// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/models/ReportModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../../app/setup.dart';
import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../customer_service/contact_customer_service_screen.dart';
import '../feed/video_player_screen.dart';
import '../feed/visualize_multiple_pictures_screen.dart';

class ReportScreen extends StatefulWidget {
  static String route = '/report';

  UserModel? currentUser, userToReport;

  ReportScreen(
      {this.currentUser, this.userToReport, Key? key})
      : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  var selectedCategory = [];
  var selectedSubCat = [];

  List<File> selectedPictures = [];
  int maxLength = 10;

  bool showBorderError = false;

  TextEditingController captionTextEditing = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ParseFileBase? parseVideoFile;
  ParseFileBase? parseVideoThumbnailFile;
  List<ParseFileBase> parseFiles = [];

  List<File> selectedVideos = [];
  File? videoFile;

  var settingsTitles = [
    "report_screen.add_photos".tr(),
    "report_screen.add_video".tr(),
    "message_settings.cancel_".tr()
  ];

  List subCatList() {
    if (selectedCategory.contains(QuickHelp.getCategoryQuestionList()[0])) {
      return QuickHelp.getConsultIssuesList();
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[1])) {
      return QuickHelp.getReportComplaintsIssuesList();
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[2])) {
      return QuickHelp.getFeedbackIssuesList();
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[3])) {
      return QuickHelp.getBusinessCooperationIssuesList();
    } else {
      return [];
    }
  }

  String subCatQuestionsList(String code) {
    if (selectedCategory.contains(QuickHelp.getCategoryQuestionList()[0])) {
      return QuickHelp.getConsultIssuesByCode(code);
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[1])) {
      return QuickHelp.getReportComplaintsIssuesByCode(code);
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[2])) {
      return QuickHelp.getFeedbackIssuesByCode(code);
    } else if (selectedCategory
        .contains(QuickHelp.getCategoryQuestionList()[3])) {
      return QuickHelp.getBusinessCooperationIssuesByCode(code);
    } else {
      return "";
    }
  }

  @override
  void dispose() {
    selectedSubCat.clear();
    selectedCategory.clear();
    selectedVideos.clear();
    selectedPictures.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          centerTitle: true,
          title: TextWithTap("report_screen.contact_customer_service".tr()),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            ContainerCorner(
              width: size.width,
              color: Colors.orange.withOpacity(0.2),
              marginBottom: 20,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                    ),
                  ),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextWithTap(
                          "report_screen.choose_cat_info".tr(),
                          color: Colors.orange,
                          marginLeft: 10,
                          marginRight: 10,
                          fontSize: size.width / 27,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Row(
              children: [
                TextWithTap(
                  "*",
                  color: Colors.red,
                  marginLeft: 15,
                ),
                TextWithTap(
                  "report_screen.select_category".tr(),
                  color: kGrayColor,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Wrap(
                alignment: WrapAlignment.center,
                children: List.generate(
                  QuickHelp.getCategoryQuestionList().length,
                  (index) {
                    bool catSelected = selectedCategory
                        .contains(QuickHelp.getCategoryQuestionList()[index]);
                    return GestureDetector(
                      onTap: () {
                        if (selectedCategory.contains(
                            QuickHelp.getCategoryQuestionList()[index])) {
                          selectedCategory.removeAt(0);
                        } else {
                          selectedCategory.clear();
                          selectedCategory
                              .add(QuickHelp.getCategoryQuestionList()[index]);
                        }
                        selectedSubCat.clear();
                        setState(() {});
                      },
                      child: Stack(
                        children: [
                          ContainerCorner(
                            width: size.width / 2.3,
                            height: 45,
                            borderWidth: 1,
                            borderColor:
                                catSelected ? kPrimaryColor : kGrayColor,
                            borderRadius: 10,
                            marginTop: 10,
                            marginRight: index == 0 || index == 2 ? 10 : 0,
                            child: Center(
                              child: TextWithTap(
                                QuickHelp.getCategoryQuestionByCode(
                                    QuickHelp.getCategoryQuestionList()[index]),
                                color: catSelected
                                    ? kPrimaryColor
                                    : isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Visibility(
              visible: selectedCategory.isNotEmpty,
              child: Row(
                children: [
                  TextWithTap(
                    "*",
                    color: Colors.red,
                    marginLeft: 15,
                  ),
                  TextWithTap(
                    "report_screen.select_issue".tr(),
                    color: kGrayColor,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
              child: Wrap(
                alignment: WrapAlignment.start,
                children: List.generate(
                  subCatList().length,
                  (index) {
                    bool catSelected =
                        selectedSubCat.contains(subCatList()[index]);
                    return GestureDetector(
                      onTap: () {
                        if (selectedSubCat.contains(subCatList()[index])) {
                          selectedSubCat.removeAt(0);
                        } else {
                          selectedSubCat.clear();
                          selectedSubCat.add(subCatList()[index]);
                        }
                        setState(() {});
                      },
                      child: ContainerCorner(
                        borderWidth: 0,
                        color: catSelected
                            ? kPrimaryColor
                            : isDarkMode
                                ? Colors.white.withOpacity(0.2)
                                : kGrayLight,
                        borderRadius: 50,
                        marginTop: 10,
                        marginRight: 10,
                        child: TextWithTap(
                          subCatQuestionsList(
                            subCatList()[index],
                          ),
                          marginTop: 5,
                          marginBottom: 5,
                          marginRight: 15,
                          marginLeft: 15,
                          color: catSelected
                              ? Colors.white
                              : isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Row(
              children: [
                TextWithTap(
                  "*",
                  color: Colors.red,
                  marginLeft: 15,
                ),
                TextWithTap(
                  "report_screen.describe_issue".tr(),
                  color: kGrayColor,
                ),
              ],
            ),
            ContainerCorner(
              marginTop: 20,
              width: size.width,
              marginLeft: 15,
              marginRight: 15,
              borderRadius: 8,
              borderColor: showBorderError ? Colors.red : kTransparentColor,
              color: isDarkMode ? Colors.white.withOpacity(0.2) : kGrayLight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {},
                    maxLines: 7,
                    maxLength: 250,
                    controller: captionTextEditing,
                    validator: (text) {
                      if (text!.isEmpty) {
                        setState(() {
                          showBorderError = true;
                        });
                        return "report_screen.describe_issue_hint".tr();
                      } else {
                        setState(() {
                          showBorderError = false;
                        });
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "report_screen.describe_issue_hint".tr(),
                      hintStyle: TextStyle(color: kGrayColor),
                      border: InputBorder.none,
                      errorMaxLines: 5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, top: 20),
              child: Wrap(
                children: [
                  Wrap(
                    children: List.generate(selectedPictures.length, (index) {
                      return Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          ContainerCorner(
                            width: size.width / 3.5,
                            height: size.width / 3.5,
                            borderRadius: 7,
                            borderWidth: 0,
                            marginRight: 7,
                            marginBottom: 7,
                            onTap: () {
                              QuickHelp.goToNavigatorScreen(
                                context,
                                VisualizeMultiplePicturesScreen(
                                  initialIndex: index,
                                  selectedPictures: selectedPictures,
                                ),
                              );
                            },
                            child: Image.file(
                              selectedPictures[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: ContainerCorner(
                              borderRadius: 50,
                              height: 23,
                              width: 23,
                              marginTop: 4,
                              marginRight: 10,
                              color: Colors.black.withOpacity(0.5),
                              onTap: () {
                                setState(() {
                                  selectedPictures.removeAt(index);
                                });
                              },
                              child: Center(
                                  child: Icon(
                                Icons.close,
                                color: Colors.white,
                                weight: 999,
                                size: 15,
                              )),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  Wrap(
                    children: List.generate(selectedVideos.length, (index) {
                      return Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              QuickHelp.goToNavigatorScreen(
                                context,
                                VideoPlayerScreen(
                                  currentUser: widget.currentUser,
                                  video: videoFile,
                                ),
                              );
                            },
                            child: Stack(
                              children: [
                                ContainerCorner(
                                  width: size.width / 3.5,
                                  height: size.width / 2.3,
                                  borderRadius: 7,
                                  borderWidth: 0,
                                  marginRight: 7,
                                  marginBottom: 7,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      selectedVideos[0],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                ContainerCorner(
                                  width: size.width / 3.5,
                                  height: size.width / 2.3,
                                  borderRadius: 7,
                                  borderWidth: 0,
                                  marginRight: 7,
                                  marginBottom: 7,
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white.withOpacity(0.4),
                                      size: size.width / 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: -3,
                            right: -10,
                            child: ContainerCorner(
                              borderRadius: 50,
                              height: 30,
                              width: 30,
                              marginTop: 4,
                              marginRight: 10,
                              color: QuickHelp.isDarkMode(context)
                                  ? Colors.white
                                  : Colors.black,
                              onTap: () {
                                setState(() {
                                  selectedVideos.clear();
                                });
                              },
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                  weight: 999,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  Visibility(
                    visible:
                        selectedPictures.length < 9 && selectedVideos.isEmpty,
                    child: ContainerCorner(
                      width: size.width / 3.5,
                      height: size.width / 3.5,
                      color: kGrayWhite,
                      borderRadius: 10,
                      borderWidth: 0,
                      marginRight: 7,
                      marginBottom: 7,
                      onTap: () => openSettingsSheet(),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: kGrayColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextWithTap(
              "report_screen.annex_media_files".tr(),
              color: kGrayColor,
              marginLeft: 15,
              marginBottom: 20,
            ),
          ],
        ),
        bottomNavigationBar: ContainerCorner(
          marginLeft: 20,
          marginRight: 20,
          marginBottom: 20,
          width: size.width,
          height: 50,
          borderRadius: 50,
          borderWidth: 0,
          color: kPrimaryColor,
          onTap: () => createReport(),
          child: Center(
            child: TextWithTap(
              "report_screen.submit_".tr(),
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void openSettingsSheet() {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        builder: (context) {
          return showSettingsSheet();
        });
  }

  Widget showSettingsSheet() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ContainerCorner(
        color: Colors.black.withOpacity(0.01),
        child: DraggableScrollableSheet(
          initialChildSize: 0.27,
          minChildSize: 0.1,
          maxChildSize: 1.0,
          builder: (_, controller) {
            return StatefulBuilder(builder: (context, setState) {
              return ContainerCorner(
                radiusTopLeft: 25,
                radiusTopRight: 25,
                color:
                    isDarkMode ? Colors.black : Colors.white.withOpacity(0.9),
                borderWidth: 0,
                child: Scaffold(
                  backgroundColor: kTransparentColor,
                  body: Column(
                    children: List.generate(
                      settingsTitles.length,
                      (index) {
                        if (index == 1 && selectedPictures.isNotEmpty) {
                          return const SizedBox();
                        } else {
                          return options(
                            caption: settingsTitles[index],
                            index: index,
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget options({required String caption, required int index}) {
    Size size = MediaQuery.of(context).size;
    bool isDarkMode = QuickHelp.isDarkMode(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ContainerCorner(
          height: 55,
          width: size.width,
          marginTop: index == (settingsTitles.length - 1) ? 6 : 0,
          radiusTopRight: index == 0 ? 25 : 0,
          radiusTopLeft: index == 0 ? 25 : 0,
          color: isDarkMode ? kContentDarkShadow : Colors.white,
          onTap: () {
            if (index == 0) {
              checkPermission(false);
            } else if (index == 1) {
              checkPermission(true);
            } else if (index == 2) {
              QuickHelp.goBackToPreviousPage(context);
            }
            QuickHelp.goBackToPreviousPage(context);
          },
          child: Center(
            child: TextWithTap(
              caption,
              fontSize: size.width / 23,
            ),
          ),
        ),
        Visibility(
          visible: index < (settingsTitles.length - 2),
          child: ContainerCorner(
            height: 0.5,
            color: kGrayColor.withOpacity(0.5),
            width: size.width,
          ),
        ),
      ],
    );
  }

  _pickVideoFile() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.video,
      ),
    );

    if (result != null && result.length > 0) {
      final File? file = await result.first.file;

      if (file!.lengthSync() <= Setup.maxVideoSize * 1024 * 1024) {
        String? mimeStr = lookupMimeType(file.path);
        var fileType = mimeStr!.split('/');

        print('Selected file type $fileType');

        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          quality: 100,
        );

        prepareVideo(file, thumbnail!);
      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "upload_video.size_exceeded_title".tr(),
          message: "upload_video.size_exceeded_explain"
              .tr(namedArgs: {"amount": "${Setup.maxVideoSize}"}),
          context: context,
        );
      }
    }
  }

  prepareVideo(File file, String previewPath) async {
    DateTime date = DateTime.now();

    final thumbnailFile = File(previewPath);

    parseVideoThumbnailFile =
        ParseFile(File(previewPath), name: "thumbnail.jpg");

    videoFile = file.absolute;

    setState(() {
      selectedVideos.add(thumbnailFile);
    });

    if (selectedVideos[0].absolute.path.isNotEmpty) {
      parseVideoFile =  await ParseFile(File(videoFile!.absolute.path),
          name: "video_${date.second}_${date.millisecond}.mp4");
    } else {
      parseVideoFile = await ParseWebFile(videoFile!.readAsBytesSync(),
          name: "video_${date.second}_${date.millisecond}.pm4");
    }

  }

  Future<void> checkPermission(bool selectVideo) async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission android');

      checkStatus(status, status2, selectVideo);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission ios');

      checkStatus(status, status2, selectVideo);
    } else {
      print('Permission other device');

      if (selectVideo) {
        _pickVideoFile();
      } else {
        _choosePhoto();
      }
    }
  }

  void checkStatus(
      PermissionStatus status, PermissionStatus status2, bool selectVideo) {
    if (status.isDenied || status2.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.

      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access".tr(),
          confirmButtonText: "permissions.okay_".tr().toUpperCase(),
          message: "permissions.photo_access_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () async {
            QuickHelp.hideLoadingDialog(context);

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                    statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted) {
              if (selectVideo) {
                _pickVideoFile();
              } else {
                _choosePhoto();
              }
            }
          });
    } else if (status.isPermanentlyDenied || status2.isPermanentlyDenied) {
      QuickHelp.showDialogPermission(
          context: context,
          title: "permissions.photo_access_denied".tr(),
          confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
          message: "permissions.photo_access_denied_explain"
              .tr(namedArgs: {"app_name": Setup.appName}),
          onPressed: () {
            QuickHelp.hideLoadingDialog(context);

            openAppSettings();
          });
    } else if (status.isGranted && status2.isGranted) {
      if (selectVideo) {
        _pickVideoFile();
      } else {
        _choosePhoto();
      }
    }

    print('Permission $status');
    print('Permission $status2');
  }

  _choosePhoto() async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 9 - selectedPictures.length,
        requestType: RequestType.image,
        filterOptions: FilterOptionGroup(
          containsLivePhotos: false,
        ),
      ),
    );

    if (result != null && result.length > 0) {
      final List<File>? images = [];

      for (int i = 0; i < result.length; i++) {
        images!.add(await result[i].file as File);
      }

      final tempDir = await getTemporaryDirectory();
      List<String> savedImagesPaths = [];
      DateTime date = DateTime.now();

      for (int i = 0; i < images!.length; i++) {
        String imageName =
            'post_picture_${selectedPictures.length + i}_${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        setState(() {
          selectedPictures.add(tempFile);
        });
      }
    } else {
      print("Photos null");
    }
  }

  createReport() async {
    QuickHelp.showLoadingDialog(context);

    if (selectedCategory.isEmpty) {
      QuickHelp.showAppNotificationAdvanced(
        title: "report_screen.cat_question".tr(),
        message: "report_screen.select_category".tr(),
        context: context,
      );
    } else if (selectedSubCat.isEmpty) {
      QuickHelp.showAppNotificationAdvanced(
        title: "report_screen.issue_detail".tr(),
        message: "report_screen.select_issue".tr(),
        context: context,
      );
    } else if (formKey.currentState!.validate()) {
      ReportModel report = ReportModel();

      report.setAccuser = widget.currentUser!;
      report.setAccuserId = widget.currentUser!.objectId!;

      if (widget.userToReport != null) {
        report.setAccused = widget.userToReport!;
        report.setAccusedId = widget.userToReport!.objectId!;
      }

      report.setMessage = captionTextEditing.text;
      report.setCategoryQuestion =
          QuickHelp.getCategoryQuestionByCode(selectedCategory[0]);
      report.setIssueDetail = subCatQuestionsList(selectedSubCat[0]);
      report.setCategoryQuestionCode = selectedCategory[0];
      report.setIssueDetailCode = selectedSubCat[0];
      report.setState = ReportModel.statePending;

      if (selectedPictures.isNotEmpty) {
        DateTime date = DateTime.now();

        for (int i = 0; i < selectedPictures.length; i++) {
          if (selectedPictures[i].absolute.path.isNotEmpty) {
            parseFiles.add(ParseFile(File(selectedPictures[i].absolute.path),
                name: "report_picture_${date.second}_${date.millisecond}.jpg"));
          } else {
            parseFiles.add(ParseWebFile(selectedPictures[i].readAsBytesSync(),
                name: "report_picture_${date.second}_${date.millisecond}.jpg"));
          }
        }

        report.setImagesList = parseFiles;
      }

      if (selectedVideos.isNotEmpty) {
        report.setVideo = parseVideoFile!;
        report.setVideoThumbnail = parseVideoThumbnailFile!;
      }

      ParseResponse response = await report.save();

      if (response.success && response.result != null) {
        ReportModel crestedReport = response.result;
        QuickHelp.hideLoadingDialog(context);

        setState(() {
          selectedSubCat.clear();
          selectedCategory.clear();
          selectedVideos.clear();
          selectedPictures.clear();
          captionTextEditing.text = "";
        });
        QuickHelp.goToNavigatorScreen(
            context,
            ContactCustomerServiceScreen(
              reportModel: crestedReport,
              currentUser: widget.currentUser,
            ),
        );
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            title: "report_screen.report_failed_title".tr(),
            context: context,
            isError: false,
            message: "report_screen.report_failed_explain".tr(),
        );
      }
    }
  }
}
