import 'dart:io';

class VideoEditorModel {

  File? videoFile;
  String? coverPath;

  VideoEditorModel({this.videoFile, this.coverPath});

  File? getVideoFile() {
    return videoFile;
  }

  void setVideoFile(File file) {
    this.videoFile = file;
  }

  String? getCoverPath() {
    return coverPath;
  }

  void setCoverPath(String path) {
    this.coverPath = path;
  }
}