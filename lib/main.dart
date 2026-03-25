import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const CompassApp());
}

class CompassApp extends StatelessWidget {
  const CompassApp({super.key});

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
  // Logic remains untouched
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
      final force = (target - angle) * 0.05;
      velocity += force;
      velocity *= 0.9;
      angle += velocity;
      if (mounted) setState(() {});
    });
    ticker.start();
  }

  void spin() {
    final list = includeNorth
        ? [0, 90, 135, 180, 225, 270, 315]
        : [90, 135, 180, 225, 270, 315];

    final rand = list[rng.nextInt(list.length)];
    target = rand + ((rng.nextInt(3) + 2) * 360);
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for a premium feel
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF232526), Color(0xFF414345)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "PRO COMPASS",
              style: TextStyle(
                color: Colors.white70,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),

            // Main 3D Compass Section
            Center(
              child: GestureDetector(
                onTap: spin,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Case (The Bezel)
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.grey.shade800, Colors.black],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(10, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(-5, -5),
                          ),
                        ],
                      ),
                    ),
                    
                    // Dial Surface
                    Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),

                    // Fixed Degree Notches
                    ...List.generate(36, (i) {
                      return Transform.rotate(
                        angle: (i * 10) * pi / 180,
                        child: Container(
                          height: 235,
                          width: 2,
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: i % 9 == 0 ? 15 : 8,
                            width: i % 9 == 0 ? 3 : 1,
                            color: i % 9 == 0 ? Colors.amber : Colors.white24,
                          ),
                        ),
                      );
                    }),

                    // Rotating Element
                    Transform.rotate(
                      angle: angle * pi / 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 3D Shadow for Needle
                          Transform.translate(
                            offset: const Offset(3, 3),
                            child: _buildNeedle(Colors.black38),
                          ),
                          // Real Needle
                          _buildNeedle(null),
                        ],
                      ),
                    ),

                    // Glass Effect Cover
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                            Colors.white.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Controls with Modern Glass-morphic feel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Enable North Pole",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                  activeColor: Colors.amber,
                  value: includeNorth,
                  onChanged: (v) => setState(() => includeNorth = v),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              "TAP COMPASS TO SPIN",
              style: TextStyle(color: Colors.white30, fontSize: 10),
            )
          ],
        ),
      ),
    );
  }

  // Needle Widget Builder
  Widget _buildNeedle(Color? shadowColor) {
    return SizedBox(
      width: 40,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              // Top Half (North)
              _Triangle(color: shadowColor ?? Colors.redAccent, isUpsideDown: false),
              // Bottom Half (South)
              _Triangle(color: shadowColor ?? Colors.white70, isUpsideDown: true),
            ],
          ),
          // Center Pivot Pin
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: shadowColor ?? Colors.grey.shade400,
              boxShadow: [
                if (shadowColor == null)
                  const BoxShadow(color: Colors.black45, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Triangle for the 3D Needle
class _Triangle extends StatelessWidget {
  final Color color;
  final bool isUpsideDown;
  const _Triangle({required this.color, required this.isUpsideDown});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 90),
      painter: _TrianglePainter(color: color, isUpsideDown: isUpsideDown),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool isUpsideDown;
  _TrianglePainter({required this.color, required this.isUpsideDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (!isUpsideDown) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}