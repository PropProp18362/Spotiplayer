import 'package:flutter/material.dart';
import '../models/spotify_models.dart';
import 'visualizers/bars_visualizer.dart';
import 'visualizers/circular_visualizer.dart';
import 'visualizers/particles_visualizer.dart';
import 'visualizers/waveform_visualizer.dart';
import 'visualizers/spectrum_visualizer.dart';
import 'visualizers/galaxy_visualizer.dart';
import 'visualizers/fire_visualizer.dart';

class VisualizerFactory {
  static Widget createVisualizer(
    VisualizationStyle style,
    Map<String, dynamic> settings,
  ) {
    switch (style) {
      case VisualizationStyle.bars:
        return BarsVisualizer(settings: settings);
      case VisualizationStyle.circular:
        return CircularVisualizer(settings: settings);
      case VisualizationStyle.particles:
        return ParticlesVisualizer(settings: settings);
      case VisualizationStyle.waveform:
        return WaveformVisualizer(settings: settings);
      case VisualizationStyle.spectrum:
        return SpectrumVisualizer(settings: settings);
      case VisualizationStyle.galaxy:
        return GalaxyVisualizer(settings: settings);
      case VisualizationStyle.fire:
        return FireVisualizer(settings: settings);
      case VisualizationStyle.matrix:
        return _MatrixPlaceholder(settings: settings);
    }
  }
}

// Placeholder for Matrix visualizer (can be implemented later)
class _MatrixPlaceholder extends StatelessWidget {
  final Map<String, dynamic> settings;

  const _MatrixPlaceholder({required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.green],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              'Matrix Visualizer',
              style: TextStyle(
                color: Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon...',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}