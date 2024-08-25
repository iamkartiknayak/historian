import 'package:flutter/material.dart';

import '../models/emoticon.dart';
import './emoticon_item.dart';

class EmoticonGridView extends StatelessWidget {
  const EmoticonGridView({
    super.key,
    required this.emoticons,
  });

  final Iterable<Emoticon> emoticons;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 10.0,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: emoticons.length,
        (context, index) {
          final emoticon = emoticons.elementAt(index);

          return Center(
            child: EmoticonItem(
              emoticon: emoticon.symbol,
              index: index,
            ),
          );
        },
      ),
    );
  }
}
