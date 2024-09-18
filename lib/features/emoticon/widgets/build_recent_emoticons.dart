import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/category_header.dart';
import '../providers/emoticon_provider.dart';
import './emoticon_grid_view.dart';

class BuildRecentEmoticons extends StatelessWidget {
  const BuildRecentEmoticons({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const CategoryHeader(label: 'Recents'),
        EmoticonGridView(
          emoticons: context.read<EmoticonProvider>().getRecentEmoticons(),
        )
      ],
    );
  }
}
