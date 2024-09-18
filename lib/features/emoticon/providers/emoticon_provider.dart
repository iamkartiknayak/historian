import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../services/snackbar_service.dart';
import '../models/emoticon.dart';

class EmoticonProvider extends ChangeNotifier {
  // getters
  static List<(String, Iterable<Emoticon>)> get categories => _categories;
  Iterable<Emoticon> get searchResultList => _searchResultList;

  TabController get tabController => _tabController;
  ScrollController get scrollController => _scrollController;
  TextEditingController get searchController => _searchController;

  int get currentTabIndex => _tabController.index;
  bool get showSearchBar => _showSearchBar;
  bool get showRecent => _showRecent;

  // private var
  static late final List<(String, Iterable<Emoticon>)> _categories;
  late Iterable<Emoticon> _searchResultList;

  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;
  late final BuildContext _context;
  late final Box<dynamic> _recents;
  late final List<dynamic> _recentEmoticons;

  bool _showSearchBar = false;
  bool _showRecent = false;
  int _hoveredItemIndex = -1;
  bool _isInitialized = false;

  // public methods
  void initControllers(TickerProvider vsync, BuildContext context) {
    if (_isInitialized) return;

    debugPrint('EmoticonProvider initControllers is called');
    _recents = Hive.box('recents');
    _recentEmoticons = _recents.get('emoticons', defaultValue: [])!;
    _context = context;
    _initEmoticonCategories();
    _searchResultList = [];
    _tabController = TabController(length: 3, vsync: vsync);
    _tabController.index = 2;
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void updateTabIndex(int index) {
    _tabController.index = index;

    _showSearchBar = currentTabIndex == 0;
    _showRecent = currentTabIndex == 1;

    if (currentTabIndex == 2) _searchController.clear();

    notifyListeners();
  }

  bool isHovering(int index) => _hoveredItemIndex == index;

  void updateHoverState(bool isHovering, int index) {
    _hoveredItemIndex = isHovering ? index : -1;
    notifyListeners();
  }

  void copyEmoticon(String emoticon) {
    Clipboard.setData(ClipboardData(text: emoticon));
    SnackBarService.showSnackBar(
      context: _context,
      message: 'Emoticon copied to clipboard',
    );

    _recentEmoticons.remove(emoticon);
    _recentEmoticons.insert(0, emoticon);
    _recents.put('emoticons', _recentEmoticons);
    if (_recentEmoticons.length > 30) _recentEmoticons.removeLast();
  }

  void searchEmoticon(String query) {
    _searchResultList = Emoticons.all().where(
      (emoticon) => emoticon.name.toLowerCase().contains(query.toLowerCase()),
    );
    _scrollController.jumpTo(0);

    notifyListeners();
  }

  void toggleSearchBar() {
    final previousIndex = _tabController.previousIndex;
    updateTabIndex(_tabController.index != 0 ? 0 : previousIndex);
  }

  Iterable<Emoticon> getRecentEmoticons() =>
      _recentEmoticons.map((emojiChar) => Emoticons.byChar(emojiChar)!);

  // private methods
  void _initEmoticonCategories() {
    _categories = [
      ('Emoticons', Emoticons.all()),
    ];
  }
}
