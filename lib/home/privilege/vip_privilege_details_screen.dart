// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helpers/quick_help.dart';
import '../../models/UserModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';

class VipPrivilegeDetailsScreen extends StatefulWidget {
  UserModel? currentUser;
  int initialIndex;

  VipPrivilegeDetailsScreen({
    this.currentUser,
    required this.initialIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<VipPrivilegeDetailsScreen> createState() =>
      _VipPrivilegeDetailsScreenState();
}

class _VipPrivilegeDetailsScreenState extends State<VipPrivilegeDetailsScreen>
    with TickerProviderStateMixin {
  late TabController tabControl;

  int tabLength = 20;
  int tabsIndex = 0;

  int? labelsIndex;

  var memberPrivilegesUrls = [
    "assets/images/ic_vip_privilege1.png",
    "assets/images/ic_vip_privilege2.png",
    "assets/images/ic_vip_privilege3.png",
    "assets/images/ic_vip_privilege4.png",
    "assets/images/ic_vip_privilege5.png",
    "assets/images/ic_vip_privilege6.png",
    "assets/images/ic_vip_privilege7.png",
    "assets/images/ic_vip_privilege8.png",
    "assets/images/ic_vip_privilege9.png",
    "assets/images/ic_vip_privilege10.png",
    "assets/images/ic_vip_privilege11.png",
    "assets/images/ic_vip_privilege12.png",
    "assets/images/ic_vip_privilege13.png",
    "assets/images/ic_vip_privilege14.png",
    "assets/images/ic_vip_privilege15.png",
    "assets/images/ic_vip_privilege16.png",
    "assets/images/ic_vip_privilege17.png",
    "assets/images/ic_vip_privilege18.png",
    "assets/images/ic_vip_privilege19.png",
    "assets/images/ic_vip_privilege20.png",
  ];

  var memberPrivilegesText = [
    "guardian_and_vip_screen.up_notification".tr(),
    "guardian_and_vip_screen.Special_Special".tr(),
    "guardian_and_vip_screen.vip_badge".tr(),
    "guardian_and_vip_screen.Avatar_Frame".tr(),
    "guardian_and_vip_screen.vip_name_card".tr(),
    "guardian_and_vip_screen.exclusive_customer".tr(),
    "guardian_and_vip_screen.free_private".tr(),
    "guardian_and_vip_screen.vip_seat".tr(),
    "guardian_and_vip_screen.message_background".tr(),
    "guardian_and_vip_screen.Highlighted_private".tr(),
    "guardian_and_vip_screen.status_advantages".tr(),
    "guardian_and_vip_screen.ban_messaging_room".tr(),
    "guardian_and_vip_screen.remove_users_rooms".tr(),
    "guardian_and_vip_screen.exclusive_gifts".tr(),
    "guardian_and_vip_screen.invisible_ranking".tr(),
    "guardian_and_vip_screen.hide_contributors".tr(),
    "guardian_and_vip_screen.invisible_follow".tr(),
    "guardian_and_vip_screen.message_ban_removal_immunity".tr(),
    "guardian_and_vip_screen.bullet_messages".tr(),
    "guardian_and_vip_screen.recommend_".tr(),
  ];

  var subTitle = [
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "1"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "2"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "2"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "3"}),
    "Hide Contributors",
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "5"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "6"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "7"}),
    "vip_privilege_details_screen.vip_higher".tr(namedArgs: {"num_vip": "9"}),
  ];

  var caption = [
    "vip_privilege_details_screen.your_leveling_up".tr(),
    "vip_privilege_details_screen.vip_user_enter_streams".tr(),
    "vip_privilege_details_screen.vip_badge_honorable".tr(),
    "vip_privilege_details_screen.vip_user_light".tr(),
    "vip_privilege_details_screen.customized_luxury".tr(),
    "vip_privilege_details_screen.exclusive_private_customer".tr(),
    "vip_privilege_details_screen.free_private_messages".tr(),
    "vip_privilege_details_screen.exclusive_vip_seat".tr(),
    "vip_privilege_details_screen.customized_chat_bubbles".tr(),
    "vip_privilege_details_screen.being_a_vip_each".tr(),
    "vip_privilege_details_screen.being_a_vip_posts".tr(),
    "vip_privilege_details_screen.vips_have_power".tr(),
    "vip_privilege_details_screen.vips_cant_kick".tr(),
    "vip_privilege_details_screen.vip_exclusive_customized".tr(),
    "vip_privilege_details_screen.set_yourself_invisible".tr(),
    "vip_privilege_details_screen.vip_users_higher".tr(),
    "vip_privilege_details_screen.make_your_follow".tr(),
    "vip_privilege_details_screen.prevent_guest_admins".tr(),
    "vip_privilege_details_screen.exclusive_vip_bullet".tr(),
    "vip_privilege_details_screen.contact_your_vip".tr(),
  ];

  var describeUrl = [
  "assets/images/level_up_notification_url.png",
  "assets/images/special_efect_entrace_one_url.png",
  "assets/images/avatar_frame_url.png",
  "assets/images/avatar_frame_url.png",
  "assets/images/vip_name_card.png",
  "assets/images/exclusive_customer.png",
  "assets/images/vip_name_card.png",
  "assets/images/vip_seat_url.png",
  "assets/images/message_background_url.png",
  "assets/images/highlighted_private_url.png",
  "assets/images/status_advantages_url.png",
  "assets/images/bean_messaging_in_room_url.png",
  "assets/images/bean_messaging_in_room_url.png",
  "assets/images/exclusive_gifts_url.png",
  "assets/images/invisible_ranking_url.png",
  "assets/images/hide_contributors_url.png",
  "assets/images/invisible_flow_url.png",
  "assets/images/exclusive_bullet_message_url.png",
  "assets/images/exclusive_bullet_message_url.png",
  "assets/images/recommend_hot_list_url.png",
  ];

  List<int> labels = [];

  @override
  initState() {
    tabControl = TabController(
        vsync: this, length: tabLength, initialIndex: widget.initialIndex)
      ..addListener(() {
        setState(() {
          tabsIndex = tabControl.index;
          labels.clear();
          labels.add(tabsIndex);
          print("$tabLength of listener");
        });
      });
    labels.add(widget.initialIndex);
    super.initState();
  }

  @override
  dispose() {
    tabControl.dispose();
    labels.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = QuickHelp.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark ? kContentColorLightTheme : kContentDarkShadow100,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => QuickHelp.goBackToPreviousPage(context),
          child: Icon(
            Icons.arrow_back_ios_outlined,
            size: 22,
          ),
        ),
        title: TextWithTap(
          "vip_privilege_details_screen.vip_privilege_details".tr(),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabControl,
            isScrollable: true,
            indicatorColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 75),
            dividerColor: Colors.transparent,
            onTap: (i){
              setState(() {
                labels.clear();
                labels.add(i);
              });
              print("$i great code");
            },
            tabs: List.generate(
              memberPrivilegesUrls.length, (index) {
                return Column(
                  children: [
                    SizedBox(height: 8),
                    Image.asset(
                      memberPrivilegesUrls[index],
                      width: 48,
                      height: 48,
                    ),
                    SizedBox(
                      width: size.width / 5,
                      child: TextWithTap(
                        memberPrivilegesText[index],
                        color: labels.contains(index)
                            ? Colors.white
                            : kGrey100,
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        marginTop: 8,
                        maxLines: 2,
                        marginBottom: labelMargin(index),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Flexible(
            child: TabBarView(
              controller: tabControl,
              children: List.generate(
                subTitle.length,
                (index) {
                  return body(
                    title: "vip_privilege_details_screen.requirements_".tr(),
                    subTitle: subTitle[index],
                    captionTitle:
                        "vip_privilege_details_screen.privilege_details".tr(),
                    caption: caption[index],
                    describeUrl: describeUrl[index],
                    index: index,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buttons(),
    );
  }

  labelMargin(int index){
    if(index == 2 || index == 3 || index == 4 || index == 7 || index == 13){
      return 10.0;
    } else{
      return 0.0;
    }
  }

  Widget body({
    required String title,
    required String subTitle,
    required String captionTitle,
    required String caption,
    required String describeUrl,
    required int index,
  }) {
    return ContainerCorner(
      color: Colors.white,
      borderWidth: 0,
      marginLeft: 15,
      marginRight: 15,
      borderRadius: 15,
      marginTop: 6,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWithTap(
                    title,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    marginBottom: 8,
                    marginLeft: 15,
                  ),
                  TextWithTap(
                    subTitle,
                    color: kGrey100,
                    fontSize: 17,
                    marginLeft: 15,
                  ),
                ],
              ),
              Image.asset(
                "assets/images/vip_privilege_new_open.png",
                width: 100,
                height: 100,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWithTap(
                  captionTitle,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  marginBottom: 8,
                ),
                TextWithTap(
                  caption,
                  color: kGrey100,
                  fontSize: 14,
                  marginRight: 30,
                ),
                Visibility(
                  visible: index == 11 || index == 12,
                  child: TextWithTap(
                    "vip_privilege_details_screen.note_".tr(),
                    color: kDarkOrange100,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    marginTop: 10,
                  ),
                ),
                SizedBox(height: 30),
                Visibility(
                  visible: index != 17,
                  child: Image.asset(
                    describeUrl,
                  ),
                ),
                Visibility(
                  visible: index == 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Image.asset(
                      "assets/images/special_effect_entrace_two.png",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buttons() {
    Size size = MediaQuery.of(context).size;
    return ContainerCorner(
      width: size.width,
      marginTop: 5,
      colors: [kRoseVip400, kRoseVip300],
      height: 45,
      marginLeft: 30,
      marginRight: 30,
      borderRadius: 50,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      onTap: () {
        /*if (userToGuard == null) {
          QuickHelp.showAppNotificationAdvanced(
            title: "error".tr(),
            message: "choose_guardian_screen.choose_guardian".tr(),
            context: context,
          );
        } else if (widget.currentUser!.getCredits! <
            selectedGuardianPeriod[0] * selectedGuardianPrice()) {
          QuickHelp.showAppNotificationAdvanced(
            title: "error".tr(),
            message: "guardian_and_vip_screen.coins_not_enough".tr(),
            context: context,
          );
        } else {
          activateGuardian();
        }*/
      },
      child: Center(
        child: TextWithTap(
          "guardian_and_vip_screen.recharge_unlock_vip".tr(),
          color: Colors.black,
        ),
      ),
    );
  }
}
