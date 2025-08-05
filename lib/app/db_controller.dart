import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show RangeValues;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:zaer/app/model/Report.dart';
import 'package:zaer/app/model/room.dart';
import 'package:zaer/app/model/zaer.dart';

class DatabaseController {
  final Database db = sqlite3.open("zaer.db");

  DatabaseController() {
    db.execute('''
    CREATE TABLE IF NOT EXISTS zaeran (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      national_code TEXT UNIQUE NOT NULL,
      phone_no INTEGER NOT NULL,
      first_name TEXT NOT NULL,
      last_name TEXT NOT NULL,
      father_name TEXT NOT NULL,
      is_male INTEGER NOT NULL,
      passport_no TEXT NOT NULL,
      address TEXT NOT NULL
    );
    CREATE INDEX IF NOT EXISTS idx_phone_no ON zaeran(phone_no);
  ''');

    db.execute('''
    CREATE TABLE IF NOT EXISTS rooms (
      room_id INTEGER NOT NULL PRIMARY KEY,
      zaer_id INTEGER NOT NULL,
      room_created_at INTEGER NOT NULL,
      room_updated_at INTEGER NOT NULL,
      entourage_count INTEGER NOT NULL,
      from_date INTEGER NOT NULL,
      to_date INTEGER NOT NULL,
      breakfast INTEGER NOT NULL,
      lunch INTEGER NOT NULL,
      dinner INTEGER NOT NULL,
      leaving INTEGER NOT NULL DEFAULT 0,
      number INTEGER NOT NULL
    );
    CREATE INDEX IF NOT EXISTS idx_zaer_id ON rooms(zaer_id);
    CREATE INDEX IF NOT EXISTS idx_from_date ON rooms(from_date);
    CREATE INDEX IF NOT EXISTS idx_to_date ON rooms(to_date);
    CREATE INDEX IF NOT EXISTS idx_leaving ON rooms(leaving);
  ''');
  }

  void insertZaer(Zaer zaer, [bool requireCheck = true]) {
    if (requireCheck) {
      if (zaer.id != 0) {
        updateZaer(zaer);
        return;
      }
      final ResultSet resultSet = db.select(
        'SELECT * FROM zaeran WHERE national_code = ?;',
        [zaer.nationalCode],
      );
      final check = resultSet.firstOrNull;
      if (check != null) {
        zaer.id = check['id'];
        updateZaer(zaer);
        return;
      }
    }
    final stmt = db.prepare(
      'INSERT INTO zaeran (created_at,updated_at,national_code,phone_no,first_name,last_name,father_name,is_male,passport_no,address) VALUES (?,?,?,?,?,?,?,?,?,?)',
    );
    stmt.execute([
      DateTime.now().millisecondsSinceEpoch,
      0,
      zaer.nationalCode,
      zaer.phoneNo,
      zaer.firstName,
      zaer.lastName,
      zaer.fatherName,
      zaer.isMale,
      zaer.passportNo,
      zaer.address,
    ]);
    stmt.dispose();
    zaer.id = db.lastInsertRowId;
  }

  bool updateZaer(Zaer zaer) {
    db.execute(
      'UPDATE zaeran SET updated_at = ?, phone_no = ?,first_name = ?,last_name = ?,father_name = ?, is_male = ?, passport_no = ?,address = ? WHERE id = ?;',
      [
        DateTime.now().millisecondsSinceEpoch,
        zaer.phoneNo,
        zaer.firstName,
        zaer.lastName,
        zaer.fatherName,
        zaer.isMale,
        zaer.passportNo,
        zaer.address,
        zaer.id,
      ],
    );
    return db.updatedRows > 0;
  }

  bool deleteZaer(Zaer zaer) {
    db.execute('DELETE FROM zaeran WHERE id = ?', [zaer.id]);
    return db.updatedRows > 0;
  }

