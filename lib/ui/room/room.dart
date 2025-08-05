import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:zaer/app/model/room.dart';
import 'package:zaer/app_extensions.dart';
import 'package:zaer/app_widgets.dart';
import 'package:zaer/routes_management.dart';
import 'package:zaer/ui/main/main_cubit.dart';

class RoomActivity extends StatelessWidget {
  const RoomActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final main = context.read<MainCubit>();
    final theme = Theme.of(context);
    main.getRooms();
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyL, control: true): () =>
            showLocation(context, main, theme),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            insertOrUpdate(context, main, theme, null),
        const SingleActivator(
          LogicalKeyboardKey.keyE,
          control: true,
        ): () async {
          final result = await context.navigate(RoutesManagement.zaer);
          if (main.currentZaerId != main.zaer?.id) {
            main.clearZaer();
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () =>
            deleteDialog(context, main),
        const SingleActivator(
          LogicalKeyboardKey.escape,
          includeRepeats: false,
        ): () =>
            context.singlePop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              IconButton(
                tooltip: "آدرس     Control+L",
                onPressed: () => showLocation(context, main, theme),
                icon: Icon(CupertinoIcons.location_solid),
              ),
              IconButton(
                tooltip: "اقامت     Control+N",
                onPressed: () => insertOrUpdate(context, main, theme, null),
                icon: Icon(CupertinoIcons.add),
              ),
              IconButton(
                tooltip: "ویرایش     Control+E",
                onPressed: () => context.navigate(RoutesManagement.zaer),
                icon: Icon(CupertinoIcons.pen),
              ),
              IconButton(
                tooltip: "حذف     Control+D",
                onPressed: () => deleteDialog(context, main),
                icon: Icon(CupertinoIcons.delete_solid),
              ),
            ],
            title: Text(
              '${main.zaer!.firstName} ${main.zaer!.lastName} (${main.zaer!.fatherName})',
            ),
          ),
          body: ValueListenableBuilder(
            valueListenable: main.rooms,
            builder: (context, value, child) {
              if (value == null) {
                return Center(
                  child: CupertinoActivityIndicator(
                    color: theme.primaryColor,
                    radius: 24,
                  ),
                );
              }
              if (value.isEmpty) {
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
                      Text("آیتمی برای نمایش وجود ندارد."),
                    ],
                  ),
                );
              }
              final now = DateTime.now().millisecondsSinceEpoch;
              return ListView.separated(
                itemBuilder: (context, index) {
                  final room = value[index];
                  return ListTile(
                    title: Row(
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
                    trailing: Row(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AlphaButton(
                          size: Size(90, 42),
                          onTap: () {
                            room.leaving = room.leaving == 0 ? 1 : 0;
                            if (main.db.updateRoom(room)) {
                              main.rooms.value = List.of(main.rooms.value!);
                            } else {
                              room.leaving = room.leaving == 0 ? 1 : 0;
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
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
                          onPressed: () =>
                              insertOrUpdate(context, main, theme, room),
                          icon: Icon(
                            CupertinoIcons.pen,
                            color: Colors.lightGreen,
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
                          color: room.breakfast == 1
                              ? Colors.yellow
                              : Colors.grey,
                          size: 20,
                        ),
                        Icon(
                          Icons.lunch_dining_rounded,
                          color: room.lunch == 1 ? Colors.yellow : Colors.grey,
                          size: 20,
                        ),
                        Icon(
                          Icons.dinner_dining_rounded,
                          color: room.dinner == 1 ? Colors.yellow : Colors.grey,
                          size: 20,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(endIndent: 8, indent: 8, thickness: 1);
                },
                itemCount: value.length,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<dynamic> deleteDialog(BuildContext context, MainCubit main) {
    return showDialog(
      context: context,
      builder: (context) => AppWidgets.alertDialog(
        context,
        title: Text("آیا از حذف زائر اطمینان دارید؟"),
        content: Text("اخطار: این عمل قابل بازگشت نیست!"),
        actions: {
          "بله": () {
            main.zaeran.value.removeAt(main.zaerIndex);
            main.zaeran.value = List.of(main.zaeran.value);
            context.singlePop();
            context.singlePop();
            main.db.deleteZaer(main.zaer!);
            main.zaer = null;
            main.zaerIndex = -1;
          },
          "خیر": () => context.singlePop(),
        },
      ),
    );
  }

  Future<void> insertOrUpdate(
    BuildContext context,
    MainCubit main,
    ThemeData theme,
    final Room? room,
  ) async {
    final bEntourageCount = main.entourageCount.text;
    final bNumber = main.number.value;
    final bFromDate = main.fromDate.value;
    final bToDate = main.toDate;
    final bBreakfast = main.breakfast.value;
    final bLunch = main.lunch.value;
    final bDinner = main.dinner.value;
    if (room != null) {
      main.entourageCount.text = room.entourageCount.toString();
      main.number.value = room.number;
      main.fromDate.value = room.fromDate;
      main.toDate = room.toDate;
      main.breakfast.value = room.breakfast == 1;
      main.lunch.value = room.lunch == 1;
      main.dinner.value = room.dinner == 1;
    } else {
      main.fromDate.value = DateTime.now().millisecondsSinceEpoch;
      main.toDate = main.fromDate.value + 24 * 60 * 60 * 1000;
    }
    await showDialog(
      context: context,
      builder: (context) => AppWidgets.alertDialog(
        context,
        content: CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(
              LogicalKeyboardKey.enter,
              control: true,
              includeRepeats: false,
            ): () {
              main.insertOrUpdateResidence(room);
              context.singlePop();
            },
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                selectionControls: CupertinoTextSelectionControls(),
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  label: Text("تعداد همراه:"),
                  counterText: '',
                ),
                controller: main.entourageCount,
                maxLength: 3,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              SizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: main.number,
                builder: (context, value, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        iconEnabledColor: theme.textTheme.bodyMedium!.color,
                        value: value,
                        items: [
                          for (var i = 1; i < 7; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(
                                "اتاق شماره $i",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                        ],
                        onChanged: (value) => main.number.value = value ?? 1,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                onTap: () async {
                  final date = Jalali.now();
                  JalaliRange? picked = await showPersianDateRangePicker(
                    context: context,
                    firstDate: Jalali(1404, 01, 01),
                    lastDate: Jalali(1999, 12, 29),
                    initialDateRange: JalaliRange(
                      start: Jalali.fromMillisecondsSinceEpoch(
                        main.fromDate.value,
                      ),
                      end: Jalali.fromMillisecondsSinceEpoch(main.toDate),
                    ),
                    initialEntryMode: PersianDatePickerEntryMode.input,
                    initialDate: date,
                  );
                  if (picked != null) {
                    final append =
                        ((date.hour * 60 * 60) +
                            (date.minute * 60) +
                            date.millisecond) *
                        1000;
                    main.toDate =
                        picked.end.toDateTime().millisecondsSinceEpoch + append;
                    main.fromDate.value =
                        picked.start.toDateTime().millisecondsSinceEpoch +
                            append;
                  }
                },
                dense: true,
                title: Text("تعداد روز", style: theme.textTheme.bodyMedium),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                subtitle: ValueListenableBuilder(
                  valueListenable: main.fromDate,
                  builder: (context, value, child) {
                    return Text(
                      value == 0
                          ? "انتخاب کنید"
                          : "${Jalali.fromDateTime(DateTime.fromMillisecondsSinceEpoch(value)).formatCompactDate()} - ${getDays(value, main.toDate)} روز",
                      style: theme.textTheme.labelSmall,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      ValueListenableBuilder(
                        valueListenable: main.breakfast,
                        builder: (context, value, w) => Checkbox(
                          value: value,
                          onChanged: (value) {
                            main.breakfast.value = value!;
                          },
                        ),
                      ),
                      Text("صبحانه"),
                      SizedBox(width: 2),
                      ValueListenableBuilder(
                        valueListenable: main.lunch,
                        builder: (context, value, w) => Checkbox(
                          value: value,
                          onChanged: (value) {
                            main.lunch.value = value!;
                          },
                        ),
                      ),
                      Text("ناهار"),
                      SizedBox(width: 2),
                      ValueListenableBuilder(
                        valueListenable: main.dinner,
                        builder: (context, value, w) => Checkbox(
                          value: value,
                          onChanged: (value) {
                            main.dinner.value = value!;
                          },
                        ),
                      ),
                      Text("شام"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              AlphaButton(
                size: Size(double.infinity, 48),
                bgColor: theme.primaryColor,
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(CupertinoIcons.checkmark_alt, color: Colors.white),
                    Expanded(
                      child: Text(
                        "${room == null ? "ثبت" : "ذخیره"} اقامت",
                        style: theme.textTheme.labelMedium!.apply(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  main.insertOrUpdateResidence(room);
                  context.singlePop();
                },
              ),
              SizedBox(height: 8),
              Text(
                "Save/Edit      Control+Enter\nMove/Select        Tab|Enter",
                style: theme.textTheme.labelSmall!.apply(fontWeightDelta: -100),
              ),
            ],
          ),
        ),
      ),
    );
    if (room != null) {
      main.entourageCount.text = bEntourageCount;
      main.number.value = bNumber;
      main.fromDate.value = bFromDate;
      main.toDate = bToDate;
      main.breakfast.value = bBreakfast;
      main.lunch.value = bLunch;
      main.dinner.value = bDinner;
    }
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

  int getDays(int fromDate, int toDate) {
    return ((toDate - fromDate) / 1000 / 60 / 60 ~/ 24) + 1;
  }

  void showLocation(BuildContext context, MainCubit main, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AppWidgets.alertDialog(
        context,
        title: Text("آدرس"),
        content: Text(main.zaer!.address),
        actions: {"بستن": () => context.singlePop()},
      ),
    );
  }
}
