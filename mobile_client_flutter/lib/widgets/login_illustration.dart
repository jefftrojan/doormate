import 'package:flutter/material.dart';

class LoginIllustration extends StatelessWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const LoginIllustration({
    super.key,
    this.size = 200,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            height: size * 0.8,
            width: size * 0.8,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          
          // House outline
          Positioned(
            bottom: size * 0.2,
            child: CustomPaint(
              size: Size(size * 0.6, size * 0.5),
              painter: HousePainter(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
              ),
            ),
          ),
          
          // Person
          Positioned(
            bottom: size * 0.15,
            right: size * 0.25,
            child: CustomPaint(
              size: Size(size * 0.15, size * 0.25),
              painter: PersonPainter(
                primaryColor: primaryColor,
              ),
            ),
          ),
          
          // Key
          Positioned(
            bottom: size * 0.3,
            left: size * 0.25,
            child: Transform.rotate(
              angle: -0.3,
              child: CustomPaint(
                size: Size(size * 0.2, size * 0.1),
                painter: KeyPainter(
                  primaryColor: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HousePainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  HousePainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = secondaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // House base
    final baseRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRect(baseRect, fillPaint);
    canvas.drawRect(baseRect, paint);

    // Roof
    final roofPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..close();
    canvas.drawPath(roofPath, fillPaint);
    canvas.drawPath(roofPath, paint);

    // Door
    final doorRect = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.7,
      size.width * 0.2,
      size.height * 0.3,
    );
    canvas.drawRect(doorRect, paint);

    // Doorknob
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.85),
      size.width * 0.02,
      paint,
    );

    // Window
    final windowRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.15,
    );
    canvas.drawRect(windowRect, paint);
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.575),
      Offset(size.width * 0.45, size.height * 0.575),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.5),
      Offset(size.width * 0.375, size.height * 0.65),
      paint,
    );

    // Second Window
    final window2Rect = Rect.fromLTWH(
      size.width * 0.55,
      size.height * 0.5,
      size.width * 0.15,
      size.height * 0.15,
    );
    canvas.drawRect(window2Rect, paint);
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.575),
      Offset(size.width * 0.7, size.height * 0.575),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.5),
      Offset(size.width * 0.625, size.height * 0.65),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PersonPainter extends CustomPainter {
  final Color primaryColor;

  PersonPainter({
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.3,
      paint,
    );

    // Body
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.7),
      paint,
    );

    // Arms
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.2, size.height * 0.55),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.55),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.95),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.95),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class KeyPainter extends CustomPainter {
  final Color primaryColor;

  KeyPainter({
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Key head
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      size.height * 0.4,
      paint,
    );

    // Key shaft
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.5),
      paint,
    );

    // Key teeth
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.7),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.9),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedLoginIllustration extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration duration;

  const AnimatedLoginIllustration({
    super.key,
    this.size = 200,
    required this.primaryColor,
    required this.secondaryColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<AnimatedLoginIllustration> createState() => _AnimatedLoginIllustrationState();
}

class _AnimatedLoginIllustrationState extends State<AnimatedLoginIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: LoginIllustration(
              size: widget.size,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
            ),
          ),
        );
      },
    );
  }
} 