import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_session_provider.dart';
import 'result_entry_screen.dart';
import 'bulk_result_screen.dart';
import 'session_result_screen.dart';

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

                return ListTile(
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
                  keyboardType: TextInputType.number,
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
                  context.read<ExamSessionProvider>().addSession(
                    batchId: batchId,
                    title: titleCtrl.text,
                    type: selectedType,
                    fullMarks: double.parse(marksCtrl.text),
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
