import 'package:flutter/material.dart';

enum AnimationDirection {
  fromBottom,
  fromTop,
  fromLeft,
  fromRight,
}

class AnimatedFadeSlide extends StatefulWidget {
  final Widget child;
  final AnimationController? controller;
  final Duration? delay;
  final Offset? beginOffset;
  final Curve curve;
  final bool show;
  final AnimationDirection direction;
  final Duration duration;

  const AnimatedFadeSlide({
    super.key,
    required this.child,
    this.controller,
    this.delay,
    this.beginOffset,
    this.curve = Curves.easeOut,
    this.show = true,
    this.direction = AnimationDirection.fromBottom,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedFadeSlide> createState() => _AnimatedFadeSlideState();
}

class _AnimatedFadeSlideState extends State<AnimatedFadeSlide> with SingleTickerProviderStateMixin {
  AnimationController? _internalController;
  late Offset _beginOffset;

  AnimationController get _effectiveController => widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
      
      if (widget.show) {
        Future.delayed(widget.delay ?? Duration.zero, () {
          if (mounted) {
            _internalController!.forward();
          }
        });
      }
    }
    
    _updateBeginOffset();
  }
  
  void _updateBeginOffset() {
    if (widget.beginOffset != null) {
      _beginOffset = widget.beginOffset!;
    } else {
      switch (widget.direction) {
        case AnimationDirection.fromBottom:
          _beginOffset = const Offset(0, 0.2);
          break;
        case AnimationDirection.fromTop:
          _beginOffset = const Offset(0, -0.2);
          break;
        case AnimationDirection.fromLeft:
          _beginOffset = const Offset(-0.2, 0);
          break;
        case AnimationDirection.fromRight:
          _beginOffset = const Offset(0.2, 0);
          break;
      }
    }
  }

  @override
  void didUpdateWidget(AnimatedFadeSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.direction != oldWidget.direction && widget.beginOffset == null) {
      _updateBeginOffset();
    }
    
    if (_internalController != null && widget.show != oldWidget.show) {
      if (widget.show) {
        Future.delayed(widget.delay ?? Duration.zero, () {
          if (mounted) {
            _internalController!.forward();
          }
        });
      } else {
        _internalController!.reverse();
      }
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the begin and end values for the interval
    final double beginValue = widget.delay != null ? (widget.delay!.inMilliseconds / 1000.0).clamp(0.0, 0.9) : 0.0;
    final double endValue = (beginValue + 0.5).clamp(0.0, 1.0);
    
    final Animation<double> opacity = CurvedAnimation(
      parent: _effectiveController,
      curve: Interval(
        beginValue,
        endValue,
        curve: widget.curve,
      ),
    );

    final Animation<Offset> position = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _effectiveController,
        curve: Interval(
          beginValue,
          endValue,
          curve: widget.curve,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: _effectiveController,
      builder: (context, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: Offset(
              position.value.dx * 100,
              position.value.dy * 100,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class StaggeredAnimations extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDuration;
  final AnimationDirection direction;
  final double offset;
  final Curve curve;
  final bool show;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const StaggeredAnimations({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 500),
    this.staggerDuration = const Duration(milliseconds: 100),
    this.direction = AnimationDirection.fromBottom,
    this.offset = 50,
    this.curve = Curves.easeOutCubic,
    this.show = true,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: List.generate(
        children.length,
        (index) => AnimatedFadeSlide(
          child: children[index],
          delay: Duration(milliseconds: index * staggerDuration.inMilliseconds),
          direction: direction,
          show: show,
          duration: itemDuration,
        ),
      ),
    );
  }
}