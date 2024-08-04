import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  int _activeIndex = 0;
  int get activeIndex => _activeIndex;

  set setActiveIndex(int value) {
    _activeIndex = value;
    notifyListeners();
  }
}
