import 'package:sqlite3/sqlite3.dart';

class Report {
  int count;
  int entourageCount;
  int room1ZaerCount;
  int room2ZaerCount;
  int room3ZaerCount;
  int room4ZaerCount;
  int room5ZaerCount;
  int room6ZaerCount;
  int breakfastCount;
  int lunchCount;
  int dinnerCount;

  Report.fromDb(Row row)
      : count = row['count'],
        entourageCount = row['entourage_count'] ?? 0,
        room1ZaerCount = row['room1_zaer_count'] ?? 0,
        room2ZaerCount = row['room2_zaer_count'] ?? 0,
        room3ZaerCount = row['room3_zaer_count'] ?? 0,
        room4ZaerCount = row['room4_zaer_count'] ?? 0,
        room5ZaerCount = row['room5_zaer_count'] ?? 0,
        room6ZaerCount = row['room6_zaer_count'] ?? 0,
        breakfastCount = row['breakfast_count'] ?? 0,
        lunchCount = row['lunch_count'] ?? 0,
        dinnerCount = row['dinner_count'] ?? 0;
}
