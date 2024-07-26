import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'dart:io';

import 'package:historian/theme.dart';

class ClipboardItemWidget extends StatelessWidget {
  const ClipboardItemWidget({
    super.key,
    this.text,
    this.file,
    required this.isPinned,
    required this.isSelected,
    required this.onTap,
    required this.onPinTap,
    required this.onDeleteTap,
    this.onSaveTap,
  });

  final String? text;
  final File? file;
  final bool isPinned;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPinTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onSaveTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.getSelectionColor(context)
                          : Colors.blueGrey.shade700,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: text != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: Text(
                            text!,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.only(right: 32),
                          constraints: const BoxConstraints(
                            minHeight: 100,
                            maxHeight: 100.0,
                          ),
                          child: Image.file(file!),
                        ),
                ),
              ),
            ],
          ),
          _buildItemOptions()
        ],
      ),
    );
  }

  Positioned _buildItemOptions() {
    return Positioned(
      right: 20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: onPinTap,
            child: Icon(
              isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
              size: 16,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onDeleteTap,
            child: const Icon(
              CupertinoIcons.delete,
              size: 16,
            ),
          ),
          const SizedBox(height: 16),
          file != null
              ? InkWell(
                  onTap: onSaveTap,
                  child: const Icon(
                    CupertinoIcons.share,
                    size: 16,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
