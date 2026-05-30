import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/exam_session_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/result_provider.dart';
import 'session_result_screen.dart';

class BulkResultScreen extends StatefulWidget {
  final ExamSessionModel session;

  const BulkResultScreen({super.key, required this.session});

  @override
  State<BulkResultScreen> createState() => _BulkResultScreenState();
}

class _BulkResultScreenState extends State<BulkResultScreen> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void dispose() {
    // ✅ prevent memory leaks
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().getByBatch(
      widget.session.batchId,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.session.title)),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                final existingResult = context
                    .read<ResultProvider>()
                    .getStudentResult(student.id, widget.session.id);

                final controller = controllers.putIfAbsent(
                  student.id,
                  () => TextEditingController(
                    text: existingResult?.obtainedMarks.toString(),
                  ),
                );

                return ListTile(
                  title: Text(student.name),
                  subtitle: Text("Out of ${widget.session.fullMarks}"),
                  trailing: SizedBox(
                    width: 80,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*$'),
                        ),
                      ],
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // SAVE BUTTON
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final provider = context.read<ResultProvider>();
                        final parsedValues = <String, double>{};

                        for (final student in students) {
                          final text =
                              controllers[student.id]?.text.trim() ?? '';

                          if (text.isEmpty) continue;

                          final obtained = double.tryParse(text);
                          if (obtained == null ||
                              obtained < 0 ||
                              obtained > widget.session.fullMarks) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Enter valid marks for ${student.name}. Max ${widget.session.fullMarks}.',
                                ),
                              ),
                            );
                            return;
                          }

                          parsedValues[student.id] = obtained;
                        }

                        if (parsedValues.isEmpty) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter at least one valid result.',
                              ),
                            ),
                          );
                          return;
                        }

                        for (final entry in parsedValues.entries) {
                          await provider.saveResult(
                            studentId: entry.key,
                            examSessionId: widget.session.id,
                            obtainedMarks: entry.value,
                          );
                        }

                        if (!mounted) return;
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('Results saved')),
                        );
                      },
                      child: const Text("Save"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // VIEW RESULT BUTTON (OPTION B)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SessionResultScreen(session: widget.session),
                          ),
                        );
                      },
                      child: const Text("View Result"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
