import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zaer/app/date_storage.dart';
import 'package:zaer/gen/fonts.gen.dart';

class ThemeController {
  static const double defRadius = 7;
  static const double filedHeightSize = 48;
  static bool isDark = false;

  final Color surfaceColor;
  final Color backgroundColor;
  final Color backgroundSecondaryColor;
  final Color colorPrimary;
  final Color secondary;
  final Color textTitleColor;
  final Color textColor;
  final Color textColorSecondary;

  static ThemeController theme() =>
      isDark ? ThemeController.dark() : ThemeController.light();

  ThemeController.dark()
    : surfaceColor = const Color(0xFF171A1E),
      backgroundColor = const Color(0xFF0F1114),
      backgroundSecondaryColor = const Color(0xFF20242A),
      colorPrimary = const Color(0xFFFF0000),
      secondary = const Color(0xff2175f3),
      textTitleColor = Colors.white,
      textColor = const Color.fromARGB(255, 236, 236, 236),
      textColorSecondary = const Color.fromARGB(255, 255, 0, 0) {
    isDark = true;
  }

  ThemeController.light()
    : surfaceColor = const Color.fromARGB(255, 227, 232, 235),
      backgroundColor = const Color.fromARGB(255, 250, 250, 250),
      backgroundSecondaryColor = Colors.white,
      colorPrimary = const Color(0xFFFF0000),
      secondary = const Color(0xff2175f3),
      textTitleColor = Colors.black,
      textColor = const Color.fromARGB(255, 21, 21, 21),
      textColorSecondary = const Color.fromARGB(255, 82, 103, 119) {
    isDark = false;
  }

  ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: colorPrimary,
      primarySwatch: _genMaterialColor(colorPrimary),
      datePickerTheme: DatePickerThemeData(
        headerBackgroundColor: colorPrimary,
        backgroundColor: surfaceColor,
        rangePickerBackgroundColor: surfaceColor,
        rangePickerHeaderForegroundColor: textTitleColor,
        rangeSelectionBackgroundColor: colorPrimary.withAlpha(40),
        headerForegroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: colorPrimary,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colorPrimary,
        secondary: secondary,
        surface: surfaceColor,
        onSurfaceVariant: textColor,
        error: const Color(0xffef5350),
        tertiary: backgroundSecondaryColor,
      ),
      fontFamily: FontFamily.iranSans,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textTitleColor,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorPrimary,
        selectionColor: tintColor(colorPrimary, 0.7),
      ),
      textTheme: TextTheme(
        displaySmall: const TextStyle(color: Colors.white),
        // displayMedium: TextStyle(),
        // displayLarge: TextStyle(),
        // headlineSmall: TextStyle(),
        // headlineMedium: TextStyle(),
        // headlineLarge: TextStyle(),
        titleSmall: TextStyle(color: textTitleColor),
        titleMedium: TextStyle(color: textTitleColor),
        titleLarge: TextStyle(color: textTitleColor, fontSize: 18),
        // appBar
        bodySmall: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        // body
        bodyLarge: TextStyle(color: textColor),
        // input
        labelSmall: TextStyle(color: textTitleColor),
        labelMedium: TextStyle(color: textTitleColor),
        labelLarge: TextStyle(color: textTitleColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        // focusedBorder:  OutlineInputBorder(),
        filled: true,
        hintStyle: TextStyle(color: colorPrimary),
        fillColor: surfaceColor,
      ),
      cardTheme: CardThemeData(
        shape: const RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(defRadius)),
        ),
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: backgroundSecondaryColor,
        shadowColor: textColor.withOpacity(0.4),
        elevation: 6,
      ),
      popupMenuTheme: PopupMenuThemeData(color: backgroundSecondaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStatePropertyAll(colorPrimary),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defRadius),
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(100, filedHeightSize)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          // splashFactory: NoSplash.splashFactory,
          foregroundColor: WidgetStatePropertyAll(colorPrimary),
          backgroundColor: WidgetStateProperty.resolveWith(_textBtnBg),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(defRadius),
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(100, filedHeightSize)),
        ),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: backgroundColor,
        backgroundColor: surfaceColor,
      ),
      dividerTheme: DividerThemeData(color: textTitleColor.withAlpha(50)),
    );
  }

  static final Set<WidgetState> _states = <WidgetState>{
    WidgetState.pressed,
    // WidgetState.hovered,
    WidgetState.focused,
  };

  Color _textBtnBg(Set<WidgetState> states) {
    if (states.any(_states.contains)) {
      return colorPrimary.withOpacity(0.2);
    }
    return Colors.transparent;
  }

  MaterialColor _genMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: _shadeColor(color, 0.1),
      700: _shadeColor(color, 0.2),
      800: _shadeColor(color, 0.3),
      900: _shadeColor(color, 0.4),
    });
  }

  int _tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  Color tintColor(Color color, double factor) => Color.fromRGBO(
    _tintValue(color.red, factor),
    _tintValue(color.green, factor),
    _tintValue(color.blue, factor),
    1,
  );

  int _shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  Color _shadeColor(Color color, double factor) => Color.fromRGBO(
    _shadeValue(color.red, factor),
    _shadeValue(color.green, factor),
    _shadeValue(color.blue, factor),
    1,
  );
}

class ThemeChangeListenable with ChangeNotifier {
  bool isDark;

  ThemeChangeListenable(this.isDark);

  void change(DataStorage ds) {
    isDark = !isDark;
    ds.isDarkMode = isDark;
    notifyListeners();
  }
}
