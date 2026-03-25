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
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          GestureDetector(
            onTap: spin,
            child: Transform.rotate(
              angle: angle * pi / 180,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Colors.amber, Colors.brown],
                  ),
                ),
                child: const Center(
                  child: Text(
                    "N",
                    style: TextStyle(color: Colors.red, fontSize: 24),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          SwitchListTile(
            title: const Text("Include North"),
            value: includeNorth,
            onChanged: (v) => setState(() => includeNorth = v),
          ),
        ],
      ),
    );
  }
}