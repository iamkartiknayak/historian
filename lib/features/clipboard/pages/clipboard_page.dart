import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'dart:io';

import '../widgets/custom_button.dart';
import '../provider/clipboard_provider.dart';
import '../widgets/clipboard_item_widget.dart';
import '../../settings/pages/settings_pag.dart';
import '../widgets/empty_clipboard_widget.dart';
import '../../settings/provider/setting_page_provider.dart';

class ClipboardPage extends StatelessWidget {
  const ClipboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsPageProvider = context.read<SettingsPageProvider>();
    final itemCount = settingsPageProvider.clipboardSize;

    Future(() => context.read<ClipboardProvider>().loadAppSettings(itemCount));

    return Scaffold(
      body: Consumer<ClipboardProvider>(
        builder: (context, value, _) {
          final bool isClipboardEmpty = value.clipboard.isEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: isClipboardEmpty ? 0 : 1,
                      child: CustomButton(
                        label: 'Clear',
                        onTap: value.clearClipboard,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      icon: CupertinoIcons.settings,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        SettingsPage.pageRoute,
                      ),
                    ),
                  ],
                ),
              ),
              isClipboardEmpty
                  ? const EmptyClipboardWidget()
                  : const SizedBox.shrink(),
              Expanded(child: _buildClipboardItems(value)),
            ],
          );
        },
      ),
    );
  }

  ScrollablePositionedList _buildClipboardItems(ClipboardProvider value) {
    return ScrollablePositionedList.builder(
      itemScrollController: value.scrollController,
      itemPositionsListener: value.positionsListener,
      reverse: true,
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      itemCount: value.clipboard.length,
      itemBuilder: (context, index) {
        final content = value.clipboard[index].content;
        final isPinned = value.clipboard[index].isPinned;
        final isFile = content is File;
        return ClipboardItemWidget(
          text: !isFile ? content : null,
          file: isFile ? content : null,
          isPinned: isPinned,
          isSelected: index == value.selectedItemIndex,
          onTap: () {
            value.copySelectedContent(index);
            _showSnackBar(context, 'Item copied to clipboard');
          },
          onPinTap: () =>
              isPinned ? value.unpinItem(index) : value.pinItem(index),
          onDeleteTap: () =>
              isFile ? value.deleteImage(index) : value.deleteText(index),
          onSaveTap: isFile
              ? () async {
                  final saved = await value.saveImageFile(content.path);

                  if (!saved) return;
                  Future(() => _showSnackBar(context, 'Image has been saved'));
                }
              : null,
        );
      },
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2000),
      content: Text(
        message,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      backgroundColor: Theme.of(context).buttonTheme.colorScheme!.surface,
    ),
  );
}
