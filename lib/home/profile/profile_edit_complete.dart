// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trace/app/setup.dart';
import 'package:trace/auth/dispache_screen.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../app/Config.dart';
import '../../models/FanClubModel.dart';
import '../../ui/button_with_icon.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../../ui/country_selector.dart';

// ignore: must_be_immutable
class ProfileCompleteEdit extends StatefulWidget {
  static String route = "/check/profile";

  UserModel? currentUser;

  ProfileCompleteEdit({Key? key, this.currentUser})
      : super(key: key);

  @override
  _ProfileCompleteEditState createState() => _ProfileCompleteEditState();
}

class _ProfileCompleteEditState extends State<ProfileCompleteEdit> {
  TextEditingController fullNameEditingController = TextEditingController();
  TextEditingController aboutYouTitleEditingController =
  TextEditingController();
  TextEditingController birthdayEditingController = TextEditingController();

  TextEditingController nickNameTextEdit = TextEditingController();

  String countryIsoCode = Config.initialCountry;
  String countryDialCode = QuickHelp.getCountryDialCode(Config.initialCountry);
  List<String> languagesIso =  QuickHelp.getLanguageByCountryIso(code: Config.initialCountry);

  String typeName = "name";
  String typeBirthday = "birthday";
  String typeGender = "gender";

  bool isValidBirthday = false;
  bool isValidGender = false;
  bool isValidName = false;
  String myBirthday = "";
  String? mySelectedGender;
  String userBirthday = "";
  String userGender = "";

  File? selectedPicture;

  String userAvatar = "";
  String userCover = "";

  ParseFileBase? parseFile;

  var genders = ["personal_data.male_".tr(), "personal_data.female_".tr()];
  var isMale = [true, false];

  String countryName = "";
  String countryFlag = "";

  DateTime dateTime = DateTime(1999);

  @override
  void dispose() {
    fullNameEditingController.dispose();
    aboutYouTitleEditingController.dispose();
    birthdayEditingController.dispose();
    super.dispose();
  }

  _getUser() async {
    aboutYouTitleEditingController.text = widget.currentUser!.getAboutYou!;
    userBirthday = widget.currentUser!.getBirthday != null
        ? QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!)
        : "profile_screen.invalid_date".tr();

    if (widget.currentUser!.getFirstName != null) {
      isValidName = true;

      fullNameEditingController.text = widget.currentUser!.getFullName!;
    }

    if (widget.currentUser!.getBirthday != null) {
      isValidBirthday = true;
      birthdayEditingController.text =
          QuickHelp.getBirthdayFromDate(widget.currentUser!.getBirthday!);
    }

    if (widget.currentUser!.getGender != null &&
        widget.currentUser!.getGender!.isNotEmpty) {
      isValidGender = true;

      mySelectedGender = widget.currentUser!.getGender!;
    }

    userGender = widget.currentUser!.getGender != null &&
        widget.currentUser!.getGender!.isNotEmpty
        ? QuickHelp.getGender(widget.currentUser!)
        : "profile_screen.gender_invalid".tr();

