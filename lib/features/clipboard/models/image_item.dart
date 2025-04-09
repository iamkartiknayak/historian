class ImageItem {
  ImageItem({
    required this.id,
    required this.imageFilePath,
    this.isPinned = false,
    this.alt = "",
  });

  final String id;
  final String imageFilePath;
  final bool isPinned;
  final String alt;

  ImageItem copyWith({
    String? id,
    String? imageFilePath,
    bool? isPinned,
    String? alt,
  }) {
    return ImageItem(
      id: id ?? this.id,
      imageFilePath: imageFilePath ?? this.imageFilePath,
      isPinned: isPinned ?? this.isPinned,
      alt: alt ?? this.alt,
    );
  }
}
