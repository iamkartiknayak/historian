import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmojiProvider extends ChangeNotifier {
  // getters
  static List<(String, Iterable<Emoji>)> get categories => _categories;
  Iterable<Emoji> get searchResultList => _searchResultList;

  TabController get tabController => _tabController;
  ScrollController get scrollController => _scrollController;
  TextEditingController get searchController => _searchController;

  bool get showSearchBar => _showSearchBar;
  bool get showRecent => _showRecent;

  // private var
  static late final List<(String, Iterable<Emoji>)> _categories;
  late Iterable<Emoji> _searchResultList;

  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  bool _showSearchBar = false;
  bool _showRecent = false;
  int _hoveredItemIndex = -1;
  bool _isInitialized = false;

  static const Map<int, int> _categoryOffsetMap = {
    2: 0, // smiley & people
    3: 6390, // animals & nature
    4: 8328, // food & drink
    5: 10110, // activity
    6: 11256, // travel
    7: 14151, // objects
    8: 17523, // symbols
    9: 20809, // flags
  };

  // public methods
  void initControllers(TickerProvider vsync) {
    if (_isInitialized) {
      if (_tabController.index == 1 || _tabController.previousIndex == 1) {
        return;
      }

      _tabController.index = 2;
      return;
    }

    debugPrint('EmojiProvider initControllers is called');
    _initEmojiCategories();
    _searchResultList = [];
    _tabController = TabController(length: 10, vsync: vsync);
    _tabController.index = 2;
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScrollController);
    _searchController = TextEditingController();
    _isInitialized = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void updateTabIndex(int index) {
    final currentTabIndex = index;
    tabController.index = currentTabIndex;

    _showSearchBar = currentTabIndex == 0;
    _showRecent = currentTabIndex == 1;
    notifyListeners();

    if (currentTabIndex < 2) return;

    _searchController.clear();

    final categoryOffset = _categoryOffsetMap[currentTabIndex]!.toDouble();

    if (_scrollController.hasClients) {
      _scrollController.jumpTo(categoryOffset);
    }
    notifyListeners();
  }

  bool isHovering(int index) => _hoveredItemIndex == index;

  void updateHoverState(bool isHovering, int index) {
    _hoveredItemIndex = isHovering ? index : -1;
    notifyListeners();
  }

  void copyEmoji(String emoji) => Clipboard.setData(ClipboardData(text: emoji));

  void searchEmoji(String query) {
    _searchResultList = Emoji.all().where(
      (emoji) => emoji.name.toLowerCase().contains(query.toLowerCase()),
    );
    _scrollController.jumpTo(0);

    notifyListeners();
  }

  // private methods
  void _handleScrollController() {
    final offset = _scrollController.offset;

    _tabController.index = _categoryOffsetMap.entries
        .lastWhere((entry) => offset >= entry.value,
            orElse: () => const MapEntry(2, 0))
        .key;
    notifyListeners();
  }

  void _initEmojiCategories() {
    _categories = [
      (
        'Smiles & People',
        [
          ...Emoji.byGroup(EmojiGroup.smileysEmotion),
          ...Emoji.byGroup(EmojiGroup.peopleBody),
        ]
      ),
      ('Animals & Nature', Emoji.byGroup(EmojiGroup.animalsNature)),
      ('Food & Drink', Emoji.byGroup(EmojiGroup.foodDrink)),
      ('Activity', Emoji.byGroup(EmojiGroup.activities)),
      ('Travel & Places', Emoji.byGroup(EmojiGroup.travelPlaces)),
      ('Objects', Emoji.byGroup(EmojiGroup.objects)),
      ('Symbols', Emoji.byGroup(EmojiGroup.symbols)),
      ('Flags', Emoji.byGroup(EmojiGroup.flags)),
    ];
  }
}
