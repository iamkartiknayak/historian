import 'package:flutter/material.dart';

class EmptyClipboardWidget extends StatelessWidget {
  const EmptyClipboardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      height: screenHeight + 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
            child: Image.asset(
              'assets/images/empty.png',
              color: Theme.of(context).textTheme.bodyLarge!.color,
              height: 80.0,
            ),
          ),
          Text(
            'Nothing to paste!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 10.0),
          Text(
            'You\'ll see your clipboard history once you\'ve copied something.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
