import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../providers/clipboard_provider.dart';
import './action_icon_button.dart';

class BuildItemActions extends StatelessWidget {
  const BuildItemActions({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context) {
    final clipboardProvider = context.read<ClipboardProvider>();
    final isPinned = clipboardProvider.clipboard[index].isPinned;
    final pinIcon = isPinned
        ? 'assets/svgs/pin_filled.svg'
        : 'assets/svgs/pin_outlined.svg';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ActionIconButton(
          svgPath: pinIcon,
          onTap: () => clipboardProvider.handleItemPin(index),
        ),
        ActionIconButton(
          svgPath: 'assets/svgs/delete_outlined.svg',
          onTap: () => clipboardProvider.deleteItem(index),
        ),
      ],
    );
  }
}