  void insertRoom(Room room) {
    final stmt = db.prepare(
      'INSERT INTO rooms (zaer_id,room_created_at,room_updated_at,entourage_count,from_date,to_date,breakfast,lunch,dinner,number) VALUES (?,?,?,?,?,?,?,?,?,?)',
    );
    stmt.execute([
      room.zaerId,
      DateTime.now().millisecondsSinceEpoch,
      0,
      room.entourageCount,
      room.fromDate,
      room.toDate,
      room.breakfast,
      room.lunch,
      room.dinner,
      room.number,
    ]);
    stmt.dispose();
    room.id = db.lastInsertRowId;
  }

  bool updateRoom(Room room) {
    db.execute(
      'UPDATE rooms SET room_updated_at = ?, entourage_count = ?,from_date = ?, to_date = ?,breakfast = ?, lunch = ?, dinner = ?, leaving = ?, number = ? WHERE room_id = ?',
      [
        DateTime.now().millisecondsSinceEpoch,
        room.entourageCount,
        room.fromDate,
        room.toDate,
        room.breakfast,
        room.lunch,
        room.dinner,
        room.leaving,
        room.number,
        room.id,
      ],
    );
    return db.updatedRows > 0;
  }

  bool deleteRoom(Room room) {
    db.execute('DELETE FROM rooms WHERE room_id = ?', [room.id]);
    return db.updatedRows > 0;
  }

  Future<List<Room>> revolted() async {
    final ResultSet resultSet = db.select(
      'SELECT rooms.*,zaeran.* FROM rooms LEFT JOIN zaeran ON zaeran.id = rooms.zaer_id WHERE to_date <= ? AND leaving = 0',
      [DateTime.now().millisecondsSinceEpoch],
    );
    final List<Room> rooms = [];
    for (final Row row in resultSet) {
      rooms.add(Room.fromDb(row));
    }
    return rooms;
  }

  Future<List<Room>> roomsByRange(bool begin, int fromDate, int toDate) async {
    final ResultSet resultSet = db.select(
      'SELECT rooms.*,zaeran.* FROM rooms LEFT JOIN zaeran ON zaeran.id = rooms.zaer_id WHERE ${begin ? 'from_date' : 'to_date'} BETWEEN ? AND ?;',
      [fromDate, toDate],
    );
    final List<Room> rooms = [];
    for (final Row row in resultSet) {
      rooms.add(Room.fromDb(row));
    }
    return rooms;
  }

  Future<List<Room>> roomsById(Zaer zaer) async {
    final ResultSet resultSet = db.select(
      'SELECT * FROM rooms WHERE zaer_id = ?;',
      [zaer.id],
    );
    final List<Room> rooms = [];
    for (final Row row in resultSet) {
      rooms.add(Room.fromDb(row));
    }
    return rooms;
  }

  Future<List<Zaer>> zaers(
    int? phoneNo,
    int? nationalCode,
    RangeValues? date,
  ) async {
    final keys = [];
    final values = [];
    if (phoneNo != null) {
      keys.add("phone_no = ?");
      values.add(phoneNo);
    }
    if (nationalCode != null) {
      keys.add("national_code = ?");
      values.add(nationalCode);
    }
    if (date != null) {
      keys.add("created_at BETWEEN ? AND ?");
      values.add(date.start);
      values.add(date.end);
    }
    final resultSet = db.select(
      'SELECT * FROM zaeran WHERE ${keys.join(' or ')};',
      values,
    );
    final List<Zaer> zaers = [];
    for (final Row row in resultSet) {
      zaers.add(Zaer.fromDb(row));
    }
    return zaers;
  }

  int maxZaerId() {
    final ResultSet resultSet = db.select('SELECT MAX(id) AS mid FROM zaeran;');
    return resultSet.first['mid'];
  }

  Future<Zaer?> zaer(int currentId, bool next) async {
    final resultSet = db.select(
      'SELECT * FROM zaeran WHERE id ${next ? '>' : '<'} ? ORDER BY id ${next ? 'ASC' : 'DESC'} LIMIT 1;',
      [currentId],
    );
    final res = resultSet.firstOrNull;
    if (res != null) {
      return Zaer.fromDb(res);
    }
    return null;
  }

