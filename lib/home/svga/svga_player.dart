import 'package:flutter/material.dart';
import 'package:svgaplayer_flutter_rhr/player.dart';

class SvgaPlayer extends StatefulWidget {
  const SvgaPlayer({super.key});

  @override
  State<SvgaPlayer> createState() => _SvgaPlayerState();
}

class _SvgaPlayerState extends State<SvgaPlayer> with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
