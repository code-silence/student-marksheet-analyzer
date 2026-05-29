class ExamModel {
  final String id;
  final String studentId;
  final String batchId;

  final String examName;   // Weekly 1 / Monthly 1
  final String examType;   // weekly / monthly

  final double obtainedMarks;
  final double fullMarks;

  final DateTime date;

  ExamModel({
    required this.id,
    required this.studentId,
    required this.batchId,
    required this.examName,
    required this.examType,
    required this.obtainedMarks,
    required this.fullMarks,
    required this.date,
  });

  double get percentage => (obtainedMarks / fullMarks) * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'batchId': batchId,
      'examName': examName,
      'examType': examType,
      'obtainedMarks': obtainedMarks,
      'fullMarks': fullMarks,
      'date': date.toIso8601String(),
    };
  }

  factory ExamModel.fromMap(Map data) {
    return ExamModel(
      id: data['id'],
      studentId: data['studentId'],
      batchId: data['batchId'],
      examName: data['examName'],
      examType: data['examType'],
      obtainedMarks: (data['obtainedMarks'] as num).toDouble(),
      fullMarks: (data['fullMarks'] as num).toDouble(),
      date: DateTime.parse(data['date']),
    );
  }
}