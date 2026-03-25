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

  final stiffness = 0.04;
  final damping = 0.90;

  late final Ticker ticker;

  final List<double> withoutNorth = [90,135,180,225,270,315];
  final List<double> withNorth = [0,90,135,180,225,270,315];

  final Random rng = Random();

  @override
  void initState() {
    super.initState();

    ticker = createTicker((_) {
      final force = (target - angle) * stiffness;
      velocity += force;
      velocity *= damping;
      angle += velocity;

      setState(() {});
    });

    ticker.start();
  }

  // 🔥 STRICT RANDOM COMPASS (NO REAL BEHAVIOR)
  void spinCompass() {
    final list = includeNorth ? withNorth : withoutNorth;

    double randAngle = list[rng.nextInt(list.length)];

    // add multiple spins for realism
    int spins = (rng.nextInt(3) + 2) * 360;

    target = randAngle + spins;
  }

  void toggleNorth() {
    setState(() {
      includeNorth = !includeNorth;

      // If currently near north and disabled → force move
      double current = angle % 360;
      if (current < 0) current += 360;

      if (!includeNorth && (current < 15 || current > 345)) {
        spinCompass();
      }
    });
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          /// COMPASS
          GestureDetector(
            onTap: spinCompass,
            child: Center(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(0.28),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    /// OUTER BRASS RING
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFf1d58a), Color(0xFF8a6a2a)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                    ),

                    /// INNER FACE
                    Container(
                      width: 240,
                      height: 240,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFe3d3b6), Color(0xFFb89f78)],
                        ),
                      ),
                    ),

                    /// CARDINAL MARKS
                    const Positioned(
                        top: 20,
                        child: Text("N",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 22,
                                fontWeight: FontWeight.bold))),
                    const Positioned(bottom: 20, child: Text("S")),
                    const Positioned(left: 20, child: Text("W")),
                    const Positioned(right: 20, child: Text("E")),

                    /// NEEDLE
                    Transform.rotate(
                      angle: angle * pi / 180,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 4,
                            height: 80,
                            color: Colors.red,
                          ),
                          Container(
                            width: 4,
                            height: 80,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),

                    /// CENTER CAP
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFfffbd5), Color(0xFFb89130)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          /// TOGGLE BUTTON
          ElevatedButton(
            onPressed: toggleNorth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text(
              "Include North: ${includeNorth ? "ON" : "OFF"}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          /// INSTRUCTION
          const Text(
            "Tap compass to generate random direction",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          )
        ],
      ),
    );
  }
}