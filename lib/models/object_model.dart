class ObjectModel {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  const ObjectModel({required this.id, required this.name, this.data});

  factory ObjectModel.fromJson(Map<String, dynamic> json) {
    return ObjectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'No Name',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (data != null && data!.isNotEmpty) 'data': data,
  };
}
