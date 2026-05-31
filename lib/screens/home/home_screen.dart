import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../batch/batch_detail_screen.dart';
import '../about_screen.dart';
import '../how_to_use_screen.dart';
import '../../providers/batch_provider.dart';
import '../../providers/exam_provider.dart';
import '../../providers/exam_session_provider.dart';
import '../../providers/result_provider.dart';
import '../../providers/student_provider.dart';

enum BatchSortOption { alphabeticalAsc, alphabeticalDesc, performanceDesc }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BatchSortOption _sortOption = BatchSortOption.alphabeticalAsc;

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

  void _updateSort(BatchSortOption option) {
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

  double _batchPerformance(
    String batchId,
    StudentProvider studentProvider,
    ExamProvider examProvider,
    ResultProvider resultProvider,
    ExamSessionProvider sessionProvider,
  ) {
    final students = studentProvider.getByBatch(batchId);
    if (students.isEmpty) return 0;
    final scores = students
        .map(
          (student) => _studentPerformance(
            student.id,
            examProvider,
            resultProvider,
            sessionProvider,
          ),
        )
        .toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  List get _filteredBatches {
    final batchProvider = context.read<BatchProvider>();
    final studentProvider = context.read<StudentProvider>();
    final examProvider = context.read<ExamProvider>();
    final resultProvider = context.read<ResultProvider>();
    final sessionProvider = context.read<ExamSessionProvider>();

    final query = _searchQuery.toLowerCase();
    final filtered = batchProvider.batches.where((batch) {
      return batch.name.toLowerCase().contains(query);
    }).toList();

    switch (_sortOption) {
      case BatchSortOption.alphabeticalAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case BatchSortOption.alphabeticalDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case BatchSortOption.performanceDesc:
        filtered.sort(
          (a, b) =>
              _batchPerformance(
                b.id,
                studentProvider,
                examProvider,
                resultProvider,
                sessionProvider,
              ).compareTo(
                _batchPerformance(
                  a.id,
                  studentProvider,
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

  String _sortLabel() {
    switch (_sortOption) {
      case BatchSortOption.alphabeticalAsc:
        return 'Name A→Z';
      case BatchSortOption.alphabeticalDesc:
        return 'Name Z→A';
      case BatchSortOption.performanceDesc:
        return 'Performance';
    }
  }

  @override
  Widget build(BuildContext context) {
    final batchProvider = context.watch<BatchProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final examProvider = context.watch<ExamProvider>();
    final resultProvider = context.watch<ResultProvider>();
    final sessionProvider = context.watch<ExamSessionProvider>();
    final filteredBatches = _filteredBatches;

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
        title: const Text(
          "StudentFlow App",
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('How to use'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HowToUseScreen()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddBatchDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Batch'),
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
                hintText: 'Search batches',
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
                PopupMenuButton<BatchSortOption>(
                  icon: const Icon(Icons.sort),
                  onSelected: _updateSort,
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: BatchSortOption.alphabeticalAsc,
                      child: Text('Name A→Z'),
                    ),
                    const PopupMenuItem(
                      value: BatchSortOption.alphabeticalDesc,
                      child: Text('Name Z→A'),
                    ),
                    const PopupMenuItem(
                      value: BatchSortOption.performanceDesc,
                      child: Text('Best performance'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: batchProvider.batches.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox, size: 68, color: Colors.blueGrey),
                          SizedBox(height: 16),
                          Text(
                            'No batches yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the button below to create your first batch and start tracking student progress.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : filteredBatches.isEmpty
                ? const Center(child: Text('No batches match your search.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredBatches.length,
                    itemBuilder: (context, index) {
                      final batch = filteredBatches[index];
                      final sessions = context
                          .read<ExamSessionProvider>()
                          .getByBatch(batch.id);
                      final studentCount = studentProvider
                          .getByBatch(batch.id)
                          .length;
                      final performance = _batchPerformance(
                        batch.id,
                        studentProvider,
                        examProvider,
                        resultProvider,
                        sessionProvider,
                      );

                      return Dismissible(
                        key: ValueKey(batch.id),
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
                              title: const Text('Confirm delete'),
                              content: Text(
                                'Delete "${batch.name}" and all related data? This cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Keep it'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete batch'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (_) async {
                          final examSessionProvider = context
                              .read<ExamSessionProvider>();
                          final resultProvider = context.read<ResultProvider>();
                          final examProvider = context.read<ExamProvider>();
                          final studentProvider = context
                              .read<StudentProvider>();

                          for (final session in sessions) {
                            await resultProvider.deleteBySession(session.id);
                          }
                          await examSessionProvider.deleteByBatch(batch.id);
                          await examProvider.deleteByBatch(batch.id);
                          await studentProvider.deleteByBatch(batch.id);
                          await context.read<BatchProvider>().deleteBatch(
                            batch.id,
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Batch "${batch.name}" removed'),
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
                              batch.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '$studentCount students • ${sessions.length} sessions • ${performance.toStringAsFixed(1)}% avg',
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BatchDetailScreen(
                                    batchId: batch.id,
                                    batchName: batch.name,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () => _showEditBatchDialog(
                              context,
                              batch.id,
                              batch.name,
                            ),
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

  void _showAddBatchDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Create new batch"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Batch name',
            hintText: 'Enter a name for this class group',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<BatchProvider>(
                  context,
                  listen: false,
                ).addBatch(controller.text.trim());

                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showEditBatchDialog(
    BuildContext context,
    String batchId,
    String batchName,
  ) {
    final controller = TextEditingController(text: batchName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit batch details"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Batch name',
            hintText: 'Update the batch name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<BatchProvider>(
                  context,
                  listen: false,
                ).updateBatch(batchId, controller.text.trim());
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

void _showEditBatchDialog(
  BuildContext context,
  String batchId,
  String batchName,
) {
  final controller = TextEditingController(text: batchName);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Batch"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Batch name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              Provider.of<BatchProvider>(
                context,
                listen: false,
              ).updateBatch(batchId, controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
