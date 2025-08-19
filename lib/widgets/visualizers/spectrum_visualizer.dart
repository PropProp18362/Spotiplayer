import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class SpectrumVisualizer extends BaseVisualizer {
  const SpectrumVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.spectrum,
          settings: settings,
        );

  @override
  State<SpectrumVisualizer> createState() => _SpectrumVisualizerState();
}

class _SpectrumVisualizerState extends BaseVisualizerState<SpectrumVisualizer> {
  @override
  CustomPainter createPainter() {
    return SpectrumPainter(
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

class SpectrumPainter extends CustomPainter {
  final AudioData? audioData;
  final double animationValue;
  final double sensitivity;
  final bool showPeaks;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  SpectrumPainter({
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

    // Draw 3D spectrum analyzer
    _draw3DSpectrum(canvas, size);
    
    // Draw frequency grid
    _drawFrequencyGrid(canvas, size);
    
    // Draw spectrum bars
    _drawSpectrumBars(canvas, size);
    
    // Draw peak indicators
    if (showPeaks) {
      _drawPeakIndicators(canvas, size);
    }
    
    // Draw beat effects
    if (audioData!.beatDetected && reactToBeats) {
      _drawBeatEffects(canvas, size);
    }
  }

  void _draw3DSpectrum(Canvas canvas, Size size) {
    final frequencies = audioData!.frequencyBands;
    final barCount = frequencies.length;
    final barWidth = size.width / barCount;
    final maxHeight = size.height * 0.8;

    // 3D perspective effect
    final perspective = 0.3;
    final depthOffset = size.height * 0.1;

    for (int i = 0; i < barCount; i++) {
      double level = frequencies[i];
      
      // Apply frequency-specific boosts
      if (i < barCount * 0.25) {
        level *= bassBoost;
      } else if (i > barCount * 0.75) {
        level *= trebleBoost;
      }

      level = (level * sensitivity).clamp(0.0, 1.0);
      final barHeight = level * maxHeight;
      
      // Calculate 3D positions
      final x = i * barWidth;
      final y = size.height - barHeight;
      final depth = level * depthOffset;

      // Front face
      final frontRect = Rect.fromLTWH(x, y, barWidth * 0.8, barHeight);
      
      // Top face (3D effect)
      final topPath = Path()
        ..moveTo(x, y)
        ..lineTo(x + depth, y - depth)
        ..lineTo(x + barWidth * 0.8 + depth, y - depth)
        ..lineTo(x + barWidth * 0.8, y)
        ..close();

      // Right face (3D effect)
      final rightPath = Path()
        ..moveTo(x + barWidth * 0.8, y)
        ..lineTo(x + barWidth * 0.8 + depth, y - depth)
        ..lineTo(x + barWidth * 0.8 + depth, size.height - depth)
        ..lineTo(x + barWidth * 0.8, size.height)
        ..close();

      // Colors for 3D effect
      final frontColor = _getFrequencyColor(i, level);
      final topColor = frontColor.withOpacity(0.8);
      final rightColor = frontColor.withOpacity(0.6);

      // Draw 3D bar
      canvas.drawRect(frontRect, Paint()..color = frontColor);
      canvas.drawPath(topPath, Paint()..color = topColor);
      canvas.drawPath(rightPath, Paint()..color = rightColor);

      // Add glow effect
      if (level > 0.6) {
        final glowPaint = Paint()
          ..color = frontColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRect(frontRect, glowPaint);
      }
    }
  }

  void _drawFrequencyGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 1; i <= 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical grid lines (frequency markers)
    final frequencies = [60, 250, 1000, 4000, 16000]; // Hz
    for (int freq in frequencies) {
      final x = _frequencyToX(freq, size.width);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );

      // Frequency labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${freq}Hz',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 2, size.height - 20));
    }
  }

  void _drawSpectrumBars(Canvas canvas, Size size) {
    final frequencies = audioData!.frequencyBands;
    final barCount = frequencies.length;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      double level = frequencies[i];
      
      // Apply boosts
      if (i < barCount * 0.25) {
        level *= bassBoost;
      } else if (i > barCount * 0.75) {
        level *= trebleBoost;
      }

      level = (level * sensitivity).clamp(0.0, 1.0);
      
      final x = i * barWidth;
      final barHeight = level * size.height * 0.9;
      final y = size.height - barHeight;

      // Create gradient for spectrum effect
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: _getSpectrumGradient(i, level),
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTWH(x, y, barWidth * 0.9, barHeight),
        );

      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth * 0.9, barHeight),
        paint,
      );
    }
  }

  void _drawPeakIndicators(Canvas canvas, Size size) {
    final frequencies = audioData!.frequencyBands;
    final barCount = frequencies.length;
    final barWidth = size.width / barCount;

    final peakPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      double level = frequencies[i];
      
      if (i < barCount * 0.25) {
        level *= bassBoost;
      } else if (i > barCount * 0.75) {
        level *= trebleBoost;
      }

      level = (level * sensitivity).clamp(0.0, 1.0);
      
      if (level > 0.2) {
        final x = i * barWidth;
        final peakY = size.height - (level * size.height * 0.9) - 5;
        
        peakPaint.color = Colors.white.withOpacity(level);
        canvas.drawRect(
          Rect.fromLTWH(x, peakY, barWidth * 0.9, 2),
          peakPaint,
        );
      }
    }
  }

  void _drawBeatEffects(Canvas canvas, Size size) {
    final beatPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Pulsing border
    final borderIntensity = audioData!.bassLevel;
    beatPaint.color = Colors.white.withOpacity(borderIntensity);
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      beatPaint,
    );

    // Beat flash overlay
    if (audioData!.bassLevel > 0.7) {
      final flashPaint = Paint()
        ..color = primaryColor.withOpacity(0.1 * audioData!.bassLevel);
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        flashPaint,
      );
    }
  }

  Color _getFrequencyColor(int index, double level) {
    final normalizedIndex = index / 64.0;
    final beatMultiplier = (audioData!.beatDetected && reactToBeats) ? 1.2 : 1.0;
    
    if (normalizedIndex < 0.2) {
      // Sub-bass - Deep red
      return Color.lerp(
        Colors.red.shade900,
        Colors.red,
        level * beatMultiplier,
      )!;
    } else if (normalizedIndex < 0.4) {
      // Bass - Red to orange
      return Color.lerp(
        Colors.red,
        Colors.orange,
        level * beatMultiplier,
      )!;
    } else if (normalizedIndex < 0.6) {
      // Mid - Orange to yellow
      return Color.lerp(
        Colors.orange,
        Colors.yellow,
        level * beatMultiplier,
      )!;
    } else if (normalizedIndex < 0.8) {
      // High-mid - Yellow to green
      return Color.lerp(
        Colors.yellow,
        Colors.green,
        level * beatMultiplier,
      )!;
    } else {
      // Treble - Green to white
      return Color.lerp(
        Colors.green,
        Colors.white,
        level * beatMultiplier,
      )!;
    }
  }

  List<Color> _getSpectrumGradient(int index, double level) {
    final baseColor = _getFrequencyColor(index, level);
    return [
      baseColor.withOpacity(0.9),
      baseColor.withOpacity(0.7),
      baseColor.withOpacity(0.3),
    ];
  }

  double _frequencyToX(int frequency, double width) {
    // Logarithmic frequency mapping
    final minFreq = 20.0;
    final maxFreq = 20000.0;
    final logFreq = log(frequency) / ln10;
    final logMin = log(minFreq) / ln10;
    final logMax = log(maxFreq) / ln10;
    
    return ((logFreq - logMin) / (logMax - logMin)) * width;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}