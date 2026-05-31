import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../batch/batch_detail_screen.dart';
import '../../providers/batch_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/exam_session_provider.dart';
import '../../providers/result_provider.dart';
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
                final sessions = context.read<ExamSessionProvider>().getByBatch(
                  batch.id,
                );
                final studentCount = studentProvider
                    .getByBatch(batch.id)
                    .length;

                return Dismissible(
                  key: ValueKey(batch.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete batch'),
                        content: Text(
                          'Delete ${batch.name}? This will remove all students, sessions, and results in this batch.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    final examSessionProvider = context
                        .read<ExamSessionProvider>();
                    final resultProvider = context.read<ResultProvider>();
                    final examProvider = context.read<ExamProvider>();
                    final studentProvider = context.read<StudentProvider>();

                    for (final session in sessions) {
                      await resultProvider.deleteBySession(session.id);
                    }
                    await examSessionProvider.deleteByBatch(batch.id);
                    await examProvider.deleteByBatch(batch.id);
                    await studentProvider.deleteByBatch(batch.id);
                    await context.read<BatchProvider>().deleteBatch(batch.id);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${batch.name} deleted')),
                      );
                    }
                  },
                  child: ListTile(
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
                    onLongPress: () =>
                        _showEditBatchDialog(context, batch.id, batch.name),
                  ),
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

  void _showEditBatchDialog(
    BuildContext context,
    String batchId,
    String batchName,
  ) {
    final controller = TextEditingController(text: batchName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Batch"),
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
                ).updateBatch(batchId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
