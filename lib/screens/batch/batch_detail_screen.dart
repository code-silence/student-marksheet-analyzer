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

                return ListTile(
                  key: ValueKey(s.id),
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
                );
              },
            ),
    );
  }

  void _showAddStudent(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

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
}
