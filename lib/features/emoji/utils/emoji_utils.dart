import 'package:emojis/emoji.dart';

class EmojiUtils {
  static Iterable<Emoji> filterCustomEmojis(Iterable<Emoji> emojis) {
    final uniqueEmojis = Set<Emoji>.from(emojis);

    uniqueEmojis.removeWhere((emoji) {
      return emoji.name.contains('skin tone') ||
          emoji.name.contains('family: ');
    });
    return uniqueEmojis;
  }
}
