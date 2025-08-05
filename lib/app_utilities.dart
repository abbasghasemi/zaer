import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class FlutterUtils {
  static bool isBrowser() {
    return kIsWeb;
  }

  static bool isWindows() {
    if (isBrowser()) {
      return false;
    }
    return Platform.isWindows;
  }

  static bool isIOS() {
    if (isBrowser()) {
      return false;
    }
    return Platform.isIOS;
  }

  static bool isAndroid() {
    if (isBrowser()) {
      return false;
    }
    return Platform.isAndroid;
  }

  static String platformName() {
    if (isBrowser()) return "web";
    if (isAndroid()) return "android";
    if (isIOS()) return "ios";
    return "?";
  }

  static PageRoute<T> pageRoute<T>(Widget activity, {String? name}) {
    final RouteSettings? settings;
    if (isBrowser()) {
      settings = RouteSettings(name: name);
    } else {
      settings = null;
    }
    return isIOS() ? CupertinoPageRoute(builder: (context) => activity) : MaterialPageRoute(builder: (context) => activity, settings: settings);
  }

  static Future<T?> showDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Duration transitionDuration = const Duration(milliseconds: 200),
    String? barrierLabel,
  }) {
    return showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, widget) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(a1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(a1),
            child: builder.call(context),
          ),
        );
      },
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: transitionDuration,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, a1, a2) => Container(),
    );
  }
}
