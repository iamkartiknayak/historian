import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../settings/pages/settings_page.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SettingsPage(),
        ),
      ),
      child: SvgPicture.asset(
        'assets/svgs/settings_outlined.svg',
        colorFilter: ColorFilter.mode(
          Colors.grey.shade700,
          BlendMode.srcIn,
        ),
        height: 24,
      ),
    );
  }
}
