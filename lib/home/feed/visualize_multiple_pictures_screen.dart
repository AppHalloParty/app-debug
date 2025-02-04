// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_zoom_widget/custom_zoom_widget.dart';
import 'package:flutter/material.dart';
import 'package:trace/ui/text_with_tap.dart';

class VisualizeMultiplePicturesScreen extends StatefulWidget {
  int? initialIndex;
  List<File>? selectedPictures;
  List<dynamic>? picturesFromDataBase;
  static String route = "/show/pictures";

  VisualizeMultiplePicturesScreen(
      {this.picturesFromDataBase,
      this.selectedPictures,
      this.initialIndex,
      Key? key})
      : super(key: key);

  @override
  State<VisualizeMultiplePicturesScreen> createState() =>
      _VisualizeMultiplePicturesScreenState();
}

class _VisualizeMultiplePicturesScreenState
    extends State<VisualizeMultiplePicturesScreen> {
  PageController pageController = PageController(initialPage: 0);
  int? totalOfPictures;

  bool blockScroll = false;

  @override
  Widget build(BuildContext context) {
    pageController = PageController(initialPage: widget.initialIndex ?? 0);

    if (widget.selectedPictures != null) {
      totalOfPictures = widget.selectedPictures!.length;
    } else {
      totalOfPictures = widget.picturesFromDataBase!.length;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          children: [
            TextWithTap(
              "${(widget.initialIndex ?? 0) + 1} / $totalOfPictures",
              color: Colors.white.withOpacity(0.8),
            ),
          ],
        ),
        leading: BackButton(
          color: Colors.white.withOpacity(0.6),
        ),
      ),
      body: PageView.builder(
        itemCount: totalOfPictures,
        controller: pageController,
        physics: blockScroll ? NeverScrollableScrollPhysics() : ScrollPhysics(),
        itemBuilder: (context, index) {
          if (widget.picturesFromDataBase == null) {
            return Column(
              children: [
                CustomZoomWidget(
                    child: Image.file(widget.selectedPictures![index],),
                    minScale: 0.8,
                    maxScale: 4,
                    resetDuration: const Duration(milliseconds: 200),
                    boundaryMargin: const EdgeInsets.only(bottom: 0),
                    clipBehavior: Clip.none,
                    useOverlay: true,
                    maxOverlayOpacity: 0.5,
                    overlayColor: Colors.black,
                    fingersRequiredToPinch: 2
                ),
              ],
            );
          } else {
            return CustomZoomWidget(
                child: CachedNetworkImage(
                  imageUrl: widget.picturesFromDataBase![index].url,
                ),
                minScale: 0.8,
                maxScale: 4,
                resetDuration: const Duration(milliseconds: 200),
                boundaryMargin: const EdgeInsets.only(bottom: 0),
                clipBehavior: Clip.none,
                useOverlay: true,
                maxOverlayOpacity: 0.5,
                overlayColor: Colors.black,
                fingersRequiredToPinch: 2,
                twoFingersOn: () => setState(() => blockScroll = true),
                twoFingersOff: () => Future.delayed(
                      CustomZoomWidget.defaultResetDuration,
                      () => setState(() => blockScroll = false),
                    ),
            );
          }
        },
        onPageChanged: (newIndex) {
          setState(() {
            widget.initialIndex = newIndex;
          });
        },
      ),
    );
  }
}
