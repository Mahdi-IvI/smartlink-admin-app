import '../config/config.dart';

class ManagerModel {
  String id;
  String username;
  String password;
  String placeId;

  ManagerModel(
      {required this.id,
      required this.username,
      required this.password,
      required this.placeId});

  Map<String, dynamic> toJson() => {
    Config.username: username,
    Config.password: password,
    Config.placeId: placeId,
  };
}
