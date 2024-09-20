import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../services/app_services.dart';
import '../../../common/accent_svg_icon.dart';

const gitHubRepoUrl = 'https://github.com/iamkartiknayak/Flutter_Historian';

class AppVersionCard extends StatelessWidget {
  const AppVersionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<BorderRadiusTheme>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(borderRadius!.categoryTwoRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          const AccentSvgIcon(iconPath: 'assets/svgs/logo.svg'),
          const SizedBox(width: 10.0),
          const Text('Historian v2.6.3'),
          const Spacer(),
          InkWell(
            onTap: () => AppServices().launchUrl(gitHubRepoUrl),
            child: const AccentSvgIcon(
              iconPath: 'assets/svgs/github.svg',
            ),
          ),
        ],
      ),
    );
  }
}
