import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/clipboard/providers/clipboard_provider.dart';
import '../features/home/pages/home_page.dart';

class SnackBarService {
  static final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  static void showSnackBar({
    required BuildContext context,
    required String message,
    bool showUndo = false,
    int time = 200,
  }) {
    final clipboardProvider = context.read<ClipboardProvider>();

    scaffoldKey.currentState
        ?.showSnackBar(
          SnackBar(
            duration: Duration(milliseconds: showUndo ? 5000 : time),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: Colors.black,
                      ),
                ),
                if (showUndo)
                  _UndoButton(
                    clipboardProvider: clipboardProvider,
                    scaffoldKey: scaffoldKey,
                  ),
              ],
            ),
          ),
        )
        .closed
        .then((SnackBarClosedReason reason) {
      final homePageState = homePageKey.currentState;
      final tabIndex = homePageState?.homeTabIndex;

      if (tabIndex != 0) return;

      switch (reason) {
        case SnackBarClosedReason.hide:
          break;

        default:
          if (showUndo) clipboardProvider.deleteItemPermanently();
          break;
      }
    });
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton({
    required this.clipboardProvider,
    required this.scaffoldKey,
  });

  final ClipboardProvider clipboardProvider;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapUp: (tap) {
        clipboardProvider.undoDeleteItem();
        scaffoldKey.currentState?.hideCurrentSnackBar();
      },
      child: Text(
        'Undo',
        style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Colors.black,
            ),
      ),
    );
  }
}
