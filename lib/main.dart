import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const PiratesCompassApp());
}

class PiratesCompassApp extends StatelessWidget {
  const PiratesCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CompassPage(),
    );
  }
}

class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage>
    with SingleTickerProviderStateMixin {
  
  // LOGIC REMAINS AS REQUESTED
  double angle = 180;
  double target = 180;
  double velocity = 0;
  bool includeNorth = false;

  late Ticker ticker;
  final rng = Random();

  @override
  void initState() {
    super.initState();
    ticker = createTicker((_) {
      // Physics for the "wobbly" needle effect
      final force = (target - angle) * 0.04; 
      velocity += force;
      velocity *= 0.92; // Friction
      angle += velocity;

      if (mounted) setState(() {});
    });
    ticker.start();
  }

  void spin() {
    // Logic: Point everywhere except North (0/360) unless includeNorth is true
    final list = includeNorth
        ? [0, 45, 90, 135, 180, 225, 270, 315]
        : [45, 90, 135, 180, 225, 270, 315];

    final rand = list[rng.nextInt(list.length)];
    // Add extra spins for cinematic effect
    target = rand + ((rng.nextInt(4) + 3) * 360);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A120B), // Dark wood color
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF3C2A21), Color(0xFF1A120B)],
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "WHERE DOES IT POINT?",
              style: TextStyle(
                fontFamily: 'Serif',
                fontSize: 18,
                letterSpacing: 4,
                color: Color(0xFFD4AF37),
                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 40),

            // COMPASS UNIT
            Center(
              child: GestureDetector(
                onTap: spin,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer 3D Wooden Case
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(10, 10))
                        ],
                        gradient: LinearGradient(
                          colors: [Colors.brown.shade900, Colors.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: const Color(0xFF3E2723), width: 8),
                      ),
                    ),

                    // Brass Bezel Ring
                    Container(
                      width: 275,
                      height: 275,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFF8B7500), Color(0xFFD4AF37)],
                          stops: [0.0, 0.5, 1.0],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            inset: true,
                            blurRadius: 5,
                          )
                        ],
                      ),
                    ),

                    // Inner Vintage Face (Parchment)
                    Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE5D3B3),
                        gradient: RadialGradient(
                          colors: [Color(0xFFF5E9D3), Color(0xFFC4A484)],
                        ),
                      ),
                      child: CustomPaint(
                        painter: CompassFacePainter(),
                      ),
                    ),

                    // Rotating Needle
                    Transform.rotate(
                      angle: angle * pi / 180,
                      child: CustomPaint(
                        size: const Size(250, 250),
                        painter: NeedlePainter(),
                      ),
                    ),

                    // Glass Glint (Overlay)
                    IgnorePointer(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.transparent,
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Controls
            Theme(
              data: ThemeData(switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(const Color(0xFFD4AF37)),
                trackColor: WidgetStateProperty.all(const Color(0xFF3C2A21)),
              )),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SwitchListTile(
                  title: const Text(
                    "FIND WHAT YOU TRULY WANT",
                    style: TextStyle(fontFamily: 'Serif', color: Colors.white70, fontSize: 12),
                  ),
                  value: includeNorth,
                  onChanged: (v) => setState(() => includeNorth = v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter for the hand-drawn compass rose
class CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw cardinal lines
    for (int i = 0; i < 8; i++) {
      double r = (i * 45) * pi / 180;
      canvas.drawLine(center, center + Offset(cos(r) * 110, sin(r) * 110), paint);
    }

    // Hand drawn letters (Stylized)
    const style = TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif');
    _drawText(canvas, "N", center + const Offset(0, -100), style);
    _drawText(canvas, "S", center + const Offset(0, 100), style);
    _drawText(canvas, "E", center + const Offset(100, 0), style);
    _drawText(canvas, "W", center + const Offset(-100, 0), style);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: text, style: style));
    tp.layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Painter for the 3D Needle
class NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shadowPaint = Paint()..color = Colors.black26..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final ironPaint = Paint()..color = const Color(0xFF2C3E50);
    final tipPaint = Paint()..color = const Color(0xFFC0392B);

    final needlePath = Path();
    // Modern Gothic/Ornate needle shape
    needlePath.moveTo(center.dx, center.dy - 110); // Point
    needlePath.lineTo(center.dx + 12, center.dy);
    needlePath.lineTo(center.dx, center.dy + 30);
    needlePath.lineTo(center.dx - 12, center.dy);
    needlePath.close();

    // Draw shadow first
    canvas.save();
    canvas.translate(5, 5);
    canvas.drawPath(needlePath, shadowPaint);
    canvas.restore();

    // Draw needle
    canvas.drawPath(needlePath, ironPaint);
    
    // Draw North tip detail
    final tipPath = Path();
    tipPath.moveTo(center.dx, center.dy - 110);
    tipPath.lineTo(center.dx + 12, center.dy);
    tipPath.lineTo(center.dx - 12, center.dy);
    tipPath.close();
    canvas.drawPath(tipPath, tipPaint);

    // Pivot center
    canvas.drawCircle(center, 6, Paint()..color = const Color(0xFFD4AF37));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}