import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:zaer/app/db_controller.dart';
import 'package:zaer/app/model/room.dart';
import 'package:zaer/app_extensions.dart';
import 'package:zaer/app_widgets.dart';
import 'package:zaer/gen/assets.gen.dart';
import 'package:zaer/l10n/app_localizations.dart';
import 'package:zaer/routes_management.dart';
import 'package:zaer/theme_controller.dart';
import 'package:zaer/ui/main/main_cubit.dart';

enum NavigationItem { insert, search, rooms, revolted }

int _navigationItemSelected = 3;
final _navigationItems = [
  [CupertinoIcons.add, "ایجاد زائر"],
  [CupertinoIcons.search, "جستجو"],
  [CupertinoIcons.person_3_fill, "اسکان ها"],
  [CupertinoIcons.person_crop_circle_badge_xmark, "ابطال شده"],
];
final _fragmentsInitialized = [];

final _imgA = [
  Assets.imgs.a1,
  Assets.imgs.a2,
  Assets.imgs.a3,
  Assets.imgs.a4,
  Assets.imgs.a5,
  Assets.imgs.a6,
  Assets.imgs.a7,
  Assets.imgs.a8,
  Assets.imgs.a9,
][Random.secure().nextInt(9)];
final _imgB = [
  Assets.imgs.b1,
  Assets.imgs.b2,
  Assets.imgs.b3,
][Random.secure().nextInt(3)];

final _globalNavigatorState = GlobalKey<NavigatorState>();

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => _MainActivityState();
}

