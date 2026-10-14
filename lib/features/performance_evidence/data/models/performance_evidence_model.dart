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

  PerformanceEvidenceFileKind get fileKind {
    final path = Uri.tryParse(file ?? '')?.path.toLowerCase() ?? '';

    if (path.endsWith('.pdf')) return PerformanceEvidenceFileKind.pdf;
    if (_imageExtensions.any(path.endsWith)) {
      return PerformanceEvidenceFileKind.image;
    }
    if (_documentExtensions.any(path.endsWith)) {
      return PerformanceEvidenceFileKind.document;
    }

    return switch (typeFile.toLowerCase()) {
      'p' => PerformanceEvidenceFileKind.pdf,
      'i' => PerformanceEvidenceFileKind.image,
      _ => PerformanceEvidenceFileKind.document,
    };
  }

  static const _imageExtensions = <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.bmp',
  ];
  static const _documentExtensions = <String>[
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
  ];
}

enum PerformanceEvidenceFileKind { image, pdf, document }

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
