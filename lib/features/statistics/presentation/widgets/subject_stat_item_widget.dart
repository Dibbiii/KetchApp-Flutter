// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SubjectStatItemWidget extends StatelessWidget {
  final IconData subjectIcon;
  final Color iconColor;
  final String subjectName;
  final String studyTime;
  final IconData? trailingIcon;
  final VoidCallback? onTap; // Add onTap callback

  const SubjectStatItemWidget({
    super.key,
    required this.subjectIcon,
    this.iconColor = Colors.grey,
    required this.subjectName,
    required this.studyTime,
    this.trailingIcon,
    this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap, // Assign the onTap callback
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(subjectIcon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    studyTime,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: colors.onSurfaceVariant.withOpacity(0.7),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