  Future<List<Report>> reportRooms() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final List<Report> list = [];
    ResultSet resultSet = db.select('SELECT COUNT(*) AS count FROM zaeran;');
    list.add(Report.fromDb(resultSet.first));
    resultSet = db.select(
      '''
    SELECT COUNT(*) AS count,SUM(entourage_count) AS entourage_count,SUM(IIF(number = 1,entourage_count+1,0)) AS room1_zaer_count
    ,SUM(IIF(number = 2,entourage_count+1,0)) AS room2_zaer_count,SUM(IIF(number = 3,entourage_count+1,0)) AS room3_zaer_count
    ,SUM(IIF(number = 4,entourage_count+1,0)) AS room4_zaer_count,SUM(IIF(number = 5,entourage_count+1,0)) AS room5_zaer_count
    ,SUM(IIF(number = 6,entourage_count+1,0)) AS room6_zaer_count,SUM(breakfast) AS breakfast_count,SUM(lunch) AS lunch_count
    ,SUM(dinner) AS dinner_count
    FROM rooms
    WHERE from_date <= ? AND to_date >= ? AND leaving = 0;
    ''',
      [timestamp, timestamp],
    );
    list.add(Report.fromDb(resultSet.first));
    resultSet = db.select(
      '''
    SELECT COUNT(*) AS count,SUM(entourage_count) AS entourage_count,SUM(IIF(number = 1,entourage_count+1,0)) AS room1_zaer_count
    ,SUM(IIF(number = 2,entourage_count+1,0)) AS room2_zaer_count,SUM(IIF(number = 3,entourage_count+1,0)) AS room3_zaer_count
    ,SUM(IIF(number = 4,entourage_count+1,0)) AS room4_zaer_count,SUM(IIF(number = 5,entourage_count+1,0)) AS room5_zaer_count
    ,SUM(IIF(number = 6,entourage_count+1,0)) AS room6_zaer_count
    FROM rooms WHERE to_date <= ? AND leaving = 0;
    ''',
      [timestamp],
    );
    list.add(Report.fromDb(resultSet.first));

    resultSet = db.select(
      '''
    SELECT COUNT(*) AS count,SUM(entourage_count) AS entourage_count,SUM(IIF(number = 1,entourage_count+1,0)) AS room1_zaer_count
    ,SUM(IIF(number = 2,entourage_count+1,0)) AS room2_zaer_count,SUM(IIF(number = 3,entourage_count+1,0)) AS room3_zaer_count
    ,SUM(IIF(number = 4,entourage_count+1,0)) AS room4_zaer_count,SUM(IIF(number = 5,entourage_count+1,0)) AS room5_zaer_count
    ,SUM(IIF(number = 6,entourage_count+1,0)) AS room6_zaer_count
    FROM rooms WHERE from_date > ? AND leaving = 0;
    ''',
      [timestamp],
    );
    list.add(Report.fromDb(resultSet.first));

