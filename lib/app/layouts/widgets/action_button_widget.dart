import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/layouts/bloc/main_layout_bloc.dart'; // We'll create this BLoC next

class ActionButtonWidget extends StatelessWidget {
  final Widget titleContent;
  final IconData iconData;
  final VoidCallback onTapAction; // Specific action for this button (e.g., navigation)
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn), // Ensure curve is applied if animation is raw controller
    );

    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn), // Ensure curve is applied
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ElevatedButton.icon(
            icon: Icon(iconData, size: 20),
            label: titleContent,
            onPressed: () {
              // Notify BLoC to toggle/close overlay
              context.read<MainLayoutBloc>().add(ToggleOverlayVisibility());
              // Execute the button's specific action
              onTapAction();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return colors.primaryContainer.withOpacity(0.5);
                }
                return colors.primaryContainer.withOpacity(0.95);
              }),
              foregroundColor: WidgetStateProperty.all<Color>(
                colors.onPrimaryContainer,
              ),
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return colors.onPrimaryContainer.withOpacity(0.12);
                }
                return null;
              }),
              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                const StadiumBorder(),
              ),
              elevation: WidgetStateProperty.all<double>(2),
              textStyle: WidgetStateProperty.all<TextStyle?>(
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}