import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final Box studentBox = Hive.box('students');
  final uuid = const Uuid();

  List<StudentModel> _students = [];

  List<StudentModel> get students => _students;

  StudentProvider() {
    loadStudents();
  }

  void loadStudents() {
    final data = studentBox.values.toList();

    _students = data
        .map((e) => StudentModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> addStudent({
    required String name,
    required String phone,
    required String batchId,
  }) async {
    final student = StudentModel(
      id: uuid.v4(),
      name: name,
      phone: phone,
      batchId: batchId,
    );

    await studentBox.put(student.id, student.toMap());

    _students.add(student);

    notifyListeners();
  }

  List<StudentModel> getByBatch(String batchId) {
    return _students.where((s) => s.batchId == batchId).toList();
  }
}