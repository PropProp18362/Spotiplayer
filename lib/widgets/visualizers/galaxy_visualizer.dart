import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class GalaxyVisualizer extends BaseVisualizer {
  const GalaxyVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.galaxy,
          settings: settings,
        );

  @override
  State<GalaxyVisualizer> createState() => _GalaxyVisualizerState();
}

class _GalaxyVisualizerState extends BaseVisualizerState<GalaxyVisualizer> {
  final List<Star> _stars = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeStars();
  }

  void _initializeStars() {
    _stars.clear();
    for (int i = 0; i < 300; i++) {
      _stars.add(Star.random(_random));
    }
  }

  @override
  CustomPainter createPainter() {
    return GalaxyPainter(
      audioData: audioData,
      animationValue: animationValue,
      stars: _stars,
      sensitivity: sensitivity,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      reactToBeats: reactToBeats,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
    );
  }
}

class Star {
  Offset position;
  double size;
  Color color;
  double angle;
  double distance;
  double speed;
  int frequencyBand;

  Star({
    required this.position,
    required this.size,
    required this.color,
    required this.angle,
    required this.distance,
    required this.speed,
    required this.frequencyBand,
  });

  factory Star.random(Random random) {
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * 300 + 50;
    
    return Star(
      position: Offset(
        400 + cos(angle) * distance,
        300 + sin(angle) * distance,
      ),
      size: random.nextDouble() * 3 + 0.5,
      color: Colors.white,
      angle: angle,
      distance: distance,
      speed: random.nextDouble() * 0.02 + 0.005,
      frequencyBand: random.nextInt(64),
    );
  }

  void update(Size canvasSize, AudioData? audioData, double animationValue) {
    if (audioData == null) return;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final frequencyLevel = audioData.frequencyBands[frequencyBand];
    
    // Rotate around center
    angle += speed * (1 + frequencyLevel);
    
    // Update distance based on audio
    final targetDistance = distance * (1 + frequencyLevel * 0.5);
    
    // Calculate new position
    position = Offset(
      center.dx + cos(angle) * targetDistance,
      center.dy + sin(angle) * targetDistance,
    );

    // Update size based on frequency
    size = (0.5 + frequencyLevel * 4).clamp(0.5, 6.0);

    // Update color based on frequency band
    color = _getStarColor(frequencyBand, frequencyLevel, audioData.beatDetected);
  }

  Color _getStarColor(int band, double level, bool beatDetected) {
    final normalizedBand = band / 64.0;
    final beatIntensity = beatDetected ? 0.4 : 0.0;
    final alpha = (level + 0.3).clamp(0.0, 1.0);

    if (normalizedBand < 0.25) {
      // Inner galaxy - warm colors
      return Color.lerp(
        Colors.orange,
        Colors.red,
        level + beatIntensity,
      )!.withOpacity(alpha);
    } else if (normalizedBand < 0.5) {
      // Mid galaxy - yellow/white
      return Color.lerp(
        Colors.yellow,
        Colors.white,
        level + beatIntensity,
      )!.withOpacity(alpha);
    } else if (normalizedBand < 0.75) {
      // Outer galaxy - blue/cyan
      return Color.lerp(
        Colors.blue,
        Colors.cyan,
        level + beatIntensity,
      )!.withOpacity(alpha);
    } else {
      // Far galaxy - purple/pink
      return Color.lerp(
        Colors.purple,
        Colors.pink,
        level + beatIntensity,
      )!.withOpacity(alpha);
    }
  }
}

class GalaxyPainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final List<Star> stars;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  GalaxyPainter({
    this.audioData,
    required this.animationValue,
    required this.stars,
    required this.sensitivity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.reactToBeats,
    required this.bassBoost,
    required this.trebleBoost,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (audioData == null) return;

    final center = Offset(size.width / 2, size.height / 2);

    // Update all stars
    for (final star in stars) {
      star.update(size, audioData, animationValue);
    }

    // Draw galaxy background
    _drawGalaxyBackground(canvas, size, center);

    // Draw spiral arms
    _drawSpiralArms(canvas, size, center);

    // Draw stars
    _drawStars(canvas, size);

    // Draw central black hole
    _drawBlackHole(canvas, center);

    // Draw energy waves
    if (audioData!.beatDetected && reactToBeats) {
      _drawEnergyWaves(canvas, center);
    }
  }

  void _drawGalaxyBackground(Canvas canvas, Size size, Offset center) {
    final backgroundPaint = Paint()
      ..style = PaintingStyle.fill;

    // Create radial gradient for galaxy background
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        primaryColor.withOpacity(0.3 * audioData!.overallLevel),
        secondaryColor.withOpacity(0.2 * audioData!.overallLevel),
        Colors.purple.withOpacity(0.1 * audioData!.overallLevel),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    backgroundPaint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: size.width * 0.6),
    );

    canvas.drawCircle(center, size.width * 0.6, backgroundPaint);
  }

  void _drawSpiralArms(Canvas canvas, Size size, Offset center) {
    final armPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final armCount = 4;
    final maxRadius = size.width * 0.4;

    for (int arm = 0; arm < armCount; arm++) {
      final armPath = Path();
      final baseAngle = (arm * 2 * pi / armCount) + (animationValue * 0.5);
      
      bool firstPoint = true;
      for (double r = 20; r < maxRadius; r += 5) {
        final spiralAngle = baseAngle + (r / maxRadius) * 4 * pi;
        final x = center.dx + cos(spiralAngle) * r;
        final y = center.dy + sin(spiralAngle) * r;
        
        if (firstPoint) {
          armPath.moveTo(x, y);
          firstPoint = false;
        } else {
          armPath.lineTo(x, y);
        }
      }

      // Color based on audio
      final armIntensity = audioData!.frequencyBands[(arm * 16) % 64];
      armPaint.color = Color.lerp(
        primaryColor,
        secondaryColor,
        armIntensity,
      )!.withOpacity(armIntensity * 0.6);

      canvas.drawPath(armPath, armPaint);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      // Create radial gradient for each star
      final gradient = RadialGradient(
        colors: [
          star.color,
          star.color.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );

      starPaint.shader = gradient.createShader(
        Rect.fromCircle(center: star.position, radius: star.size),
      );

      canvas.drawCircle(star.position, star.size, starPaint);

      // Add twinkle effect for bright stars
      if (star.size > 3) {
        _drawStarTwinkle(canvas, star);
      }
    }
  }

  void _drawStarTwinkle(Canvas canvas, Star star) {
    final twinklePaint = Paint()
      ..color = star.color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final twinkleSize = star.size * 1.5;
    
    // Draw cross pattern
    canvas.drawLine(
      Offset(star.position.dx - twinkleSize, star.position.dy),
      Offset(star.position.dx + twinkleSize, star.position.dy),
      twinklePaint,
    );
    canvas.drawLine(
      Offset(star.position.dx, star.position.dy - twinkleSize),
      Offset(star.position.dx, star.position.dy + twinkleSize),
      twinklePaint,
    );
  }

  void _drawBlackHole(Canvas canvas, Offset center) {
    final holePaint = Paint()
      ..style = PaintingStyle.fill;

    // Pulsing black hole based on bass
    final holeRadius = 15 + (audioData!.bassLevel * 10);
    
    // Create gradient for black hole
    final gradient = RadialGradient(
      colors: [
        Colors.black,
        Colors.purple.withOpacity(0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.8, 1.0],
    );

    holePaint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: holeRadius * 2),
    );

    canvas.drawCircle(center, holeRadius * 2, holePaint);

    // Draw accretion disk
    final diskPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final diskRadius = holeRadius * (2 + i);
      final diskIntensity = audioData!.frequencyBands[i * 20] * sensitivity;
      
      diskPaint.color = Color.lerp(
        Colors.orange,
        Colors.red,
        diskIntensity,
      )!.withOpacity(diskIntensity);

      canvas.drawCircle(center, diskRadius, diskPaint);
    }
  }

  void _drawEnergyWaves(Canvas canvas, Offset center) {
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final waveCount = 5;
    final maxRadius = audioData!.bassLevel * 200;

    for (int i = 0; i < waveCount; i++) {
      final waveRadius = maxRadius * (i + 1) / waveCount;
      final opacity = (1 - i / waveCount) * audioData!.bassLevel;
      
      wavePaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(center, waveRadius, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}