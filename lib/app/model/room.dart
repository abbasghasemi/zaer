import 'package:sqlite3/sqlite3.dart';
import 'package:zaer/app/model/zaer.dart';

class Room {
  int id;
  int createdAt;
  int updatedAt;
  int zaerId;
  int entourageCount;
  int fromDate;
  int toDate;
  int breakfast;
  int lunch;
  int dinner;
  int leaving;
  int number;
  Zaer? zaer;

  Room.fromDb(Row row)
    : id = row['room_id'],
      zaerId = row['zaer_id'],
      createdAt = row['room_created_at'],
      updatedAt = row['room_updated_at'],
      entourageCount = row['entourage_count'],
      fromDate = row['from_date'],
      toDate = row['to_date'],
      breakfast = row['breakfast'],
      lunch = row['lunch'],
      dinner = row['dinner'],
      leaving = row['leaving'],
      number = row['number'],
      zaer = row.containsKey('id') ? Zaer.fromDb(row) : null;

  Room()
    : id = 0,
      zaerId = 0,
      createdAt = 0,
      updatedAt = 0,
      entourageCount = 0,
      fromDate = 0,
      toDate = 0,
      breakfast = 0,
      lunch = 0,
      dinner = 0,
      number = 0,
      leaving = 0;
}
