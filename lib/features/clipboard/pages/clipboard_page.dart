import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/custom_button.dart';
import '../providers/clipboard_provider.dart';
import '../widgets/clipboard_item_layout.dart';
import '../widgets/empty_clipboard_widget.dart';
import '../widgets/text_item_widget.dart';

class ClipboardPage extends StatelessWidget {
  const ClipboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clipboardProvider = context.watch<ClipboardProvider>();
    clipboardProvider.initClipboard();

    final activeItemIndex = clipboardProvider.activeItemIndex;
    final isClipboardEmpty = clipboardProvider.clipboard.isEmpty;

    return Scaffold(
      body: !isClipboardEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomButton(
                  label: 'Clear',
                  onTap: clipboardProvider.clearClipboard,
                ),
                Expanded(
                  child: ListView.builder(
                    controller: clipboardProvider.scrollController,
                    itemCount: clipboardProvider.clipboard.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemBuilder: (context, index) {
                      final item = clipboardProvider.clipboard[index];
                      final isActive = activeItemIndex == index;

                      return ClipboardItemLayout(
                        onTap: () => clipboardProvider.copyItem(index),
                        isActive: isActive,
                        child: TextItemWidget(index: index, item: item),
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
