import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final bool useCircularGradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors = const [
      Color(0xFFF5F0E6),
      Color(0xFFE6D7C3),
      Color(0xFFD8C4A9),
    ],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.useCircularGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: useCircularGradient
            ? RadialGradient(
                colors: colors,
                center: Alignment.center,
                radius: 1.0,
              )
            : LinearGradient(
                begin: begin,
                end: end,
                colors: colors,
              ),
      ),
      child: child,
    );
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<List<Color>> colorSets;
  final Duration duration;
  final Curve curve;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.colorSets,
    this.duration = const Duration(seconds: 10),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentIndex;
  late int _nextIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _nextIndex = 1;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = _nextIndex;
            _nextIndex = (_nextIndex + 1) % widget.colorSets.length;
          });
          _controller.reset();
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final List<Color> currentColors = widget.colorSets[_currentIndex];
        final List<Color> nextColors = widget.colorSets[_nextIndex];
        final List<Color> animatedColors = List.generate(
          currentColors.length,
          (index) {
            return Color.lerp(
              currentColors[index],
              nextColors[index],
              _controller.value,
            )!;
          },
        );

        return GradientBackground(
          colors: animatedColors,
          child: widget.child,
        );
      },
    );
  }
} 