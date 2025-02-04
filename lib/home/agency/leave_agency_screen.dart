// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_help.dart';
import '../../helpers/send_notifications.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

class LeaveAgencyScreen extends StatefulWidget {
  UserModel? currentUser, agent;

  LeaveAgencyScreen({
    this.currentUser,
    this.agent,
    Key? key})
      : super(key: key);

  @override
  State<LeaveAgencyScreen> createState() => _LeaveAgencyScreenState();
}

class _LeaveAgencyScreenState extends State<LeaveAgencyScreen> {
  var rules = [
    "host_rules_screen.change_agency_1".tr(),
    "host_rules_screen.change_agency_2".tr(),
    "host_rules_screen.change_agency_3".tr(),
    "host_rules_screen.change_agency_4".tr(),
    "host_rules_screen.change_agency_5".tr(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kTransparentColor,
        leading: BackButton(
          color: Colors.white,
        ),
        centerTitle: true,
        title: TextWithTap(
          "my_agent_screen.my_agent".tr(),
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      body: ContainerCorner(
        height: size.height,
        width: size.width,
        borderWidth: 0,
        imageDecoration: "assets/images/bg_leave_agency.png",
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWithTap(
              "leave_agency_screen.apply_describe".tr(),
              fontSize: size.width / 18,
              fontWeight: FontWeight.w700,
              marginBottom: 40,
            ),
            Padding(
              padding:
              EdgeInsets.only(left: size.width / 9, right: size.width / 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: List.generate(
                  rules.length,
                      (index) => textRule(
                    text: rules[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ContainerCorner(
        borderRadius: 50,
        marginLeft: 40,
        height: 45,
        width: size.width,
        marginRight: 40,
        marginBottom: 30,
        borderWidth: 0,
        color: kPrimaryColor,
        onTap: () => confirmLeaveAgency(),
        child: TextWithTap(
          "leave_agency_screen.apply_to_leave".tr(),
          color: Colors.white,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Widget textRule({required String text}) {
    return TextWithTap(
      text,
      color: kGrayColor,
      marginBottom: 3,
      marginTop: 7,
    );
  }

  confirmLeaveAgency() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, newState) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextWithTap(
                  "leave_agency_screen.sure_wanna_leave".tr(),
                  textAlign: TextAlign.center,
                  marginTop: 20,
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: TextWithTap(
                        "cancel".tr(),
                        color: kGrayColor,
                        marginRight: 15,
                        marginLeft: 15,
                      ),
                      onPressed: () => QuickHelp.goBackToPreviousPage(context),
                    ),
                    TextButton(
                      child: TextWithTap(
                        "confirm_".tr(),
                        color: kPrimaryColor,
                        marginRight: 20,
                        marginLeft: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      onPressed: () {
                        QuickHelp.hideLoadingDialog(context);
                        leaveAgency();
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  leaveAgency() {
    _saveMessage(
      "leave_agency_screen.leave_agency_msg".tr(namedArgs: {"name": widget.currentUser!.getFullName!}),
      receiver: widget.agent!,
      messageType:
      MessageModel.messageTypeLeaveAgencyApplication,
    );
  }

  // Save the message
  _saveMessage(String messageText,
      {required String messageType, required UserModel receiver}) async {
    if (messageText.isNotEmpty) {
      QuickHelp.showLoadingDialog(context);
      MessageModel message = MessageModel();

      message.setAuthor = widget.currentUser!;
      message.setAuthorId = widget.currentUser!.objectId!;

      message.setReceiver = receiver;
      message.setReceiverId = receiver.objectId!;

      message.setDuration = messageText;
      message.setIsMessageFile = false;

      message.setMessageType = messageType;

      message.setIsRead = false;

      widget.currentUser!.setChatWithUsersIds = receiver.objectId!;
      widget.currentUser!.save();

      ParseResponse response = await message.save();

      if (response.success) {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.gotoChat(
          context,
          currentUser: widget.currentUser,
          mUser: receiver,
        );
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
          title: "tab_feed.say_hell_failed_title".tr(),
          context: context,
          message: "tab_feed.say_hell_failed_explain".tr(),
        );
      }

      _saveList(message, receiver: receiver);

      SendNotifications.sendPush(
          widget.currentUser!, receiver, SendNotifications.typeChat,
          message: messageText);
    }
  }

  // Update or Create message list
  _saveList(MessageModel messageModel, {required UserModel receiver}) async {
    QueryBuilder<MessageListModel> queryFrom =
    QueryBuilder<MessageListModel>(MessageListModel());
    queryFrom.whereEqualTo(MessageListModel.keyListId,
        widget.currentUser!.objectId! + receiver.objectId!);

    QueryBuilder<MessageListModel> queryTo =
    QueryBuilder<MessageListModel>(MessageListModel());
    queryTo.whereEqualTo(MessageListModel.keyListId,
        receiver.objectId! + widget.currentUser!.objectId!);

    QueryBuilder<MessageListModel> queryBuilder =
    QueryBuilder.or(MessageListModel(), [queryFrom, queryTo]);

    ParseResponse parseResponse = await queryBuilder.query();

    if (parseResponse.success) {
      if (parseResponse.results != null) {
        MessageListModel messageListModel = parseResponse.results!.first;

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = receiver;
        messageListModel.setReceiverId = receiver.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.greetingsMessage;

        messageListModel.setIsRead = false;
        messageListModel.setListId =
            widget.currentUser!.objectId! + receiver.objectId!;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;

        await messageModel.save();
      } else {
        MessageListModel messageListModel = MessageListModel();

        messageListModel.setAuthor = widget.currentUser!;
        messageListModel.setAuthorId = widget.currentUser!.objectId!;

        messageListModel.setReceiver = receiver;
        messageListModel.setReceiverId = receiver.objectId!;

        messageListModel.setMessage = messageModel;
        messageListModel.setMessageId = messageModel.objectId!;
        messageListModel.setText = messageModel.getDuration!;
        messageListModel.setIsMessageFile = false;

        messageListModel.setMessageType = messageModel.getMessageType!;
        messageListModel.setMessageCategory = MessageListModel.greetingsMessage;

        messageListModel.setListId =
            widget.currentUser!.objectId! + receiver.objectId!;
        messageListModel.setIsRead = false;

        messageListModel.incrementCounter = 1;
        await messageListModel.save();

        messageModel.setMessageList = messageListModel;
        messageModel.setMessageListId = messageListModel.objectId!;
        await messageModel.save();
      }
    }
  }

}
