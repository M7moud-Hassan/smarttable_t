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
          ? EvidenceCategoryModel.fromJson(
              json['category'] as Map<String, dynamic>,
            )
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
  final int? parentId;
  final bool isMain;
  final List<EvidenceCategoryModel> subcategories;

  EvidenceCategoryModel({
    this.id,
    required this.name,
    this.parentId,
    this.isMain = false,
    this.subcategories = const [],
  });

  factory EvidenceCategoryModel.fromJson(Map<String, dynamic> json) {
    final rawParent = json['parent'];
    final rawSubcategories = json['subcategories'];

    return EvidenceCategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      parentId: rawParent is int
          ? rawParent
          : rawParent is Map
              ? rawParent['id'] as int?
              : null,
      isMain: json['is_main'] as bool? ?? false,
      subcategories: rawSubcategories is List
          ? rawSubcategories
              .whereType<Map>()
              .map(
                (subcategory) => EvidenceCategoryModel.fromJson(
                  Map<String, dynamic>.from(subcategory),
                ),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent': parentId,
      'is_main': isMain,
      'subcategories': subcategories.map((item) => item.toJson()).toList(),
    };
  }
}
