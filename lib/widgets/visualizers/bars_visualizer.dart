import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class BarsVisualizer extends BaseVisualizer {
  const BarsVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.bars,
          settings: settings,
        );

  @override
  State<BarsVisualizer> createState() => _BarsVisualizerState();
}

class _BarsVisualizerState extends BaseVisualizerState<BarsVisualizer> {
  @override
  CustomPainter createPainter() {
    return BarsPainter(
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

class BarsPainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final double sensitivity;
  final bool showPeaks;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  BarsPainter({
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

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final peakPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final frequencies = audioData!.frequencyBands;
    final barCount = frequencies.length;
    final barWidth = size.width / barCount;
    final maxHeight = size.height * 0.9;

    // Beat reaction multiplier
    final beatMultiplier = (audioData!.beatDetected && reactToBeats) ? 1.2 : 1.0;

    for (int i = 0; i < barCount; i++) {
      double level = frequencies[i];
      
      // Apply frequency-specific boosts
      if (i < barCount * 0.25) {
        level *= bassBoost; // Bass frequencies
      } else if (i > barCount * 0.75) {
        level *= trebleBoost; // Treble frequencies
      }

      level = (level * sensitivity * beatMultiplier).clamp(0.0, 1.0);
      
      final barHeight = level * maxHeight;
      final x = i * barWidth;
      final y = size.height - barHeight;

      // Create gradient based on frequency and level
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: _getBarColors(i, level),
        stops: const [0.0, 0.5, 1.0],
      );

      paint.shader = gradient.createShader(
        Rect.fromLTWH(x, y, barWidth * 0.8, barHeight),
      );

      // Draw main bar with rounded corners
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + barWidth * 0.1, y, barWidth * 0.8, barHeight),
        Radius.circular(barWidth * 0.1),
      );
      canvas.drawRRect(barRect, paint);

      // Draw peak indicator
      if (showPeaks && level > 0.1) {
        final peakY = y - 5;
        peakPaint.color = Colors.white.withOpacity(level);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + barWidth * 0.1, peakY, barWidth * 0.8, 3),
            const Radius.circular(1.5),
          ),
          peakPaint,
        );
      }

      // Add glow effect for high levels
      if (level > 0.7) {
        final glowPaint = Paint()
          ..color = _getBarColors(i, level)[2].withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        
        canvas.drawRRect(barRect, glowPaint);
      }
    }

    // Draw bass pulse effect
    if (audioData!.beatDetected && reactToBeats) {
      _drawBassPulse(canvas, size);
    }
  }

  List<Color> _getBarColors(int index, double level) {
    final normalizedIndex = index / 64.0;
    final beatIntensity = (audioData!.beatDetected && reactToBeats) ? 0.3 : 0.0;
    
    if (normalizedIndex < 0.25) {
      // Bass frequencies - Red spectrum
      return [
        Colors.red.withOpacity(0.8),
        Colors.orange.withOpacity(0.9),
        Colors.yellow.withOpacity(level + beatIntensity),
      ];
    } else if (normalizedIndex < 0.75) {
      // Mid frequencies - Blue to Purple spectrum
      return [
        primaryColor.withOpacity(0.8),
        secondaryColor.withOpacity(0.9),
        Colors.cyan.withOpacity(level + beatIntensity),
      ];
    } else {
      // Treble frequencies - Purple to White spectrum
      return [
        secondaryColor.withOpacity(0.8),
        Colors.purple.withOpacity(0.9),
        Colors.white.withOpacity(level + beatIntensity),
      ];
    }
  }

  void _drawBassPulse(Canvas canvas, Size size) {
    final pulsePaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pulseRadius = audioData!.bassLevel * size.width * 0.3;
    final center = Offset(size.width / 2, size.height);

    canvas.drawCircle(center, pulseRadius, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}