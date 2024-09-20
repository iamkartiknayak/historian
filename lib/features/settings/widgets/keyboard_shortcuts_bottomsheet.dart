import 'package:flutter/material.dart';

import 'shortcut_item.dart';

class KeyboardShortcutsBottomsheet extends StatelessWidget {
  const KeyboardShortcutsBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              'Keyboard Shortcuts',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            'Clipboard',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8.0),
          const ShortcutItem(
            shortcut: ('Ctrl', 'C'),
            description: 'Copy Item',
          ),
          const ShortcutItem(
            shortcut: ('Ctrl', 'P'),
            description: 'Pin / Unpin Item',
          ),
          const ShortcutItem(
            shortcut: ('Ctrl', 'D'),
            description: 'Delete Item',
          ),
          const ShortcutItem(
            shortcut: ('Ctrl', 'U'),
            description: 'Undo Delete',
          ),
          const ShortcutItem(
            shortcut: ('Ctrl', 'L'),
            description: 'Clear Items',
          ),
          const SizedBox(height: 12.0),
          Text(
            'Emojis & Emoticons',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8.0),
          const ShortcutItem(
            shortcut: ('Ctrl', 'S'),
            description: 'Toggle Search',
          ),
        ],
      ),
    );
  }
}
