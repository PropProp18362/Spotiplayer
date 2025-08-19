import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/spotify_models.dart';
import 'base_visualizer.dart';

class WaveformVisualizer extends BaseVisualizer {
  const WaveformVisualizer({
    Key? key,
    Map<String, dynamic> settings = const {},
  }) : super(
          key: key,
          style: VisualizationStyle.waveform,
          settings: settings,
        );

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends BaseVisualizerState<WaveformVisualizer> {
  final List<double> _waveformHistory = [];
  static const int maxHistoryLength = 200;

  @override
  void initState() {
    super.initState();
    // Initialize with zeros
    _waveformHistory.addAll(List.filled(maxHistoryLength, 0.0));
  }

  @override
  CustomPainter createPainter() {
    // Update waveform history
    if (audioData != null) {
      _waveformHistory.add(audioData!.overallLevel);
      if (_waveformHistory.length > maxHistoryLength) {
        _waveformHistory.removeAt(0);
      }
    }

    return WaveformPainter(
      audioData: audioData,
      waveformHistory: List.from(_waveformHistory),
      animationValue: animationValue,
      sensitivity: sensitivity,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      reactToBeats: reactToBeats,
      bassBoost: bassBoost,
      trebleBoost: trebleBoost,
    );
  }
}

class WaveformPainter extends CustomPainter {
  final AudioData? audioData;
  final List<double> waveformHistory;
  final double animationValue;
  final double sensitivity;
  final Color primaryColor;
  final Color secondaryColor;
  final bool reactToBeats;
  final double bassBoost;
  final double trebleBoost;

  WaveformPainter({
    this.audioData,
    required this.waveformHistory,
    required this.animationValue,
    required this.sensitivity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.reactToBeats,
    required this.bassBoost,
    required this.trebleBoost,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (audioData == null || waveformHistory.isEmpty) return;

    // Draw main waveform
    _drawMainWaveform(canvas, size);
    
    // Draw frequency layers
    _drawFrequencyLayers(canvas, size);
    
    // Draw beat indicators
    if (audioData!.beatDetected && reactToBeats) {
      _drawBeatIndicators(canvas, size);
    }
    
    // Draw center line
    _drawCenterLine(canvas, size);
  }

  void _drawMainWaveform(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;
    final stepX = size.width / (waveformHistory.length - 1);

    // Create gradient
    final gradient = LinearGradient(
      colors: [primaryColor, secondaryColor],
      stops: const [0.0, 1.0],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Build waveform path
    for (int i = 0; i < waveformHistory.length; i++) {
      final x = i * stepX;
      final level = waveformHistory[i] * sensitivity;
      final y = centerY + sin(level * pi) * size.height * 0.3;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw mirrored waveform
    final mirrorPath = Path();
    for (int i = 0; i < waveformHistory.length; i++) {
      final x = i * stepX;
      final level = waveformHistory[i] * sensitivity;
      final y = centerY - sin(level * pi) * size.height * 0.3;

      if (i == 0) {
        mirrorPath.moveTo(x, y);
      } else {
        mirrorPath.lineTo(x, y);
      }
    }

    paint.color = secondaryColor.withOpacity(0.7);
    canvas.drawPath(mirrorPath, paint);
  }

  void _drawFrequencyLayers(Canvas canvas, Size size) {
    if (audioData!.frequencyBands.isEmpty) return;

    final centerY = size.height / 2;
    
    // Bass layer
    _drawFrequencyLayer(
      canvas, 
      size, 
      audioData!.bassFrequencies, 
      centerY, 
      Colors.red.withOpacity(0.6),
      0.4,
      bassBoost,
    );
    
    // Mid layer
    _drawFrequencyLayer(
      canvas, 
      size, 
      audioData!.midFrequencies, 
      centerY, 
      primaryColor.withOpacity(0.5),
      0.3,
      1.0,
    );
    
    // Treble layer
    _drawFrequencyLayer(
      canvas, 
      size, 
      audioData!.trebleFrequencies, 
      centerY, 
      Colors.cyan.withOpacity(0.4),
      0.2,
      trebleBoost,
    );
  }

  void _drawFrequencyLayer(Canvas canvas, Size size, List<double> frequencies, 
                          double centerY, Color color, double amplitude, double boost) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final stepX = size.width / (frequencies.length - 1);

    for (int i = 0; i < frequencies.length; i++) {
      final x = i * stepX;
      final level = frequencies[i] * sensitivity * boost;
      final offset = sin(level * pi + animationValue * 2 * pi) * size.height * amplitude;
      final y = centerY + offset;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw mirrored layer
    final mirrorPath = Path();
    for (int i = 0; i < frequencies.length; i++) {
      final x = i * stepX;
      final level = frequencies[i] * sensitivity * boost;
      final offset = sin(level * pi + animationValue * 2 * pi) * size.height * amplitude;
      final y = centerY - offset;

      if (i == 0) {
        mirrorPath.moveTo(x, y);
      } else {
        mirrorPath.lineTo(x, y);
      }
    }

    canvas.drawPath(mirrorPath, paint);
  }

  void _drawBeatIndicators(Canvas canvas, Size size) {
    final beatPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final centerY = size.height / 2;
    final beatIntensity = audioData!.bassLevel;

    // Vertical beat lines
    final lineCount = 5;
    for (int i = 0; i < lineCount; i++) {
      final x = size.width * (i + 1) / (lineCount + 1);
      final lineHeight = beatIntensity * size.height * 0.6;
      
      canvas.drawLine(
        Offset(x, centerY - lineHeight / 2),
        Offset(x, centerY + lineHeight / 2),
        beatPaint,
      );
    }

    // Pulsing circle at center
    final pulseRadius = beatIntensity * 30;
    beatPaint.style = PaintingStyle.stroke;
    beatPaint.strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.width / 2, centerY),
      pulseRadius,
      beatPaint,
    );
  }

  void _drawCenterLine(Canvas canvas, Size size) {
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}