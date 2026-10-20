import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _controller.forward().whenComplete(_goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -80,
              child: _circle(280, AppColors.gold.withValues(alpha: 0.1)),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: _circle(300, Colors.white.withValues(alpha: 0.04)),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final intro = Curves.easeOut
                      .transform((_controller.value * 3).clamp(0.0, 1.0));
                  final progress = Curves.easeInOut.transform(_controller.value);

                  return Opacity(
                    opacity: intro,
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * intro,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomPaint(
                            size: const Size(72, 90),
                            painter: _LogoPainter(),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'CLUBWEAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Menswear, simplified.',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 12.5,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 42),
                          Container(
                            width: 120,
                            height: 3,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Container(
                              width: 120 * progress,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(5, 5, size.width - 10, size.width - 10);
    canvas.drawArc(rect, 0.6, 5.1, false, ring);

    final line = Paint()
      ..color = AppColors.goldLight
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.butt;
    canvas.drawLine(
      Offset(size.width * 0.32, size.height - 3),
      Offset(size.width * 0.68, size.height - 3),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}