    resultSet = db.select('''
    SELECT COUNT(*) AS count,SUM(entourage_count) AS entourage_count FROM rooms WHERE leaving = 1;
    ''');
    list.add(Report.fromDb(resultSet.first));
    return list;
  }

  Future<void> backupCSV(
    String directory,
    bool backupZaeran,
    bool backupRooms,
  ) async {
    final sep = Platform.pathSeparator;
    File zaeran = File("$directory${sep}zaeran.csv");
    File rooms = File("$directory${sep}rooms.csv");
    if (backupZaeran) {
      IOSink file = zaeran.openWrite(mode: FileMode.writeOnly);
      file.add([0xEf, 0xBB, 0xBF]);
      ResultSet result = db.select('SELECT * FROM zaeran;', []);
      file.writeln(
        "آیدی,تاریخ ایجاد,تاریخ بروزرسانی,کد ملی,شماره تماس,نام,نام خانوادگی,نام پدر,آدرس,جنسیت,شماره پاسپورت",
      );
      for (var row in result) {
        file.writeln(
          '${row['id']},"${Jalali.fromMillisecondsSinceEpoch(row['created_at']).toJalaliDateTime()}",'
          '"${row['updated_at'] == 0 ? '' : Jalali.fromMillisecondsSinceEpoch(row['updated_at']).toJalaliDateTime()}",'
          '"${row['national_code']}",${row['phone_no']},"${row['first_name']}","${row['last_name']}",'
          '"${row['father_name']}","${row['address']}","${row['is_male'] == 1 ? 'مرد' : 'زن'}","${row['passport_no']}"',
        );
      }
      await file.flush();
      await file.close();
    }

    if (backupRooms) {
      final file = rooms.openWrite(mode: FileMode.writeOnly);
      file.add([0xEf, 0xBB, 0xBF]);
      final result = db.select('SELECT * FROM rooms;', []);
      file.writeln(
        "آیدی,آیدی زائر,تاریخ ایجاد,تاریخ بروزرسانی,تعداد همراه,از تاریخ,تا تاریخ,صبحانه,ناهار,شام,خارج شده,شماره اتاق",
      );
      for (var row in result) {
        file.writeln(
          '${row['room_id']},${row['zaer_id']},"${Jalali.fromMillisecondsSinceEpoch(row['room_created_at']).toJalaliDateTime()}",'
          '"${row['room_updated_at'] == 0 ? '' : Jalali.fromMillisecondsSinceEpoch(row['room_updated_at']).toJalaliDateTime()}",${row['entourage_count']},'
          '"${Jalali.fromMillisecondsSinceEpoch(row['from_date']).toJalaliDateTime()}",'
          '"${Jalali.fromMillisecondsSinceEpoch(row['to_date']).toJalaliDateTime()}",'
          '${row['breakfast']},${row['lunch']},${row['dinner']},${row['leaving']},${row['number']}',
        );
      }
      await file.flush();
      await file.close();
    }
  }

  Future<void> loadCSV(String path, bool append) async {
    final isZaeran = path.endsWith("zaeran.csv");
    if (!(isZaeran || path.endsWith("rooms.csv"))) {
      return;
    }
    final io = File(
      path,
    ).openRead().transform(utf8.decoder).transform(LineSplitter());
    if (append) {
      db.execute("DELETE FROM ${isZaeran ? 'zaeran' : 'rooms'};");
      db.execute("VACUUM;");
    }
    if (isZaeran) {
      await for (var line in io.skip(1)) {
        final data = line.split(",");
        final zaer = Zaer()
          ..id = int.parse(data.first)
          ..createdAt = DateTime.parse(
            data[1].substring(1, 20),
          ).millisecondsSinceEpoch
          ..updatedAt = data[2].length == 2
              ? 0
              : DateTime.parse(data[2].substring(1, 20)).millisecondsSinceEpoch
          ..nationalCode = data[3].replaceAll('"', "")
          ..phoneNo = int.parse(data[4])
          ..firstName = data[5].replaceAll('"', "")
          ..lastName = data[6].replaceAll('"', "")
          ..fatherName = data[7].replaceAll('"', "")
          ..address = data[8].replaceAll('"', "")
          ..isMale = data[9] == '"مرد"' ? 1 : 0
          ..passportNo = data[10].replaceAll('"', "");
        try {
          insertZaer(zaer, false);
        } catch (e) {
          //
        }
      }
    } else {
      await for (var line in io.skip(1)) {
        final data = line.split(",");
        final room = Room()
          ..id = int.parse(data.first)
          ..zaerId = int.parse(data[1])
          ..createdAt = DateTime.parse(
            data[2].substring(1, 20),
          ).millisecondsSinceEpoch
          ..updatedAt = data[3].length == 2
              ? 0
              : DateTime.parse(data[3].substring(1, 20)).millisecondsSinceEpoch
          ..entourageCount = int.parse(data[4])
          ..fromDate = DateTime.parse(
            data[5].substring(1, 20),
          ).millisecondsSinceEpoch
          ..toDate = DateTime.parse(
            data[6].substring(1, 20),
          ).millisecondsSinceEpoch
          ..breakfast = int.parse(data[7])
          ..lunch = int.parse(data[8])
          ..dinner = int.parse(data[9])
          ..leaving = int.parse(data[10])
          ..number = int.parse(data[11]);
        try {
          insertRoom(room);
        } catch (e) {
          //
        }
      }
    }
  }

  void close() {
    db.dispose();
  }
}
