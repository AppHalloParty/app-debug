import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'widgets/quit_button.dart';
import 'widgets/stop_button.dart';

class PKV2Surface extends StatefulWidget {
  final ValueNotifier<Map<String, List<String>>>
      requestingHostsMapRequestIDNotifier;
  final ValueNotifier<String> requestIDNotifier;
  final ValueNotifier<ZegoLiveStreamingState> liveStateNotifier;

  const PKV2Surface({
    Key? key,
    required this.requestIDNotifier,
    required this.liveStateNotifier,
    required this.requestingHostsMapRequestIDNotifier,
  }) : super(key: key);

  @override
  State<PKV2Surface> createState() => _PKV2SurfaceState();
}

class _PKV2SurfaceState extends State<PKV2Surface> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZegoLiveStreamingState>(
      valueListenable: widget.liveStateNotifier,
      builder: (context, state, _) {
        const baseYPos = 50;

        final canPK = state != ZegoLiveStreamingState.idle;
        return canPK
            ? Stack(children: [
                Positioned(
                  bottom: baseYPos + 3 * 30 + 3 * 5,
                  right: 1,
                  child: PKQuitButton(
                    liveStateNotifier: widget.liveStateNotifier,
                    requestingHostsMapRequestIDNotifier:
                        widget.requestingHostsMapRequestIDNotifier,
                  ),
                ),
                Positioned(
                  bottom: baseYPos + 2 * 30 + 2 * 5,
                  right: 1,
                  child: PKStopButton(
                    liveStateNotifier: widget.liveStateNotifier,
                    requestingHostsMapRequestIDNotifier:
                        widget.requestingHostsMapRequestIDNotifier,
                  ),
                ),
                // Positioned(
                //   bottom: baseYPos,
                //   right: 1,
                //   child: PKJoinWidget(
                //     liveController: widget.liveController,
                //     requestingHostsMapRequestIDNotifier:
                //         widget.requestingHostsMapRequestIDNotifier,
                //   ),
                // ),

              ])
            : Container();
      },
    );
  }
}
