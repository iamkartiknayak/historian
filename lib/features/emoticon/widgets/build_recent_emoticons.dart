import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/category_header.dart';
import '../../../common/empty_recents_widget.dart';
import '../providers/emoticon_provider.dart';
import './emoticon_grid_view.dart';

class BuildRecentEmoticons extends StatelessWidget {
  const BuildRecentEmoticons({super.key});

  @override
  Widget build(BuildContext context) {
    final recentEmoticons =
        context.read<EmoticonProvider>().getRecentEmoticons();

    return CustomScrollView(
      slivers: [
        const CategoryHeader(label: 'Recents'),
        recentEmoticons.isEmpty
            ? const EmptyRecentsWidget()
            : EmoticonGridView(emoticons: recentEmoticons)
      ],
    );
  }
}
