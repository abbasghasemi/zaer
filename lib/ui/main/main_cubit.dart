import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:zaer/app/db_controller.dart';
import 'package:zaer/app/model/room.dart';
import 'package:zaer/app/model/zaer.dart';
import 'package:zaer/routes_management.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  final DatabaseController db;

  MainCubit(this.db) : super(MainInitial());

  bool update = false;
  final firstNameFn = FocusNode();
  final lastNameFn = FocusNode();
  final fatherNameFn = FocusNode();
  final addressFn = FocusNode();
  final phoneNoFn = FocusNode();
  final nationalCodeFn = FocusNode();
  final passportNoFn = FocusNode();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final fatherName = TextEditingController();
  final address = TextEditingController();
  final phoneNo = TextEditingController();
  final nationalCode = TextEditingController();
  final passportNo = TextEditingController();
  final isMale = ValueNotifier(true);

  final nationalCodeSearch = TextEditingController();
  final phoneNoSearch = TextEditingController();
  final zaeran = ValueNotifier<List<Zaer>>([]);
  final loading = ValueNotifier(false);
  final preview = ValueNotifier(false);

  void Function(String message)? onMessage;
  void Function(String fragment)? onNavigate;
  Zaer? zaer;
  int zaerIndex = -1;

  final rooms = ValueNotifier<List<Room>?>(null);
  final rooms2 = ValueNotifier<List<Room>>([]);

  final entourageCount = TextEditingController(text: '0');
  final fromDate = ValueNotifier(0);
  int toDate = 0;
  final number = ValueNotifier(1);
  final breakfast = ValueNotifier(false);
  final lunch = ValueNotifier(false);
  final dinner = ValueNotifier(false);

  final fromDateSearch = ValueNotifier(0);
  int toDateSearch = 0;
  final fromDateResidenceSearch = ValueNotifier(true);

  void insertOrUpdateZaer() async {
    if (firstName.text.isEmpty) {
      onMessage?.call("نام نمی تواند خالی باشد.");
      firstNameFn.requestFocus();
    } else if (lastName.text.isEmpty) {
      onMessage?.call("نام خانوادگی نمی تواند خالی باشد.");
      lastNameFn.requestFocus();
    } else if (fatherName.text.isEmpty) {
      onMessage?.call("نام پدر نمی تواند خالی باشد.");
      fatherNameFn.requestFocus();
    } else if (phoneNo.text.isEmpty) {
      onMessage?.call("شماره همراه نمی تواند خالی باشد.");
      phoneNoFn.requestFocus();
    } else if (nationalCode.text.isEmpty) {
      onMessage?.call("کد ملی نمی تواند خالی باشد.");
      nationalCodeFn.requestFocus();
    } else if (passportNo.text.isEmpty) {
      onMessage?.call("شماره پاسپورت نمی تواند خالی باشد.");
      passportNoFn.requestFocus();
    } else {
      zaer ??= Zaer();
      zaer!
        ..firstName = firstName.text
        ..lastName = lastName.text
        ..fatherName = fatherName.text
        ..phoneNo = int.parse(phoneNo.text)
        ..nationalCode = nationalCode.text
        ..passportNo = passportNo.text
        ..isMale = isMale.value ? 1 : 0
        ..address = address.text;
      if (update) {
        if (db.updateZaer(zaer!)) {
          zaer!.updatedAt = DateTime.now().millisecondsSinceEpoch;
          onMessage?.call("بروزرسانی شد.");
        } else {
          onMessage?.call("در ارتباط با دیتابیس خطایی رویداده است.");
        }
      } else {
        if (!preview.value && zaer?.id != 0) {
          zaer?.id = 0;
        }
        db.insertZaer(zaer!);
        if (zaer!.id > 0) {
          zaer!.createdAt = DateTime.now().millisecondsSinceEpoch;
          onNavigate?.call(RoutesManagement.room);
          if (!preview.value) clearZaer();
        } else {
          onMessage?.call("در ارتباط با دیتابیس خطایی رویداده است.");
        }
      }
    }
  }

  void searchZaer() async {
    if (loading.value) return;
    if (phoneNoSearch.text.isEmpty &&
        nationalCodeSearch.text.isEmpty &&
        toDateSearch == 0) {
      onMessage?.call("همزمان هر سه فیلد نمی تواند خالی باشد.");
    } else {
      loading.value = true;
      final result = await db.zaers(
        int.tryParse(phoneNoSearch.text),
        int.tryParse(nationalCodeSearch.text),
        RangeValues(fromDateSearch.value.toDouble(), toDateSearch.toDouble()),
      );
      if (result.isEmpty && zaeran.value.isEmpty) {
        onMessage?.call("زائری پیدا نشد.");
      }
      zaeran.value = result;
      loading.value = false;
    }
  }

  void setZaerUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      firstName.text = zaer!.firstName;
      lastName.text = zaer!.lastName;
      fatherName.text = zaer!.fatherName;
      phoneNo.text = zaer!.phoneNo.toString();
      nationalCode.text = zaer!.nationalCode;
      address.text = zaer!.address;
      passportNo.text = zaer!.passportNo;
      isMale.value = zaer!.isMale == 1;
    });
  }

  void insertOrUpdateResidence(Room? room) {
    if (entourageCount.text.isEmpty) {
      entourageCount.text = "0";
    }
    if (toDate == 0) {
      return;
    }
    room ??= Room();
    room
      ..entourageCount = int.parse(entourageCount.text)
      ..fromDate = fromDate.value
      ..toDate = toDate
      ..number = number.value
      ..breakfast = breakfast.value ? 1 : 0
      ..lunch = lunch.value ? 1 : 0
      ..dinner = dinner.value ? 1 : 0;
    if (room.id != 0) {
      db.updateRoom(room);
      room.updatedAt = DateTime.now().millisecondsSinceEpoch;
      rooms.value = List.of(rooms.value!);
    } else {
      room.zaerId = zaer!.id;
      room.createdAt = DateTime.now().millisecondsSinceEpoch;
      db.insertRoom(room);
      rooms.value = List.of([...?rooms.value, room]);
    }
  }

  void searchRoom() async {
    if (loading.value) return;
    if (fromDateSearch.value == 0) {
      onMessage?.call("تاریخ انتخاب نشده است.");
    } else {
      loading.value = true;
      final result = await db.roomsByRange(
        fromDateResidenceSearch.value,
        fromDateSearch.value,
        toDateSearch,
      );
      if (result.isEmpty && rooms2.value.isEmpty) {
        onMessage?.call("موردی پیدا نشد.");
      }
      rooms2.value = result;
      loading.value = false;
    }
  }

  void getRooms() async {
    rooms.value = null;
    rooms.value = await db.roomsById(zaer!);
  }

  void clearZaer() {
    firstName.clear();
    lastName.clear();
    fatherName.clear();
    phoneNo.clear();
    nationalCode.clear();
    passportNo.clear();
    address.clear();
    zaer == null;
    if (preview.value) {
      preview.value = false;
    }
  }

  int currentZaerId = -1;

  void previous() async {
    if (currentZaerId == -1) {
      currentZaerId = db.maxZaerId() + 1;
    }
    if (!preview.value) {
      preview.value = true;
      if (currentZaerId != -1) {
        currentZaerId++;
      }
    }
    final result = await db.zaer(currentZaerId, false);
    if (result == null) {
      return;
    }
    currentZaerId = result.id;
    zaer = result;
    setZaerUpdate();
  }

  void next() async {
    if (currentZaerId == -1) {
      currentZaerId = db.maxZaerId() - 1;
    }
    if (!preview.value) {
      preview.value = true;
      if (currentZaerId != -1) {
        currentZaerId--;
      }
    }
    final result = await db.zaer(currentZaerId, true);
    if (result == null) {
      return;
    }
    currentZaerId = result.id;
    zaer = result;
    setZaerUpdate();
  }
}
