// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/utils/colors.dart';

import '../../helpers/quick_help.dart';
import '../../models/MedalsModel.dart';
import '../../models/UserModel.dart';
import '../../ui/button_widget.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';

class MedalScreen extends StatefulWidget {
  UserModel? currentUser;

  MedalScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<MedalScreen> createState() => _MedalScreenState();
}

class _MedalScreenState extends State<MedalScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: kTransparentColor,
        elevation: 1.5,
        centerTitle: true,
        title: TextWithTap(
          "medal_screen.medal_".tr(),
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            "assets/images/medal_bg.png",
            height: size.height,
            width: size.width,
          ),
          feedbacks()
        ],
      ),
    );
  }

  Widget feedbacks() {
    Size size = MediaQuery.of(context).size;

    QueryBuilder<MedalsModel> queryBuilder =
        QueryBuilder<MedalsModel>(MedalsModel());
    queryBuilder.whereEqualTo(
        MedalsModel.keyAccuserId, widget.currentUser!.objectId);

    return ParseLiveListWidget<MedalsModel>(
      query: queryBuilder,
      reverse: false,
      lazyLoading: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.zero,
      childBuilder: (BuildContext context,
          ParseLiveListElementSnapshot<MedalsModel> snapshot) {
        if (snapshot.hasData) {
          MedalsModel medal = snapshot.loadedData!;
          return ButtonWidget(
            onTap: () {},
            child: TextWithTap(
              medal.objectId.toString(),
              color: Colors.white,
            ),
          );
        } else {
          return Container();
        }
      },
      listLoadingElement: QuickHelp.appLoading(),
      queryEmptyElement: ContainerCorner(
        width: size.width,
        height: size.height,
        borderWidth: 0,
        child: Center(
            child: Image.asset(
          "assets/images/szy_kong_icon.png",
          height: size.width / 2,
        )),
      ),
    );
  }
}
