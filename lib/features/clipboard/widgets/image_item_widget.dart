import 'dart:io';

import 'package:flutter/material.dart';

import '../models/image_item.dart';
import './build_item_actions.dart';

class ImageItemWidget extends StatelessWidget {
  const ImageItemWidget({
    super.key,
    required this.index,
    required this.item,
  });

  final int index;
  final ImageItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Image.file(File(item.imageFilePath)),
        ),
        BuildItemActions(
          index: index,
          isImage: true,
        )
      ],
    );
  }
}
