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
    final batch = BatchModel(
      id: uuid.v4(),
      name: name,
    );

    await batchBox.put(batch.id, batch.toMap());

    _batches.add(batch);

    notifyListeners();
  }
}