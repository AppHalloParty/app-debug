import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:svgaplayer_flutter_rhr/parser.dart';
import 'package:svgaplayer_flutter_rhr/player.dart';
import 'package:svgaplayer_flutter_rhr/proto/svga.pb.dart';

import '../../helpers/quick_actions.dart';
import '../../models/GiftsModel.dart';
import '../../ui/container_with_corner.dart';
import '../../ui/text_with_tap.dart';
import '../../utils/colors.dart';


class SvgaListsCreen extends StatefulWidget {
  @override
  State<SvgaListsCreen> createState() => _SvgaListsCreenState();
}

class _SvgaListsCreenState extends State<SvgaListsCreen> with TickerProviderStateMixin{
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController.unbounded(vsync: this);
  }

  // callback for register dynamicItem
  final dynamicSamples = <String, void Function(MovieEntity entity)>{
    "kingset.svga": (entity) => entity.dynamicItem
      ..setText(
          TextPainter(
              text: TextSpan(
                  text: "Hello, World!",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ))),
          "banner")
  };

  @override
  Widget build(BuildContext context) {
    Widget getGifts() {
      QueryBuilder<GiftsModel> giftQuery = QueryBuilder<GiftsModel>(GiftsModel());
      giftQuery.whereValueExists(GiftsModel.keyGiftCategories, true);
      giftQuery.whereEqualTo(GiftsModel.keyGiftCategories, GiftsModel.categorySvgaGifts);

      return ContainerCorner(
        color: kTransparentColor,
        child: ParseLiveGridWidget<GiftsModel>(
          query: giftQuery,
          crossAxisCount: 4,
          reverse: false,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          lazyLoading: false,
          //childAspectRatio: 1.0,
          shrinkWrap: true,
          listenOnAllSubItems: true,
          duration: Duration(seconds: 0),
          animationController: _animationController,
          childBuilder: (BuildContext context,
              ParseLiveListElementSnapshot<GiftsModel> snapshot) {
            GiftsModel gift = snapshot.loadedData!;
            return GestureDetector(
              //onTap: () => _checkCredits(gift, setState),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _goToSample(context, [gift.getFile!.url!]),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(2)),
                              border: Border.all(),
                            ),
                            width: 50,
                            height: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: QuickActions.photosWidget(gift.getPreview!.url),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ContainerCorner(
                      color: kTransparentColor,
                      marginTop: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/svg/ic_coin_with_star.svg",
                            width: 16,
                            height: 16,
                          ),
                          TextWithTap(
                            gift.getCoins.toString(),
                            color: Colors.black,
                            fontSize: 14,
                            marginLeft: 5,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          queryEmptyElement: QuickActions.noContentFound(context),
          gridLoadingElement: Container(
            margin: EdgeInsets.only(top: 50),
            alignment: Alignment.topCenter,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('SVGA Flutter Samples')),
      body: getGifts(),
    );

  }

  void _goToSample(context, List<String> sample) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SVGASampleScreen(
          name: sample.first,
          image: sample.last,
          dynamicCallback: dynamicSamples[sample.first]);
    }));
  }
}

class SVGASampleScreen extends StatefulWidget {
  final String? name;
  final String image;
  final void Function(MovieEntity entity)? dynamicCallback;
  const SVGASampleScreen(
      {Key? key, required this.image, this.name, this.dynamicCallback})
      : super(key: key);

  @override
  _SVGASampleScreenState createState() => _SVGASampleScreenState();
}

