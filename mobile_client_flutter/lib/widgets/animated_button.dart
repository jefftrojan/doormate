import 'package:flutter/material.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';

class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isGlass;
  final bool isOutlined;
  final Color? borderColor;
  final double borderWidth;
  final bool isLoading;
  final Widget? loadingWidget;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 56,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.gradientColors,
    this.padding,
    this.margin,
    this.isGlass = false,
    this.isOutlined = false,
    this.borderColor,
    this.borderWidth = 1.5,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBorderRadius = BorderRadius.circular(16);
    
    Widget buttonContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: widget.isLoading
          ? widget.loadingWidget ??
              SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isOutlined
                        ? (widget.borderColor ?? theme.primaryColor)
                        : Colors.white,
                  ),
                ),
              )
          : widget.child,
    );

    Widget buttonWidget;
    
    if (widget.isGlass) {
      buttonWidget = GradientGlassContainer(
        height: widget.height,
        width: widget.width,
        borderRadius: widget.borderRadius ?? defaultBorderRadius,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        margin: widget.margin,
        gradientColors: widget.gradientColors ?? [
          Colors.white.withOpacity(0.2),
          Colors.white.withOpacity(0.1),
        ],
        child: Center(child: buttonContent),
      );
    } else if (widget.isOutlined) {
      buttonWidget = Container(
        height: widget.height,
        width: widget.width,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? defaultBorderRadius,
          border: Border.all(
            color: widget.borderColor ?? theme.primaryColor,
            width: widget.borderWidth,
          ),
        ),
        child: Center(child: buttonContent),
      );
    } else {
      buttonWidget = Container(
        height: widget.height,
        width: widget.width,
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? defaultBorderRadius,
          color: widget.backgroundColor ?? theme.primaryColor,
          gradient: widget.gradientColors != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.gradientColors!,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? theme.primaryColor)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: buttonContent),
      );
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonWidget,
      ),
    );
  }
} 