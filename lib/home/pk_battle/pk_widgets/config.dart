import 'package:flutter/material.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../prebuild_live/pk_timer.dart';

ZegoLiveStreamingPKBattleConfig pkConfig(
    {
      required String liveId,
      required Widget pointsWidget,
      required Widget showWinnerAndLoser,
      required Widget victoryWidget,
    }
) {
  return ZegoLiveStreamingPKBattleConfig(
    mixerLayout: PKGridLayout(),
    // pKBattleViewTopPadding: 100,
    // hostReconnectingBuilder: (
    //   BuildContext context,
    //   ZegoUIKitUser? host,
    //   Map<String, dynamic> extraInfo,
    // ) {
    //   return const CircularProgressIndicator(
    //     backgroundColor: Colors.red,
    //     color: Colors.purple,
    //   );
    // },
    foregroundBuilder: (
      BuildContext context,
      List<ZegoUIKitUser?> hosts,
      Map<String, dynamic> extraInfo,
    ) {
      Size size = MediaQuery.sizeOf(context);
      return SizedBox(
        width: size.width,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BattleTimer(roomID: liveId,),
                Image.asset(
                    "assets/images/live_pk_icon_vs.png",
                  height: 45,
                ),
              ],
            ),
            Positioned(
              top: 10,
                child: victoryWidget
            ),
            showWinnerAndLoser
          ],
        ),
      );
    },
    topBuilder: (
      BuildContext context,
      List<ZegoUIKitUser?> hosts,
      Map<String, dynamic> extraInfo,
    ) {
      return pointsWidget;
      /*Size size = MediaQuery.sizeOf(context);
      var pkColors = [kOrangedColor, kPurpleColor];
      var points = [myBattlePoints, hisBattlePoints];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          hosts.length,
              (index) {
            return ContainerCorner(
              width: size.width / 2,
              height: 15,
              color: pkColors[index],
              borderWidth: 0,
              child: TextWithTap(
                "${points[index]} "+"coins_and_points_screen.points_".tr(),
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
      );*/
     // return PointsDisplay(roomID: liveId, hosts: hosts,);
    },
    bottomBuilder: (
      BuildContext context,
      List<ZegoUIKitUser?> hosts,
      Map<String, dynamic> extraInfo,
    ) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          hosts.length,
              (index) {
            return ContainerCorner(
              child: TextWithTap(
                  hosts[index]!.name,
                color: Colors.white,
                fontSize: 10,
              ),
            );
          },
        ),
      );
    },
  );
}

/// two:
/// ┌───┬────┐
/// │😄 │ 😄 │
/// └───┴────┘
/// four:
/// ┌───┬───┐
/// │😄 │😄 │
/// ├───┼───┤
/// │😄 │   │
/// └───┴───┘
/// nine:
/// ┌───┬───┬───┐
/// │😄 │😄 │😄 │
/// ├───┼───┼───┤
/// │😄 │😄 │😄 │
/// ├───┼───┼───┤
/// │😄 │😄 │   │
/// └───┴───┴───┘
class PKGridLayout extends ZegoLiveStreamingPKMixerLayout {
  @override
  Size getResolution() => const Size(1080, 960);

  @override
  List<Rect> getRectList(
    int hostCount, {
    double scale = 1.0,
  }) {
    final resolution = getResolution();
    final rowCount = getRowCount(hostCount);
    final columnCount = getColumnCount(hostCount);
    final itemWidth = resolution.width / columnCount;
    final itemHeight = resolution.height / rowCount;

    final rectList = <Rect>[];
    var hostRowIndex = 0;
    var hostColumnIndex = 0;
    for (var hostIndex = 0; hostIndex < hostCount; ++hostIndex) {
      if (hostColumnIndex == columnCount) {
        hostColumnIndex = 0;
        hostRowIndex++;
      }

      rectList.add(
        Rect.fromLTWH(
          itemWidth * hostColumnIndex * scale,
          itemHeight * hostRowIndex * scale,
          itemWidth * scale,
          itemHeight * scale,
        ),
      );

      ++hostColumnIndex;
    }

    return rectList;
  }

  int getRowCount(int hostCount) {
    if (hostCount > 6) {
      return 3;
    }
    if (hostCount > 2) {
      return 2;
    }
    return 1;
  }

  int getColumnCount(int hostCount) {
    if (hostCount > 4) {
      return 3;
    }
    return 2;
  }
}
