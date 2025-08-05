import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:zaer/app/date_storage.dart';
import 'package:zaer/app/db_controller.dart';
import 'package:zaer/app_utilities.dart';
import 'package:zaer/l10n/app_localizations.dart';
import 'package:zaer/theme_controller.dart';
import 'package:zaer/ui/launher/launcher.dart';
import 'package:zaer/ui/main/main_cubit.dart';

void main() async {
  if (FlutterUtils.isWindows()) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(720, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } else {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Color(0xffe2e2e2),
      ),
    );
  }
  HijriCalendar.setLocal("ar");
  final storage = DataStorage();
  await storage.init();
  runApp(Application(storage));
}

class Application extends StatelessWidget {
  final DataStorage storage;

  const Application(this.storage, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DataStorage>(create: (_) => storage),
        ChangeNotifierProvider<ThemeChangeListenable>(
          create: (c) => ThemeChangeListenable(storage.isDarkMode),
        ),
        Provider<DatabaseController>(create: (_) => DatabaseController()),
        BlocProvider<MainCubit>(create: (c) => MainCubit(c.read()), lazy: true),
      ],
      child: Builder(
        builder: (context) {
          return ListenableBuilder(
            listenable: context.read<ThemeChangeListenable>(),
            builder: (context, child) {
              final change = context.read<ThemeChangeListenable>();
              final theme = change.isDark
                  ? ThemeController.dark().build()
                  : ThemeController.light().build();
              return MaterialApp(
                themeMode: change.isDark ? ThemeMode.dark : ThemeMode.light,
                theme: theme,
                locale: const Locale("fa", "IR"),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const LauncherActivity(),
              );
            },
          );
        },
      ),
    );
  }
}
