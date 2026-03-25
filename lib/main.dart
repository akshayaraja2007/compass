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
      // THE WOBBLE PHYSICS
      // Tension/Force towards target
      final force = (target - angle) * 0.06; 
      velocity += force;
      
      // Friction (lower makes it wobble longer)
      velocity *= 0.88; 

      // Small random "jitters" to simulate Jack's unstable compass
      if ((target - angle).abs() < 10) {
        velocity += (rng.nextDouble() - 0.5) * 0.5;
      }

      angle += velocity;

      if (mounted) setState(() {});
    });
    ticker.start();
  }

  void spin() {
    // Standard random directions
    final list = includeNorth
        ? [0, 45, 90, 135, 180, 225, 270, 315]
        : [45, 90, 135, 180, 225, 270, 315];

    // Select a random stop
    final rand = list[rng.nextInt(list.length)];
    
    // Logic for many spins before settling
    target = rand + ((rng.nextInt(5) + 4) * 360);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A07),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2B1B12), Color(0xFF0F0A07)],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "NOT NORTH?",
              style: TextStyle(
                fontSize: 20,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 50),

            // MAIN COMPASS BOX
            GestureDetector(
              onTap: spin,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Square Box (3D Wood Look)
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, blurRadius: 30, offset: Offset(15, 15))
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.brown.shade900, Colors.black],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFF2D1B0D), width: 10),
                    ),
                  ),

                  // The Golden Dial (Bezel)
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF8B7500), width: 2),
                      gradient: const SweepGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFF8B7500), Color(0xFFD4AF37)],
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 5),
                      ],
                    ),
                  ),

                  // The Paper/Parchment Face
                  Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFF3E5AB), Color(0xFFC4A484)],
                      ),
                    ),
                    child: CustomPaint(
                      painter: CompassFacePainter(),
                    ),
                  ),

                  // The Wobbly Needle
                  Transform.rotate(
                    angle: angle * pi / 180,
                    child: CustomPaint(
                      size: const Size(220, 220),
                      painter: NeedlePainter(),
                    ),
                  ),

                  // Center Pin
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      boxShadow: [BoxShadow(color: Colors.white24, blurRadius: 2)],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            // Bottom Switch Logic
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: SwitchListTile(
                title: const Text(
                  "POINT TO NORTH?",
                  style: TextStyle(color: Color(0xFFC4A484), fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("OR WHAT YOU WANT MOST...", style: TextStyle(fontSize: 10)),
                activeColor: const Color(0xFFD4AF37),
                value: includeNorth,
                onChanged: (v) => setState(() => includeNorth = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw Ornate Grid Lines
    for (int i = 0; i < 16; i++) {
      double r = (i * 22.5) * pi / 180;
      double length = i % 4 == 0 ? 100.0 : 85.0;
      canvas.drawLine(center, center + Offset(cos(r) * length, sin(r) * length), paint);
    }

    const textStyle = TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold);
    _drawText(canvas, "N", center + const Offset(0, -90), textStyle);
    _drawText(canvas, "S", center + const Offset(0, 90), textStyle);
    _drawText(canvas, "E", center + const Offset(90, 0), textStyle);
    _drawText(canvas, "W", center + const Offset(-90, 0), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(textDirection: TextDirection.ltr, text: TextSpan(text: text, style: style));
    tp.layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shadowPaint = Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final needlePaint = Paint()..color = const Color(0xFF1A1A1A);
    final tipPaint = Paint()..color = const Color(0xFF8B0000);

    final path = Path();
    path.moveTo(center.dx, center.dy - 100); // Point
    path.lineTo(center.dx + 15, center.dy);
    path.lineTo(center.dx, center.dy + 40);
    path.lineTo(center.dx - 15, center.dy);
    path.close();

    // 1. Draw Shadow
    canvas.save();
    canvas.translate(6, 6);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    // 2. Draw Body
    canvas.drawPath(path, needlePaint);

    // 3. Draw North Red Tip (Sharp triangle overlay)
    final tipPath = Path();
    tipPath.moveTo(center.dx, center.dy - 100);
    tipPath.lineTo(center.dx + 15, center.dy);
    tipPath.lineTo(center.dx - 15, center.dy);
    tipPath.close();
    canvas.drawPath(tipPath, tipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}