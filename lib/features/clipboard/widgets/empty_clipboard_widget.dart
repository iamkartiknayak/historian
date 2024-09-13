import 'package:flutter/material.dart';

class EmptyClipboardWidget extends StatelessWidget {
  const EmptyClipboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: Image.asset(
              'assets/images/empty_clipboard.png',
              height: 100.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            'Nothing to paste!',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10.0),
          Text(
            'You\'ll see your clipboard history once you\'ve copied something.',
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50.0)
        ],
      ),
    );
  }
}
