import 'package:flutter/material.dart';

class BackgroundProvider with ChangeNotifier {
  String selectedBackground =
      'assets/background/airport.png'; // 기본값 고정 또는 랜덤 초기화

  void setBackground(String path) {
    selectedBackground = path;
    notifyListeners();
  }
}
