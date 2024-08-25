import 'package:flutter/material.dart';

import '../../../common/category_header.dart';

// TODO: Implement recent feat
class BuildRecentEmojis extends StatelessWidget {
  const BuildRecentEmojis({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        CategoryHeader(label: 'Recents'),
      ],
    );
  }
}
