class BatchModel {
  final String id;
  final String name;

  BatchModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory BatchModel.fromMap(Map data) {
    return BatchModel(
      id: data['id'],
      name: data['name'],
    );
  }
}