class _MainActivityState extends State<MainActivity> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        FlutterWindowClose.setWindowShouldCloseHandler(() async {
          return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('آیا می خواهید از برنامه خارج شوید؟'),
                actions: [
                  AlphaButton(
                    bgColor: theme.primaryColor,
                    onTap: () {
                      context.read<DatabaseController>().close();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('بله'),
                  ),
                  AlphaButton(
                    bgColor: theme.primaryColor,
                    onTap: () => Navigator.of(context).pop(false),
                    child: const Text('خیر'),
                  ),
                ],
              );
            },
          );
        });
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: theme.appBarTheme.backgroundColor!.withAlpha(77),
                ),
              ),
            ),
            leadingWidth: 1,
            actions: [
              Lottie.asset(Assets.lottie.flag, width: 24, height: 24),
              Text(AppLocalizations.of(context)!.appTitle),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    "امام جعفر صادق: بنده‌ای به زیارت حضرت نرفته و قدمی برنداشته مگر آنکه حق‌تعالی برای او یک حسنه نوشته و یک گناه از او پاک می‌کند.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => settingsDialog(theme),
                icon: Icon(CupertinoIcons.settings),
              ),
              SizedBox(width: 8),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: theme.textTheme.titleMedium!.color!.withAlpha(100),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _imgA.image(
                        fit: BoxFit.cover,
                        opacity: AlwaysStoppedAnimation(0.95),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        spacing: 16,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var item in NavigationItem.values)
                            AlphaButton(
                              opacity: 0.5,
                              boxShadow: _navigationItemSelected == item.index
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(150),
                                        blurRadius: 15,
                                        // blurStyle: BlurStyle.inner
                                      ),
                                    ]
                                  : null,
                              borderRadius: BorderRadius.circular(25),

                              size: Size(80, 80),
                              onTap: () {
                                if (_navigationItemSelected != item.index) {
                                  setState(() {
                                    _navigationItemSelected = item.index;
                                    if (_globalNavigatorState.currentContext !=
                                        null) {
                                      while (Navigator.canPop(
                                        _globalNavigatorState.currentContext!,
                                      )) {
                                        Navigator.pop(
                                          _globalNavigatorState.currentContext!,
                                        );
                                      }
                                    }
                                  });
                                }
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _navigationItems[item.index][0] as IconData,
                                    size: 32,
                                    color: Colors.white,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black54,
                                        blurStyle: BlurStyle.outer,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _navigationItems[item.index][1] as String,
                                    style: theme.textTheme.titleMedium!.apply(
                                      color: Colors.white,
                                      shadows: [
                                        BoxShadow(
                                          color: Colors.black,
                                          blurStyle: BlurStyle.outer,
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 50,
                      child: TimerWidget(
                        duration: Duration(seconds: 1),
                        builder: (context) {
                          String twoDigits(int n) {
                            if (n >= 10) return '$n';
                            return '0$n';
                          }

                          final now = Jalali.now();
                          return Text(
                            '${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}',
                            style: theme.textTheme.titleMedium!.apply(
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurStyle: BlurStyle.outer,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _imgB.image(
                        fit: BoxFit.cover,
                        opacity: AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                    Navigator(
                      key: _globalNavigatorState,
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (builder) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 56.0),
                              child: IndexedStack(
                                alignment: AlignmentDirectional.topCenter,
                                index: _navigationItemSelected,
                                children: [
                                  initFragment(
                                    NavigationItem.insert,
                                    const ZaerInfo(false),
                                  ),
                                  initFragment(
                                    NavigationItem.search,
                                    const Search(),
                                  ),
                                  initFragment(
                                    NavigationItem.rooms,
                                    const Rooms(),
                                  ),
                                  initFragment(
                                    NavigationItem.revolted,
                                    const Revolted(),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget initFragment(NavigationItem item, Widget fragment) {
    if (item.index == _navigationItemSelected) {
      return fragment;
    }
    if (!_fragmentsInitialized.contains(_navigationItemSelected) &&
        _navigationItemSelected < 2) {
      _fragmentsInitialized.add(_navigationItemSelected);
    }
    return _fragmentsInitialized.contains(item.index)
        ? Offstage(
            offstage: _navigationItemSelected != item.index,
            child: fragment,
          )
        : Container();
  }

  void settingsDialog(ThemeData theme) {
    showMenu(
      color: theme.colorScheme.surface.withAlpha(150),
      context: context,
      position: RelativeRect.fromLTRB(0, 0, 1, 0),
      items: [
        PopupMenuItem<Never>(
          onTap: () {
            context.read<ThemeChangeListenable>().change(context.read());
          },
          child: Row(
            spacing: 16,
            children: [
              Icon(
                context.read<ThemeChangeListenable>().isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                size: 20,
              ),
              Text("حالت شب/روز"),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem<Never>(
          child: Row(
            spacing: 16,
            children: [
              Icon(Icons.import_export_rounded, size: 20),
              Text("گزارشات"),
            ],
          ),
          onTap: () => context.navigate(RoutesManagement.report),
        ),
        PopupMenuItem<Never>(
          child: Row(
            spacing: 16,
            children: [
              Icon(CupertinoIcons.arrow_down_doc_fill, size: 20),
              Text("خروجی اکسل"),
            ],
          ),
          onTap: () async {
            String? selectedDirectory = await FilePicker.platform
                .getDirectoryPath();
            if (selectedDirectory != null) {
              if (context.mounted) {
                context.read<MainCubit>().onMessage?.call(
                  "در حال ایجاد خروجی...",
                );
                context
                    .read<DatabaseController>()
                    .backupCSV(selectedDirectory, true, true)
                    .then(
                      (value) {
                        if (context.mounted) {
                          context.read<MainCubit>().onMessage?.call(
                            "خروجی تهیه شد.",
                          );
                        }
                      },
                      onError: (err) {
                        if (context.mounted) {
                          context.read<MainCubit>().onMessage?.call(
                            err.toString(),
                          );
                        }
                      },
                    );
              }
            }
          },
        ),
        PopupMenuItem<Never>(
          child: Row(
            spacing: 16,
            children: [
              Icon(CupertinoIcons.arrow_up_doc_fill, size: 20),
              Text("بارگذاری اکسل"),
            ],
          ),
          onTap: () async {
            final FilePickerResult? result = await FilePicker.platform
                .pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                );
            if (result != null &&
                context.mounted &&
                result.paths.first != null &&
                result.paths.first!.isNotEmpty) {
              context.read<MainCubit>().onMessage?.call(
                "در حال بارگذاری...",
              );
              await context.read<DatabaseController>().loadCSV(
                result.paths.first!,
                false,
              );
              context.read<MainCubit>().onMessage?.call(
                "بارگذاری باموفقیت انجام شد.",
              );
            }
          },
        ),
        PopupMenuDivider(),
        PopupMenuItem<Never>(child: Text(Jalali.now().formatFullDate())),
        PopupMenuItem<Never>(child: Text(HijriCalendar.now().fullDate())),
      ],
    );
  }
}

class ZaerInfo extends StatelessWidget {
  final bool update;

  const ZaerInfo(this.update, {super.key});

  @override
  Widget build(BuildContext context) {
    final main = context.read<MainCubit>();
    if (update) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("ویرایش زائر"),
          actions: [
            Text(
              main.zaer!.updatedAt == 0
                  ? "-"
                  : Jalali.fromMillisecondsSinceEpoch(
                      main.zaer!.updatedAt,
                    ).toJalaliDateTime(),
            ),
            SizedBox(width: 4),
            Icon(CupertinoIcons.calendar, size: 16),
            SizedBox(width: 16),
            Text(
              Jalali.fromMillisecondsSinceEpoch(
                main.zaer!.createdAt,
              ).toJalaliDateTime(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(Icons.date_range_rounded, size: 16),
            ),
          ],
        ),
        body: body(context, main),
      );
    }
    return body(context, main);
  }

  Widget body(BuildContext context, MainCubit main) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(12),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent) {
            if (update && e.physicalKey == PhysicalKeyboardKey.escape) {
              context.singlePop();
              return;
            }
            if (LogicalKeyboardKey.backspace == e.logicalKey ||
                LogicalKeyboardKey.goBack == e.logicalKey) {
              if (main.addressFn.hasFocus) {
                if (main.address.text.isEmpty) {
                  main.phoneNoFn.requestFocus();
                }
              } else if (main.phoneNoFn.hasFocus) {
                if (main.phoneNo.text.isEmpty) {
                  main.passportNoFn.requestFocus();
                }
              } else if (main.passportNoFn.hasFocus) {
                if (main.passportNo.text.isEmpty) {
                  if (update) {
                    main.fatherNameFn.requestFocus();
                  } else {
                    main.nationalCodeFn.requestFocus();
                  }
                }
              } else if (main.nationalCodeFn.hasFocus) {
                if (main.nationalCode.text.isEmpty) {
                  main.fatherNameFn.requestFocus();
                }
              } else if (main.fatherNameFn.hasFocus) {
                if (main.fatherName.text.isEmpty) {
                  main.lastNameFn.requestFocus();
                }
              } else if (main.lastNameFn.hasFocus) {
                if (main.lastName.text.isEmpty) {
                  main.firstNameFn.requestFocus();
                }
              }
            }
          }
        },
        child: FocusTraversalGroup(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final theme = Theme.of(context);
              main.update = update;
              if (update) {
                main.setZaerUpdate();
              }
              main.onNavigate = (fragment) => context.navigate(fragment);
              main.onMessage = (message) {
                if (context.mounted) {
                  AppWidgets.toastMessage(context, message: message);
                }
              };
              final mq = MediaQuery.of(context);
              if (mq.displaySize == DisplaySize.desktop) {
                return Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: firstNameField(main)),
                        Expanded(child: lastNameField(main)),
                        Expanded(child: fatherNameField(main)),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: isMaleField(main, theme),
                        ),
                        Expanded(child: nationalCodeField(main)),
                        Expanded(child: passportNoField(main)),
                        Expanded(child: phoneNoField(main)),
                      ],
                    ),
                    addressField(main),
                    buttonField(main, theme),
                    nextAndPrevious(main, theme),
                  ],
                );
              }
              if (mq.displaySize == DisplaySize.tablet ||
                  !mq.isPortrait && mq.displaySize == DisplaySize.mobile) {
                return Column(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: firstNameField(main)),
                        Expanded(child: lastNameField(main)),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: fatherNameField(main)),
                        Expanded(child: isMaleField(main, theme)),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: nationalCodeField(main)),
                        Expanded(child: passportNoField(main)),
                      ],
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(child: phoneNoField(main)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: addressField(main),
                          ),
                        ),
                      ],
                    ),
                    buttonField(main, theme),
                    nextAndPrevious(main, theme),
                  ],
                );
              }
              return Column(
                spacing: 12,
                children: [
                  firstNameField(main),
                  lastNameField(main),
                  fatherNameField(main),
                  isMaleField(main, theme),
                  nationalCodeField(main),
                  passportNoField(main),
                  phoneNoField(main),
                  addressField(main),
                  buttonField(main, theme),
                  nextAndPrevious(main, theme),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget nextAndPrevious(MainCubit main, ThemeData theme) {
    if (update) return Center();
    return Row(
      spacing: 24,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AlphaButton(
          boxShadow: [
            BoxShadow(color: theme.colorScheme.surface, blurRadius: 20),
          ],
          onTap: () => main.previous(),
          border: Border.all(
            color: theme.textTheme.titleMedium!.color!,
            width: 1,
          ),
          size: Size(75, 42),
          child: Row(
            spacing: 8,
            children: [Icon(CupertinoIcons.arrow_turn_up_right), Text("قبلی")],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: main.preview,
          builder: (context, value, child) {
            return AlphaButton(
              boxShadow: [
                BoxShadow(color: theme.colorScheme.surface, blurRadius: 20),
              ],
              onTap: value ? () => main.clearZaer() : null,
              border: Border.all(
                color: theme.textTheme.titleMedium!.color!,
                width: 1,
              ),
              size: Size(75, 42),
              child: Row(
                spacing: 8,
                children: [
                  Icon(CupertinoIcons.staroflife_fill, size: 20),
                  Text("جدید"),
                ],
              ),
            );
          },
        ),
        AlphaButton(
          boxShadow: [
            BoxShadow(color: theme.colorScheme.surface, blurRadius: 20),
          ],
          onTap: () => main.next(),
          border: Border.all(
            color: theme.textTheme.titleMedium!.color!,
            width: 1,
          ),
          size: Size(75, 42),
          child: Row(
            spacing: 8,
            children: [Icon(CupertinoIcons.arrow_turn_up_left), Text("بعدی")],
          ),
        ),
      ],
    );
  }

  Widget buttonField(MainCubit main, ThemeData theme) {
    return AlphaButton(
      bgColor: theme.colorScheme.primary,
      size: Size(120, 42),
      onTap: () => main.insertOrUpdateZaer(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
          Text(
            "ذخیره کردن",
            style: theme.textTheme.titleSmall!.apply(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget addressField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      onSubmitted: (_) => main.insertOrUpdateZaer(),
      focusNode: main.addressFn,
      controller: main.address,
      decoration: InputDecoration(label: Text("آدرس"), counterText: ''),
      maxLength: 256,
    );
  }

  Widget passportNoField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      focusNode: main.passportNoFn,
      onSubmitted: (_) => main.phoneNoFn.requestFocus(),
      controller: main.passportNo,
      decoration: InputDecoration(label: Text("شماره پاسپورت")),
      maxLength: 32,
    );
  }

  Widget isMaleField(MainCubit main, ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: main.isMale,
      builder: (context, value, child) {
        return CupertinoSegmentedControl(
          groupValue: main.isMale.value,
          unselectedColor: Colors.black26,
          children: {
            false: Text(
              "     زن     ",
              style: theme.textTheme.bodyMedium!.apply(color: Colors.white),
            ),
            true: Text(
              "مرد",
              style: theme.textTheme.bodyMedium!.apply(color: Colors.white),
            ),
          },
          onValueChanged: (value) {
            main.isMale.value = value;
          },
        );
      },
    );
  }

  Widget phoneNoField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      focusNode: main.phoneNoFn,
      onSubmitted: (_) => main.addressFn.requestFocus(),
      controller: main.phoneNo,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(label: Text("شماره همراه")),
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget nationalCodeField(MainCubit main) {
    return ValueListenableBuilder(
      valueListenable: main.preview,
      builder: (context, value, child) {
        return TextField(
          selectionControls: CupertinoTextSelectionControls(),
          enableInteractiveSelection: true,
          focusNode: main.nationalCodeFn,
          onSubmitted: (_) => main.passportNoFn.requestFocus(),
          enabled: !update && !value,
          controller: main.nationalCode,
          textDirection: TextDirection.ltr,
          decoration: InputDecoration(label: Text("کد ملی")),
          keyboardType: TextInputType.number,
          maxLength: 16,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        );
      },
    );
  }

  Widget fatherNameField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      focusNode: main.fatherNameFn,
      onSubmitted: (_) => update
          ? main.passportNoFn.requestFocus()
          : main.nationalCodeFn.requestFocus(),
      controller: main.fatherName,
      decoration: InputDecoration(label: Text("نام پدر"), counterText: ''),
      maxLength: 30,
    );
  }

  Widget lastNameField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      focusNode: main.lastNameFn,
      onSubmitted: (_) => main.fatherNameFn.requestFocus(),
      controller: main.lastName,
      decoration: InputDecoration(label: Text("نام خانوادگی"), counterText: ''),
      maxLength: 30,
    );
  }

  Widget firstNameField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      autofocus: true,
      focusNode: main.firstNameFn,
      onSubmitted: (_) => main.lastNameFn.requestFocus(),
      controller: main.firstName,
      decoration: InputDecoration(label: Text("نام"), counterText: ''),
      maxLength: 30,
    );
  }
}

