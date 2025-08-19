import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class ParticlesVisualizer extends BaseVisualizer {
  const ParticlesVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.particles,
          settings: settings,
        );

  @override
  State<ParticlesVisualizer> createState() => _ParticlesVisualizerState();
}

class _ParticlesVisualizerState extends BaseVisualizerState<ParticlesVisualizer> {
  final List<Particle> _particles = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    _particles.clear();
    for (int i = 0; i < 200; i++) {
      _particles.add(Particle.random(_random));
    }
  }

  @override
  CustomPainter createPainter() {
    return ParticlesPainter(
      audioData: audioData,
      animationValue: animationValue,
      particles: _particles,
      sensitivity: sensitivity,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      reactToBeats: reactToBeats,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double life;
  double maxLife;
  int frequencyBand;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.life,
    required this.maxLife,
    required this.frequencyBand,
  });

  factory Particle.random(Random random) {
    return Particle(
      position: Offset(
        random.nextDouble() * 800,
        random.nextDouble() * 600,
      ),
      velocity: Offset(
        (random.nextDouble() - 0.5) * 2,
        (random.nextDouble() - 0.5) * 2,
      ),
      size: random.nextDouble() * 4 + 1,
      color: Colors.blue,
      life: random.nextDouble() * 100,
      maxLife: random.nextDouble() * 100 + 50,
      frequencyBand: random.nextInt(64),
    );
  }

  void update(Size canvasSize, AudioData? audioData) {
    if (audioData == null) return;

    // Get frequency level for this particle
    final frequencyLevel = audioData.frequencyBands[frequencyBand];
    
    // Update velocity based on audio
    velocity = Offset(
      velocity.dx + (Random().nextDouble() - 0.5) * frequencyLevel * 0.5,
      velocity.dy + (Random().nextDouble() - 0.5) * frequencyLevel * 0.5,
    );

    // Apply some damping
    velocity = velocity * 0.98;

    // Update position
    position = position + velocity;

    // Wrap around screen edges
    if (position.dx < 0) position = Offset(canvasSize.width, position.dy);
    if (position.dx > canvasSize.width) position = Offset(0, position.dy);
    if (position.dy < 0) position = Offset(position.dx, canvasSize.height);
    if (position.dy > canvasSize.height) position = Offset(position.dx, 0);

    // Update life
    life += 1;
    if (life > maxLife) {
      life = 0;
      position = Offset(
        Random().nextDouble() * canvasSize.width,
        Random().nextDouble() * canvasSize.height,
      );
    }

    // Update size based on frequency
    size = (1 + frequencyLevel * 3).clamp(0.5, 6.0);

    // Update color based on frequency band and level
    color = _getParticleColor(frequencyBand, frequencyLevel, audioData.beatDetected);
  }

  Color _getParticleColor(int band, double level, bool beatDetected) {
    final normalizedBand = band / 64.0;
    final beatIntensity = beatDetected ? 0.3 : 0.0;
    final alpha = (level + 0.2).clamp(0.0, 1.0);

    if (normalizedBand < 0.33) {
      // Bass particles - Red/Orange
      return Color.lerp(
        Colors.red,
        Colors.orange,
        level + beatIntensity,
      )!.withOpacity(alpha);
    } else if (normalizedBand < 0.66) {
      // Mid particles - Blue/Cyan
      return Color.lerp(
        Colors.blue,
        Colors.cyan,
        level + beatIntensity,
      )!.withOpacity(alpha);
    } else {
      // Treble particles - Purple/White
      return Color.lerp(
        Colors.purple,
        Colors.white,
        level + beatIntensity,
      )!.withOpacity(alpha);
    }
  }
}

class ParticlesPainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final List<Particle> particles;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  ParticlesPainter({
    this.audioData,
    required this.animationValue,
    required this.particles,
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

    // Update all particles
    for (final particle in particles) {
      particle.update(size, audioData);
    }

    // Draw connections between nearby particles
    _drawConnections(canvas, size);

    // Draw particles
    _drawParticles(canvas, size);

    // Draw energy field
    if (audioData!.overallLevel > 0.5) {
      _drawEnergyField(canvas, size);
    }

    // Draw beat explosion effect
    if (audioData!.beatDetected && reactToBeats) {
      _drawBeatExplosion(canvas, size);
    }
  }

  void _drawConnections(Canvas canvas, Size size) {
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const maxConnectionDistance = 80.0;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;
        
        if (distance < maxConnectionDistance) {
          final opacity = (1 - distance / maxConnectionDistance) * 0.3;
          connectionPaint.color = primaryColor.withOpacity(opacity);
          
          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            connectionPaint,
          );
        }
      }
    }
  }

  void _drawParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Create radial gradient for each particle
      final gradient = RadialGradient(
        colors: [
          particle.color,
          particle.color.withOpacity(0.5),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      );

      particlePaint.shader = gradient.createShader(
        Rect.fromCircle(center: particle.position, radius: particle.size),
      );

      canvas.drawCircle(particle.position, particle.size, particlePaint);

      // Add glow effect for high-energy particles
      if (particle.size > 4) {
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        
        canvas.drawCircle(particle.position, particle.size * 1.5, glowPaint);
      }
    }
  }

  void _drawEnergyField(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withOpacity(0.05);

    // Create energy field based on audio level
    final center = Offset(size.width / 2, size.height / 2);
    final fieldRadius = audioData!.overallLevel * size.width * 0.4;

    canvas.drawCircle(center, fieldRadius, fieldPaint);

    // Add pulsing rings
    for (int i = 1; i <= 3; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = secondaryColor.withOpacity(0.1 * audioData!.overallLevel);

      canvas.drawCircle(center, fieldRadius * i / 3, ringPaint);
    }
  }

  void _drawBeatExplosion(Canvas canvas, Size size) {
    final explosionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final explosionRadius = audioData!.bassLevel * size.width * 0.3;

    // Multiple explosion rings
    for (int i = 0; i < 3; i++) {
      final radius = explosionRadius * (i + 1) / 3;
      final opacity = (1 - i / 3) * audioData!.bassLevel;
      
      explosionPaint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(center, radius, explosionPaint);
    }

    // Radial lines
    final lineCount = 12;
    final angleStep = (2 * pi) / lineCount;
    
    for (int i = 0; i < lineCount; i++) {
      final angle = i * angleStep;
      final startRadius = explosionRadius * 0.5;
      final endRadius = explosionRadius;
      
      final start = Offset(
        center.dx + cos(angle) * startRadius,
        center.dy + sin(angle) * startRadius,
      );
      final end = Offset(
        center.dx + cos(angle) * endRadius,
        center.dy + sin(angle) * endRadius,
      );

      explosionPaint.color = Colors.yellow.withOpacity(audioData!.bassLevel * 0.7);
      canvas.drawLine(start, end, explosionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}