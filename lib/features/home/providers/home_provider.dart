import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  // getters
  int get currentTabIndex => _tabController.index;
  TabController get tabController => _tabController;

  // private var
  late final TabController _tabController;
  bool _isInitialized = false;

  // public methods
  void initControllers(TickerProvider vsync) {
    if (_isInitialized) return;

    debugPrint('HomeProvider initControllers is called');
    _tabController = TabController(length: 3, vsync: vsync);
    _isInitialized = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updateTabIndex(int index) {
    _tabController.index = index;
    notifyListeners();
  }

  // private methods
}
