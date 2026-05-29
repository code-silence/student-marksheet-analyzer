import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox('batches');
    await Hive.openBox('students');
    await Hive.openBox('exams');
  }
}