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
    String analysis = '',
  }) async {
    final student = StudentModel(
      id: uuid.v4(),
      name: name,
      phone: phone,
      batchId: batchId,
      analysis: analysis,
    );

    await studentBox.put(student.id, student.toMap());

    _students.add(student);

    notifyListeners();
  }

  StudentModel? getById(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStudentAnalysis(String studentId, String analysis) async {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final updated = _students[index].copyWith(analysis: analysis);
    _students[index] = updated;

    await studentBox.put(studentId, updated.toMap());
    notifyListeners();
  }

  Future<void> updateStudent({
    required String studentId,
    required String name,
    required String phone,
    required String analysis,
  }) async {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index == -1) return;

    final updated = _students[index].copyWith(
      name: name,
      phone: phone,
      analysis: analysis,
    );
    _students[index] = updated;

    await studentBox.put(studentId, updated.toMap());
    notifyListeners();
  }

  Future<void> deleteStudent(String studentId) async {
    await studentBox.delete(studentId);
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
  }

  Future<void> deleteByBatch(String batchId) async {
    final toRemove = _students.where((s) => s.batchId == batchId).toList();
    for (final student in toRemove) {
      await studentBox.delete(student.id);
    }
    _students.removeWhere((s) => s.batchId == batchId);
    notifyListeners();
  }

  List<StudentModel> getByBatch(String batchId) {
    return _students.where((s) => s.batchId == batchId).toList();
  }
}
