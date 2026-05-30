class ExamSessionModel {
  final String id;
  final String batchId;

  final String title;

  final String type; // weekly/monthly

  final double fullMarks;

  final DateTime date;

  ExamSessionModel({
    required this.id,
    required this.batchId,
    required this.title,
    required this.type,
    required this.fullMarks,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchId': batchId,
      'title': title,
      'type': type,
      'fullMarks': fullMarks,
      'date': date.toIso8601String(),
    };
  }

  factory ExamSessionModel.fromMap(Map data) {
    return ExamSessionModel(
      id: data['id'],
      batchId: data['batchId'],
      title: data['title'],
      type: data['type'],
      fullMarks: (data['fullMarks'] as num).toDouble(),
      date: DateTime.parse(data['date']),
    );
  }
}