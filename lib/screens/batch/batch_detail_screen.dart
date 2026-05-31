import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/student_provider.dart';
import '../exam/exam_session_screen.dart';
import '../student/student_detail_screen.dart';

class BatchDetailScreen extends StatelessWidget {
  final String batchId;
  final String batchName;

  const BatchDetailScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();

    final students = studentProvider.getByBatch(batchId);

    return Scaffold(
      appBar: AppBar(
        title: Text(batchName),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ExamSessionScreen(batchId: batchId, batchName: batchName),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudent(context),
        child: const Icon(Icons.person_add),
      ),

      body: students.isEmpty
          ? const Center(child: Text("No students yet"))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];

                return Dismissible(
                  key: ValueKey(s.id),
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
                        title: const Text('Delete student'),
                        content: Text(
                          'Delete ${s.name}? This action cannot be undone.',
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
                  onDismissed: (_) {
                    context.read<StudentProvider>().deleteStudent(s.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${s.name} deleted')),
                    );
                  },
                  child: ListTile(
                    title: Text(s.name),
                    subtitle: Text(s.phone),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentDetailScreen(
                            studentId: s.id,
                            studentName: s.name,
                            batchId: batchId,
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _showEditStudentDialog(context, s),
                  ),
                );
              },
            ),
    );
  }

  void _showAddStudent(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final analysisCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(hintText: "Phone"),
            ),
            TextField(
              controller: analysisCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Initial Analysis (optional)",
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
              if (nameCtrl.text.isNotEmpty) {
                context.read<StudentProvider>().addStudent(
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                  batchId: batchId,
                  analysis: analysisCtrl.text.trim(),
                );

                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditStudentDialog(BuildContext context, student) {
    final nameCtrl = TextEditingController(text: student.name);
    final phoneCtrl = TextEditingController(text: student.phone);
    final analysisCtrl = TextEditingController(text: student.analysis);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(hintText: "Phone"),
            ),
            TextField(
              controller: analysisCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: "Analysis"),
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
              if (nameCtrl.text.isNotEmpty) {
                context.read<StudentProvider>().updateStudent(
                  studentId: student.id,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  analysis: analysisCtrl.text.trim(),
                );
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
