// ignore_for_file: deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/GiftsModel.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

class ReplyStoryScreen {
  ReplyStoryScreen(
      {required BuildContext context,
      required UserModel currentUser,
      Function(GiftsModel giftsModel)? onGiftSelected,
      Function(int coins)? onCoinsPurchased,
      bool isDismissible = true,
      bool enableDrag = true,
      bool isScrollControlled = true,
      bool showOnlyCoinsPurchase = false,
      Color backgroundColor = Colors.transparent}) {
    showModalBottomSheet(
        context: (context),
        isScrollControlled: isScrollControlled,
        backgroundColor: backgroundColor,
        enableDrag: enableDrag,
        isDismissible: isDismissible,
        builder: (context) {
          return _ReplyTextFieldWidget(
            currentUser: currentUser,
            onCoinsPurchased: onCoinsPurchased,
            onGiftSelected: onGiftSelected,
            showOnlyCoinsPurchase: showOnlyCoinsPurchase,
          );
        });
  }
}

class _ReplyTextFieldWidget extends StatefulWidget {
  final Function? onCoinsPurchased;
  final Function? onGiftSelected;
  final bool? showOnlyCoinsPurchase;
  final UserModel currentUser;

  const _ReplyTextFieldWidget({
    required this.currentUser,
    this.onCoinsPurchased,
    this.onGiftSelected,
    this.showOnlyCoinsPurchase = false,
  });

  @override
  State<_ReplyTextFieldWidget> createState() => _ReplyTextFieldWidgetState();
}

class _ReplyTextFieldWidgetState extends State<_ReplyTextFieldWidget>
    with TickerProviderStateMixin {
  TextEditingController storyMessageTextEditing = TextEditingController();
  FocusNode focusNode = FocusNode();
  int bottomSheetCurrentIndex = 0;

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _replyInputTextField();
  }

  Widget _replyInputTextField() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.001),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.67,
            minChildSize: 0.1,
            maxChildSize: 1.0,
            builder: (_, controller) {
              return StatefulBuilder(builder: (context, setState) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ContainerCorner(
                    color: kTransparentColor,
                    child: Scaffold(
                      backgroundColor: kTransparentColor,
                      appBar: AppBar(
                        actions: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/svg/ic_coin_with_star.svg",
                                width: 20,
                                height: 20,
                              ),
                              TextWithTap(
                                widget.currentUser.getCredits.toString(),
                                color: Colors.white,
                                marginLeft: 5,
                                marginRight: 15,
                              )
                            ],
                          ),
                        ],
                        backgroundColor: kTransparentColor,
                        title: TextWithTap(
                          "message_screen.get_coins".tr(),
                          marginRight: 10,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        leading: BackButton(
                          onPressed: () {
                            Navigator.of(this.context).pop();
                          },
                        ),
                      ),
                      body: getBody(),
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return Row(
      children: [
        Expanded(
          child: ContainerCorner(
            color: kTransparentColor,
            borderColor: Colors.white,
            borderRadius: 50,
            marginRight: 10,
            height: 50,
            marginLeft: 20,
            width: 300,
            child: TextFormField(
              focusNode: focusNode,
              minLines: 1,
              maxLines: 100,
              controller: storyMessageTextEditing,
              autovalidateMode: AutovalidateMode.disabled,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "stories.story_text_hint".tr(),
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(left: 10),
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        ContainerCorner(
          marginRight: 10,
          color: kFacebookColor,
          child: ContainerCorner(
            color: kTransparentColor,
            marginAll: 5,
            height: 30,
            width: 30,
            child: SvgPicture.asset(
              "assets/svg/ic_send_message.svg",
              color: Colors.white,
              height: 10,
              width: 30,
            ),
          ),
          borderRadius: 50,
          height: 45,
          width: 45,
          onTap: () {
            if (storyMessageTextEditing.text.isEmpty) {
              QuickHelp.showAppNotificationAdvanced(
                title: "stories.make_sure_title".tr(),
                message: "stories.make_sure_explain".tr(),
                isError: true,
                context: context,
              );
            }
          },
        )
      ],
    );
  }
}