class _SVGASampleScreenState extends State<SVGASampleScreen>
    with SingleTickerProviderStateMixin {
  SVGAAnimationController? animationController;
  bool isLoading = true;
  Color backgroundColor = Colors.transparent;
  bool allowOverflow = true;
  // Canvaskit need FilterQuality.high
  FilterQuality filterQuality = kIsWeb ? FilterQuality.high : FilterQuality.low;
  BoxFit fit = BoxFit.contain;
  late double containerWidth;
  late double containerHeight;
  bool hideOptions = false;
  @override
  void initState() {
    super.initState();
    this.animationController = SVGAAnimationController(vsync: this);
    this._loadAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    containerWidth = math.min(350, MediaQuery.of(context).size.width);
    containerHeight = math.min(350, MediaQuery.of(context).size.height);
  }

  @override
  void dispose() {
    this.animationController?.dispose();
    this.animationController = null;
    super.dispose();
  }

  void _loadAnimation() async {
    // FIXME: may throw error on loading
    final videoItem = await _loadVideoItem(widget.image);
    if (widget.dynamicCallback != null) {
      widget.dynamicCallback!(videoItem);
    }
    if (mounted)
      setState(() {
        this.isLoading = false;
        this.animationController?.videoItem = videoItem;
        _playAnimation();
      });
  }

  void _playAnimation() {
    if (animationController?.isCompleted == true) {
      animationController?.reset();
    }
    animationController?.repeat(); // or animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.name ?? ""),
        bottom: PreferredSize(preferredSize: Size.fromHeight(70), child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text("Url: ${widget.image}",
                    style: Theme.of(context).textTheme.titleSmall)),
            if (isLoading) LinearProgressIndicator(),
          ],
        ),),
      ),
      body: ListView(
        //alignment: AlignmentDirectional.center,
        children: <Widget>[
          ContainerCorner(
            width: size.width,
            height: size.height,
            child: ColoredBox(
              color: backgroundColor,
              child: SVGAImage(
                this.animationController!,
                fit: BoxFit.fill,
                clearsAfterStop: true,
                allowDrawingOverflow: true,
                filterQuality: FilterQuality.high,
                preferredSize: Size(size.width, size.height),
              ),
            ),
          ),
          _buildOptions(context),
        ],
      ),
      floatingActionButton: isLoading || animationController!.videoItem == null
          ? null
          : FloatingActionButton.extended(
          label: Text(animationController!.isAnimating ? "Pause" : "Play"),
          icon: Icon(animationController!.isAnimating
              ? Icons.pause
              : Icons.play_arrow),
          onPressed: () {
            if (animationController?.isAnimating == true) {
              animationController?.stop();
            } else {
              _playAnimation();
            }
            setState(() {});
          }),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.black12,
      padding: EdgeInsets.all(8.0),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          showValueIndicator: ShowValueIndicator.always,
          trackHeight: 2,
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 6, pressedElevation: 4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
                onPressed: () {
                  setState(() {
                    hideOptions = !hideOptions;
                  });
                },
                icon: hideOptions
                    ? Icon(Icons.arrow_drop_up)
                    : Icon(Icons.arrow_drop_down),
                label: Text(hideOptions ? 'Show options' : 'Hide options')),
            AnimatedBuilder(
                animation: animationController!,
                builder: (context, child) {
                  return Text(
                      'Current frame: ${animationController!.currentFrame + 1}/${animationController!.frames}');
                }),
            if (!hideOptions) ...[
              AnimatedBuilder(
                  animation: animationController!,
                  builder: (context, child) {
                    return Slider(
                      min: 0,
                      max: animationController!.frames.toDouble(),
                      value: animationController!.currentFrame.toDouble(),
                      label: '${animationController!.currentFrame}',
                      onChanged: (v) {
                        if (animationController?.isAnimating == true) {
                          animationController?.stop();
                        }
                        animationController?.value =
                            v / animationController!.frames;
                      },
                    );
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Image filter quality'),
                  DropdownButton<FilterQuality>(
                    value: filterQuality,
                    onChanged: (FilterQuality? newValue) {
                      setState(() {
                        filterQuality = newValue!;
                      });
                    },
                    items: FilterQuality.values.map((FilterQuality value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Allow drawing overflow'),
                  const SizedBox(width: 8),
                  Switch(
                    value: allowOverflow,
                    onChanged: (v) {
                      setState(() {
                        allowOverflow = v;
                      });
                    },
                  )
                ],
              ),
              Text('Container options:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(' width:'),
                  Slider(
                    min: 100,
                    max: MediaQuery.of(context).size.width.roundToDouble(),
                    value: containerWidth,
                    label: '$containerWidth',
                    onChanged: (v) {
                      setState(() {
                        containerWidth = v.truncateToDouble();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(' height:'),
                  Slider(
                    min: 100,
                    max: MediaQuery.of(context).size.height.roundToDouble(),
                    label: '$containerHeight',
                    value: containerHeight,
                    onChanged: (v) {
                      setState(() {
                        containerHeight = v.truncateToDouble();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(' box fit: '),
                  const SizedBox(width: 8),
                  DropdownButton<BoxFit>(
                    value: fit,
                    onChanged: (BoxFit? newValue) {
                      setState(() {
                        fit = newValue!;
                      });
                    },
                    items: BoxFit.values.map((BoxFit value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Colors.transparent,
                  Colors.red,
                  Colors.green,
                  Colors.blue,
                  Colors.yellow,
                  Colors.black,
                ]
                    .map(
                      (e) => GestureDetector(
                    onTap: () {
                      setState(() {
                        backgroundColor = e;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: ShapeDecoration(
                        color: e,
                        shape: CircleBorder(
                          side: backgroundColor == e
                              ? const BorderSide(
                            color: Colors.white,
                            width: 3,
                          )
                              : const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future _loadVideoItem(String image) {
  Future Function(String) decoder;
  if (image.startsWith(RegExp(r'https?://'))) {
    decoder = SVGAParser.shared.decodeFromURL;
  } else {
    decoder = SVGAParser.shared.decodeFromAssets;
  }
  return decoder(image);
}