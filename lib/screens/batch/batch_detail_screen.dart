import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/exam_provider.dart';
import '../../providers/exam_session_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/student_provider.dart';
import '../exam/exam_session_screen.dart';
import '../student/student_detail_screen.dart';

enum StudentSortOption { alphabeticalAsc, alphabeticalDesc, performanceDesc }

class BatchDetailScreen extends StatefulWidget {
  final String batchId;
  final String batchName;

  const BatchDetailScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  StudentSortOption _sortOption = StudentSortOption.alphabeticalAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value.trim();
    });
  }

  void _updateSort(StudentSortOption option) {
    setState(() {
      _sortOption = option;
    });
  }

  double _studentPerformance(
    String studentId,
    ExamProvider examProvider,
    ResultProvider resultProvider,
    ExamSessionProvider sessionProvider,
  ) {
    final manual = examProvider.getByStudent(studentId);
    final manualScores = manual.map((e) => e.percentage).toList();
    final bulkScores = resultProvider
        .getByStudent(studentId)
        .map((result) {
          final session = sessionProvider.getById(result.examSessionId);
          if (session == null || session.fullMarks <= 0) return null;
          return (result.obtainedMarks / session.fullMarks) * 100;
        })
        .whereType<double>()
        .toList();
    final allScores = [...manualScores, ...bulkScores];
    if (allScores.isEmpty) return 0;
    return allScores.reduce((a, b) => a + b) / allScores.length;
  }

  String _sortLabel() {
    switch (_sortOption) {
      case StudentSortOption.alphabeticalAsc:
        return 'Name A→Z';
      case StudentSortOption.alphabeticalDesc:
        return 'Name Z→A';
      case StudentSortOption.performanceDesc:
        return 'Performance';
    }
  }

  List _filteredStudents(
    List students,
    ExamProvider examProvider,
    ResultProvider resultProvider,
    ExamSessionProvider sessionProvider,
  ) {
    final query = _searchQuery.toLowerCase();
    final filtered = students.where((student) {
      return student.name.toLowerCase().contains(query);
    }).toList();

    switch (_sortOption) {
      case StudentSortOption.alphabeticalAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case StudentSortOption.alphabeticalDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case StudentSortOption.performanceDesc:
        filtered.sort(
          (a, b) =>
              _studentPerformance(
                b.id,
                examProvider,
                resultProvider,
                sessionProvider,
              ).compareTo(
                _studentPerformance(
                  a.id,
                  examProvider,
                  resultProvider,
                  sessionProvider,
                ),
              ),
        );
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final examProvider = context.watch<ExamProvider>();
    final resultProvider = context.watch<ResultProvider>();
    final sessionProvider = context.watch<ExamSessionProvider>();

    final students = studentProvider.getByBatch(widget.batchId);
    final filteredStudents = _filteredStudents(
      students,
      examProvider,
      resultProvider,
      sessionProvider,
    );

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          widget.batchName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamSessionScreen(
                    batchId: widget.batchId,
                    batchName: widget.batchName,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.quiz, color: Colors.white),
            label: const Text(
              'Add exam session',
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudent(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add student'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _updateSearch,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search students',
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _updateSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Sort by: ${_sortLabel()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                PopupMenuButton<StudentSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: _updateSort,
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: StudentSortOption.alphabeticalAsc,
                      child: Text('Name A→Z'),
                    ),
                    const PopupMenuItem(
                      value: StudentSortOption.alphabeticalDesc,
                      child: Text('Name Z→A'),
                    ),
                    const PopupMenuItem(
                      value: StudentSortOption.performanceDesc,
                      child: Text('Best performance'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.people_outline,
                            size: 72,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No students yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Use the button below to add your first student to this batch.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredStudents.isEmpty
                ? const Center(child: Text('No students match your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final s = filteredStudents[index];
                      final performance = _studentPerformance(
                        s.id,
                        examProvider,
                        resultProvider,
                        sessionProvider,
                      );

                      return Dismissible(
                        key: ValueKey(s.id),
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
                                'Remove ${s.name} from this batch? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Keep student'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) {
                          context.read<StudentProvider>().deleteStudent(s.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${s.name} removed')),
                          );
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
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              'Phone: ${s.phone} • ${performance.toStringAsFixed(1)}% avg',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudentDetailScreen(
                                    studentId: s.id,
                                    studentName: s.name,
                                    batchId: widget.batchId,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () =>
                                _showEditStudentDialog(context, s),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
        title: const Text("Add student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Student name',
                hintText: 'Enter full name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'Optional contact number',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: analysisCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add a short note or observation',
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
                  batchId: widget.batchId,
                  analysis: analysisCtrl.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Add student"),
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
        title: const Text("Edit student info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Student name',
                hintText: 'Update the name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: 'Update contact details',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: analysisCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Update notes for this student',
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
                context.read<StudentProvider>().updateStudent(
                  studentId: student.id,
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  analysis: analysisCtrl.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Save changes"),
          ),
        ],
      ),
    );
  }
}
