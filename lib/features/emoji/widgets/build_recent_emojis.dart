import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/category_header.dart';
import '../../../common/empty_recents_widget.dart';
import '../providers/emoji_provider.dart';
import './emoji_grid_view.dart';

class BuildRecentEmojis extends StatelessWidget {
  const BuildRecentEmojis({super.key});

  @override
  Widget build(BuildContext context) {
    final recentEmojis = context.read<EmojiProvider>().getRecentEmojis();

    return CustomScrollView(
      slivers: [
        const CategoryHeader(label: 'Recents'),
        recentEmojis.isEmpty
            ? const EmptyRecentsWidget()
            : EmojiGridView(emojis: recentEmojis)
      ],
    );
  }
}
