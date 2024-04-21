import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hero Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HeroAnimation(),
    );
  }
}

class HeroAnimation extends StatelessWidget {
  const HeroAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> animations = [
      {'tag': 'standard', 'label': 'Standard Hero', 'builder': null, 'slowMotion': false},
      {'tag': 'radial', 'label': 'Radial Hero', 'builder': radialShuttleBuilder, 'slowMotion': false},
      {'tag': 'slow-motion', 'label': 'Slow Motion Hero', 'builder': null, 'slowMotion': true},
      {'tag': 'elastic', 'label': 'Elastic Hero', 'builder': elasticShuttleBuilder, 'slowMotion': false},
      {'tag': 'rotate', 'label': 'Rotating Hero', 'builder': rotatingShuttleBuilder, 'slowMotion': false}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Animation 5 Flavors'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: animations.map((animation) => buildHeroWidget(context, animation)).toList(),
      ),
    );
  }

  Widget buildHeroWidget(BuildContext context, Map<String, dynamic> animation) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            if (animation['slowMotion']) {
              timeDilation = 10.0; // Slows down animations for slow motion
            } else {
              timeDilation = 3.0; // Reset time dilation for standard animations
            }

            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(animation['label']),
                  ),
                  body: Container(
                    color: Colors.lightBlueAccent,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.topLeft,
                    child: PhotoHero(
                      photo: 'assets/images/lake.jpg',
                      width: 150.0,
                      onTap: () {
                        timeDilation = 3.0; // Reset time dilation when returning
                        Navigator.of(context).pop();
                      },
                      tag: animation['tag'],
                      flightShuttleBuilder: animation['builder'],
                    ),
                  ),
                );
              },
            ));
          },
          child: PhotoHero(
            photo: 'assets/images/lake.jpg',
            width: 500.0,
            onTap: null,
            tag: animation['tag'],
            flightShuttleBuilder: animation['builder'],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(animation['label']),
        ),
      ],
    );
  }

  // Flight shuttle builders

  static Widget radialShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: toHeroContext.widget,
      builder: (BuildContext context, Widget? child) {
        return RadialExpansion(
          maxRadius: 300 * animation.value,
          child: child,
          
        );
      },
    );
  }

  static Widget elasticShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: toHeroContext.widget,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: 1.0 + math.sin(animation.value * math.pi * 2) * 0.05,
          child: child,
        );
      },
    );
  }

  static Widget rotatingShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      child: toHeroContext.widget,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: animation.value * math.pi * 2,
          child: child,
        );
      },
    );
  }
}

class PhotoHero extends StatelessWidget {
  final String photo;
  final VoidCallback? onTap;
  final double width;
  final String tag;
  final Widget Function(BuildContext, Animation<double>, HeroFlightDirection, BuildContext, BuildContext)?flightShuttleBuilder;

  const PhotoHero({
    Key? key,
    required this.photo,
    this.onTap,
    required this.width,
    required this.tag,
    this.flightShuttleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: tag,
        flightShuttleBuilder: flightShuttleBuilder,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.asset(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  const RadialExpansion({
    Key? key,
    required this.maxRadius,
    this.child,
  }) : clipRectSize = 2.0 * (maxRadius / math.sqrt2), super(key: key);

  final double maxRadius;
  final double clipRectSize;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Center(
        child: SizedBox(
          width: clipRectSize,
          height: clipRectSize,
          child: ClipRect(
            child: child,
          ),
        ),
      ),
    );
  }
}


