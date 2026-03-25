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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CompassPage(),
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

  double noiseTime = 0;
  double microJitter = 0;

  @override
  void initState() {
    super.initState();

    ticker = createTicker((_) {
      // SPRING FORCE
      final force = (target - angle) * 0.04;
      velocity += force;

      // DAMPING
      velocity *= 0.93;

      // TIME EVOLUTION
      noiseTime += 0.04;

      // 🔥 MULTI-LAYER WOBBLE

      // Slow drifting instability
      double drift = sin(noiseTime * 0.6) * 1.5;

      // Fluid oscillation
      double fluid = cos(noiseTime * 1.7) * 1.0;

      // Micro random jitter
      microJitter += (rng.nextDouble() - 0.5) * 0.6;
      microJitter *= 0.85;

      // Rare sudden twitch
      double twitch = (rng.nextDouble() < 0.03)
          ? (rng.nextDouble() - 0.5) * 10
          : 0;

      // Extra instability when near target
      double proximity = (target - angle).abs();
      double instability = proximity < 20
          ? (rng.nextDouble() - 0.5) * 1.5
          : 0;

      // FINAL MOTION
      angle += velocity + drift + fluid + microJitter + twitch + instability;

      // Prevent overflow (important for long runtime)
      angle = angle % 360;

      if (mounted) setState(() {});
    });

    ticker.start();
  }

  void spin() {
    final list = includeNorth
        ? [0, 45, 90, 135, 180, 225, 270, 315]
        : [45, 90, 135, 180, 225, 270, 315];

    final rand = list[rng.nextInt(list.length)];

    target = rand + ((rng.nextInt(5) + 3) * 360);
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
              ),
            ),
            const SizedBox(height: 50),

            GestureDetector(
              onTap: spin,
              child: Stack(
                alignment: Alignment.center,
                children: [

                  // WOOD FRAME
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E2723),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, blurRadius: 30, offset: Offset(15, 15))
                      ],
                    ),
                  ),

                  // BRASS RING
                  Container(
                    width: 240,
                    height: 240,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Color(0xFFD4AF37),
                          Color(0xFF8B7500),
                          Color(0xFFD4AF37)
                        ],
                      ),
                    ),
                  ),

                  // FACE
                  Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFFF3E5AB), Color(0xFFC4A484)],
                      ),
                    ),
                    child: CustomPaint(painter: CompassFacePainter()),
                  ),

                  // NEEDLE
                  Transform.rotate(
                    angle: angle * pi / 180,
                    child: CustomPaint(
                      size: const Size(220, 220),
                      painter: NeedlePainter(),
                    ),
                  ),

                  // CENTER
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),

            SwitchListTile(
              title: const Text("POINT TO NORTH?"),
              value: includeNorth,
              onChanged: (v) => setState(() => includeNorth = v),
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
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 16; i++) {
      double r = (i * 22.5) * pi / 180;
      canvas.drawLine(center, center + Offset(cos(r) * 90, sin(r) * 90), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..moveTo(c.dx, c.dy - 100)
      ..lineTo(c.dx + 15, c.dy)
      ..lineTo(c.dx, c.dy + 40)
      ..lineTo(c.dx - 15, c.dy)
      ..close();

    canvas.drawPath(path, Paint()..color = Colors.black);

    final tip = Path()
      ..moveTo(c.dx, c.dy - 100)
      ..lineTo(c.dx + 15, c.dy)
      ..lineTo(c.dx - 15, c.dy)
      ..close();

    canvas.drawPath(tip, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}