class StudentModel {
  final String id;
  final String name;
  final String phone;
  final String batchId;

  StudentModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.batchId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'batchId': batchId,
    };
  }

  factory StudentModel.fromMap(Map data) {
    return StudentModel(
      id: data['id'],
      name: data['name'],
      phone: data['phone'],
      batchId: data['batchId'],
    );
  }
}