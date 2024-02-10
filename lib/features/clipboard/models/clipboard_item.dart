class ClipboardItem {
  ClipboardItem({
    required this.id,
    required this.content,
    required this.isPinned,
  });

  final String id;
  final dynamic content;
  final bool isPinned;

  ClipboardItem copyWith({
    String? id,
    String? content,
    bool? isPinned,
    bool? isSelected,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
