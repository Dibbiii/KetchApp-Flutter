import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final Widget titleContent;
  final IconData iconData;
  final VoidCallback onTapAction;
  final Animation<double> animation;

  const ActionButtonWidget({
    super.key,
    required this.titleContent,
    required this.iconData,
    required this.onTapAction,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: GestureDetector(
        onTap: onTapAction,
        child: Row(
          children: [
            Icon(iconData),
            const SizedBox(width: 8),
            titleContent,
          ],
        ),
      ),
    );
  }
}
