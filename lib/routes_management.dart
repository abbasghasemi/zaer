import 'package:flutter/cupertino.dart';
import 'package:zaer/app_utilities.dart';
import 'package:zaer/ui/launher/launcher.dart';
import 'package:zaer/ui/main/main.dart';
import 'package:zaer/ui/report/report.dart';
import 'package:zaer/ui/room/room.dart';

class RoutesManagement {
  static const String _prefix = "";
  static const String launcher = "launcher";
  static const String main = "";
  static const String room = "room";
  static const String zaer = "zaer";
  static const String report = "report";

  static PageRoute<T> generateRoute<T>(
    String name, [
    Map<String, dynamic>? arguments,
  ]) {
    return FlutterUtils.pageRoute(
      generateActivity(name, arguments),
      name: _prefix + name,
    );
  }

  static Widget generateActivity(
    String name, [
    Map<String, dynamic>? arguments,
  ]) {
    switch (name) {
      case launcher:
        return const LauncherActivity();
      case main:
        return const MainActivity();
      case room:
        return const RoomActivity();
      case zaer:
        return const ZaerInfo(true);
      case report:
        return const ReportActivity();
      default:
        throw Exception("Not found '$name' route.");
    }
  }
}
