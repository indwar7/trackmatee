import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E), // Dark purple
              Color(0xFF0F0F1E), // Darker purple-black
              Color(0xFF000000), // Black
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Title Section
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TRACKMATE',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Map Illustration
              Expanded(
                flex: 3,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Starry background
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width * 0.8,
                            MediaQuery.of(context).size.height * 0.4),
                        painter: StarryBackgroundPainter(),
                      ),
                      // Map illustration
                      CustomPaint(
                        size: Size(MediaQuery.of(context).size.width * 0.8,
                            MediaQuery.of(context).size.height * 0.4),
                        painter: MapIllustrationPainter(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Continue with Email Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6), // Purple
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue with Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Terms of Use Text
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    children: [
                      const TextSpan(text: 'By Signing up you agree to our '),
                      TextSpan(
                        text: 'Terms of Use',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for starry background
class StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw stars
    for (int i = 0; i < 30; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7) % size.height;
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for map illustration
class MapIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw compass structure
    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - size.height * 0.2),
      Offset(centerX, centerY + size.height * 0.2),
      paint,
    );
    
    // Horizontal line
    canvas.drawLine(
      Offset(centerX - size.width * 0.2, centerY),
      Offset(centerX + size.width * 0.2, centerY),
      paint,
    );

    // Draw map outline (simplified continents)
    final path = Path();
    
    // Left continent
    path.moveTo(centerX - size.width * 0.3, centerY - size.height * 0.1);
    path.lineTo(centerX - size.width * 0.25, centerY);
    path.lineTo(centerX - size.width * 0.3, centerY + size.height * 0.15);
    path.lineTo(centerX - size.width * 0.35, centerY + size.height * 0.1);
    path.close();
    
    // Right continent
    path.moveTo(centerX + size.width * 0.2, centerY - size.height * 0.15);
    path.lineTo(centerX + size.width * 0.3, centerY - size.height * 0.05);
    path.lineTo(centerX + size.width * 0.28, centerY + size.height * 0.1);
    path.lineTo(centerX + size.width * 0.15, centerY + size.height * 0.05);
    path.close();
    
    // Bottom continent
    path.moveTo(centerX - size.width * 0.1, centerY + size.height * 0.2);
    path.lineTo(centerX + size.width * 0.1, centerY + size.height * 0.25);
    path.lineTo(centerX + size.width * 0.05, centerY + size.height * 0.3);
    path.lineTo(centerX - size.width * 0.15, centerY + size.height * 0.28);
    path.close();

    // Draw with dotted line effect
    final dottedPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Draw path as dots
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final tangent = pathMetric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2, dottedPaint);
        }
        distance += 8;
      }
    }

    // Draw airplane icon (simplified)
    final airplanePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final airplaneX = centerX - size.width * 0.25;
    final airplaneY = centerY - size.height * 0.15;
    
    // Simple airplane shape
    final airplanePath = Path();
    airplanePath.moveTo(airplaneX, airplaneY);
    airplanePath.lineTo(airplaneX + 15, airplaneY - 5);
    airplanePath.lineTo(airplaneX + 20, airplaneY);
    airplanePath.lineTo(airplaneX + 15, airplaneY + 5);
    airplanePath.close();
    canvas.drawPath(airplanePath, airplanePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

