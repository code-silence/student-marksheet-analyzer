import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_provider.dart';
import '../../providers/exam_session_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/student_provider.dart';

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
    final resultProvider = context.watch<ResultProvider>();
    final sessionProvider = context.watch<ExamSessionProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final student = studentProvider.getById(studentId);
    final examResults = examProvider.getByStudent(studentId);
    final bulkResults = resultProvider.getByStudent(studentId);
    final sessionMap = {
      for (final session in sessionProvider.sessions) session.id: session,
    };

    final combinedResults = [
      ...examResults.map(
        (e) => _StudentResult(
          id: e.id,
          title: e.examName,
          date: e.date,
          obtainedMarks: e.obtainedMarks,
          fullMarks: e.fullMarks,
          percentage: e.percentage,
          sourceLabel: 'Manual exam',
        ),
      ),
      ...bulkResults.map((result) {
        final session = sessionMap[result.examSessionId];
        return _StudentResult(
          id: result.id,
          title: session?.title ?? 'Bulk result',
          date: session?.date ?? DateTime.now(),
          obtainedMarks: result.obtainedMarks,
          fullMarks: session?.fullMarks ?? 0,
          percentage: session != null && session.fullMarks > 0
              ? (result.obtainedMarks / session.fullMarks) * 100
              : 0,
          sourceLabel: session != null
              ? 'Session • ${session.type}'
              : 'Bulk result',
        );
      }),
    ];

    combinedResults.sort((a, b) => b.date.compareTo(a.date));
    final avg = combinedResults.isEmpty
        ? 0
        : combinedResults.map((e) => e.percentage).reduce((a, b) => a + b) /
              combinedResults.length;
    final monthlyResults = combinedResults
        .where(
          (e) =>
              e.date.month == DateTime.now().month &&
              e.date.year == DateTime.now().year,
        )
        .toList();
    final monthlyAvg = monthlyResults.isEmpty
        ? 0
        : monthlyResults.map((e) => e.percentage).reduce((a, b) => a + b) /
              monthlyResults.length;
    final yearlyResults = combinedResults
        .where((e) => e.date.year == DateTime.now().year)
        .toList();
    final yearlyAvg = yearlyResults.isEmpty
        ? 0
        : yearlyResults.map((e) => e.percentage).reduce((a, b) => a + b) /
              yearlyResults.length;
    final totalExams = combinedResults.length;

    if (student == null) {
      return Scaffold(
        appBar: AppBar(title: Text(studentName)),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analysis',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showAnalysisEditor(context, student.analysis),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  student.analysis.isEmpty
                      ? 'No analysis yet. Tap edit to add notes.'
                      : student.analysis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text("This Month Avg: ${monthlyAvg.toStringAsFixed(2)}%"),
                Text("This Year Avg: ${yearlyAvg.toStringAsFixed(2)}%"),
                Text("Total Exams: $totalExams"),
              ],
            ),
          ),

          Expanded(
            child: combinedResults.isEmpty
                ? const Center(child: Text("No exam results yet"))
                : ListView.builder(
                    itemCount: combinedResults.length,
                    itemBuilder: (context, index) {
                      final result = combinedResults[index];
                      final scoreText = result.fullMarks > 0
                          ? "${result.obtainedMarks}/${result.fullMarks} (${result.percentage.toStringAsFixed(1)}%)"
                          : "${result.obtainedMarks} points";

                      return ListTile(
                        title: Text(result.title),
                        subtitle: Text(scoreText),
                        trailing: Text(result.sourceLabel),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAnalysisEditor(BuildContext context, String currentAnalysis) {
    final analysisCtrl = TextEditingController(text: currentAnalysis);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Student Analysis'),
        content: TextField(
          controller: analysisCtrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Enter notes or review for this student',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StudentProvider>().updateStudentAnalysis(
                studentId,
                analysisCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _StudentResult {
  final String id;
  final String title;
  final DateTime date;
  final double obtainedMarks;
  final double fullMarks;
  final double percentage;
  final String sourceLabel;

  _StudentResult({
    required this.id,
    required this.title,
    required this.date,
    required this.obtainedMarks,
    required this.fullMarks,
    required this.percentage,
    required this.sourceLabel,
  });
}
