import '../models/exam_model.dart';

class AnalyticsService {
  /// Monthly average percentage
  static double monthlyAverage(List<ExamModel> exams, int month, int year) {
    final filtered = exams.where((e) =>
        e.date.month == month && e.date.year == year);

    if (filtered.isEmpty) return 0;

    return filtered
        .map((e) => e.percentage)
        .reduce((a, b) => a + b) /
        filtered.length;
  }

  /// Yearly average percentage
  static double yearlyAverage(List<ExamModel> exams, int year) {
    final filtered = exams.where((e) => e.date.year == year);

    if (filtered.isEmpty) return 0;

    return filtered
        .map((e) => e.percentage)
        .reduce((a, b) => a + b) /
        filtered.length;
  }

  /// Total exams count
  static int totalExams(List<ExamModel> exams, {int? month, int? year}) {
    return exams.where((e) {
      if (month != null && e.date.month != month) return false;
      if (year != null && e.date.year != year) return false;
      return true;
    }).length;
  }

  /// Best exam
  static ExamModel? bestExam(List<ExamModel> exams) {
    if (exams.isEmpty) return null;

    exams.sort((a, b) => b.percentage.compareTo(a.percentage));
    return exams.first;
  }

  /// Worst exam
  static ExamModel? worstExam(List<ExamModel> exams) {
    if (exams.isEmpty) return null;

    exams.sort((a, b) => a.percentage.compareTo(b.percentage));
    return exams.first;
  }
}