import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:trace/models/PostsModel.dart';

import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FastReelsScreen extends StatefulWidget {
  @override
  _FastReelsScreenState createState() => _FastReelsScreenState();
}

class _FastReelsScreenState extends State<FastReelsScreen> {
  List<PostsModel> _videos = [];
  int _currentVideoIndex = 0;
  VideoPlayerController? _videoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeParse();
  }

  Future<void> _initializeParse() async {
    await Parse().initialize('APPLICATION_ID', 'SERVER_URL');
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final query = QueryBuilder<PostsModel>(PostsModel());
    final response = await query.query();

    if (response.success && response.results != null) {
      setState(() {
        _videos = response.results as List<PostsModel>;
        _loadVideo(_currentVideoIndex);
      });
    }
  }

  void _loadVideo(int index) {
    if (_videoController != null) {
      _videoController!.dispose();
    }

    final videoUrl = _videos[index].get<String>('videoUrl');

    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl!))
      ..initialize().then((_) {
        setState(() {
          _isLoading = false;
          _videoController!.play();
        });
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _onVideoChanged(int index) {
    setState(() {
      _currentVideoIndex = index;
      _isLoading = true;
      _loadVideo(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _videos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical,
        onPageChanged: _onVideoChanged,
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          final thumbnailUrl = video.get<String>('thumbnailUrl');
          return Stack(
            alignment: Alignment.center,
            children: [
              if (_isLoading)
                CachedNetworkImage(
                  imageUrl: thumbnailUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              if (!_isLoading && _videoController!.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
            ],
          );
        },
      ),
    );
  }
}
