import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ketchapp_flutter/components/footer.dart'; // Import Footer
// app_colors.dart is likely superseded by Theme.of(context).colorScheme
import 'package:ketchapp_flutter/components/animated_gradient_text.dart';
import 'package:ketchapp_flutter/components/header.dart'; // Import the new widget
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ketchapp_flutter/app/layouts/bloc/main_layout_bloc.dart';
import 'package:ketchapp_flutter/app/layouts/widgets/action_button_widget.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  OverlayEntry? _optionsOverlayEntry;
  late AnimationController _fabAnimationController;
  late AnimationController _overlayContentAnimationController;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _overlayContentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ), // Kept from previous optimization
    );
  }

  Future<void> _removeOptionsOverlayInternal() async {
    if (_optionsOverlayEntry != null) {
      await _overlayContentAnimationController.reverse().orCancel;
      _optionsOverlayEntry?.remove();
      _optionsOverlayEntry = null;
    }
  }

  @override
  void dispose() {
    _removeOptionsOverlayInternal(); // Attempt to clean up
    _fabAnimationController.dispose();
    _overlayContentAnimationController.dispose();
    super.dispose();
  }

  // Modify this method to accept a context that can find the BLoC
  void _showOptionsOverlayInternal(BuildContext blocContext) {
    if (_optionsOverlayEntry != null) return;

    // For Theme, MediaQuery, etc., you can still use this.context if needed,
    // or pass blocContext if it's guaranteed to have them (usually it will).
    final ColorScheme colors = Theme.of(this.context).colorScheme;
    final TextTheme textTheme = Theme.of(this.context).textTheme;
    final MediaQueryData mediaQuery = MediaQuery.of(this.context);

    final double bottomSafeArea = mediaQuery.padding.bottom;
    final double fabHeight = 56.0;
    final double fabMargin = 16.0;
    // Corrected Footer height: kBottomNavigationBarHeight (56.0) + internal vertical padding (6.0 * 2 = 12.0)
    final double footerHeight =
        kBottomNavigationBarHeight + (6.0 * 2); // Total 68.0

    // Position of the Scaffold's FAB (which is always visible)
    final double mainFabBottomEdgeFromScreenBottom =
        bottomSafeArea + footerHeight + fabMargin;
    final double mainFabRightEdgeFromScreenRight = fabMargin;

    // Action buttons are positioned above the main FAB
    final double gapAboveMainFab = 16.0;
    final double actionButtonsBottomOffset =
        mainFabBottomEdgeFromScreenBottom + fabHeight + gapAboveMainFab;

    final Animation<double> button1Animation = CurvedAnimation(
      parent: _overlayContentAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
    );
    final Animation<double> button2Animation = CurvedAnimation(
      parent: _overlayContentAnimationController,
      curve: const Interval(0.15, 0.75, curve: Curves.fastOutSlowIn),
    );

    _optionsOverlayEntry = OverlayEntry(
      builder: (overlayBuildContext) {
        // This is the overlay's own context
        return BlocProvider.value(
          value: BlocProvider.of<MainLayoutBloc>(
            blocContext,
          ), // Use the passed blocContext here
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    // Use blocContext or overlayBuildContext.read here
                    onTap:
                        () => blocContext.read<MainLayoutBloc>().add(
                          ToggleOverlayVisibility(),
                        ),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
                Positioned(
                  bottom: actionButtonsBottomOffset, // Ensure this is defined
                  right:
                      mainFabRightEdgeFromScreenRight, // Ensure this is defined
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      ActionButtonWidget(
                        iconData: Icons.edit_note,
                        titleContent: Text(
                          'Create Manual Plan',
                          style: TextStyle(color: colors.onPrimaryContainer),
                        ),
                        // Use this.context for GoRouter if it needs the router from the main widget tree
                        onTapAction:
                            () =>
                                GoRouter.of(this.context).push('/plan/manual'),
                        animation: button2Animation,
                      ),
                      ActionButtonWidget(
                        iconData: Icons.auto_awesome,
                        titleContent: AnimatedGradientText(
                          text: 'Plan with AI',
                          colors: [
                            colors.primary,
                            colors.tertiary.withAlpha(
                              (0.2 * 255).round(),
                            ), // Adjusted for alpha
                          ],
                          style: textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                        onTapAction:
                            () => GoRouter.of(
                              this.context,
                            ).push('/plan/automatic'),
                        animation: button1Animation,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(
      this.context,
    ).insert(_optionsOverlayEntry!); // Use this.context for Overlay.of
    _overlayContentAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainLayoutBloc(),
      child: BlocConsumer<MainLayoutBloc, MainLayoutState>(
        listener: (blocConsumerContext, state) {
          // Renamed to blocConsumerContext for clarity
          if (state.isOverlayVisible) {
            if (_optionsOverlayEntry == null) {
              _fabAnimationController.forward();
              _showOptionsOverlayInternal(
                blocConsumerContext,
              ); // Pass the correct context here
            }
          } else {
            if (_optionsOverlayEntry != null) {
              _fabAnimationController.reverse();
              _removeOptionsOverlayInternal();
            }
          }
        },
        builder: (builderContext, state) {
          // Renamed to builderContext for clarity
          final ColorScheme colors = Theme.of(builderContext).colorScheme;
          final bool isOverlayOpen = state.isOverlayVisible;

          return Scaffold(
            appBar: Header(),
            body: widget.child,
            floatingActionButton: FloatingActionButton(
              onPressed:
                  () => builderContext.read<MainLayoutBloc>().add(
                    ToggleOverlayVisibility(),
                  ),
              backgroundColor:
                  isOverlayOpen ? colors.primary : colors.primaryContainer,
              foregroundColor:
                  isOverlayOpen ? colors.onPrimary : colors.primary,
              tooltip: isOverlayOpen ? 'Close' : 'Create Plan',
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              elevation: isOverlayOpen ? 4.0 : 2.0,
              child: RotationTransition(
                turns: Tween(
                  begin: 0.0,
                  end: 0.125,
                ).animate(_fabAnimationController),
                child: const Icon(Icons.add, size: 28),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: const Footer(),
          );
        },
      ),
    );
  }
}
