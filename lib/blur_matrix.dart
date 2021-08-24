library blur_matrix;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Animate colors and give them to BlurMatrix
// The animation simply lerps colors row by row, from a color to the next one
class BlurMatrixAnimate extends StatefulWidget {
  /// 2D color matrix
  final List<List<Color>> colors;

  // Duration of the animation
  final Duration duration;

  const BlurMatrixAnimate({
    Key? key,
    required this.colors,
    this.duration: const Duration(seconds: 3),
  })  : assert(colors.length > 0, 'The color matrix must be at least 2x1'),
        super(key: key);

  @override
  _BlurMatrixAnimateState createState() => _BlurMatrixAnimateState();
}

class _BlurMatrixAnimateState extends State<BlurMatrixAnimate>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<List<Color>> m;

  @override
  void dispose() {
    _animation.removeListener(_animationListener);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  /// intercept hot reload and reset the parameters
  @override
  void reassemble() {
    super.reassemble();
    _animation.removeListener(_animationListener);
    _controller.dispose();
    _init();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  _animationListener() {
    setState(() {
      calcColors();
    });
  }

  /// initialize matrix colors and animation
  _init() {
    m = List.generate(
        widget.colors.length, (index) => []..addAll(widget.colors[index]));

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
      ..addListener( _animationListener );

    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlurMatrix(
      colors: m,
    );
  }

  /// compute color from a to b based on animation
  Color _lerp(Color a, Color b) {
    return Color.lerp(a, b, _controller.value) ?? Colors.transparent;
  }

  calcColors() {
    Color a, b;
    for (int y = 0; y < widget.colors.length; y++) {
      int x;
      for (x = 0; x < widget.colors[y].length - 1; x++) {
        a = widget.colors[y][x];
        b = widget.colors[y][x + 1];
        m[y][x] = _lerp(a, b);
      }
      m[y][x] = _lerp(widget.colors[y][x], widget.colors[y][0]);
    }
  }
}

/// This widget takes the given colors matrix and creates a little bitmap.
/// When enlarging the bitmap the result will be this
class BlurMatrix extends StatelessWidget {
  /// List of colors used to create the bitmap
  final List<List<Color>> colors;

  const BlurMatrix({
    Key? key,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int rows = colors.length;
    int cols = colors.elementAt(0).length;
    return FutureBuilder<dynamic>(
      future: makeImage(cols, rows),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RawImage(
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
            image: snapshot.data,
          );
        } else {
          return Container();
        }
      },
    );
  }

  /// if !isWeb returns ui.Image
  /// else an Image
  Future<dynamic> makeImage(int cols, int rows) {
    final c = Completer<dynamic>();
    Uint32List pixels = Uint32List(rows * cols);
    int i = 0;
    colors.forEach((row) {
      row.forEach((col) {
        // Color.value is in abgr8888 format
        // Must be converted to rgba8888
        pixels[i] = (((col.alpha & 0xff) << 24) |
                ((col.blue & 0xff) << 16) |
                ((col.green & 0xff) << 8) |
                ((col.red & 0xff) << 0)) &
            0xFFFFFFFF;
        i++;
      });
    });

    // this doesn't work on web: https://github.com/flutter/flutter/issues/45190
    // it never complete
    // Use this on other platforms because it's faster
    if (!kIsWeb)
      ui.decodeImageFromPixels(
        pixels.buffer.asUint8List(),
        cols,
        rows,
        ui.PixelFormat.rgba8888,
        c.complete,
      );
    else {
      // so use decodeImageFromList which need an encoded image
      final header = RGBA32BitmapHeader(cols * rows * 4, cols, rows)
        ..applyContent(pixels.buffer.asUint8List());

      ui.decodeImageFromList(header.headerIntList, (ui.Image img) {
        c.complete(img);
      });
    }

    return c.future;
  }
}

/// class to compose an uncompressed bmp image
class RGBA32BitmapHeader {
  static const int RGBA32HeaderSize = 122;
  final int contentSize;
  late Uint8List headerIntList;

  int get imgLength => contentSize + RGBA32HeaderSize;

  RGBA32BitmapHeader(this.contentSize, int width, int height) {
    headerIntList = Uint8List(imgLength);

    final ByteData bd = headerIntList.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, imgLength, Endian.little);
    bd.setInt32(0xa, RGBA32HeaderSize, Endian.little);
    bd.setUint32(0xe, 108, Endian.little);
    bd.setUint32(0x12, width, Endian.little);
    bd.setUint32(0x16, -height, Endian.little);
    bd.setUint16(0x1a, 1, Endian.little);
    bd.setUint32(0x1c, 32, Endian.little); // pixel size
    bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
    bd.setUint32(0x22, contentSize, Endian.little);
    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3a, 0x0000ff00, Endian.little);
    bd.setUint32(0x3e, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);
  }

  void applyContent(Uint8List contentIntList) {
    headerIntList.setRange(
      RGBA32HeaderSize,
      imgLength,
      contentIntList,
    );
  }
}
