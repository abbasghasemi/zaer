import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:zaer/routes_management.dart';

extension ContextExt on BuildContext {
  void singlePop<T extends Object?>([T? result]) {
    if (Navigator.canPop(this)) Navigator.pop(this, result);
  }

  void finish() {
    while (Navigator.canPop(this)) {
      Navigator.pop(this);
    }
  }

  Future<T?> navigate<T extends Object?, TO extends Object?>(
    String name, {
    TO? result,
    replace = false,
    replaceAll = false,
    Map<String, dynamic>? arguments,
  }) {
    PageRoute<T> route = RoutesManagement.generateRoute(name, arguments);
    if (replaceAll) {
      return Navigator.of(this).pushAndRemoveUntil(
        route,
        (Route<dynamic> route) => false,
      );
    }
    return replace ? Navigator.of(this).pushReplacement(route) : Navigator.of(this).push(route);
  }
}

enum DisplaySize {
  mobile,
  tablet,
  desktop,
}

extension DisplaySizeScreen on MediaQueryData {
  DisplaySize get displaySize {
    if (size.width < 600) {
      return DisplaySize.mobile;
    } else if (size.width <= 1240) {
      return DisplaySize.tablet;
    }
    return DisplaySize.desktop;
  }

  bool get isPortrait => orientation == Orientation.portrait;
}
extension ScrollNotificationExt on ScrollNotification {
  /// Check if this view can be scrolled vertically in a certain direction.
  ///
  /// @param direction Negative to check scrolling up, positive to check scrolling down.
  /// @return true if this view can be scrolled in the specified direction, false otherwise.
  bool canScrollVertically(int direction) {
    if (direction < 0) return metrics.pixels == 0;
    return metrics.maxScrollExtent - metrics.pixels == 0;
  }
}

extension UserScrollNotificationExt on UserScrollNotification {

  bool scrollForwarded() {
    return direction == ScrollDirection.forward;
  }

  bool scrollReversed() {
    return direction == ScrollDirection.reverse;
  }

  bool scrollIdle() {
    return direction == ScrollDirection.idle;
  }
}
