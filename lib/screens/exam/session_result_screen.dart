import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exam_session_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/result_provider.dart';

class SessionResultScreen extends StatelessWidget {
  final ExamSessionModel session;

  const SessionResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().getByBatch(
      session.batchId,
    );

    final results = context.watch<ResultProvider>().results;

    // build ranking list
    List<Map<String, dynamic>> ranked = [];

    for (final s in students) {
      final r = results.where(
        (e) => e.studentId == s.id && e.examSessionId == session.id,
      );

      final marks = r.isNotEmpty ? r.first.obtainedMarks : 0;

      ranked.add({"name": s.name, "marks": marks});
    }

    ranked.sort((a, b) => b["marks"].compareTo(a["marks"]));
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
        title: Text(
          "${session.title} Result",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: ranked.length,
        itemBuilder: (context, index) {
          final item = ranked[index];

          return ListTile(
            leading: Text("#${index + 1}"),
            title: Text(item["name"]),
            trailing: Text("${item["marks"]}/${session.fullMarks}"),
          );
        },
      ),
    );
  }
}
