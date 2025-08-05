import 'package:sqlite3/sqlite3.dart';

class Zaer {
  int id;
  int createdAt;
  int updatedAt;
  String nationalCode;
  int phoneNo;
  String firstName;
  String lastName;
  String fatherName;
  String address;
  int isMale;
  String passportNo;

  Zaer.fromDb(Row row)
    : id = row['id'],
      createdAt = row['created_at'],
      updatedAt = row['updated_at'],
      nationalCode = row['national_code'],
      phoneNo = row['phone_no'],
      firstName = row['first_name'],
      lastName = row['last_name'],
      fatherName = row['father_name'],
      address = row['address'],
      isMale = row['is_male'],
      passportNo = row['passport_no'];

  Zaer()
    : id = 0,
      createdAt = 0,
      updatedAt = 0,
      nationalCode = "",
      phoneNo = 0,
      firstName = "",
      lastName = "",
      fatherName = "",
      address = "",
      isMale = 0,
      passportNo = "";
}
