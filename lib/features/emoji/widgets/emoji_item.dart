import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/emoji_provider.dart';

class EmojiItem extends StatelessWidget {
  const EmojiItem({
    super.key,
    required this.emoji,
    required this.index,
  });

  final String emoji;
  final int index;

  @override
  Widget build(BuildContext context) {
    final emojisProvider = context.read<EmojiProvider>();
    final isHovered = context.select((EmojiProvider p) => p.isHovering(index));

    return GestureDetector(
      onTap: () => emojisProvider.copyEmoji(emoji),
      child: MouseRegion(
        onEnter: (_) => emojisProvider.updateHoverState(true, index),
        onExit: (_) => emojisProvider.updateHoverState(false, index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isHovered)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ),
                ),
              ),
            Text(
              emoji,
              style: TextStyle(
                fontSize: isHovered ? 40.0 : 32.0,
                fontFamily: 'NotoColorEmoji',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
