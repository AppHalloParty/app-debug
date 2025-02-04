import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../helpers/quick_actions.dart';
import '../../helpers/quick_help.dart';
import '../../helpers/send_notifications.dart';
import '../../models/AgencyInvitationModel.dart';
import '../../models/MessageListModel.dart';
import '../../models/MessageModel.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import 'invitation_report_screen.dart';

// ignore: must_be_immutable
class AddHostScreen extends StatefulWidget {
  UserModel? currentUser;

  AddHostScreen({this.currentUser, Key? key})
      : super(key: key);

  @override
  State<AddHostScreen> createState() => _AddHostScreenState();
}

class _AddHostScreenState extends State<AddHostScreen> {
  TextEditingController hostIdController = TextEditingController();
  TextEditingController hostCodeController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool showErrorOnIdInput = false;
  bool showErrorOnCodeInput = false;

  Timer? debounce;

  UserModel? hostToAdd;

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  void onTextChanged(String value) {
    if (debounce != null) {
      debounce!.cancel();
    }

    String hostId = hostIdController.text;
    String hostCode = hostCodeController.text;

    int currentUserId = widget.currentUser!.getUid!;
    String currentUserCode = widget.currentUser!.objectId!;

    debounce = Timer(Duration(milliseconds: 1000), () {
      if (formKey.currentState!.validate()) {
        if(hostId == "$currentUserId" && hostCode == currentUserCode) {
          QuickHelp.showAppNotificationAdvanced(
            title: "error".tr(),
            message: "add_host_screen.cannot_add_yourself".tr(),
            context: context,
          );
        }else{
          if(hostId.length == 10 && hostCode.length == 10){
            getHostToAdd();
          }else{
            QuickHelp.showAppNotificationAdvanced(
              title: "error".tr(),
              message: "add_host_screen.make_sure_correct_id_code".tr(),
              context: context,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return GestureDetector(
      onTap: () => QuickHelp.removeFocusOnTextField(context),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: isDark ? Colors.white : kContentColorLightTheme,
          ),
          centerTitle: true,
          title: TextWithTap(
            "add_host_screen.add_host".tr(),
            fontWeight: FontWeight.w600,
          ),
          actions: [
            TextButton(
              onPressed: () {
                QuickHelp.goToNavigatorScreen(
                    context,
                    InvitationReportScreen(
                      currentUser: widget.currentUser!,
                    ),
                );
              },
              child: TextWithTap(
                "add_host_screen.history_".tr(),
                color: isDark ? Colors.white : kContentColorLightTheme,
              ),
            )
          ],
        ),
        body: ListView(
          padding: EdgeInsets.only(left: 15, right: 15, top: 10),
          children: [
            Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "*",
                        color: Colors.red,
                      ),
                      TextWithTap(
                        "add_host_screen.user_id".tr(),
                        fontSize: 12,
                      ),
                      Icon(
                        Icons.info_outline,
                        size: 15,
                      ),
                    ],
                  ),
                  ContainerCorner(
                    marginTop: 10,
                    height: 50,
                    borderRadius: 8,
                    color: kGrayColor.withOpacity(0.1),
                    marginBottom: 20,
                    borderColor:
                        showErrorOnIdInput ? Colors.red : kTransparentColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextFormField(
                        controller: hostIdController,
                        keyboardType: TextInputType.number,
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                          color: kGrayColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "add_host_screen.user_id".tr(),
                          hintStyle: GoogleFonts.roboto(
                            color: kGrayColor.withOpacity(0.7),
                          ),
                          errorStyle: GoogleFonts.roboto(
                            fontSize: 0.0,
                          ),
                        ),
                        onChanged: (text) {
                          onTextChanged(text);
                        },
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) {
                          if (value!.isEmpty) {
                            setState(() {
                              showErrorOnIdInput = true;
                            });
                            return "";
                          } else {
                            setState(() {
                              showErrorOnIdInput = false;
                            });
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextWithTap(
                        "*",
                        color: Colors.red,
                      ),
                      TextWithTap(
                        "add_host_screen.host_code".tr(),
                        fontSize: 12,
                      ),
                      Icon(
                        Icons.info_outline,
                        size: 15,
                      ),
                    ],
                  ),
                  ContainerCorner(
                    marginTop: 10,
                    height: 50,
                    borderRadius: 8,
                    color: kGrayColor.withOpacity(0.1),
                    borderColor:
                        showErrorOnCodeInput ? Colors.red : kTransparentColor,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextFormField(
                        controller: hostCodeController,
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                          color: kGrayColor,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "add_host_screen.host_code_no".tr(),
                          hintStyle: GoogleFonts.roboto(
                            color: kGrayColor.withOpacity(0.7),
                          ),
                          errorStyle: GoogleFonts.roboto(
                            fontSize: 0.0,
                          ),
                        ),
                        onChanged: (text) {
                          onTextChanged(text);
                        },
                        autovalidateMode: AutovalidateMode.disabled,
                        validator: (value) {
                          if (value!.isEmpty) {
                            setState(() {
                              showErrorOnCodeInput = true;
                            });
                            return "";
                          } else {
                            setState(() {
                              showErrorOnCodeInput = false;
                            });
                            return null;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: hostToAdd == null,
              child: TextWithTap(
                "add_host_screen.id_and_code_from_host".tr(),
                fontSize: 12,
                marginLeft: 10,
                marginTop: 15,
                color: kGrayColor,
              ),
            ),
            if (hostToAdd != null)
              ContainerCorner(
                height: 40,
                marginTop: 10,
                width: size.width,
                borderRadius: 8,
                color: kGrayColor.withOpacity(0.1),
                child: Row(
                  children: [
                    QuickActions.avatarWidget(
                      hostToAdd!,
                      height: 30,
                      width: 30,
                    ),
                    TextWithTap(
                      hostToAdd!.getFullName!,
                      marginLeft: 5,
                    ),
                  ],
                ),
              ),
            ContainerCorner(
              color: hostToAdd != null
                  ? kPrimaryColor
                  : kPrimaryColor.withOpacity(0.4),
              borderRadius: 50,
              height: 50,
              width: size.width,
              marginTop: 25,
              onTap: () {
                if (hostToAdd != null) {
                  sendInvitation();
                }
              },
              child: TextWithTap(
                "add_host_screen.send_invitation".tr(),
                color: Colors.white,
                alignment: Alignment.center,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  getHostToAdd() async {
    QuickHelp.showLoadingDialog(context);
    QueryBuilder<UserModel> query =
        QueryBuilder<UserModel>(UserModel.forQuery());

    query.whereEqualTo(UserModel.keyObjectId, hostCodeController.text);
    ParseResponse response = await query.query();

    if (response.success) {
      QuickHelp.hideLoadingDialog(context);
      if (response.results != null) {
        setState(() {
          hostToAdd = response.results!.first;
        });
      } else {
        QuickHelp.showAppNotificationAdvanced(
          title: "error".tr(),
          message: "qr_code.user_not_found".tr(),
          context: context,
        );
      }
    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.showAppNotificationAdvanced(
        title: "error".tr(),
        context: context,
        message: "report_screen.report_failed_explain".tr(),
      );
    }
  }

  sendInvitation() {
    UserModel receiver = hostToAdd!;
    _saveMessage(
      "add_host_screen.you_received_invitation".tr(),
      receiver: receiver,
      messageType: MessageModel.messageTypeAgencyInvitation,
    );
  }

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
        registerInvitation();
        QuickHelp.gotoChat(
          context,
          currentUser: widget.currentUser,
          mUser: receiver,
        );
        setState(() {
          hostCodeController.text = "";
          hostIdController.text = "";
          hostToAdd = null;
        });
      } else {
        QuickHelp.hideLoadingDialog(context);
        QuickHelp.showAppNotificationAdvanced(
            title: "tab_feed.say_hell_failed_title".tr(),
            context: context,
            message: "tab_feed.say_hell_failed_explain".tr());
      }

      _saveList(message, receiver: receiver);

      SendNotifications.sendPush(
          widget.currentUser!, receiver, SendNotifications.typeChat,
          message: messageText);
    }
  }

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

  registerInvitation() async{
    AgencyInvitationModel invitation = AgencyInvitationModel();

    invitation.setAgent = widget.currentUser!;
    invitation.setAgentId = widget.currentUser!.objectId!;
    invitation.setHost = hostToAdd!;
    invitation.setHostId = hostToAdd!.objectId!;
    invitation.setInvitationStatus = AgencyInvitationModel.keyStatusPending;
    invitation.save();
  }
}
