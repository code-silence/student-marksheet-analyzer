import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../batch/batch_detail_screen.dart';
import '../../providers/batch_provider.dart';
import '../../providers/student_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<BatchProvider>();
    final studentProvider = context.watch<StudentProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text("Batches")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBatchDialog(context);
        },
        child: const Icon(Icons.add),
      ),

      body: batchProvider.batches.isEmpty
          ? const Center(child: Text("No batches yet"))
          : ListView.builder(
              itemCount: batchProvider.batches.length,
              itemBuilder: (context, index) {
                final batch = batchProvider.batches[index];

                final studentCount = studentProvider
                    .getByBatch(batch.id)
                    .length;

                return ListTile(
                  key: ValueKey(batch.id),
                  title: Text(batch.name),
                  subtitle: Text(
                    "$studentCount ${studentCount == 1 ? 'student' : 'students'}",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BatchDetailScreen(
                          batchId: batch.id,
                          batchName: batch.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showAddBatchDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Batch"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Batch name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<BatchProvider>(
                  context,
                  listen: false,
                ).addBatch(controller.text);

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
