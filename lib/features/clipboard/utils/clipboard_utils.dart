class ClipboardUtils {
  static bool isOnlyEmoticons(String text) {
    final emojiRegex = RegExp(
      r'^[\s'
      r'\u{1F300}-\u{1F5FF}' // Miscellaneous Symbols and Pictographs
      r'\u{1F600}-\u{1F64F}' // Emoticons
      r'\u{1F680}-\u{1F6FF}' // Transport and Map Symbols
      r'\u{1F700}-\u{1F77F}' // Alchemical Symbols
      r'\u{1F780}-\u{1F7FF}' // Geometric Shapes Extended
      r'\u{1F800}-\u{1F8FF}' // Supplemental Arrows-C
      r'\u{1F900}-\u{1F9FF}' // Supplemental Symbols and Pictographs
      r'\u{1FA00}-\u{1FA6F}' // Chess Symbols
      r'\u{1FA70}-\u{1FAFF}' // Symbols and Pictographs Extended-A
      r'\u{2600}-\u{26FF}' // Miscellaneous Symbols
      r'\u{2700}-\u{27BF}' // Dingbats
      r'\u{FE00}-\u{FE0F}' // Variation Selectors
      r'\u{1F000}-\u{1F02F}' // Mahjong Tiles
      r'\u{1F0A0}-\u{1F0FF}' // Playing Cards
      r'\u{1F100}-\u{1F1FF}' // Enclosed Alphanumeric Supplement
      r'\u{1F200}-\u{1F2FF}' // Enclosed Ideographic Supplement
      r']+$',
      unicode: true,
    );

    return emojiRegex.hasMatch(text.trim());
  }

  static bool isValidWebLink(String link) {
    link = link.trim();

    if (!link.startsWith(RegExp(r'^(http://|https://|ftp://)'))) {
      link = 'http://$link';
    }

    final urlPattern = RegExp(
      r'^(http://|https://|ftp://)' // Protocol
      r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+(?:[A-Z]{2,6}\.?|[A-Z0-9-]{2,}\.?)|' // Domain name
      r'localhost|' // localhost
      r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' // IP address
      r'(?::\d+)?' // Optional port
      r'(?:/\S*)?$', // Optional path and query string
      caseSensitive: false,
    );

    return urlPattern.hasMatch(link);
  }
}
