import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../widgets/app_version_card.dart';
import '../provider/setting_page_provider.dart';
import '../../clipboard/widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const pageRoute = '/settingsPage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsPageProvider>(builder: (context, value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
                icon: CupertinoIcons.chevron_back,
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Clipboard size',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const Spacer(),
                  CustomButton(
                    onTap: () =>
                        value.setClipboardSize(ModificationType.decrement),
                    icon: CupertinoIcons.chevron_down,
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      value.clipboardSize.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomButton(
                    onTap: () =>
                        value.setClipboardSize(ModificationType.increment),
                    icon: CupertinoIcons.chevron_up,
                  )
                ],
              ),
              const Spacer(),
              const AppVersionCard()
            ],
          ),
        );
      }),
    );
  }
}
