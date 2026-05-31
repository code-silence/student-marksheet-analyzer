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
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "$batchName exams",
          style: const TextStyle(color: Colors.white),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Exam Session'),
      ),

      body: sessions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.event_note_outlined,
                      size: 72,
                      color: Colors.blueGrey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No exam sessions yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a session to start recording bulk exam results for this batch.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];

                return Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirm removal'),
                        content: Text(
                          'Delete "${session.title}" and all its saved results? This action is permanent.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Keep session'),
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
                        SnackBar(
                          content: Text('Session "${session.title}" removed'),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      title: Text(
                        session.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${session.type[0].toUpperCase()}${session.type.substring(1)} • ${session.fullMarks} full marks',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BulkResultScreen(session: session),
                          ),
                        );
                      },
                    ),
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
            title: const Text("Add Exam Session"),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Session title',
                    hintText: 'Example: Weekly Quiz 1',
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Session type'),
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

                const SizedBox(height: 12),
                TextField(
                  controller: marksCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Full marks',
                    hintText: 'Total achievable score',
                  ),
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
                      const SnackBar(
                        content: Text('Please enter a session title.'),
                      ),
                    );
                    return;
                  }

                  if (fullMarks == null || fullMarks <= 0) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Full marks must be greater than zero.'),
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
                child: const Text("Create session"),
              ),
            ],
          );
        },
      ),
    );
  }
}
