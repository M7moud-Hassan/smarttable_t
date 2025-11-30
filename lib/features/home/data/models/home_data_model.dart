import 'menu_data_model.dart';
import 'welcome_data_model.dart';

class HomeDataModel {
  HomeDataModel({
    required this.welcome,
    required this.menus,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
        welcome: WelcomeDataModel.fromJson(json["welcome"]),
        menus: List<MenuDataModel>.from(
            json["menus"].map((x) => MenuDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "welcome": welcome.toJson(),
        "menus": List<dynamic>.from(menus.map((x) => x.toJson())),
      };

  WelcomeDataModel welcome;
  List<MenuDataModel> menus;
}
