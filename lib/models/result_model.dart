class ResultModel {
  final String id;

  final String studentId;
  final String examSessionId;

  final double obtainedMarks;

  ResultModel({
    required this.id,
    required this.studentId,
    required this.examSessionId,
    required this.obtainedMarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'examSessionId': examSessionId,
      'obtainedMarks': obtainedMarks,
    };
  }

  factory ResultModel.fromMap(Map data) {
    return ResultModel(
      id: data['id'],
      studentId: data['studentId'],
      examSessionId: data['examSessionId'],
      obtainedMarks: (data['obtainedMarks'] as num).toDouble(),
    );
  }
}