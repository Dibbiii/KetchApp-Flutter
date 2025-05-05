import 'package:flutter/material.dart';

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final List<Color> colors;
  final Duration duration;
  final TextStyle? style;

  const AnimatedGradientText({
    super.key,
    required this.text,
    required this.colors,
    this.duration = const Duration(seconds: 4), // Adjusted default duration
    this.style,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: false); // Ensure it loops infinitely forward

    // Use a linear animation for constant speed
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure there are at least two colors for a gradient
    final effectiveColors =
        widget.colors.length >= 2
            ? widget.colors
            // Fallback if fewer than 2 colors are provided
            : [
              widget.style?.color ?? Colors.black,
              widget.style?.color ?? Colors.black,
            ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate a shift value based on the animation.
        // Multiplying by 2 means the gradient pattern shifts by twice its width
        // over one animation cycle, ensuring smooth repetition with TileMode.repeated.
        final double shift = _animation.value * 2.0;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          // Apply gradient color only where text is drawn
          shaderCallback:
              (bounds) => LinearGradient(
                colors: effectiveColors,
                // Animate the horizontal alignment. The gradient starts at (-1 + shift)
                // and ends at (1 + shift). As shift goes from 0 to 2, the gradient
                // pattern effectively scrolls across the text area.
                begin: Alignment(-1.0 + shift, 0.0),
                // Start alignment shifts left-to-right
                end: Alignment(1.0 + shift, 0.0),
                // End alignment also shifts left-to-right
                // TileMode.repeated makes the gradient pattern repeat infinitely,
                // creating a seamless scroll effect when combined with the alignment shift.
                tileMode: TileMode.repeated,
              ).createShader(
                // Define the rectangle area for the shader (the text bounds)
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
          // The Text widget that the gradient mask is applied to
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}
