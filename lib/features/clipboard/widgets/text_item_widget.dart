import 'package:flutter/material.dart';

import '../models/text_item.dart';
import '../utils/clipboard_utils.dart';
import './build_item_actions.dart';

class TextItemWidget extends StatelessWidget {
  const TextItemWidget({
    super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final TextItem item;

  @override
  Widget build(BuildContext context) {
    final onlyEmoticons = ClipboardUtils.isOnlyEmoticons(item.textPreview);

    return Row(
      children: [
        Expanded(
          child: Text(
            item.textPreview,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontFamily: onlyEmoticons ? 'NotoColorEmoji' : 'Inter',
                  fontSize: onlyEmoticons ? 28.0 : null,
                ), // =>
          ),
        ),
        BuildItemActions(index: index)
      ],
    );
  }
}