    setState(() {
      userAvatar = widget.currentUser!.getAvatar != null
          ? widget.currentUser!.getAvatar!.url!
          : "";
      userCover = widget.currentUser!.getCover != null
          ? widget.currentUser!.getCover!.url!
          : "";
    });
  }

  @override
  void initState() {
    initializeNickNameTextField();
    _getUser();
    /*Future.delayed(Duration(seconds: 2), () {
      showNotification();
    });*/
    super.initState();
  }

  showNotification() {
    if (widget.currentUser!.getFirstName!.isEmpty ||
        widget.currentUser!.getGender == null ||
        widget.currentUser!.getBirthday == null) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "profile_screen.complete_profile".tr(),
        message: "profile_screen.complete_profile_explain".tr(),
        isError: true,
        user: widget.currentUser!,
      );
    }
  }

  String? _validateBirthday(String value) {
    isValidBirthday = false;
    if (value.isEmpty) {
      return "profile_screen.choose_birthday".tr();
    } else if (!QuickHelp.isValidDateBirth(value, QuickHelp.dateFormatDmy)) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "personal_data.error_".tr(),
        message: "profile_screen.invalid_date".tr(),
        isError: true,
        user: widget.currentUser!,
      );
    } else if (!QuickHelp.minimumAgeAllowed(value, QuickHelp.dateFormatDmy)) {
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "personal_data.error_".tr(),
        message: "profile_screen.mim_age_required".tr(namedArgs: {'age': Setup.minimumAgeToRegister.toString()}),
        isError: true,
        user: widget.currentUser!,
      );
      setState(() {
        dateTime = DateTime(1999);
      });
    } else {
      isValidBirthday = true;
      myBirthday = value;
      return null;
    }
    return null;
  }

  initializeNickNameTextField() {
    nickNameTextEdit.text = widget.currentUser!.objectId!;
  }

  @override
  Widget build(BuildContext context) {

    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          backgroundColor: kTransparentColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 20, right: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size.width / 1.5,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWithTap(
                            "personal_data.complete_date".tr(),
                            fontSize: size.width / 17,
                            fontWeight: FontWeight.w900,
                          ),
                          TextWithTap(
                            "personal_data.provide_experience".tr(),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            marginTop: 7,
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          child: QuickActions.profileAvatar(
                            userAvatar,
                            boxShape: BoxShape.circle,
                            width: size.width / 9,
                            height: size.width / 9,
                            borderRadius: 0,
                            margin: EdgeInsets.only(
                              bottom: 0,
                              top: 0,
                              left: 10,
                              right: 5,
                            ),
                          ),
                          onTap: () => checkPermission(true),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          //right: 40,
                          child: ContainerCorner(
                            color: kGrayColor.withOpacity(0.5),
                            height: 20,
                            width: 20,
                            borderRadius: 50,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 22,
                            ),
                            onTap: () => checkPermission(true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                nickNameTextField(),
                birthDayTextField(),
                CountrySelector(
                  radiusBottomLeft: 50,
                  radiusTopLeft: 50,
                  radiusTopRight: 50,
                  radiusBottomRight: 50,
                  countrySearchHint: "leaders.search_country".tr(),
                  height: 45,
                  marginTop: 20,
                  width: size.width,
                  backgroundColor: isDarkMode
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.blueAccent.withOpacity(0.05),
                  onCountryChanged: (country) {
                    countryIsoCode = country.isoCode;
                    countryDialCode = country.dialCode;
                    languagesIso =  country.languagesIso;
                    countryName = QuickHelp.getCountryName(code: countryIsoCode);
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                      genders.length,
                          (index) => genderSelector(
                          caption: genders[index], male: isMale[index])),
                ),
                ButtonWithIcon(
                  mainAxisAlignment: MainAxisAlignment.center,
                  height: 45,
                  marginTop: 40,
                  marginBottom: 10,
                  borderRadius: 60,
                  fontSize: 14,
                  textColor: Colors.white,
                  backgroundColor: kPrimaryColor,
                  text: "personal_data.submit_".tr(),
                  fontWeight: FontWeight.normal,
                  onTap: () {
                    if(parseFile == null && widget.currentUser!.getAvatar == null){
                      QuickHelp.showAppNotificationAdvanced(
                        context: context,
                        title: "error".tr(),
                        message: "profile_edit_complete.select_avatar".tr(),
                        isError: true,
                        user: widget.currentUser!,
                      );
                    }else if (!isValidGender) {
                      QuickHelp.showAppNotificationAdvanced(
                        context: context,
                        title: "profile_screen.complete_profile".tr(),
                        message: "personal_data.select_gender".tr(),
                        isError: true,
                        user: widget.currentUser!,
                      );
                    } else {
                      _updateNow();
                    }
                  },
                ),
                TextWithTap(
                  "personal_data.advice".tr(),
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget genderSelector({required String caption, required bool male}) {
    return ContainerCorner(
      height: 30,
      borderRadius: 50,
      color: male
          ? mySelectedGender == UserModel.keyGenderMale
          ? Colors.blueAccent.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.05)
          : mySelectedGender == UserModel.keyGenderFemale ? Colors.redAccent.withOpacity(0.3) : Colors.redAccent.withOpacity(0.05),
      marginRight: 15,
      onTap: (){
        setState(() {
          if(male) {
            isValidGender = true;
            mySelectedGender = UserModel.keyGenderMale;
          }else{
            isValidGender = true;
            mySelectedGender = UserModel.keyGenderFemale;
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 10,
          ),
          Icon(
            male ? Icons.male : Icons.female,
            color: male ? Colors.lightBlueAccent : Colors.redAccent,
          ),
          TextWithTap(
            caption,
            marginLeft: 10,
            marginRight: 20,
          )
        ],
      ),
    );
  }

  Widget nickNameTextField() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      borderRadius: 50,
      height: 45,
      marginTop: 20,
      color: isDarkMode
          ? Colors.blueAccent.withOpacity(0.3)
          : Colors.blueAccent.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Center(
          child: TextFormField(
            controller: nickNameTextEdit,
            keyboardType: TextInputType.text,
            cursorColor: kGrayColor,
            autocorrect: false,
            decoration: InputDecoration(
              errorMaxLines: 1,
              errorStyle: TextStyle(fontSize: 10),
              border: InputBorder.none,
              hintText: "personal_data.nickname_".tr(),
              hintStyle:
              TextStyle(color: kGrayColor.withOpacity(0.5), fontSize: 13),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {}
              return null;
            },
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
        ),
      ),
    );
  }

  showCalendar() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor:
            isDarkMode ? kContentColorLightTheme : Colors.white,
            insetPadding: EdgeInsets.only(left: 10, right: 10),
            content: ContainerCorner(
              height: 400,
              width: size.width,
              child: CalendarDatePicker2WithActionButtons(
                config: CalendarDatePicker2WithActionButtonsConfig(
                  firstDayOfWeek: 1,
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                  calendarType: CalendarDatePicker2Type.single,
                  selectedDayTextStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  selectedDayHighlightColor: Colors.purple[800],
                  //centerAlignModePickerButton: true,
                  //customModePickerButtonIcon: SizedBox(),
                ),
                //initialValue: [dateTime],
                onValueChanged: (dates) => setState(() {
                  dateTime = dates[0]!;
                }),
                onCancelTapped: () {
                  setState(() {
                    dateTime = DateTime(1999);
                  });
                  QuickHelp.hideLoadingDialog(context);
                },
                onOkTapped: () {
                  _validateBirthday("${dateTime.day}/${dateTime.month}/${dateTime.year}");
                  QuickHelp.hideLoadingDialog(context);
                }, value: [],
              ),
            ),
          );
        });
  }

  Widget birthDayTextField() {
    bool isDarkMode = QuickHelp.isDarkMode(context);
    return ContainerCorner(
      borderRadius: 50,
      height: 45,
      marginTop: 20,
      onTap: () => showCalendar(),
      color: isDarkMode
          ? Colors.blueAccent.withOpacity(0.3)
          : Colors.blueAccent.withOpacity(0.05),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Icon(
              Icons.calendar_month_outlined,
              size: 15,
              color: kGrayColor,
            ),
          ),
          TextWithTap(
            "${dateTime.year}-${dateTime.month}-${dateTime.day}",
            marginLeft: 5,
          ),
        ],
      ),
    );
  }

  Future<void> _updateNow() async {
    QuickHelp.showLoadingDialog(context);

    String fullName = nickNameTextEdit.text.trim();
    String firstName = "";
    String lastName = "";

    if (fullName.contains(" ")) {
      int firstSpace = fullName.indexOf(" ");
      firstName = fullName.substring(0, firstSpace);
      lastName = fullName.substring(firstSpace).trim();
    } else {
      firstName = fullName;
    }

    String username = fullName.replaceAll(" ", "");

    widget.currentUser!.setFullName = fullName;
    widget.currentUser!.setFirstName = firstName;
    widget.currentUser!.setLastName = lastName;
    widget.currentUser!.setGender = mySelectedGender!;
    widget.currentUser!.username = username.toLowerCase();
    widget.currentUser!.setBirthday = dateTime;
    widget.currentUser!.setCountry = countryName;
    widget.currentUser!.setBio = Setup.bio;
    widget.currentUser!.setCountryCode = countryIsoCode;
    widget.currentUser!.setCountryDialCode = countryDialCode;
    widget.currentUser!.setCountryLanguages = languagesIso;

    if(widget.currentUser!.getUid == 00000000) {
      widget.currentUser!.setUid = QuickHelp.generateUId();
    }

    if (aboutYouTitleEditingController.text.isNotEmpty) {
      widget.currentUser!.setAboutYou = aboutYouTitleEditingController.text;
    }

    if(widget.currentUser!.getCredits == 0) {
      widget.currentUser!.addCredit = Setup.welcomeCredit;
    }

    ParseResponse userResult = await widget.currentUser!.save();

    if (userResult.success) {

      widget.currentUser = userResult.results!.first as UserModel;

      QuickHelp.hideLoadingDialog(context);
      createFanClub();

      QuickHelp.goToNavigatorScreen(
        context,
        DispacheScreen(
          currentUser: widget.currentUser,
        ),
        finish: true,
        back: false,
      );

      _getUser();
    } else if (userResult.error!.code == 100) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context, title: "error".tr(), message: "not_connected".tr());
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
          context: context,
          title: "error".tr(),
          message: "try_again_later".tr());
    }
  }

  Future<void> checkPermission(bool isAvatar) async {
    if (QuickHelp.isAndroidPlatform()) {
      PermissionStatus status = await Permission.storage.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission android');

      checkStatus(status, status2, isAvatar);
    } else if (QuickHelp.isIOSPlatform()) {
      PermissionStatus status = await Permission.photos.status;
      PermissionStatus status2 = await Permission.camera.status;
      print('Permission ios');

      checkStatus(status, status2, isAvatar);
    } else {
      print('Permission other device');

      _choosePhoto(isAvatar);
    }
  }

  void checkStatus(
      PermissionStatus status, PermissionStatus status2, bool isAvatar) {
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

            //if (await Permission.camera.request().isGranted) {
            // Either the permission was already granted before or the user just granted it.
            //}

            // You can request multiple permissions at once.
            Map<Permission, PermissionStatus> statuses = await [
              Permission.camera,
              Permission.photos,
              Permission.storage,
            ].request();

            if (statuses[Permission.camera]!.isGranted &&
                statuses[Permission.photos]!.isGranted ||
                statuses[Permission.storage]!.isGranted) {
              _choosePhoto(isAvatar);
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
      //_uploadPhotos(ImageSource.gallery);
      _choosePhoto(isAvatar);
    }

    print('Permission $status');
    print('Permission $status2');
  }

  _choosePhoto(bool isAvatar) async {
    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
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
            'avatar${date.second}_${date.millisecond}.jpg';

        File tempFile = File('${tempDir.path}/$imageName');
        await tempFile.writeAsBytes(await images[i].readAsBytes());
        savedImagesPaths.add(tempFile.path);

        setState(() {
          selectedPicture = tempFile;
        });
      }
      uploadFile();
    } else {
      print("Photos null");
    }
  }


  uploadFile() async {
    QuickHelp.showLoadingDialog(context);

    DateTime date = DateTime.now();

    if (selectedPicture!.absolute.path.isNotEmpty) {
      parseFile = ParseFile(File(selectedPicture!.absolute.path),
          name: "avatar${date.second}_${date.millisecond}.jpg");
    } else {
      parseFile = ParseWebFile(selectedPicture!.readAsBytesSync(),
          name: "avatar${date.second}_${date.millisecond}.jpg");
    }

    widget.currentUser!.setAvatar = parseFile!;

    ParseResponse parseResponse = await widget.currentUser!.save();

    if (parseResponse.success) {
      QuickHelp.hideLoadingDialog(context);
      widget.currentUser = parseResponse.results!.first as UserModel;

      setState(() {
        userAvatar = widget.currentUser!.getAvatar != null
            ? widget.currentUser!.getAvatar!.url!
            : "";
      });

    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        context: context,
        title: "error".tr(),
        message: "try_again_later".tr(),
      );
    }
  }

  createFanClub() async{
    FanClubModel fanClubModel = FanClubModel();
    fanClubModel.setAuthorId = widget.currentUser!.objectId!;
    fanClubModel.setAuthor = widget.currentUser!;
    fanClubModel.setName = "fan_club_screen.fans_".tr();
    await fanClubModel.save();
  }
}
