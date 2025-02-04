// ignore_for_file: must_be_immutable

import 'package:advstory/advstory.dart';
import 'package:flutter/material.dart';
import 'package:trace/models/UserModel.dart';

class AllStoriesScreen extends StatefulWidget {
  UserModel? currentUser;
  AllStoriesScreen({this.currentUser, Key? key}) : super(key: key);

  @override
  State<AllStoriesScreen> createState() => _AllStoriesScreenState();
}

class _AllStoriesScreenState extends State<AllStoriesScreen> {
  AdvStoryController storyController = AdvStoryController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AdvStory(
        storyCount: 4,
        controller: storyController,
        storyBuilder: (storyIndex) => Story(
          contentCount: 2,
          contentBuilder: (contentIndex) => ImageContent(
            url: widget.currentUser!.getAvatar!.url!,
            duration: const Duration(seconds: 5),
          ),
        ),
        trayBuilder: (index) => AdvStoryTray(
          shape: BoxShape.circle,
          size: const Size(80, 80),
          borderRadius: 10,
          url: widget.currentUser!.getAvatar!.url!,
        ),
      ),
    );
  }
}
