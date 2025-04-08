import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final dynamic borderRadius;
  final double blur;
  final double opacity;
  final Color color;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color = Colors.white,
    this.border,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius = borderRadius is BorderRadius
        ? borderRadius
        : BorderRadius.circular(borderRadius is double ? borderRadius : 16.0);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: effectiveBorderRadius,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}

// A preset glass container with a nice gradient effect
class GradientGlassContainer extends StatelessWidget {
  final Widget child;
  final dynamic borderRadius;
  final double blur;
  final List<Color> gradientColors;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool useCircularGradient;
  final Color? backgroundColor;
  final Color? borderColor;

  const GradientGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.blur = 10.0,
    required this.gradientColors,
    this.border,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.useCircularGradient = false,
    this.backgroundColor,
    this.borderColor, EdgeInsetsGeometry? margin,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius effectiveBorderRadius = borderRadius is BorderRadius
        ? borderRadius
        : BorderRadius.circular(borderRadius is double ? borderRadius : 16.0);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: useCircularGradient
                ? RadialGradient(
                    colors: gradientColors,
                    center: Alignment.center,
                    radius: 1.0,
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
            borderRadius: effectiveBorderRadius,
            border: border ?? (borderColor != null ? Border.all(color: borderColor!) : null),
            color: backgroundColor,
          ),
          child: child,
        ),
      ),
    );
  }
}