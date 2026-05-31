import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exam_session_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/result_provider.dart';

class ResultEntryScreen extends StatelessWidget {
  final ExamSessionModel session;

  const ResultEntryScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().getByBatch(
      session.batchId,
    );

    return Scaffold(
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
        title: Text(session.title, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];

          return ListTile(
            title: Text(student.name),
            trailing: SizedBox(
              width: 80,
              child: ElevatedButton(
                onPressed: () {
                  _showMarksDialog(context, student.id, student.name);
                },
                child: const Text("Marks"),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMarksDialog(
    BuildContext context,
    String studentId,
    String studentName,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(studentName),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Marks"),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              context.read<ResultProvider>().saveResult(
                studentId: studentId,
                examSessionId: session.id,
                obtainedMarks: double.parse(controller.text),
              );

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
