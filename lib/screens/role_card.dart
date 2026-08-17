import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/widget.dart';

/// Large tappable card used on the driver/passenger choice screens.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Row(
        children: [
          AccentIcon(icon, size: 52),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title.copyWith(fontSize: 18)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.bodyMuted.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 22),
        ],
      ),
    );
  }
}
