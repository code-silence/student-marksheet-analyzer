import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/exam_model.dart';

class ExamProvider extends ChangeNotifier {
  final Box examBox = Hive.box('exams');
  final uuid = const Uuid();

  List<ExamModel> _exams = [];

  List<ExamModel> get exams => _exams;

  ExamProvider() {
    loadExams();
  }

  void loadExams() {
    final data = examBox.values.toList();

    _exams = data
        .map((e) => ExamModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> addExam(ExamModel exam) async {
    await examBox.put(exam.id, exam.toMap());

    _exams.add(exam);
    notifyListeners();
  }

  Future<void> deleteByStudent(String studentId) async {
    final toRemove = _exams.where((e) => e.studentId == studentId).toList();
    for (final exam in toRemove) {
      await examBox.delete(exam.id);
    }
    _exams.removeWhere((e) => e.studentId == studentId);
    notifyListeners();
  }

  Future<void> deleteByBatch(String batchId) async {
    final toRemove = _exams.where((e) => e.batchId == batchId).toList();
    for (final exam in toRemove) {
      await examBox.delete(exam.id);
    }
    _exams.removeWhere((e) => e.batchId == batchId);
    notifyListeners();
  }

  List<ExamModel> getByStudent(String studentId) {
    return _exams.where((e) => e.studentId == studentId).toList();
  }

  double studentAverage(String studentId) {
    final list = getByStudent(studentId);
    if (list.isEmpty) return 0;

    return list.map((e) => e.percentage).reduce((a, b) => a + b) / list.length;
  }
}
