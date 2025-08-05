// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsImgsGen {
  const $AssetsImgsGen();

  /// File path: assets/imgs/a1.jpeg
  AssetGenImage get a1 => const AssetGenImage('assets/imgs/a1.jpeg');

  /// File path: assets/imgs/a2.jpg
  AssetGenImage get a2 => const AssetGenImage('assets/imgs/a2.jpg');

  /// File path: assets/imgs/a3.jpeg
  AssetGenImage get a3 => const AssetGenImage('assets/imgs/a3.jpeg');

  /// File path: assets/imgs/a4.jpg
  AssetGenImage get a4 => const AssetGenImage('assets/imgs/a4.jpg');

  /// File path: assets/imgs/a5.jpg
  AssetGenImage get a5 => const AssetGenImage('assets/imgs/a5.jpg');

  /// File path: assets/imgs/a6.jpeg
  AssetGenImage get a6 => const AssetGenImage('assets/imgs/a6.jpeg');

  /// File path: assets/imgs/a7.jpeg
  AssetGenImage get a7 => const AssetGenImage('assets/imgs/a7.jpeg');

  /// File path: assets/imgs/a8.png
  AssetGenImage get a8 => const AssetGenImage('assets/imgs/a8.png');

  /// File path: assets/imgs/a9.png
  AssetGenImage get a9 => const AssetGenImage('assets/imgs/a9.png');

  /// File path: assets/imgs/b1.jpeg
  AssetGenImage get b1 => const AssetGenImage('assets/imgs/b1.jpeg');

  /// File path: assets/imgs/b2.png
  AssetGenImage get b2 => const AssetGenImage('assets/imgs/b2.png');

  /// File path: assets/imgs/b3.jpg
  AssetGenImage get b3 => const AssetGenImage('assets/imgs/b3.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
    a1,
    a2,
    a3,
    a4,
    a5,
    a6,
    a7,
    a8,
    a9,
    b1,
    b2,
    b3,
  ];
}

class $AssetsLottieGen {
  const $AssetsLottieGen();

  /// File path: assets/lottie/flag.json
  String get flag => 'assets/lottie/flag.json';

  /// List of all assets
  List<String> get values => [flag];
}

class Assets {
  const Assets._();

  static const $AssetsImgsGen imgs = $AssetsImgsGen();
  static const $AssetsLottieGen lottie = $AssetsLottieGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
