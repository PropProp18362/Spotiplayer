import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class CircularVisualizer extends BaseVisualizer {
  const CircularVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.circular,
          settings: settings,
        );

  @override
  State<CircularVisualizer> createState() => _CircularVisualizerState();
}

class _CircularVisualizerState extends BaseVisualizerState<CircularVisualizer> {
  @override
  CustomPainter createPainter() {
    return CircularPainter(
      audioData: audioData,
      animationValue: animationValue,
      sensitivity: sensitivity,
      showPeaks: showPeaks,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      reactToBeats: reactToBeats,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
    );
  }
}

class CircularPainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final double sensitivity;
  final bool showPeaks;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  CircularPainter({
    this.audioData,
    required this.animationValue,
    required this.sensitivity,
    required this.showPeaks,
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
    final baseRadius = min(size.width, size.height) * 0.15;
    final maxRadius = min(size.width, size.height) * 0.4;

    final frequencies = audioData!.frequencyBands;
    final barCount = frequencies.length;
    final angleStep = (2 * pi) / barCount;

    // Beat reaction
    final beatMultiplier = (audioData!.beatDetected && reactToBeats) ? 1.3 : 1.0;
    final rotationOffset = animationValue * 2 * pi * 0.1;

    // Draw background circles
    _drawBackgroundCircles(canvas, center, baseRadius, maxRadius);

    // Draw frequency bars in circular pattern
    for (int i = 0; i < barCount; i++) {
      double level = frequencies[i];
      
      // Apply frequency-specific boosts
      if (i < barCount * 0.25) {
        level *= bassBoost;
      } else if (i > barCount * 0.75) {
        level *= trebleBoost;
      }

      level = (level * sensitivity * beatMultiplier).clamp(0.0, 1.0);
      
      final angle = i * angleStep + rotationOffset;
      final barLength = level * (maxRadius - baseRadius);
      
      _drawFrequencyBar(canvas, center, angle, baseRadius, barLength, i, level);
    }

    // Draw center visualization
    _drawCenterVisualization(canvas, center, baseRadius);

    // Draw outer ring effects
    if (audioData!.beatDetected && reactToBeats) {
      _drawBeatRing(canvas, center, maxRadius + 20);
    }
  }

  void _drawBackgroundCircles(Canvas canvas, Offset center, double baseRadius, double maxRadius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primaryColor.withOpacity(0.1);

    // Draw concentric circles
    for (double r = baseRadius; r <= maxRadius; r += 20) {
      canvas.drawCircle(center, r, paint);
    }
  }

  void _drawFrequencyBar(Canvas canvas, Offset center, double angle, 
                        double baseRadius, double barLength, int index, double level) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final startX = center.dx + cos(angle) * baseRadius;
    final startY = center.dy + sin(angle) * baseRadius;
    final endX = center.dx + cos(angle) * (baseRadius + barLength);
    final endY = center.dy + sin(angle) * (baseRadius + barLength);

    final start = Offset(startX, startY);
    final end = Offset(endX, endY);

    // Create gradient for the bar
    final gradient = LinearGradient(
      colors: _getFrequencyColors(index, level),
      stops: const [0.0, 0.5, 1.0],
    );

    paint.shader = gradient.createShader(Rect.fromPoints(start, end));
    canvas.drawLine(start, end, paint);

    // Draw peak indicator
    if (showPeaks && level > 0.2) {
      final peakPaint = Paint()
        ..color = Colors.white.withOpacity(level)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(end, 2, peakPaint);
    }

    // Add glow effect for high levels
    if (level > 0.8) {
      final glowPaint = Paint()
        ..color = _getFrequencyColors(index, level)[2].withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawLine(start, end, glowPaint);
    }
  }

  void _drawCenterVisualization(Canvas canvas, Offset center, double baseRadius) {
    final centerPaint = Paint()
      ..style = PaintingStyle.fill;

    // Pulsing center based on overall audio level
    final pulseRadius = baseRadius * 0.6 * (1 + audioData!.overallLevel * 0.5);
    
    // Create radial gradient
    final gradient = RadialGradient(
      colors: [
        primaryColor.withOpacity(0.8),
        secondaryColor.withOpacity(0.6),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    centerPaint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: pulseRadius),
    );

    canvas.drawCircle(center, pulseRadius, centerPaint);

    // Draw bass level indicator in center
    if (audioData!.bassLevel > 0.3) {
      final bassPaint = Paint()
        ..color = Colors.red.withOpacity(audioData!.bassLevel)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(center, baseRadius * 0.3 * audioData!.bassLevel, bassPaint);
    }
  }

  void _drawBeatRing(Canvas canvas, Offset center, double radius) {
    final beatPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withOpacity(0.6);

    // Animated beat ring
    final animatedRadius = radius + sin(animationValue * 4 * pi) * 10;
    canvas.drawCircle(center, animatedRadius, beatPaint);

    // Multiple rings for intense beats
    if (audioData!.bassLevel > 0.7) {
      beatPaint.color = primaryColor.withOpacity(0.4);
      canvas.drawCircle(center, animatedRadius + 15, beatPaint);
    }
  }

  List<Color> _getFrequencyColors(int index, double level) {
    final normalizedIndex = index / 64.0;
    final beatIntensity = (audioData!.beatDetected && reactToBeats) ? 0.3 : 0.0;
    
    if (normalizedIndex < 0.33) {
      // Bass - Warm colors
      return [
        Colors.red.withOpacity(0.8),
        Colors.orange.withOpacity(0.9),
        Colors.yellow.withOpacity(level + beatIntensity),
      ];
    } else if (normalizedIndex < 0.66) {
      // Mid - Cool colors
      return [
        primaryColor.withOpacity(0.8),
        Colors.cyan.withOpacity(0.9),
        Colors.blue.withOpacity(level + beatIntensity),
      ];
    } else {
      // Treble - Bright colors
      return [
        secondaryColor.withOpacity(0.8),
        Colors.purple.withOpacity(0.9),
        Colors.white.withOpacity(level + beatIntensity),
      ];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}