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
    this.duration = const Duration(seconds: 4),
    this.style,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: false);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors =
        widget.colors.length >= 2
            ? widget.colors
            : [
              widget.style?.color ?? Colors.black,
              widget.style?.color ?? Colors.black,
            ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double shift = _animation.value * 2.0;

        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback:
              (bounds) => LinearGradient(
                colors: effectiveColors,
                begin: Alignment(-1.0 + shift, 0.0),
                end: Alignment(1.0 + shift, 0.0),
                tileMode: TileMode.repeated,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}
