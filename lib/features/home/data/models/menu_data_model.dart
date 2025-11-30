class MenuDataModel {
  int id;
  String image;
  String title;
  String key;
  String description;
  bool isActive;
  int displayOrder;

  MenuDataModel({
    required this.id,
    required this.image,
    required this.title,
    required this.key,
    required this.description,
    required this.isActive,
    required this.displayOrder,
  });

  factory MenuDataModel.fromJson(Map<String, dynamic> json) => MenuDataModel(
        id: json["id"],
        image: json["image"],
        title: json["title"],
        key: json["key"],
        description: json["description"],
        isActive: json["is_active"],
        displayOrder: json["display_order"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "title": title,
        "key": key,
        "description": description,
        "is_active": isActive,
        "display_order": displayOrder,
      };
}
