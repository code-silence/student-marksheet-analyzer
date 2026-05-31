class StudentModel {
  final String id;
  final String name;
  final String phone;
  final String batchId;
  final String analysis;

  StudentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.batchId,
    this.analysis = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'batchId': batchId,
      'analysis': analysis,
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? batchId,
    String? analysis,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      batchId: batchId ?? this.batchId,
      analysis: analysis ?? this.analysis,
    );
  }

  factory StudentModel.fromMap(Map data) {
    return StudentModel(
      id: data['id'],
      name: data['name'],
      phone: data['phone'],
      batchId: data['batchId'],
      analysis: data['analysis'] ?? '',
    );
  }
}
