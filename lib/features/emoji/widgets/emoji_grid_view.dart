import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

import './emoji_item.dart';

class EmojiGridView extends StatelessWidget {
  const EmojiGridView({
    super.key,
    required this.emojis,
  });

  final Iterable<Emoji> emojis;

  @override
  Widget build(BuildContext context) {
    debugPrint('EmojiGridView build is called');

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: emojis.length,
        (context, index) {
          final emoji = emojis.elementAt(index);

          return Center(
            child: EmojiItem(
              emoji: Emoji.modify(
                emoji.char,
                fitzpatrick.light,
              ),
              index: index,
            ),
          );
        },
      ),
    );
  }
}
