// ignore_for_file: must_be_immutable

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:trace/home/prebuild_live/pk_points_controller.dart';
import 'package:zego_uikit/zego_uikit.dart';

import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';
import '../controller/controller.dart';

Controller controller = Get.put(Controller());

class PointsDisplay extends StatefulWidget {
  final String roomID;
  List<ZegoUIKitUser?> hosts;

  PointsDisplay({
    required this.roomID,
    required this.hosts
  });


  @override
  _PointsDisplayState createState() => _PointsDisplayState();
}

class _PointsDisplayState extends State<PointsDisplay> {

  @override
  void initState() {
    super.initState();
    PointsController.initialize(widget.roomID, _updatePoints);
  }

  @override
  void dispose() {
    PointsController.dispose();
    super.dispose();
  }

  void _updatePoints(int myPoints, int hisPoints) {
    controller.myBattlePoints.value = myPoints;
    controller.hisBattlePoints.value = hisPoints;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    var pkColors = [kOrangedColor, kPurpleColor];
    return Obx((){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          widget.hosts.length,
              (index) {
            return ContainerCorner(
              width: size.width / 2,
              height: 15,
              color: pkColors[index],
              borderWidth: 0,
              child: TextWithTap(
                "${index == 0 ? controller.myBattlePoints.value : controller.hisBattlePoints.value} "+"coins_and_points_screen.points_".tr(),
                color: Colors.white,
                alignment: index == 1 ? Alignment.centerRight : Alignment.centerLeft,
                fontSize: 12,
                marginRight: index == 1 ? 10 : 0,
                marginLeft: index == 0 ? 10 : 0,
                fontWeight: FontWeight.w900,
              ),
            );
          },
        ),
      );
    });
  }
}
