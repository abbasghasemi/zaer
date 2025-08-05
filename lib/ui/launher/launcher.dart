import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zaer/app/confg.dart';
import 'package:zaer/app_extensions.dart';
import 'package:zaer/l10n/app_localizations.dart';
import 'package:zaer/routes_management.dart';
import 'package:zaer/theme_controller.dart';

class LauncherActivity extends StatefulWidget {
  const LauncherActivity({super.key});

  @override
  State<LauncherActivity> createState() => _LauncherActivityState();
}

class _LauncherActivityState extends State<LauncherActivity> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 2500)).then((value) async {
      if (mounted) {
        context.navigate(RoutesManagement.main, replaceAll: true);
        WindowOptions windowOptions = WindowOptions(
          size: Size(1280, 720),
          center: true,
          minimumSize: Size(720, 500),
          titleBarStyle: TitleBarStyle.normal,
        );
        windowManager.waitUntilReadyToShow(windowOptions, () async {
          await windowManager.show();
          await windowManager.focus();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeController.theme();
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {},
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              colors: [
                tc.backgroundColor,
                tc.surfaceColor,
                tc.backgroundSecondaryColor,
                tc.backgroundColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Lottie.asset(
                        "assets/lottie/flag.json",
                        width: 196,
                        height: 196,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'v ${AppConfig.appVersionName}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
