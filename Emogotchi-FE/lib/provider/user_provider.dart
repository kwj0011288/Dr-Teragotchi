import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _userName = '';
  String uuid = '';
  String animalType = '';
  String animalLevel = '';
  String emotion = '';
  int points = 0;
  bool isNotified = false;

  String get userName => _userName;
  String get getUuid => uuid;
  String get getAnimalType => animalType;
  String get getAnimalLevel => animalLevel;
  String get getEmotion => emotion;
  int get getPoints => points;
  bool get getIsNotified => isNotified;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
    saveToLocal();
  }

  void setUuid(String id) {
    uuid = id;
    notifyListeners();
    saveToLocal();
  }

  void setAnimalType(String type) {
    animalType = type;
    notifyListeners();
    saveToLocal();
  }

  void setAnimalLevel(String level) {
    animalLevel = level;
    notifyListeners();
    saveToLocal();
  }

  void setEmotion(String newEmotion) {
    emotion = newEmotion;
    notifyListeners();
    saveToLocal();
  }

  void setPoints(int newPoints) {
    points = newPoints;
    notifyListeners();
    saveToLocal();
  }

  void setIsNotified(bool value) {
    isNotified = value;
    notifyListeners();
    saveToLocal();
  }

  void setUserData({
    String? uuid,
    String? emotion,
    String? animal,
    String? animalLevel,
    int? points,
    String? userName,
    bool? isNotified,
  }) {
    if (uuid != null && uuid.isNotEmpty) this.uuid = uuid;
    if (emotion != null && emotion.isNotEmpty) this.emotion = emotion;
    if (animal != null && animal.isNotEmpty) animalType = animal;
    if (animalLevel != null && animalLevel.isNotEmpty)
      this.animalLevel = animalLevel;
    if (points != null) this.points = points;
    if (userName != null && userName.isNotEmpty) _userName = userName;
    if (isNotified != null) this.isNotified = isNotified;

    notifyListeners();
    saveToLocal();
  }

  // ✅ 로컬 저장
  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    await prefs.setString('uuid', uuid);
    await prefs.setString('animalType', animalType);
    await prefs.setString('animalLevel', animalLevel);
    await prefs.setString('emotion', emotion);
    await prefs.setInt('points', points);
    await prefs.setBool('isNotified', isNotified);
    debugPrint(
        '[Local Save] userName=$_userName, uuid=$uuid, animalType=$animalType, animalLevel=$animalLevel, emotion=$emotion, points=$points, isNotified=$isNotified');
  }

  // ✅ 로컬 불러오기
  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    uuid = prefs.getString('uuid') ?? '';
    animalType = prefs.getString('animalType') ?? '';
    animalLevel = prefs.getString('animalLevel') ?? '';
    emotion = prefs.getString('emotion') ?? '';
    points = prefs.getInt('points') ?? 0;
    isNotified = prefs.getBool('isNotified') ?? false;
    debugPrint(
        '[Local Load] userName=$_userName, emotion=$emotion, animal=$animalType');
    notifyListeners();
  }
}
