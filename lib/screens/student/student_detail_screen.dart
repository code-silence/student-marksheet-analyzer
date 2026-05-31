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
    final Color performanceCardColor = avg < 40
        ? Colors.red.shade100
        : avg < 70
        ? Colors.yellow.shade100
        : Colors.green.shade100;

    if (student == null) {
      return Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(studentName, style: const TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.indigoAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(student.name, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            color: performanceCardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current performance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${avg.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on $totalExams exam ${totalExams == 1 ? 'result' : 'results'}.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Student notes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit notes',
                        onPressed: () =>
                            _showAnalysisEditor(context, student.analysis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student.analysis.isEmpty
                        ? 'No notes yet. Tap edit to add a quick observation.'
                        : student.analysis,
                    style: const TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'This month',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${monthlyAvg.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'This year',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${yearlyAvg.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            'Exam history',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          combinedResults.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No exam results yet. Results will appear here once they are added.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Column(
                  children: combinedResults.map((result) {
                    final scoreText = result.fullMarks > 0
                        ? '${result.obtainedMarks}/${result.fullMarks} (${result.percentage.toStringAsFixed(1)}%)'
                        : '${result.obtainedMarks} points';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        title: Text(
                          result.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${result.date.day}/${result.date.month}/${result.date.year} • $scoreText',
                        ),
                        trailing: Text(
                          result.sourceLabel,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }).toList(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit student notes'),
        content: TextField(
          controller: analysisCtrl,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Notes',
            hintText: 'Add or update your comment about this student',
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
            child: const Text('Save notes'),
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
