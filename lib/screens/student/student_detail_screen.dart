import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_provider.dart';
import '../../models/exam_model.dart';
import '../../services/analytics_service.dart';

class StudentDetailScreen extends StatelessWidget {
  final String studentId;
  final String studentName;
  final String batchId;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.batchId,
  });

  @override
  Widget build(BuildContext context) {
    final examProvider = context.watch<ExamProvider>();

    final exams = examProvider.getByStudent(studentId);
    final avg = examProvider.studentAverage(studentId);

    return Scaffold(
      appBar: AppBar(title: Text(studentName)),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExam(context),
        child: const Icon(Icons.add_chart),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Text(
              "Average: ${avg.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 18),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  "This Month Avg: ${AnalyticsService.monthlyAverage(exams, DateTime.now().month, DateTime.now().year).toStringAsFixed(2)}%",
                ),
                Text(
                  "This Year Avg: ${AnalyticsService.yearlyAverage(exams, DateTime.now().year).toStringAsFixed(2)}%",
                ),
                Text("Total Exams: ${AnalyticsService.totalExams(exams)}"),
              ],
            ),
          ),

          Expanded(
            child: exams.isEmpty
                ? const Center(child: Text("No exams yet"))
                : ListView.builder(
                    itemCount: exams.length,
                    itemBuilder: (context, index) {
                      final e = exams[index];

                      return ListTile(
                        title: Text(e.examName),
                        subtitle: Text(
                          "${e.obtainedMarks}/${e.fullMarks} (${e.percentage.toStringAsFixed(1)}%)",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddExam(BuildContext context) {
    final nameCtrl = TextEditingController();
    final obtainedCtrl = TextEditingController();
    final fullCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Exam Result"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: "Exam Name"),
            ),
            TextField(
              controller: obtainedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Obtained Marks"),
            ),
            TextField(
              controller: fullCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Full Marks"),
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
                final exam = ExamModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  studentId: studentId,
                  batchId: batchId,
                  examName: nameCtrl.text,
                  examType: "manual",
                  obtainedMarks: double.parse(obtainedCtrl.text),
                  fullMarks: double.parse(fullCtrl.text),
                  date: DateTime.now(),
                );

                context.read<ExamProvider>().addExam(exam);

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
