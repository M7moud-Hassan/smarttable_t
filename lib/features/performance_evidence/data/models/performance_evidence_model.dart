class PerformanceEvidenceModel {
  final int id;
  final String? title;
  final String? file;
  final EvidenceCategoryModel? category;
  final int categoryId;
  final String typeFile;

  PerformanceEvidenceModel({
    required this.id,
    this.title,
    this.file,
    this.category,
    required this.categoryId,
    required this.typeFile,
  });

  factory PerformanceEvidenceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceEvidenceModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      file: json['file'] as String?,
      category: json['category'] != null
          ? EvidenceCategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      categoryId: json['category_id'] as int? ?? 0,
      typeFile: json['type_file'] as String? ?? 'i',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'type_file': typeFile,
    };
  }
}

class EvidenceCategoryModel {
  final int? id;
  final String name;

  EvidenceCategoryModel({
    this.id,
    required this.name,
  });

  factory EvidenceCategoryModel.fromJson(Map<String, dynamic> json) {
    return EvidenceCategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
