import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/category_header.dart';
import '../providers/emoji_provider.dart';
import './emoji_grid_view.dart';

class BuildRecentEmojis extends StatelessWidget {
  const BuildRecentEmojis({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CategoryHeader(label: 'Recents'),
        EmojiGridView(emojis: context.read<EmojiProvider>().getRecentEmojis())
      ],
    );
  }
}
