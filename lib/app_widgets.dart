import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zaer/app_utilities.dart';
import 'package:zaer/theme_controller.dart';

class AppWidgets {
  // default platform
  static Widget progressBar(BuildContext context, [Color? color]) =>
      FlutterUtils.isIOS()
      ? CupertinoActivityIndicator(
          radius: 20,
          color: color ?? Theme.of(context).colorScheme.secondary,
        )
      : CircularProgressIndicator(
          color: color ?? Theme.of(context).colorScheme.secondary,
          strokeWidth: 3,
        );

  static Widget alertDialog(
    BuildContext context, {
    Widget? title,
    Widget? content,
    Map<String, VoidCallback> actions = const <String, Function()>{},
  }) {
    final actions_ = <Widget>[];
    actions.forEach((key, value) {
      actions_.add(
        TextButton(
          style: FlutterUtils.isIOS()
              ? ButtonStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                )
              : null,
          onPressed: value,
          child: Text(key),
        ),
      );
    });
    return FlutterUtils.isIOS()
        ? CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions_,
          )
        : AlertDialog(
            title: title,
            titleTextStyle: Theme.of(context).textTheme.titleMedium,
            contentTextStyle: Theme.of(context).textTheme.bodySmall,
            content: content,
            actions: actions_.isEmpty ? null : actions_,
            actionsOverflowDirection: VerticalDirection.down,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(ThemeController.defRadius),
              ),
            ),
          );
  }

  static Future<void> toastMessageDialog(
    BuildContext context, {
    required Widget child,
    Duration? duration,
  }) async {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return _toast(child, 32);
      },
    );
    Future<void>.delayed(
      duration ?? const Duration(milliseconds: 1000),
    ).whenComplete(() {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  static void toastMessage(
    BuildContext context, {
    required String message,
    Duration? duration,
  }) {
    AppWidgets.toast(
      context,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.red),
      ),
    );
  }

  static void toast(
    BuildContext context, {
    required Widget child,
    Duration? duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration ?? const Duration(milliseconds: 2000),
        content: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragDown: (_) {},
          child: _toast(child),
        ),
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }

  static Widget _toast(Widget child, [double verticalMargin = 8]) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(vertical: verticalMargin, horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(240),
          borderRadius: BorderRadius.circular(ThemeController.defRadius),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: child,
      ),
    );
  }
}

class SeekBarController extends ValueNotifier<double> {
  SeekBarController([super.value = 0]);
}

class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.min,
    required this.max,
    this.listener,
    this.controller,
  }) : assert(controller != null || listener != null);
  final double min;
  final double max;
  final Function(int value)? listener;
  final SeekBarController? controller;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double value = 0;
  VoidCallback? listener;

  @override
  void initState() {
    widget.controller?.addListener(
      listener = () {
        final newValue = min(
          widget.max,
          max(widget.min, widget.controller!.value),
        );
        if (newValue != value) {
          setState(() {
            value = newValue;
          });
        }
      },
    );
    final double defValue = widget.controller == null
        ? 0
        : widget.controller!.value;
    value = min(widget.max, max(widget.min, defValue));
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Slider(
      value: value,
      min: widget.min,
      max: widget.max,
      activeColor: theme.primaryColor,
      inactiveColor: theme.colorScheme.surface,
      onChanged: (double newValue) {
        widget.listener?.call(newValue.round());
        if (widget.controller != null) {
          widget.controller!.value = newValue;
        } else {
          setState(() {
            value = newValue;
          });
        }
      },
      semanticFormatterCallback: (double newValue) {
        return '${newValue.round()}';
      },
    );
  }
}

class AlphaButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Size? size;
  final Color? bgColor;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final double opacity;

  const AlphaButton({
    super.key,
    this.onTap,
    this.bgColor,
    this.size,
    required this.child,
    this.border,
    this.margin,
    this.boxShadow,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 5),
    this.borderRadius = const BorderRadius.all(
      Radius.circular(ThemeController.defRadius),
    ),
    this.opacity = 0.25,
  });

  @override
  State<AlphaButton> createState() => _AlphaButtonState();
}

class _AlphaButtonState extends State<AlphaButton> {
  static _AlphaButtonState? hasTouch;
  bool onDown = false;
  bool onPressed = false;
  int timeStartPressed = 0;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.maybeBrightnessOf(context) == Brightness.light;
    return widget.onTap == null
        ? buildButton(isLight)
        : KeyboardListener(
            focusNode: _focus,
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.physicalKey == PhysicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  widget.onTap?.call();
                }
              }
            },
            child: buildButton(isLight),
          );
  }

  Widget buildButton(bool isLight) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (d) {
          if (hasTouch != null) {
            return;
          }
          timeStartPressed = SamplingClock().now().millisecondsSinceEpoch;
          onDown = true;
          // hasTouch = this;
          onFocus(true);
        },
        onTap: () {
          if (widget.onTap != null &&
              (hasTouch == null || hasTouch == this) &&
              (!onDown ||
                  SamplingClock().now().millisecondsSinceEpoch -
                          timeStartPressed <
                      800)) {
            onFocus(true);
            widget.onTap!.call();
            Future<void>.delayed(
              const Duration(milliseconds: 80),
            ).then((value) => onCancelled());
          } else {
            onCancelled();
          }
        },
        onTapUp: (d) => onFocus(false),
        onTapCancel: onCancelled,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: onPressed ? 80 : 250),
          opacity: onPressed || widget.onTap == null ? widget.opacity : 1.0,
          child: Container(
            height: widget.size == null || widget.size!.height <= 0
                ? ThemeController.filedHeightSize
                : widget.size!.height,
            width: widget.size == null || widget.size!.width <= 0
                ? 64
                : widget.size!.width,
            alignment: Alignment.center,
            padding: widget.padding,
            margin: widget.margin,
            foregroundDecoration: _focus.hasFocus
                ? BoxDecoration(
                    color: (isLight ? Colors.black : Colors.white).withAlpha(
                      150,
                    ),
                    borderRadius: widget.borderRadius,
                    border: widget.border,
                  )
                : null,
            decoration: BoxDecoration(
              color: widget.bgColor,
              borderRadius: widget.borderRadius,
              border: widget.border,
              boxShadow: widget.boxShadow,
              gradient: widget.gradient,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void onFocus(bool pressed) {
    if (widget.onTap != null) {
      if (pressed != onPressed) {
        setState(() {
          onPressed = pressed;
        });
      }
    } else if (onPressed) {
      onPressed = false;
    }
  }

  void onCancelled([bool onDown = false]) {
    onFocus(false);
    this.onDown = onDown;
    if (hasTouch != null && hasTouch == this) {
      hasTouch = null;
    }
  }
}
