import 'package:flutter/material.dart';
import '../../services/audio_analysis_service.dart';
import '../../models/spotify_models.dart';

abstract class BaseVisualizer extends StatefulWidget {
  final VisualizationStyle style;
  final Map<String, dynamic> settings;

  const BaseVisualizer({
    Key? key,
    required this.style,
    this.settings = const {},
  }) : super(key: key);
}

abstract class BaseVisualizerState<T extends BaseVisualizer> extends State<T>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  AudioData? _currentAudioData;
  
  // Common settings
  double get sensitivity => widget.settings['sensitivity']?.toDouble() ?? 1.0;
  double get smoothing => widget.settings['smoothing']?.toDouble() ?? 0.8;
  bool get showPeaks => widget.settings['showPeaks'] ?? true;
  Color get primaryColor => widget.settings['primaryColor'] ?? Colors.blue;
  Color get secondaryColor => widget.settings['secondaryColor'] ?? Colors.purple;
  bool get reactToBeats => widget.settings['reactToBeats'] ?? true;
  double get bassBoost => widget.settings['bassBoost']?.toDouble() ?? 1.0;
  double get trebleBoost => widget.settings['trebleBoost']?.toDouble() ?? 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 16),
      vsync: this,
    );
    
    _startListening();
    _animationController.repeat();
  }

  void _startListening() {
    AudioAnalysisService().audioDataStream.listen((audioData) {
      if (mounted) {
        setState(() {
          _currentAudioData = audioData;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: createPainter(),
        child: Container(),
      ),
    );
  }

  // Abstract method to be implemented by specific visualizers
  CustomPainter createPainter();

  // Helper methods for common visualizer needs
  List<Color> getGradientColors() {
    if (_currentAudioData?.beatDetected == true && reactToBeats) {
      return [
        primaryColor.withOpacity(0.9),
        secondaryColor.withOpacity(0.9),
        Colors.white.withOpacity(0.3),
      ];
    }
    return [
      primaryColor.withOpacity(0.7),
      secondaryColor.withOpacity(0.7),
    ];
  }

  double getScaledLevel(double level) {
    return (level * sensitivity).clamp(0.0, 1.0);
  }

  Color getFrequencyColor(int index, double level) {
    final normalizedIndex = index / 64.0;
    final beatMultiplier = (_currentAudioData?.beatDetected == true && reactToBeats) ? 1.3 : 1.0;
    
    if (normalizedIndex < 0.25) {
      // Bass - Red to Orange
      return Color.lerp(
        Colors.red,
        Colors.orange,
        level * beatMultiplier,
      )!.withOpacity(level);
    } else if (normalizedIndex < 0.75) {
      // Mid - Orange to Yellow
      return Color.lerp(
        Colors.orange,
        Colors.yellow,
        level * beatMultiplier,
      )!.withOpacity(level);
    } else {
      // Treble - Yellow to White
      return Color.lerp(
        Colors.yellow,
        Colors.white,
        level * beatMultiplier,
      )!.withOpacity(level);
    }
  }

  // Get current audio data safely
  AudioData? get audioData => _currentAudioData;
  
  // Animation value
  double get animationValue => _animationController.value;
}