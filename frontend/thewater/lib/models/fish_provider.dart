import 'package:flutter/material.dart';

class FishProvider with ChangeNotifier {
  // 상태 변수
  int _count = 0;

  // 상태값을 가져오는 getter
  int get count => _count;

  // 상태를 변경하는 함수 (예: 카운트를 증가시킴)
  void increment() {
    _count++;
    notifyListeners(); // 상태 변경 후 UI 갱신 요청
  }

  // 상태를 변경하는 다른 함수 (예: 카운트를 초기화)
  void reset() {
    _count = 0;
    notifyListeners(); // 상태 변경 후 UI 갱신 요청
  }

  // 필요한 경우 다른 함수 추가 가능 (예: 감소하는 함수 등)
  void decrement() {
    if (_count > 0) {
      _count--;
      notifyListeners(); // 상태 변경 후 UI 갱신 요청
    }
  }
}
