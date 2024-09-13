class TextItem {
  TextItem({
    required this.id,
    required this.textPreview,
    required this.textFilePath,
    required this.textCategory,
    this.isPinned = false,
  });

  final String id;
  final String textPreview;
  final String textFilePath;
  final String textCategory;
  final bool isPinned;

  TextItem copyWith({
    String? id,
    String? textPreview,
    String? textFilePath,
    String? textCategory,
    bool? isPinned,
  }) {
    return TextItem(
      id: id ?? this.id,
      textPreview: textPreview ?? this.textPreview,
      textFilePath: textFilePath ?? this.textFilePath,
      textCategory: textCategory ?? this.textCategory,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
