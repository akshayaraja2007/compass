import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const RealisticCompassApp());
}

class RealisticCompassApp extends StatelessWidget {
  const RealisticCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {

  double _angle = 180;
  double _target = 180;
  double _velocity = 0;
  bool _includeNorth = false;

  late final Ticker _ticker;
  final Random _rng = Random();

  final double stiffness = 0.05;
  final double damping = 0.92;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      final force = (_target - _angle) * stiffness;
      _velocity += force;
      _velocity *= damping;
      _angle += _velocity;

      setState(() {});
    });

    _ticker.start();
  }

  /// STRICT RANDOM (NO REAL COMPASS)
  void _spin() {
    final list = _includeNorth
        ? [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0]
        : [45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0];

    double randAngle = list[_rng.nextInt(list.length)];

    int spins = (_rng.nextInt(3) + 2) * 360;

    _target = randAngle + spins;
  }

  void _toggleNorth(bool val) {
    setState(() {
      _includeNorth = val;

      // If disabling north while pointing near north → move away
      double current = _angle % 360;
      if (current < 0) current += 360;

      if (!_includeNorth && (current < 15 || current > 345)) {
        _spin();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1a1a1a), Color(0xFF000000)],
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            GestureDetector(
              onTap: _spin,
              child: AnimatedCompass(angle: _angle),
            ),

            const SizedBox(height: 60),

            SwitchListTile(
              title: const Text(
                "INCLUDE NORTH",
                style: TextStyle(letterSpacing: 2),
              ),
              value: _includeNorth,
              activeColor: Colors.amber,
              onChanged: _toggleNorth,
              contentPadding: const EdgeInsets.symmetric(horizontal: 60),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap compass to generate random direction",
              style: TextStyle(color: Colors.white38, fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedCompass extends StatelessWidget {
  final double angle;

  const AnimatedCompass({super.key, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateX(0.35),
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// OUTER SHADOW
          Container(
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 20,
                  offset: const Offset(0, 20),
                )
              ],
            ),
          ),

          /// BRASS BODY
          Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF704a1e),
                  Color(0xFFb58d4a),
                  Color(0xFFeccd8c),
                  Color(0xFF704a1e),
                ],
              ),
            ),
          ),

          /// FACE
          Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFdcc194), Color(0xFFb49666)],
              ),
            ),
          ),

          /// TICKS
          SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              children: List.generate(36, (i) {
                double degree = i * 10;
                return Transform.rotate(
                  angle: degree * pi / 180,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: i % 9 == 0 ? 3 : 1,
                      height: i % 9 == 0 ? 12 : 6,
                      color: Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ),

          /// NEEDLE
          Transform.rotate(
            angle: angle * pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 4, height: 90, color: Colors.red),
                Container(width: 4, height: 90, color: Colors.black),
              ],
            ),
          ),

          /// CENTER
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0xFFeccd8c), Color(0xFF704a1e)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}