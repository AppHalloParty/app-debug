import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/home/coins/refill_coins_screen.dart';
import 'package:trace/home/menu/blocked_users_screen.dart';
import 'package:trace/home/menu/get_money_screen.dart';
import 'package:trace/home/menu/invited_friends.dart';
import 'package:trace/home/menu/referral_program_screen.dart';
import 'package:trace/home/menu/settings_screen.dart';
import 'package:trace/home/profile/profile_screen.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/ui/button_widget.dart';
import 'package:trace/ui/button_with_icon.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';

// ignore: must_be_immutable
class ProfileMenuScreen extends StatefulWidget {
  static String route = '/profile/menu';

  UserModel? userModel;

  ProfileMenuScreen({Key? key, this.userModel}) : super(key: key);

  @override
  _ProfileMenuScreenState createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {

  @override
  Widget build(BuildContext context) {

    return ToolBar(
      leftButtonIcon: Icons.arrow_back,
      onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context, result: widget.userModel),
      child: SafeArea(
        child: ContainerCorner(
          color: QuickHelp.isDarkMode(context)
              ? kContentColorLightTheme
              : kGreyColor0,
          child: ListView(
            children: [
              ButtonWidget(
                marginTop: 0,
                marginBottom: 10,
                padding: EdgeInsets.all(5),
                color: QuickHelp.isDarkMode(context)
                    ? kContentColorLightTheme
                    : kContentColorDarkTheme,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          QuickActions.avatarWidget(
                            widget.userModel!,
                            width: 45,
                            height: 45,
                            margin: EdgeInsets.only(
                                bottom: 0, top: 0, left: 15, right: 5),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWithTap(
                                widget.userModel!.getFullName.toString(),
                                marginLeft: 10,
                                fontSize: 20,
                                marginBottom: 5,
                                fontWeight: FontWeight.w900,
                                color: QuickHelp.isDarkMode(context)
                                    ? kContentColorDarkTheme
                                    : kContentColorLightTheme,
                              ),
                              ContainerCorner(
                                marginLeft: 10,
                                color: kTransparentColor,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/ic_diamond.svg",
                                      height: 30,
                                      width: 30,
                                    ),
                                    TextWithTap(
                                      widget.userModel!.getDiamonds.toString(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      marginRight: 20,
                                      color: kGrayColor,
                                    ),
                                    SvgPicture.asset(
                                      "assets/svg/ic_menu_followers.svg",
                                      width: 20,
                                    ),
                                    TextWithTap(
                                      widget.userModel!.getFollowers!.length
                                          .toString(),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      marginLeft: 5,
                                      color: kGrayColor,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: kGrayColor,
                      ),
                    ),
                  ],
                ),
                onTap: () async {

                  UserModel? user = await QuickHelp.goToNavigatorScreenForResult(
                      context,
                      ProfileScreen(
                        currentUser: widget.userModel,
                      ));

                  if(user != null){
                    widget.userModel = user;
                  }
                },
              ),
              //profilOptions("profile_screen.op_live_family".tr(),"assets/svg/ic_tab_following_default.svg", ),
             /* profilOptions(
                "profile_screen.op_top_giftters".tr(),
                "assets/svg/ic_menu_gifters.svg",
                GiftersScreen(currentUser: widget.userModel,),
              ),*/
              /*profilOptions(
                "profile_screen.op_statistic".tr(),
                "assets/svg/ic_statistics_menu.svg",
                route: StatisticsScreen.route,
                arguments:
                    widget.userModel != null ? widget.userModel : currentUser,
              ),*/
              //profilOptions("profile_screen.op_subscriptions".tr(),"assets/svg/ic_tab_following_default.svg", ),

              widget.userModel!.getInvitedUsers!.length > 0 ?

              profilOptions(
                "profile_screen.op_invite_friends".tr(),
                "assets/svg/ic_referral_menu.svg",
                InvitedUsers(currentUser: widget.userModel),
              ) :
              profilOptions(
                "profile_screen.op_invite_friends".tr(),
                "assets/svg/ic_referral_menu.svg",
                  ReferralScreen(currentUser: widget.userModel,),
              ),
              profilOptions(
                "profile_screen.op_blocked_users".tr(),
                "assets/svg/ic_blocked_menu.svg",
                  BlockedUsersScreen(currentUser: widget.userModel,),
              ),
              coinBalanceOption(
                "profile_screen.op_refill_coin_balance".tr(),
                "assets/svg/ic_refill_menu.svg",
                route: RefillCoinsScreen.route,
              ),
              getMoneyOption(
                "profile_screen.op_get_money".tr(),
                "assets/svg/ic_redeem_menu.svg",
                GetMoneyScreen(currentUser: widget.userModel),
              ),
              /*instagramOption(
                "profile_screen.op_connect_instagram".tr(),
                "profile_screen.insta_description".tr(),
                "assets/svg/ic_share_instagram.svg",
              ),*/
              profilOptions(
                "profile_screen.op_settings".tr(),
                "assets/svg/ic_settings_menu.svg",
                SettingsScreen(currentUser: widget.userModel,),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profilOptions(String text, String svgIconURL, Widget widgetNav) {
    return ButtonWithIcon(
      text: text,
      iconURL: svgIconURL,
      borderRadius: 10,
      borderColor: QuickHelp.isDarkMode(context)
          ? kTabIconDefaultColor
          : kTransparentColor,
      borderWidth: 1,
      backgroundColor: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      height: 50,
      marginLeft: 10,
      marginRight: 10,
      marginBottom: 5,
      fontSize: 18,
      iconSize: 30,
      textColor:
          QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kGreyColor2,
      urlIconColor: kTabIconDefaultColor,
      mainAxisAlignment: MainAxisAlignment.start,
      onTap: () =>
          QuickHelp.goToNavigatorScreen(context, widgetNav),
    );
  }

  Widget instagramOption(String title, String description, String svgIconURL,
      {String? route}) {
    return ButtonWidget(
      color: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      borderColor: QuickHelp.isDarkMode(context)
          ? kTabIconDefaultColor
          : kTransparentColor,
      marginLeft: 10,
      marginRight: 10,
      marginTop: 10,
      height: 100,
      borderWidth: 1,
      borderRadiusAll: 10,
      marginBottom: 15,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: SvgPicture.asset(
                  svgIconURL,
                  height: 30,
                  width: 30,
                ),
              ),
              TextWithTap(
                title,
                marginLeft: 10,
                fontSize: 18,
                color: QuickHelp.isDarkMode(context)
                    ? kContentColorDarkTheme
                    : kGreyColor2,
                //color: Colors.black,
              )
            ],
          ),
          TextWithTap(
            description,
            marginLeft: 50,
            fontSize: 16,
            color: kGrayColor,
            marginRight: 10,
          ),
        ],
      ),
      onTap: () => QuickHelp.goToNavigator(context, route!),
    );
  }

  Widget coinBalanceOption(String text, String svgIconURL, {String? route}) {
    return ButtonWidget(
      borderColor: QuickHelp.isDarkMode(context)
          ? kTabIconDefaultColor
          : kTransparentColor,
      height: 50,
      marginLeft: 10,
      marginRight: 10,
      borderWidth: 1,
      marginBottom: 5,
      marginTop: 10,
      borderRadiusAll: 10,
      color: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerCorner(
            color: kTransparentColor,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(
                    svgIconURL,
                    height: 30,
                    width: 30,
                  ),
                ),
                TextWithTap(
                  text,
                  marginLeft: 10,
                  fontSize: 18,
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorDarkTheme
                      : kGreyColor2,
                  //color: Colors.black,
                ),
              ],
            ),
          ),
          ContainerCorner(
            color: kTransparentColor,
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/svg/ic_coin_inactive.svg",
                  height: 18,
                  width: 18,
                ),
                TextWithTap(
                  widget.userModel!.getCredits.toString(),
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  marginRight: 20,
                  marginLeft: 5,
                  color: QuickHelp.isDarkMode(context)
                      ? kContentColorDarkTheme
                      : kGreyColor2,
                  //color: Colors.black,
                ),
              ],
            ),
          )
        ],
      ),
      onTap: () => route == RefillCoinsScreen.route ? QuickHelp.goToNavigatorScreen(context, RefillCoinsScreen(currentUser: widget.userModel,)) : QuickHelp.goToNavigator(context, route!),
    );
  }

  Widget getMoneyOption(String text, String svgIconURL, Widget widgetNav) {
    return ButtonWidget(
      color: QuickHelp.isDarkMode(context)
          ? kContentColorLightTheme
          : kContentColorDarkTheme,
      borderColor: QuickHelp.isDarkMode(context)
          ? kTabIconDefaultColor
          : kTransparentColor,
      marginLeft: 10,
      marginRight: 10,
      borderRadiusAll: 10,
      marginBottom: 5,
      borderWidth: 1,
      padding: EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerCorner(
            color: kTransparentColor,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SvgPicture.asset(
                    svgIconURL,
                    height: 30,
                    width: 30,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWithTap(
                      text,
                      marginLeft: 10,
                      fontSize: 18,
                      color: QuickHelp.isDarkMode(context)
                          ? kContentColorDarkTheme
                          : kGreyColor2,
                      //color: Colors.black,
                    ),
                    Row(
                      children: [
                        TextWithTap(
                          QuickHelp.getDiamondsLeftToRedeem(
                              widget.userModel!.getDiamonds!),
                          marginRight: 2,
                          marginLeft: 10,
                          marginTop: 5,
                          //color: Colors.black,
                          color: QuickHelp.isDarkMode(context)
                              ? kContentColorDarkTheme
                              : kGreyColor2,
                          fontWeight: FontWeight.bold,
                          marginBottom: 5,
                          fontSize: 15,
                        ),
                        TextWithTap(
                          widget.userModel!.getPayouts! > 0
                              ? "profile_screen.get_money_for_diamonds_".tr()
                              : "profile_screen.get_money_for_diamonds".tr(),
                          marginRight: 20,
                          marginTop: 5,
                          color: QuickHelp.isDarkMode(context)
                              ? kContentColorDarkTheme
                              : kGreyColor2,
                          marginBottom: 5,
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          ContainerCorner(
            color: kTransparentColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/ic_diamond.svg",
                      height: 30,
                      width: 30,
                    ),
                    TextWithTap(
                      widget.userModel!.getDiamonds.toString(),
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      marginRight: 20,
                      marginLeft: 5,
                      color: QuickHelp.isDarkMode(context)
                          ? kContentColorDarkTheme
                          : kGreyColor2,
                      //color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
      onTap: () async {
        UserModel? user = await QuickHelp.goToNavigatorScreenForResult(context, widgetNav);

        if(user != null){
          widget.userModel = user;
        }
      }
    );
  }
}
