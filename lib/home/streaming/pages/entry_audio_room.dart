// ignore_for_file: must_be_immutable

part of 'home_page.dart';

class AudioRoomEntry extends StatefulWidget {
  UserModel? currentUser;
  SharedPreferences? preferences;
  AudioRoomEntry({this.preferences, this.currentUser, super.key});

  @override
  State<AudioRoomEntry> createState() => _AudioRoomEntryState();
}

class _AudioRoomEntryState extends State<AudioRoomEntry> {

  TextEditingController liveTitleTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool showErrorOnTitleInput = false;
  var liveSubTypeSelected = [];
  bool shuffled = false;

  var liveTitle = [
    "random_live_title.live_chat".tr(),
    "random_live_title.playing_chat".tr(),
    "random_live_title.live_cooking".tr(),
    "random_live_title.leve_music".tr(),
    "random_live_title.live_meme".tr(),
    "random_live_title.relaxing_live".tr(),
    "random_live_title.complete_live".tr(),
    "random_live_title.drawing_live".tr(),
    "random_live_title.to_films".tr(),
  ];


  @override
  void initState() {
    super.initState();
    liveTitle.add("random_live_title.live_with_me".tr(
      namedArgs: {"name": "${widget.currentUser!.getUsername}"},
    ));
    liveTitle.shuffle();
    liveTitleTextController.text = liveTitle[3];
    liveSubTypeSelected.add(QuickHelp.getLiveTagsList()[0]);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=> QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            leaveButton(),
            SizedBox(width: 10,),
          ],
        ),
        body: ContainerCorner(
          imageDecoration: "assets/images/live_bg.png",
          borderWidth: 0,
          width: size.width,
          height: size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              liveTitleAndTags(),
              startLiveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget startLiveButton() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      color: kPrimaryColor,
      borderWidth: 0,
      height: 45,
      borderRadius: 50,
      marginLeft: 10,
      width: size.width / 1.8,
      onTap: () {
        if (formKey.currentState!.validate()) {
          if (liveSubTypeSelected.isEmpty) {
            liveSubTypeSelected.add(
              QuickHelp.getLiveTagsList()[0],
            );
          }
          createAudioRoom();
        }
      },
      child: TextWithTap(
        "start_audio_room".tr(),
        color: Colors.white,
        alignment: Alignment.center,
      ),
    );
  }

  Widget leaveButton() {
    return CommonButton(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(6),
      onTap: () {
        Navigator.pop(context);
      },
      child: Image.asset('assets/icons/nav_close.png'),
    );
  }

  Widget liveTitleAndTags() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      height: 110,
      width: size.width - 30,
      color: Colors.black.withOpacity(0.1),
      borderRadius: 20,
      borderWidth: 0,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContainerCorner(
              marginTop: 10,
              height: 40,
              width: size.width,
              borderRadius: 10,
              marginLeft: 10,
              marginRight: 10,
              borderColor:
              showErrorOnTitleInput ? Colors.red : kTransparentColor,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextFormField(
                  controller: liveTitleTextController,
                  maxLines: 1,
                  autocorrect: false,
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "live_streaming.enter_title".tr(),
                    hintStyle: GoogleFonts.roboto(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    errorStyle: GoogleFonts.roboto(
                      fontSize: 0.0,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.disabled,
                  validator: (value) {
                    if (value!.isEmpty) {
                      showErrorOnTitleInput = true;
                      setState(() {});
                      return "";
                    } else {
                      showErrorOnTitleInput = false;
                      setState(() {});
                      return null;
                    }
                  },
                ),
              ),
            ),
            ContainerCorner(
              marginTop: 15,
              height: 30,
              marginLeft: 10,
              child: ListView(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                children: List.generate(
                    QuickHelp.getLiveTagsList().length, (index) {
                  bool isSelected = liveSubTypeSelected
                      .contains(QuickHelp.getLiveTagsList()[index]);
                  return ContainerCorner(
                    borderRadius: 10,
                    height: 25,
                    borderWidth: isSelected ? 0 : 1,
                    borderColor:
                    isSelected ? kTransparentColor : Colors.white,
                    color: isSelected ? kPrimaryColor : kTransparentColor,
                    onTap: () {
                      liveSubTypeSelected.clear();
                      liveSubTypeSelected
                          .add(QuickHelp.getLiveTagsList()[index]);
                      setState(() {});
                    },
                    marginRight: 10,
                    child: TextWithTap(
                      QuickHelp.getLiveTagsByCode(
                          QuickHelp.getLiveTagsList()[index]),
                      color: Colors.white,
                      marginLeft: 8,
                      marginRight: 8,
                      alignment: Alignment.center,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void createAudioRoom() async {
    QuickHelp.showLoadingDialog(context, isDismissible: false);

    QueryBuilder<LiveStreamingModel> queryBuilder =
    QueryBuilder(LiveStreamingModel());
    queryBuilder.whereEqualTo(
        LiveStreamingModel.keyAuthorId, widget.currentUser!.objectId);
    queryBuilder.whereEqualTo(LiveStreamingModel.keyStreaming, true);

    ParseResponse parseResponse = await queryBuilder.query();
    if (parseResponse.success) {
      if (parseResponse.results != null) {
        LiveStreamingModel live =
        parseResponse.results!.first! as LiveStreamingModel;

        live.setStreaming = false;
        await live.save();

        startNewAudioRoom();
      } else {
        startNewAudioRoom();
      }
    } else {
      QuickHelp.showErrorResult(context, parseResponse.error!.code);
      QuickHelp.hideLoadingDialog(context);
    }
  }

  startNewAudioRoom() async {
    LiveStreamingModel streamingModel = LiveStreamingModel();
    streamingModel.setStreamingChannel =
        widget.currentUser!.objectId! + widget.currentUser!.getUid!.toString();

    streamingModel.setAuthor = widget.currentUser!;
    streamingModel.setAuthorId = widget.currentUser!.objectId!;
    streamingModel.setAuthorUid = widget.currentUser!.getUid!;
    streamingModel.addAuthorTotalDiamonds =
    widget.currentUser!.getDiamondsTotal!;
    streamingModel.setFirstLive = widget.currentUser!.isFirstLive!;

    streamingModel.setLiveTitle = liveTitleTextController.text;
    if(widget.currentUser!.getLiveCover != null) {
      streamingModel.setImage = widget.currentUser!.getLiveCover!;
    }else{
      streamingModel.setImage = widget.currentUser!.getAvatar!;
    }

    if(widget.currentUser!.getPartyTheme != null) {
      streamingModel.setPartyTheme = widget.currentUser!.getPartyTheme!;
    }
    streamingModel.setPartyType = LiveStreamingModel.liveAudio;
    streamingModel.setLiveType = LiveStreamingModel.liveAudio;

    if (widget.currentUser!.getGeoPoint != null) {
      streamingModel.setStreamingGeoPoint = widget.currentUser!.getGeoPoint!;
    }

    streamingModel.setPrivate = false;
    streamingModel.setStreaming = true;
    streamingModel.addViewersCount = 0;
    streamingModel.addDiamonds = 0;

    ParseResponse parseResponse = await streamingModel.save();

    if (parseResponse.success && parseResponse.results != null) {
      QuickHelp.hideLoadingDialog(context);
      LiveStreamingModel liveStreaming = parseResponse.results!.first!;
      QuickHelp.goToNavigatorScreen(
          context, AudioRoomPage(
        roomID: liveStreaming.getStreamingChannel!,
        role: ZegoLiveAudioRoomRole.host,
        currentUser: widget.currentUser,
        preferences: widget.preferences,
      ));
    }else{
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }
}