class Search extends StatelessWidget {
  const Search({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final main = context.read<MainCubit>();
          main.onMessage = (message) {
            if (context.mounted) {
              AppWidgets.toastMessage(context, message: message);
            }
          };
          final mq = MediaQuery.of(context);
          if (mq.displaySize == DisplaySize.mobile && mq.isPortrait) {
            return Column(
              spacing: 12,
              children: [
                nationalCodeField(main),
                orField(),
                phoneNoField(main),
                orField(),
                fromToDateField(context, theme, main),
                searchButtonField(main, theme),
                listSearchBox(main, theme),
              ],
            );
          }
          return Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 12,
                children: [
                  Expanded(child: nationalCodeField(main)),
                  orField(),
                  Expanded(child: phoneNoField(main)),
                  orField(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsGeometry.only(bottom: 20),
                      child: fromToDateField(context, theme, main),
                    ),
                  ),
                ],
              ),
              searchButtonField(main, theme),
              listSearchBox(main, theme),
            ],
          );
        },
      ),
    );
  }

  Text orField() => Text("یا");

  Widget phoneNoField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      onSubmitted: (_) => main.searchZaer(),
      controller: main.phoneNoSearch,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(label: Text("شماره همراه")),
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget nationalCodeField(MainCubit main) {
    return TextField(
      selectionControls: CupertinoTextSelectionControls(),
      enableInteractiveSelection: true,
      autofocus: true,
      onSubmitted: (_) => main.searchZaer(),
      controller: main.nationalCodeSearch,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(label: Text("کد ملی")),
      keyboardType: TextInputType.number,
      maxLength: 16,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Widget fromToDateField(
    BuildContext context,
    ThemeData theme,
    MainCubit main,
  ) {
    return ListTile(
      onTap: () async {
        JalaliRange? picked = await showPersianDateRangePicker(
          context: context,
          initialDate: Jalali.now(),
          firstDate: Jalali(1404, 01, 01),
          lastDate: Jalali(1999, 12, 29),
          initialEntryMode: PersianDatePickerEntryMode.calendar,
        );
        if (picked != null) {
          main.toDateSearch = picked.end.toDateTime().millisecondsSinceEpoch;
          main.fromDateSearch.value = picked.start
              .toDateTime()
              .millisecondsSinceEpoch;
        } else {
          main.toDateSearch = 0;
          main.fromDateSearch.value = 0;
        }
      },
      dense: true,
      title: Text("انتخاب روز", style: theme.textTheme.titleSmall),
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      subtitle: ValueListenableBuilder(
        valueListenable: main.fromDateSearch,
        builder: (context, value, child) {
          return Text(
            value == 0
                ? "انتخاب کنید"
                : "${Jalali.fromMillisecondsSinceEpoch(value).formatCompactDate()} تا ${Jalali.fromMillisecondsSinceEpoch(main.toDateSearch).formatCompactDate()}",
            style: theme.textTheme.labelSmall,
          );
        },
      ),
    );
  }

  Widget listSearchBox(MainCubit main, ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: main.zaeran,
      builder: (context, zaeran, w) {
        if (zaeran.isEmpty) {
          if (main.phoneNoSearch.text.isEmpty &&
              main.nationalCodeSearch.text.isEmpty) {
            return Container();
          }
          return Center(
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.nosign,
                  color: theme.textTheme.titleMedium!.color,
                  size: 64,
                ),
                Text("زائری برای نمایش پیدا نشد."),
              ],
            ),
          );
        }
        return SizedBox.fromSize(
          size: Size(double.infinity, MediaQuery.sizeOf(context).height - 218),
          child: ListView.builder(
            itemCount: zaeran.length,
            itemBuilder: (context, index) {
              final zaer = zaeran[index];
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
                title: Row(
                  children: [
                    Icon(
                      zaer.isMale == 1 ? Icons.man : Icons.woman,
                      color: theme.textTheme.titleSmall!.color,
                      size: 18,
                    ),
                    Text(
                      "${zaer.firstName} ${zaer.lastName} (${zaer.fatherName})",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                trailing: Icon(
                  CupertinoIcons.arrow_left,
                  color: theme.textTheme.titleSmall!.color,
                  size: 20,
                ),
                onTap: () {
                  main.zaer = zaer;
                  main.zaerIndex = index;
                  context.navigate(RoutesManagement.room);
                },
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 4),
                    Text("${zaer.phoneNo}", style: theme.textTheme.bodySmall!),
                    SizedBox(width: 4),
                    Icon(
                      CupertinoIcons.phone_fill,
                      size: 12,
                      color: theme.textTheme.titleSmall!.color,
                    ),
                    SizedBox(width: 8),
                    Text(zaer.nationalCode, style: theme.textTheme.bodySmall),
                    SizedBox(width: 4),
                    Text("M"),
                    SizedBox(width: 8),
                    Text(zaer.passportNo, style: theme.textTheme.bodySmall),
                    SizedBox(width: 4),
                    Text("P"),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  AlphaButton searchButtonField(MainCubit main, ThemeData theme) {
    return AlphaButton(
      bgColor: theme.colorScheme.primary,
      size: Size(120, 42),
      onTap: () => main.searchZaer(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ValueListenableBuilder(
            valueListenable: main.loading,
            builder: (context, loading, w) {
              if (loading) {
                return CupertinoActivityIndicator(
                  radius: 10,
                  color: theme.primaryColor,
                );
              }
              return Icon(CupertinoIcons.search, color: Colors.white);
            },
          ),
          Text(
            "جستجو",
            style: theme.textTheme.titleSmall!.apply(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class Rooms extends StatelessWidget {
  const Rooms({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final main = context.read<MainCubit>();
          main.onMessage = (message) {
            if (context.mounted) {
              AppWidgets.toastMessage(context, message: message);
            }
          };
          final mq = MediaQuery.of(context);
          if (mq.displaySize == DisplaySize.mobile && mq.isPortrait) {
            return Column(
              spacing: 12,
              children: [
                fromToDateField(context, theme, main),
                fromDateResidenceField(main, theme),
                searchButtonField(main, theme),
                listSearchBox(main, theme),
              ],
            );
          }
          return Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 12,
                children: [
                  Expanded(child: fromToDateField(context, theme, main)),
                  fromDateResidenceField(main, theme),
                ],
              ),
              searchButtonField(main, theme),
              listSearchBox(main, theme),
            ],
          );
        },
      ),
    );
  }

  Widget fromDateResidenceField(MainCubit main, ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: main.fromDateResidenceSearch,
      builder: (context, value, child) {
        return CupertinoSegmentedControl(
          unselectedColor: Colors.black26,
          groupValue: main.fromDateResidenceSearch.value,
          children: {
            true: Text(
              " شروع اسکان ",
              style: theme.textTheme.bodySmall!.apply(color: Colors.white),
            ),
            false: Text(
              "پایان اسکان",
              style: theme.textTheme.bodySmall!.apply(color: Colors.white),
            ),
          },
          onValueChanged: (value) {
            main.fromDateResidenceSearch.value = value;
          },
        );
      },
    );
  }

  Widget fromToDateField(
    BuildContext context,
    ThemeData theme,
    MainCubit main,
  ) {
    return ListTile(
      onTap: () async {
        JalaliRange? picked = await showPersianDateRangePicker(
          context: context,
          initialDate: Jalali.now(),
          firstDate: Jalali(1404, 01, 01),
          lastDate: Jalali(1999, 12, 29),
          initialEntryMode: PersianDatePickerEntryMode.calendar,
        );
        if (picked != null) {
          main.toDateSearch = picked.end.toDateTime().millisecondsSinceEpoch;
          main.fromDateSearch.value = picked.start
              .toDateTime()
              .millisecondsSinceEpoch;
        }
      },
      dense: true,
      title: Text("انتخاب روز", style: theme.textTheme.titleSmall),
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
      subtitle: ValueListenableBuilder(
        valueListenable: main.fromDateSearch,
        builder: (context, value, child) {
          return Text(
            value == 0
                ? "انتخاب کنید"
                : "${Jalali.fromMillisecondsSinceEpoch(value).formatCompactDate()} تا ${Jalali.fromMillisecondsSinceEpoch(main.toDateSearch).formatCompactDate()}",
            style: theme.textTheme.bodySmall,
          );
        },
      ),
    );
  }

  Widget listSearchBox(MainCubit main, ThemeData theme) {
    return ValueListenableBuilder(
      valueListenable: main.rooms2,
      builder: (context, rooms, w) {
        if (rooms.isEmpty) {
          if (main.fromDateSearch.value == 0) {
            return Container();
          }
          return Center(
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.nosign,
                  color: theme.textTheme.titleMedium!.color,
                  size: 64,
                ),
                Text("موردی برای نمایش پیدا نشد."),
              ],
            ),
          );
        }
        final mq = MediaQuery.of(context);
        return SizedBox(
          width: mq.size.width,
          height: mq.size.height - 203,
          child: RoomListView(rooms),
        );
      },
    );
  }

  AlphaButton searchButtonField(MainCubit main, ThemeData theme) {
    return AlphaButton(
      margin: EdgeInsets.only(top: 4),
      bgColor: theme.colorScheme.primary,
      size: Size(120, 42),
      onTap: () => main.searchRoom(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ValueListenableBuilder(
            valueListenable: main.loading,
            builder: (context, loading, w) {
              if (loading) {
                return CupertinoActivityIndicator(
                  radius: 10,
                  color: theme.primaryColor,
                );
              }
              return Icon(CupertinoIcons.search, color: Colors.white);
            },
          ),
          Text(
            "جستجو",
            style: theme.textTheme.titleSmall!.apply(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class Revolted extends StatelessWidget {
  const Revolted({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final update = ValueNotifier(false);
    return FutureBuilder(
      future: context.read<DatabaseController>().revolted(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "در ارتباط با دیتابیس خطایی رویداده است.\n${snapshot.error}\n${snapshot.stackTrace}",
            ),
          );
        }
        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data.isEmpty) {
            return Center(
              child: Column(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.list_dash,
                    color: theme.textTheme.titleMedium!.color,
                    size: 64,
                  ),
                  Text("گزارشی برای نمایش وجود ندارد."),
                ],
              ),
            );
          }
          return ValueListenableBuilder(
            valueListenable: update,
            builder: (context, value, child) {
              return RoomListView(snapshot.data!);
            },
          );
        }
        return Center(
          child: CupertinoActivityIndicator(
            radius: 50,
            color: theme.primaryColor,
          ),
        );
      },
    );
  }
}

class RoomListView extends StatefulWidget {
  final List<Room> rooms;

  const RoomListView(this.rooms, {super.key});

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final main = context.read<MainCubit>();
    final now = DateTime.now().millisecondsSinceEpoch;
    return ListView.separated(
      itemBuilder: (context, index) {
        final room = widget.rooms[index];
        return ListTile(
          title: Column(
            children: [
              Row(
                children: [
                  Icon(
                    room.zaer!.isMale == 1 ? Icons.man : Icons.woman,
                    color: theme.textTheme.titleMedium!.color,
                    size: 18,
                  ),
                  Text(
                    "${room.zaer!.firstName} ${room.zaer!.lastName} (${room.zaer!.fatherName})",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 2, left: 8),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: getBadgeColor(room, now),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  Text(
                    "تعداد همراه: ${room.entourageCount} نفر، اسکان در اتاق شماره ی ${room.number}",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          trailing: Row(
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              AlphaButton(
                size: Size(90, 42),
                onTap: () {
                  room.leaving = room.leaving == 0 ? 1 : 0;
                  if (main.db.updateRoom(room)) {
                    setState(() {});
                  } else {
                    room.leaving = room.leaving == 0 ? 1 : 0;
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: BoxBorder.all(
                      color: room.leaving == 0
                          ? Colors.grey
                          : theme.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      SizedBox.fromSize(
                        size: Size(24, 24),
                        child: Icon(
                          room.leaving == 0
                              ? CupertinoIcons.clear
                              : CupertinoIcons.checkmark_alt,
                          size: 16,
                          color: room.leaving == 0
                              ? Colors.grey
                              : theme.primaryColor,
                        ),
                      ),
                      Text(
                        "خروج",
                        style: theme.textTheme.labelMedium!.apply(
                          color: room.leaving == 0
                              ? Colors.grey
                              : theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  main.zaer = room.zaer!;
                  context.navigate(RoutesManagement.room);
                },
                icon: Icon(
                  CupertinoIcons.arrow_left,
                  size: 24,
                  color: theme.textTheme.titleMedium!.color,
                ),
              ),
            ],
          ),
          subtitle: Row(
            spacing: 4,
            children: [
              Icon(
                Icons.arrow_circle_right_rounded,
                color: Colors.green,
                size: 20,
              ),
              Text(
                Jalali.fromMillisecondsSinceEpoch(
                  room.fromDate,
                ).toJalaliDateTime(),
                style: theme.textTheme.labelMedium,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.arrow_circle_left_rounded,
                color: Colors.red,
                size: 20,
              ),
              Text(
                Jalali.fromMillisecondsSinceEpoch(
                  room.toDate,
                ).toJalaliDateTime(),
                style: theme.textTheme.labelMedium,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.breakfast_dining_rounded,
                color: room.breakfast == 1 ? Colors.blue : Colors.grey,
                size: 20,
              ),
              Icon(
                Icons.lunch_dining_rounded,
                color: room.lunch == 1 ? Colors.blue : Colors.grey,
                size: 20,
              ),
              Icon(
                Icons.dinner_dining_rounded,
                color: room.dinner == 1 ? Colors.blue : Colors.grey,
                size: 20,
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return Divider(endIndent: 8, indent: 8, thickness: 1);
      },
      itemCount: widget.rooms.length,
    );
  }

  Color getBadgeColor(Room room, int now) {
    if (room.leaving == 1) return Colors.red;
    if (room.fromDate > now) {
      return Colors.blue;
    }
    if (room.toDate <= now) {
      return Colors.orange;
    }
    return Colors.green;
  }
}

class TimerWidget extends StatefulWidget {
  final Duration duration;
  final WidgetBuilder builder;

  const TimerWidget({required this.duration, required this.builder, super.key});

  @override
  State<StatefulWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
