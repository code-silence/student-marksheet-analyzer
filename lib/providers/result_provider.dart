import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/result_model.dart';

class ResultProvider extends ChangeNotifier {
  final Box resultBox = Hive.box('results');

  final uuid = const Uuid();

  List<ResultModel> _results = [];

  List<ResultModel> get results => _results;

  ResultProvider() {
    loadResults();
  }

  void loadResults() {
    final data = resultBox.values.toList();

    _results = data
        .map((e) => ResultModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> saveResult({
    required String studentId,
    required String examSessionId,
    required double obtainedMarks,
  }) async {
    final existing = _results.where(
      (r) => r.studentId == studentId && r.examSessionId == examSessionId,
    );

    if (existing.isNotEmpty) {
      final old = existing.first;

      final updated = ResultModel(
        id: old.id,
        studentId: studentId,
        examSessionId: examSessionId,
        obtainedMarks: obtainedMarks,
      );

      await resultBox.put(old.id, updated.toMap());

      final index = _results.indexWhere((r) => r.id == old.id);

      _results[index] = updated;
    } else {
      final result = ResultModel(
        id: uuid.v4(),
        studentId: studentId,
        examSessionId: examSessionId,
        obtainedMarks: obtainedMarks,
      );

      await resultBox.put(result.id, result.toMap());

      _results.add(result);
    }

    notifyListeners();
  }

  ResultModel? getStudentResult(String studentId, String examSessionId) {
    try {
      return _results.firstWhere(
        (r) => r.studentId == studentId && r.examSessionId == examSessionId,
      );
    } catch (_) {
      return null;
    }
  }

  List<ResultModel> getByStudent(String studentId) {
    return _results.where((r) => r.studentId == studentId).toList();
  }

  Future<void> deleteByStudent(String studentId) async {
    final toRemove = _results.where((r) => r.studentId == studentId).toList();
    for (final result in toRemove) {
      await resultBox.delete(result.id);
    }
    _results.removeWhere((r) => r.studentId == studentId);
    notifyListeners();
  }

  Future<void> deleteBySession(String sessionId) async {
    final toRemove = _results
        .where((r) => r.examSessionId == sessionId)
        .toList();
    for (final result in toRemove) {
      await resultBox.delete(result.id);
    }
    _results.removeWhere((r) => r.examSessionId == sessionId);
    notifyListeners();
  }

  List<ResultModel> getBySession(String sessionId) {
    return _results.where((r) => r.examSessionId == sessionId).toList();
  }
}
