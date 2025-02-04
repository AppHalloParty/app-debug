// ignore_for_file: must_be_immutable, deprecated_member_use
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/GroupMessageModel.dart';
import 'package:trace/models/MessageListModel.dart';
import 'package:trace/models/MessageModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

import '../../models/AgencyMembersModel.dart';


class AgencyGroupCreationScreen extends StatefulWidget {
  UserModel? currentUser;
  static const String route = "/chat/createGroup";
  AgencyGroupCreationScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<AgencyGroupCreationScreen> createState() => _AgencyGroupCreationScreenState();
}

class _AgencyGroupCreationScreenState extends State<AgencyGroupCreationScreen> {
  TextEditingController userSearchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  List selectedUserID = [];
  List<UserModel> selectedUsers = [];
  List<String> userNames = [];

  @override
  void dispose() {
    userSearchController.dispose();
    selectedUserID.clear();
    selectedUsers.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kTransparentColor,
          automaticallyImplyLeading: false,
          leadingWidth: 120,
          leading: Visibility(
              visible: selectedUserID.length > 1,
              child: TextWithTap(
                "group_creation.create".tr(),
                color: Colors.green,
                fontWeight: FontWeight.w900,
                marginLeft: 10,
                marginTop: 15,
                onTap: () => _createGroup(),
              )),
          title: TextWithTap(
            "group_creation.new_group".tr(),
            color: QuickHelp.isDarkMode(context)
                ? Colors.white
                : kContentColorLightTheme,
            fontWeight: FontWeight.w900,
          ),
          actions: [
            TextWithTap(
              "cancel".tr(),
              fontSize: 20,
              fontWeight: FontWeight.w600,
              marginRight: 10,
              marginTop: 15,
              color: kRedColor1,
              onTap: () => QuickHelp.goBackToPreviousPage(context),
            )
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              child: Column(
                children: [
                  chatInputField(),
                  Flexible(child: showAllUsers()),
                ],
              ),
            ),
            Visibility(
              visible: selectedUserID.isNotEmpty ? true : false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: ContainerCorner(
                      //color: Colors.white.withOpacity(0.5),
                      height: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ContainerCorner(
                            width: MediaQuery.of(context).size.width,
                            marginTop: 2,
                            marginBottom: 5,
                            color: Colors.black.withOpacity(0.1),
                            child: TextWithTap(
                              "group_creation.selected".tr(),
                              color: QuickHelp.isDarkMode(context)
                                  ? Colors.white
                                  : kContentColorLightTheme,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              marginLeft: 5,
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              children: List.generate(selectedUserID.length,
                                      (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          SizedBox(
                                            child: Column(
                                              children: [
                                                QuickActions.avatarWidget(
                                                  selectedUsers[index],
                                                  width: 50,
                                                  height: 50,
                                                ),
                                                TextWithTap(
                                                  selectedUsers[index]
                                                      .getFirstName!,
                                                  fontSize: 10,
                                                  marginTop: 3,
                                                  color: QuickHelp.isDarkMode(
                                                      context)
                                                      ? Colors.white
                                                      : kContentColorLightTheme,
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            child: IconButton(
                                              onPressed: () {
                                                for (int i = 0;
                                                i < selectedUserID.length;
                                                i++) {
                                                  if (selectedUsers[index]
                                                      .objectId! ==
                                                      selectedUserID[i]) {
                                                    selectedUserID.removeAt(i);
                                                    selectedUsers.removeAt(i);
                                                  }
                                                }
                                                setState(() {});
                                              },
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.red,
                                                size: 35,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatInputField() {
    return ContainerCorner(
      borderWidth: 0,
      borderRadius: 10,
      marginLeft: 10,
      marginRight: 10,
      marginBottom: 10,
      color: Colors.white.withOpacity(0.1),
      height: 45,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 5,
                right: 10,
              ),
              child: Center(
                child: TextField(
                  autocorrect: false,
                  readOnly: true,
                  style: GoogleFonts.nunito(
                    color: QuickHelp.isDarkMode(context)
                        ? Colors.white
                        : kContentColorLightTheme,
                  ),
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(userNames),
                    );
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  controller: userSearchController,
                  decoration: InputDecoration(
                    hintText: "group_creation.search".tr(),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ParseLiveListWidget showAllUsers() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<AgencyMembersModel> queryBuilder =
    QueryBuilder<AgencyMembersModel>(AgencyMembersModel());

    queryBuilder.whereNotEqualTo(
        AgencyMembersModel.keyAgentId, widget.currentUser!.objectId);

    return ParseLiveListWidget<AgencyMembersModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      duration: const Duration(microseconds: 1),
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<AgencyMembersModel> snapshot) {
        if (snapshot.hasData) {
          AgencyMembersModel agencyMembers = snapshot.loadedData as AgencyMembersModel;
          UserModel user = agencyMembers.getHost!;
          userNames.add(user.getFullName!);

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () {
                if (!selectedUserID.contains(user.objectId)) {
                  selectedUserID.add(user.objectId);
                  selectedUsers.add(user);
                }
                if (selectedUserID.length > 3) {

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    return await _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 5),
                        curve: Curves.easeInOut);
                  });
                }
                setState(() {});
              },
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuickActions.avatarWidget(user,
                            width: size.width / 6, height: size.width / 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWithTap(
                                user.getFullName!,
                                fontSize: size.width / 23,
                                fontWeight: FontWeight.w600,
                                marginBottom: 4,
                              ),
                              Row(
                                children: [
                                  QuickActions.getGender(
                                      currentUser: user, context: context),
                                  const SizedBox(width: 5,),
                                  QuickActions.giftReceivedLevel(
                                    receivedGifts: user.getDiamondsTotal!,
                                    width: 35,
                                  ),
                                  const SizedBox(width: 5,),
                                  QuickActions.wealthLevel(
                                    credit: user.getCreditsSent!,
                                    width: 35,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextWithTap(
                                    "tab_profile.id_".tr(),
                                    fontSize: size.width / 33,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  TextWithTap(
                                    widget.currentUser!.getUid!.toString(),
                                    fontSize: size.width / 33,
                                    marginLeft: 3,
                                    marginRight: 3,
                                  ),
                                  Icon(
                                    Icons.copy,
                                    color: kGrayColor,
                                    size: size.width / 30,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(selectedUserID.contains(user.objectId)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked),
                  ),
                ],
              ),
            ),
          );
        } else {
          return QuickActions.noContentFound(context);
        }
      },
      queryEmptyElement: QuickActions.noContentFound(context),
      listLoadingElement: Center(
        child: QuickHelp.appLoading(),
      ),
    );
  }

  _createGroup() async {
    QuickHelp.showLoadingDialog(context);

    selectedUserID.add(widget.currentUser!.objectId);
    selectedUsers.add(widget.currentUser!);

    MessageGroupModel messageGroupModel = MessageGroupModel();

    messageGroupModel.setMembers = selectedUsers;
    messageGroupModel.setGroupType = MessageGroupModel.keyAgencyGroupType;

    messageGroupModel.setMemberIDs = selectedUserID;
    messageGroupModel.setAuthor = widget.currentUser!;
    messageGroupModel.setAuthorId = widget.currentUser!.objectId!;
    messageGroupModel.setGroupName = "group_creation.group_default_name"
        .tr(namedArgs: {"name": widget.currentUser!.getUsername!});
    messageGroupModel.setAdmin = widget.currentUser!.objectId!;

    ParseResponse response = await messageGroupModel.save();

    if (response.success) {
      _sendFirstMessage(messageGroupModel);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "group_creation.error_title".tr(),
        message: "group_creation.error_explain".tr(),
        context: context,
        isError: true,
      );
    }
  }

  // Save the message
  _sendFirstMessage(MessageGroupModel groupMessageModel) async {
    MessageModel message = MessageModel();

    message.setMemberIDs = selectedUserID;

    message.setAuthor = widget.currentUser!;
    message.setAuthorId = widget.currentUser!.objectId!;

    message.setGroupReceiver = groupMessageModel;
    message.setGroupReceiverId = groupMessageModel.objectId!;

    message.setReceiverId = groupMessageModel.objectId!;

    message.setDuration = "group_creation.first_msg".tr();
    message.setIsMessageFile = false;

    message.setMessageType = MessageModel.messageGroupNotify;

    message.setIsRead = false;

    await message.save();
    _saveList(message, groupMessageModel, selectedUserID);
  }

  _saveList(MessageModel messageModel, MessageGroupModel groupMessageModel,
      List<dynamic> memberIDs) async {
    MessageListModel messageListModel = MessageListModel();

    messageListModel.setMemberIDs = memberIDs;

    messageListModel.setAuthor = widget.currentUser!;
    messageListModel.setAuthorId = widget.currentUser!.objectId!;

    messageListModel.setGroupReceiver = groupMessageModel;
    messageListModel.setReceiverId = groupMessageModel.objectId!;
    messageListModel.setGroupReceiverId = groupMessageModel.objectId!;

    messageListModel.setMessage = messageModel;
    messageListModel.setMessageId = messageModel.objectId!;
    messageListModel.setText = messageModel.getDuration!;
    messageListModel.setIsMessageFile = false;

    messageListModel.setMessageType = MessageModel.messageGroupNotify;

    messageListModel.setIsRead = false;

    messageListModel.incrementCounter = 1;
    await messageListModel.save();

    messageModel.setMessageList = messageListModel;
    messageModel.setMessageListId = messageListModel.objectId!;

    ParseResponse response = await messageModel.save();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goBackToPreviousPage(context);
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "group_creation.error_title".tr(),
        message: "group_creation.error_explain".tr(),
        context: context,
        isError: true,
      );
    }
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String>? users;

  CustomSearchDelegate(this.users);

  //List<dynamic> searchTerms = users;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];

    for (var user in users!) {
      if (user.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return TextButton(
          onPressed: () {},
          child: ListTile(
            title: Text(result),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var user in users!) {
      if (user.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(user);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
