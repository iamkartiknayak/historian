import 'package:flutter/material.dart';

import './shortcut_key.dart';

class ShortcutItem extends StatelessWidget {
  const ShortcutItem({
    super.key,
    required this.shortcut,
    required this.description,
  });

  final (String, String) shortcut;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(description),
          const Spacer(),
          Row(
            children: [
              ShortcutKey(shortcutKey: shortcut.$1),
              const SizedBox(width: 4.0),
              const Text('+'),
              const SizedBox(width: 4.0),
              ShortcutKey(shortcutKey: shortcut.$2),
            ],
          )
        ],
      ),
    );
  }
}
