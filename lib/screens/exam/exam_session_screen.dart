import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_session_provider.dart';
import '../../providers/result_provider.dart';
import 'bulk_result_screen.dart';

class ExamSessionScreen extends StatelessWidget {
  final String batchId;
  final String batchName;

  const ExamSessionScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExamSessionProvider>();

    final sessions = provider.getByBatch(batchId);

    return Scaffold(
      appBar: AppBar(title: Text("$batchName Exams")),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),

      body: sessions.isEmpty
          ? const Center(child: Text("No exams yet"))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];

                return Dismissible(
                  key: ValueKey(session.id),
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
                        title: const Text('Delete session'),
                        content: Text(
                          'Delete ${session.title}? This will remove saved results for this session.',
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
                    final resultProvider = context.read<ResultProvider>();
                    await resultProvider.deleteBySession(session.id);
                    await context.read<ExamSessionProvider>().deleteSession(
                      session.id,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${session.title} deleted')),
                      );
                    }
                  },
                  child: ListTile(
                    title: Text(session.title),
                    subtitle: Text("${session.type} • ${session.fullMarks}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BulkResultScreen(session: session),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();

    final marksCtrl = TextEditingController();

    String selectedType = "weekly";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add Exam"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: "Exam title"),
                ),

                const SizedBox(height: 10),

                DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: "weekly", child: Text("Weekly")),
                    DropdownMenuItem(value: "monthly", child: Text("Monthly")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),

                TextField(
                  controller: marksCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(hintText: "Full marks"),
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

              ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final fullMarks = double.tryParse(marksCtrl.text);
                  final messenger = ScaffoldMessenger.of(context);

                  if (title.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Exam title is required.')),
                    );
                    return;
                  }

                  if (fullMarks == null || fullMarks <= 0) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Full marks must be a positive number.'),
                      ),
                    );
                    return;
                  }

                  context.read<ExamSessionProvider>().addSession(
                    batchId: batchId,
                    title: title,
                    type: selectedType,
                    fullMarks: fullMarks,
                  );

                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }
}
