import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/layouts/bloc/main_layout_bloc.dart';

/// An animated action button with icon and text.
///
/// This widget provides a customized button with animations for overlay menus
/// and handles toggling the overlay visibility through the MainLayoutBloc.
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Create slide animation
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn));

    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ElevatedButton.icon(
            icon: Icon(iconData, size: 20),
            label: titleContent,
            onPressed: () {
              context.read<MainLayoutBloc>().add(ToggleOverlayVisibility());
              onTapAction();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.pressed)) {
                  return colorScheme.primaryContainer.withOpacity(0.5);
                }
                return colorScheme.primaryContainer.withOpacity(0.95);
              }),
              foregroundColor: MaterialStateProperty.all<Color>(
                colorScheme.onPrimaryContainer,
              ),
              overlayColor: MaterialStateProperty.resolveWith<Color?>((
                Set<MaterialState> states,
              ) {
                if (states.contains(MaterialState.pressed)) {
                  return colorScheme.onPrimaryContainer.withOpacity(0.12);
                }
                return null;
              }),
              padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const StadiumBorder(),
              ),
              elevation: MaterialStateProperty.all<double>(2),
              textStyle: MaterialStateProperty.all<TextStyle?>(
                textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
