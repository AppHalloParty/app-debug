// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/utils/colors.dart';
import 'package:video_player/video_player.dart';

import '../../helpers/quick_help.dart';

class VideoPlayerScreen extends StatefulWidget {
  static String route = "/video/player";
  UserModel? currentUser;
  File? video;
  VideoPlayerScreen(
      {this.currentUser,
        this.video,
        Key? key})
      : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoPlayerController;
  bool isVideoReady = false;
  bool showPlayBtn = false;
  bool showPauseBtn = false;
  bool alreadyShown = false;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.file(widget.video!)
      ..initialize().then((value) {
        videoPlayerController.play();
        videoPlayerController.setVolume(0.5);
        setState(() {
          isVideoReady = true;
        });
      })
      ..setLooping(true)
      ..addListener(() {
        setState(() {
          if (videoPlayerController.value.position.inSeconds > 0 &&
              videoPlayerController.value.position.inSeconds ==
                  videoPlayerController.value.duration.inSeconds ~/ 2) {}
          if (videoPlayerController.value.position.inSeconds == 0) {
            alreadyShown = false;
          }
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    VideoProgressColors colors = VideoProgressColors(
      bufferedColor: Colors.white.withOpacity(0.5),
      playedColor: kPrimaryColor,
      backgroundColor: Colors.white.withOpacity(0.3),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kTransparentColor,
        leading: ContainerCorner(
          borderRadius: 50,
          color: Colors.black,
            child: BackButton(color: Colors.white,)
        ),
      ),
      body: videoPlayerController.value.isInitialized
          ? ContainerCorner(
              width: size.width,
              height: size.height,
              color: Colors.black,
              borderWidth: 0,
              onTap: () => _playAndPause(),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  AspectRatio(
                    aspectRatio: videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(videoPlayerController),
                  ),
                  Visibility(
                    visible: showPlayBtn,
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white.withOpacity(0.5),
                      size: size.width / 4,
                    ),
                  ),
                  Visibility(
                    visible: showPauseBtn,
                    child: Icon(
                      Icons.pause,
                      color: Colors.white.withOpacity(0.5),
                      size: size.width / 4,
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: VideoProgressIndicator(
                        videoPlayerController,
                        allowScrubbing: true,
                        colors: colors,
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QuickHelp.appLoading(),
              ],
            ),
    );
  }

  void changeVideoSpeed(double speed) {
    videoPlayerController.setPlaybackSpeed(speed);
  }

  _playAndPause() {
    setState(() {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
        showPauseBtn = true;
      } else {
        videoPlayerController.play();
        showPlayBtn = true;
        showPauseBtn = false;
      }
    });
    _hidePlayAndPauseBtn();
  }

  _hidePlayAndPauseBtn() {
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        showPlayBtn = false;
      });
    });
  }
}
