import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsPage extends StatefulWidget {
  @override
  _ReelsPageState createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final List<String> _videoUrls = [
    'https://cdn.teego.live/video_file_kVDrv3qUmf_723_1492672097.mp4',
    'https://cdn.teego.live/video_file_qwjhh68Zdq_376_1929041614.mp4',
    'https://cdn.teego.live/video_file_qwjhh68Zdq_578_1988425057.mp4',
    'https://cdn.teego.live/video_file_qwjhh68Zdq_602_1842582329.mp4',
    'https://cdn.teego.live/video_file_Gw4j5gCZTS_751_1503887187.mp4',
    'https://cdn.teego.live/video_file_l3rWlG9to8_955_1258012996.mp4',
  ];

  late List<VideoPlayerController> _controllers;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controllers = _videoUrls.map((url) => VideoPlayerController.networkUrl(Uri(scheme: url))).toList();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: _controllers.length,
          scrollDirection: Axis.vertical,
          onPageChanged: (index){
            setState(() => _currentIndex = index);

            if(_currentIndex == index){
              _controllers[index].play();
            } else {
              _controllers[index].pause();
            }

          },
          itemBuilder: (context, index) {
            final controller = _controllers[index];
            return FutureBuilder(
              future: controller.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
    );
  }
}