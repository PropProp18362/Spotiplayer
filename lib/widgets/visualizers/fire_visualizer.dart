import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class FireVisualizer extends BaseVisualizer {
  const FireVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.fire,
          settings: settings,
        );

  @override
  State<FireVisualizer> createState() => _FireVisualizerState();
}

class _FireVisualizerState extends BaseVisualizerState<FireVisualizer> {
  final List<Flame> _flames = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeFlames();
  }

  void _initializeFlames() {
    _flames.clear();
    for (int i = 0; i < 150; i++) {
      _flames.add(Flame.random(_random));
    }
  }

  @override
  CustomPainter createPainter() {
    return FirePainter(
      audioData: audioData,
      animationValue: animationValue,
      flames: _flames,
      sensitivity: sensitivity,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      reactToBeats: reactToBeats,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
    );
  }
}

class Flame {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life;
  double maxLife;
  int frequencyBand;
  double intensity;

  Flame({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.life,
    required this.maxLife,
    required this.frequencyBand,
    required this.intensity,
  });

  factory Flame.random(Random random) {
    return Flame(
      position: Offset(
        random.nextDouble() * 800,
        600 + random.nextDouble() * 100, // Start from bottom
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2,
        -random.nextDouble() * 3 - 1, // Move upward
      ),
      size: random.nextDouble() * 8 + 2,
      color: Colors.red,
      life: 0,
      maxLife: random.nextDouble() * 60 + 30,
      frequencyBand: random.nextInt(64),
      intensity: random.nextDouble(),
    );
  }

  void update(Size canvasSize, AudioData? audioData) {
    if (audioData == null) return;

    final frequencyLevel = audioData.frequencyBands[frequencyBand];
    intensity = frequencyLevel;

    // Update velocity based on audio
    velocity = Offset(
      velocity.dx + (Random().nextDouble() - 0.5) * 0.5,
      velocity.dy - frequencyLevel * 2, // More upward movement with audio
    );

    // Apply some turbulence
    velocity = Offset(
      velocity.dx * 0.98 + sin(life * 0.1) * 0.2,
      velocity.dy * 0.95,
    );

    // Update position
    position = position + velocity;

    // Update life
    life += 1;
    
    // Reset if flame is too old or off screen
    if (life > maxLife || position.dy < -50) {
      _reset(canvasSize);
    }

    // Update size based on frequency and life
    final lifeRatio = 1 - (life / maxLife);
    size = (2 + frequencyLevel * 6) * lifeRatio;

    // Update color based on frequency band and life
    color = _getFlameColor(frequencyBand, frequencyLevel, lifeRatio);
  }

  void _reset(Size canvasSize) {
    life = 0;
    position = Offset(
      Random().nextDouble() * canvasSize.width,
      canvasSize.height + Random().nextDouble() * 50,
    );
    velocity = Offset(
      (Random().nextDouble() - 0.5) * 2,
      -Random().nextDouble() * 3 - 1,
    );
    maxLife = Random().nextDouble() * 60 + 30;
  }

  Color _getFlameColor(int band, double level, double lifeRatio) {
    final normalizedBand = band / 64.0;
    final alpha = (level * lifeRatio + 0.2).clamp(0.0, 1.0);

    if (lifeRatio > 0.8) {
      // Hot core - white/yellow
      return Color.lerp(
        Colors.white,
        Colors.yellow,
        normalizedBand,
      )!.withOpacity(alpha);
    } else if (lifeRatio > 0.5) {
      // Mid flame - yellow/orange
      return Color.lerp(
        Colors.yellow,
        Colors.orange,
        normalizedBand,
      )!.withOpacity(alpha);
    } else if (lifeRatio > 0.2) {
      // Outer flame - orange/red
      return Color.lerp(
        Colors.orange,
        Colors.red,
        normalizedBand,
      )!.withOpacity(alpha);
    } else {
      // Dying flame - red/purple
      return Color.lerp(
        Colors.red,
        Colors.purple,
        normalizedBand,
      )!.withOpacity(alpha * 0.5);
    }
  }
}

class FirePainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final List<Flame> flames;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  FirePainter({
    this.audioData,
    required this.animationValue,
    required this.flames,
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

    // Update all flames
    for (final flame in flames) {
      flame.update(size, audioData);
    }

    // Draw base fire glow
    _drawBaseGlow(canvas, size);

    // Draw flames
    _drawFlames(canvas, size);

    // Draw heat distortion effect
    _drawHeatDistortion(canvas, size);

    // Draw sparks
    _drawSparks(canvas, size);

    // Draw beat explosion
    if (audioData!.beatDetected && reactToBeats) {
      _drawBeatExplosion(canvas, size);
    }
  }

  void _drawBaseGlow(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..style = PaintingStyle.fill;

    // Create base glow at bottom
    final glowHeight = audioData!.overallLevel * size.height * 0.3;
    
    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.red.withOpacity(0.8 * audioData!.bassLevel),
        Colors.orange.withOpacity(0.6 * audioData!.midLevel),
        Colors.yellow.withOpacity(0.4 * audioData!.trebleLevel),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.6, 1.0],
    );

    glowPaint.shader = gradient.createShader(
      Rect.fromLTWH(0, size.height - glowHeight, size.width, glowHeight),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - glowHeight, size.width, glowHeight),
      glowPaint,
    );
  }

  void _drawFlames(Canvas canvas, Size size) {
    final flamePaint = Paint()
      ..style = PaintingStyle.fill;

    // Sort flames by size (draw larger ones first)
    flames.sort((a, b) => b.size.compareTo(a.size));

    for (final flame in flames) {
      if (flame.size <= 0) continue;

      // Create radial gradient for each flame
      final gradient = RadialGradient(
        colors: [
          flame.color,
          flame.color.withOpacity(0.7),
          flame.color.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      );

      flamePaint.shader = gradient.createShader(
        Rect.fromCircle(center: flame.position, radius: flame.size),
      );

      // Draw flame as elongated ellipse
      canvas.save();
      canvas.translate(flame.position.dx, flame.position.dy);
      canvas.scale(1.0, 1.5 + flame.intensity); // Stretch vertically
      canvas.drawCircle(Offset.zero, flame.size, flamePaint);
      canvas.restore();

      // Add flicker effect for intense flames
      if (flame.intensity > 0.7) {
        _drawFlameFlicker(canvas, flame);
      }
    }
  }

  void _drawFlameFlicker(Canvas canvas, Flame flame) {
    final flickerPaint = Paint()
      ..color = Colors.white.withOpacity(flame.intensity * 0.5)
      ..style = PaintingStyle.fill;

    final flickerSize = flame.size * 0.3;
    canvas.drawCircle(flame.position, flickerSize, flickerPaint);
  }

  void _drawHeatDistortion(Canvas canvas, Size size) {
    final distortionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw wavy lines to simulate heat distortion
    final waveCount = 10;
    final waveHeight = audioData!.overallLevel * 20;

    for (int i = 0; i < waveCount; i++) {
      final y = size.height * (0.3 + i * 0.05);
      final path = Path();
      
      for (double x = 0; x < size.width; x += 5) {
        final waveY = y + sin((x / 20) + (animationValue * 4 * pi)) * waveHeight;
        if (x == 0) {
          path.moveTo(x, waveY);
        } else {
          path.lineTo(x, waveY);
        }
      }

      distortionPaint.color = Colors.orange.withOpacity(0.2 * audioData!.overallLevel);
      canvas.drawPath(path, distortionPaint);
    }
  }

  void _drawSparks(Canvas canvas, Size size) {
    final sparkPaint = Paint()
      ..style = PaintingStyle.fill;

    final sparkCount = (audioData!.overallLevel * 20).round();
    final random = Random();

    for (int i = 0; i < sparkCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = size.height - (random.nextDouble() * size.height * 0.6);
      final sparkSize = random.nextDouble() * 2 + 0.5;
      
      sparkPaint.color = Color.lerp(
        Colors.yellow,
        Colors.white,
        random.nextDouble(),
      )!.withOpacity(audioData!.overallLevel);

      canvas.drawCircle(Offset(x, y), sparkSize, sparkPaint);
    }
  }

  void _drawBeatExplosion(Canvas canvas, Size size) {
    final explosionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height * 0.8);
    final explosionRadius = audioData!.bassLevel * size.width * 0.4;

    // Multiple explosion rings
    for (int i = 0; i < 4; i++) {
      final radius = explosionRadius * (i + 1) / 4;
      final opacity = (1 - i / 4) * audioData!.bassLevel;
      
      explosionPaint.color = Color.lerp(
        Colors.white,
        Colors.orange,
        i / 4,
      )!.withOpacity(opacity);

      canvas.drawCircle(center, radius, explosionPaint);
    }

    // Radial flame bursts
    final burstCount = 8;
    final angleStep = (2 * pi) / burstCount;
    
    for (int i = 0; i < burstCount; i++) {
      final angle = i * angleStep;
      final burstLength = explosionRadius * 0.8;
      
      final start = Offset(
        center.dx + cos(angle) * explosionRadius * 0.3,
        center.dy + sin(angle) * explosionRadius * 0.3,
      );
      final end = Offset(
        center.dx + cos(angle) * burstLength,
        center.dy + sin(angle) * burstLength,
      );

      explosionPaint.color = Colors.yellow.withOpacity(audioData!.bassLevel);
      explosionPaint.strokeWidth = 4;
      canvas.drawLine(start, end, explosionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}