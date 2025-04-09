import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/custom_button.dart';
import '../providers/clipboard_provider.dart';
import '../widgets/clipboard_item_layout.dart';
import '../widgets/empty_clipboard_widget.dart';
import '../widgets/image_item_widget.dart';
import '../widgets/text_item_widget.dart';

class ClipboardPage extends StatelessWidget {
  const ClipboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClipboardProvider>();
    final activeItemIndex = provider.activeItemIndex;

    return Scaffold(
      body: provider.clipboard.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomButton(
                  onTap: provider.clearClipboard,
                  label: 'Clear',
                  margin: const EdgeInsets.only(
                    top: 8.0,
                    right: 16.0,
                    bottom: 20.0,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: provider.scrollController,
                    itemCount: provider.clipboard.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemBuilder: (context, index) {
                      final item = provider.clipboard[index];
                      final isActive = activeItemIndex == index;

                      return ClipboardItemLayout(
                        onTap: () => provider.copyItem(index),
                        isActive: isActive,
                        child: item.id.startsWith("text")
                            ? TextItemWidget(index: index, item: item)
                            : ImageItemWidget(index: index, item: item),
                      );
                    },
                  ),
                ),
              ],
            )
          : const EmptyClipboardWidget(),
    );
  }
}
