import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zaer/app/db_controller.dart';
import 'package:zaer/app_extensions.dart';

class ReportActivity extends StatelessWidget {
  const ReportActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text("گزارشات")),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (e) {
          if (e is KeyDownEvent &&
              e.logicalKey == LogicalKeyboardKey.escape) {
            context.singlePop();
          }
        },
        child: FutureBuilder(
          future: context.read<DatabaseController>().reportRooms(),
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
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 8,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("تعداد زائران برنامه: ${data.first.count}"),
                      SizedBox(height: 8),
                      Text(
                        "حاضرین",
                        style: theme.textTheme.bodyMedium!.apply(
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        "تعداد زائران: ${data[1].count + data[1].entourageCount}",
                      ),
                      Text("تعداد همراهان: ${data[1].entourageCount}"),
                      Text("تعداد اقامت در اتاق 1: ${data[1].room1ZaerCount}"),
                      Text("تعداد اقامت در اتاق 2: ${data[1].room2ZaerCount}"),
                      Text("تعداد اقامت در اتاق 3: ${data[1].room3ZaerCount}"),
                      Text("تعداد اقامت در اتاق 4: ${data[1].room4ZaerCount}"),
                      Text("تعداد اقامت در اتاق 5: ${data[1].room5ZaerCount}"),
                      Text("تعداد اقامت در اتاق 6: ${data[1].room6ZaerCount}"),
                      Text("تعداد صبحانه: ${data[1].breakfastCount}"),
                      Text("تعداد ناهار: ${data[1].lunchCount}"),
                      Text("تعداد شام: ${data[1].dinnerCount}"),
                      SizedBox(height: 8),
                      Text(
                        "در انتظار خروج",
                        style: theme.textTheme.bodyMedium!.apply(
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        "تعداد زائران: ${data[2].count + data[2].entourageCount}",
                      ),
                      Text("تعداد همراهان: ${data[2].entourageCount}"),
                      Text("تعداد اقامت در اتاق 1: ${data[2].room1ZaerCount}"),
                      Text("تعداد اقامت در اتاق 2: ${data[2].room2ZaerCount}"),
                      Text("تعداد اقامت در اتاق 3: ${data[2].room3ZaerCount}"),
                      Text("تعداد اقامت در اتاق 4: ${data[2].room4ZaerCount}"),
                      Text("تعداد اقامت در اتاق 5: ${data[2].room5ZaerCount}"),
                      Text("تعداد اقامت در اتاق 6: ${data[2].room6ZaerCount}"),
                      Text(
                        "رزرو شده",
                        style: theme.textTheme.bodyMedium!.apply(
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        "تعداد زائران: ${data[3].count + data[3].entourageCount}",
                      ),
                      Text("تعداد همراهان: ${data[3].entourageCount}"),
                      Text("تعداد اقامت در اتاق 1: ${data[3].room1ZaerCount}"),
                      Text("تعداد اقامت در اتاق 2: ${data[3].room2ZaerCount}"),
                      Text("تعداد اقامت در اتاق 3: ${data[3].room3ZaerCount}"),
                      Text("تعداد اقامت در اتاق 4: ${data[3].room4ZaerCount}"),
                      Text("تعداد اقامت در اتاق 5: ${data[3].room5ZaerCount}"),
                      Text("تعداد اقامت در اتاق 6: ${data[3].room6ZaerCount}"),
                      Text(
                        "خارج شده",
                        style: theme.textTheme.bodyMedium!.apply(
                          color: theme.primaryColor,
                        ),
                      ),
                      Text(
                        "تعداد زائران: ${data[4].count + data[4].entourageCount}",
                      ),
                      Text("تعداد همراهان: ${data[4].entourageCount}"),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: CupertinoActivityIndicator(
                radius: 50,
                color: theme.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}
