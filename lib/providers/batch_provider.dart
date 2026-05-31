import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/batch_model.dart';

class BatchProvider extends ChangeNotifier {
  final Box batchBox = Hive.box('batches');
  final uuid = const Uuid();

  List<BatchModel> _batches = [];

  List<BatchModel> get batches => _batches;

  BatchProvider() {
    loadBatches();
  }

  void loadBatches() {
    final data = batchBox.values.toList();

    _batches = data
        .map((e) => BatchModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    notifyListeners();
  }

  Future<void> addBatch(String name) async {
    final batch = BatchModel(id: uuid.v4(), name: name);

    await batchBox.put(batch.id, batch.toMap());

    _batches.add(batch);

    notifyListeners();
  }

  Future<void> updateBatch(String batchId, String name) async {
    final index = _batches.indexWhere((b) => b.id == batchId);
    if (index == -1) return;

    final updated = BatchModel(id: batchId, name: name);
    _batches[index] = updated;

    await batchBox.put(batchId, updated.toMap());
    notifyListeners();
  }

  Future<void> deleteBatch(String batchId) async {
    await batchBox.delete(batchId);
    _batches.removeWhere((b) => b.id == batchId);
    notifyListeners();
  }
}
