import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/exam_session_model.dart';

class ExamSessionProvider extends ChangeNotifier {
  final Box sessionBox = Hive.box('exam_sessions');

  final uuid = const Uuid();

  List<ExamSessionModel> _sessions = [];

  List<ExamSessionModel> get sessions => _sessions;

  ExamSessionProvider() {
    loadSessions();
  }

  void loadSessions() {
    final data = sessionBox.values.toList();

    _sessions = data
        .map((e) => ExamSessionModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> addSession({
    required String batchId,
    required String title,
    required String type,
    required double fullMarks,
  }) async {
    final session = ExamSessionModel(
      id: uuid.v4(),
      batchId: batchId,
      title: title,
      type: type,
      fullMarks: fullMarks,
      date: DateTime.now(),
    );

    await sessionBox.put(session.id, session.toMap());

    _sessions.add(session);

    notifyListeners();
  }

  ExamSessionModel? getById(String sessionId) {
    try {
      return _sessions.firstWhere((s) => s.id == sessionId);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteSession(String sessionId) async {
    await sessionBox.delete(sessionId);
    _sessions.removeWhere((s) => s.id == sessionId);
    notifyListeners();
  }

  Future<void> deleteByBatch(String batchId) async {
    final toRemove = _sessions.where((s) => s.batchId == batchId).toList();
    for (final session in toRemove) {
      await sessionBox.delete(session.id);
    }
    _sessions.removeWhere((s) => s.batchId == batchId);
    notifyListeners();
  }

  List<ExamSessionModel> getByBatch(String batchId) {
    return _sessions.where((s) => s.batchId == batchId).toList();
  }
}
