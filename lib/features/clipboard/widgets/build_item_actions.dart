import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../services/app_services.dart';
import '../providers/clipboard_provider.dart';
import './action_icon_button.dart';

class BuildItemActions extends StatelessWidget {
  const BuildItemActions({
    super.key,
    required this.index,
    required this.isUrl,
  });

  final int index;
  final bool isUrl;

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
        if (isUrl)
          ActionIconButton(
            svgPath: 'assets/svgs/open.svg',
            onTap: () => AppServices()
                .launchUrl(clipboardProvider.clipboard[index].textPreview),
          )
      ],
    );
  }
}
