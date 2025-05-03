import 'package:flutter/material.dart';

class EmotionProvider with ChangeNotifier {
  String _emotion = '';

  String get emotion => _emotion;

  void setEmotion(String newEmotion) {
    _emotion = newEmotion;
    print('🔄 Emotion set to: $_emotion'); // 디버깅용 로그
    notifyListeners();
  }

  String getEmotion() {
    return _emotion;
  }
}
