import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/spotify_models.dart';
import 'web_audio_service.dart';

class AudioAnalysisService {
  static final AudioAnalysisService _instance = AudioAnalysisService._internal();
  factory AudioAnalysisService() => _instance;
  
  // Web-specific audio service
  WebAudioService? _webAudioService;
  bool _usingWebAudio = false;
  
  AudioAnalysisService._internal() {
    if (kIsWeb) {
      _webAudioService = WebAudioService();
      _usingWebAudio = true;
      
      // Listen to web audio data streams
      _webAudioService?.frequencyDataStream.listen(_handleWebFrequencyData);
      _webAudioService?.timeDataStream.listen(_handleWebTimeData);
    }
  }

  final StreamController<AudioData> _audioDataController = 
      StreamController<AudioData>.broadcast();
  
  Stream<AudioData> get audioDataStream => _audioDataController.stream;

  Timer? _analysisTimer;
  final Random _random = Random();
  
  // Audio analysis parameters
  static const int sampleRate = 44100;
  static const int fftSize = 2048;
  static const int numBands = 64;
  
  // Frequency bands for different visualization needs
  final List<double> _frequencyBands = List.filled(numBands, 0.0);
  final List<double> _previousBands = List.filled(numBands, 0.0);
  final List<double> _peakBands = List.filled(numBands, 0.0);
  
  // Bass, mid, treble analysis
  double _bassLevel = 0.0;
  double _midLevel = 0.0;
  double _trebleLevel = 0.0;
  
  // Beat detection
  double _beatThreshold = 0.0;
  bool _beatDetected = false;
  final List<double> _beatHistory = [];
  
  // Smoothing and responsiveness
  double _smoothingFactor = 0.8;
  double _sensitivity = 1.0;

  void startAnalysis() {
    if (_usingWebAudio && kIsWeb) {
      // Use web audio service for better browser performance
      _webAudioService?.startSpotifyAnalysis();
    } else {
      // Use simulated audio for non-web platforms
      _analysisTimer?.cancel();
      _analysisTimer = Timer.periodic(
        const Duration(milliseconds: 16), // ~60 FPS
        (_) => _performAnalysis(),
      );
    }
  }

  void stopAnalysis() {
    if (_usingWebAudio && kIsWeb) {
      _webAudioService?.stopAnalysis();
    } else {
      _analysisTimer?.cancel();
    }
  }
  
  // Handle web audio frequency data
  void _handleWebFrequencyData(Uint8List data) {
    if (!_usingWebAudio) return;
    
    // Convert to frequency bands
    final numBands = _frequencyBands.length;
    final step = data.length ~/ numBands;
    
    for (int i = 0; i < numBands; i++) {
      int sum = 0;
      final startIdx = i * step;
      final endIdx = (i + 1) * step;
      
      for (int j = startIdx; j < endIdx && j < data.length; j++) {
        sum += data[j];
      }
      
      final avg = sum / step / 255.0; // Normalize to 0.0-1.0
      
      // Apply smoothing
      _frequencyBands[i] = _frequencyBands[i] * _smoothingFactor + 
                          avg * (1 - _smoothingFactor);
                          
      // Update peaks
      if (_frequencyBands[i] > _peakBands[i]) {
        _peakBands[i] = _frequencyBands[i];
      } else {
        _peakBands[i] *= 0.95; // Decay peaks
      }
    }
    
    // Calculate bass, mid, treble levels
    _calculateLevelsFromBands();
    
    // Detect beats
    _detectBeat();
    
    // Send audio data
    _sendAudioData();
  }
  
  // Handle web audio time domain data
  void _handleWebTimeData(Uint8List data) {
    // Time domain data can be used for waveform visualizations
    // We don't need to process it further for now
  }
  
  // Calculate audio levels from frequency bands
  void _calculateLevelsFromBands() {
    // Bass: first ~20% of bands
    final bassRange = (_frequencyBands.length * 0.2).round();
    double bassSum = 0;
    for (int i = 0; i < bassRange; i++) {
      bassSum += _frequencyBands[i];
    }
    _bassLevel = (bassSum / bassRange).clamp(0.0, 1.0);
    
    // Mid: middle ~60% of bands
    final midStart = bassRange;
    final midEnd = (_frequencyBands.length * 0.8).round();
    double midSum = 0;
    for (int i = midStart; i < midEnd; i++) {
      midSum += _frequencyBands[i];
    }
    _midLevel = (midSum / (midEnd - midStart)).clamp(0.0, 1.0);
    
    // Treble: last ~20% of bands
    double trebleSum = 0;
    for (int i = midEnd; i < _frequencyBands.length; i++) {
      trebleSum += _frequencyBands[i];
    }
    _trebleLevel = (trebleSum / (_frequencyBands.length - midEnd)).clamp(0.0, 1.0);
  }
  
  // Send audio data to listeners
  void _sendAudioData() {
    final audioData = AudioData(
      frequencyBands: List.from(_frequencyBands),
      bassLevel: _bassLevel,
      midLevel: _midLevel,
      trebleLevel: _trebleLevel,
      beatDetected: _beatDetected,
      beatStrength: _beatDetected ? _bassLevel : 0.0,
      overallLevel: (_bassLevel + _midLevel + _trebleLevel) / 3,
      timestamp: DateTime.now(),
    );
    
    _audioDataController.add(audioData);
  }

  void _performAnalysis() {
    // For now, we'll simulate audio data since we don't have direct audio capture
    // In a real implementation, this would process actual audio input
    _simulateAudioAnalysis();
    
    final audioData = AudioData(
      frequencyBands: List.from(_frequencyBands),
      bassLevel: _bassLevel,
      midLevel: _midLevel,
      trebleLevel: _trebleLevel,
      beatDetected: _beatDetected,
      beatStrength: _beatDetected ? _bassLevel : 0.0,
      overallLevel: (_bassLevel + _midLevel + _trebleLevel) / 3,
      timestamp: DateTime.now(),
    );
    
    _audioDataController.add(audioData);
  }

  void _simulateAudioAnalysis() {
    // Simulate realistic audio data with bass, mid, and treble components
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    // Generate bass frequencies (20-250 Hz)
    _bassLevel = _generateBassLevel(time);
    
    // Generate mid frequencies (250-4000 Hz)
    _midLevel = _generateMidLevel(time);
    
    // Generate treble frequencies (4000-20000 Hz)
    _trebleLevel = _generateTrebleLevel(time);
    
    // Generate frequency bands
    for (int i = 0; i < numBands; i++) {
      final frequency = _getFrequencyForBand(i);
      double level = 0.0;
      
      if (frequency < 250) {
        // Bass range
        level = _bassLevel * _generateFrequencyResponse(frequency, 60, 100);
      } else if (frequency < 4000) {
        // Mid range
        level = _midLevel * _generateFrequencyResponse(frequency, 1000, 500);
      } else {
        // Treble range
        level = _trebleLevel * _generateFrequencyResponse(frequency, 8000, 2000);
      }
      
      // Add some randomness and harmonics
      level += _random.nextDouble() * 0.1;
      level = level.clamp(0.0, 1.0);
      
      // Smooth the transition
      _frequencyBands[i] = _frequencyBands[i] * _smoothingFactor + 
                          level * (1 - _smoothingFactor);
      
      // Track peaks
      if (_frequencyBands[i] > _peakBands[i]) {
        _peakBands[i] = _frequencyBands[i];
      } else {
        _peakBands[i] *= 0.95; // Decay peaks
      }
    }
    
    // Beat detection
    _detectBeat();
  }

  double _generateBassLevel(double time) {
    // Simulate bass with some rhythm
    final bassRhythm = sin(time * 2) * 0.5 + 0.5;
    final bassVariation = sin(time * 0.5) * 0.3 + 0.7;
    return (bassRhythm * bassVariation * _sensitivity).clamp(0.0, 1.0);
  }

  double _generateMidLevel(double time) {
    // Simulate mid frequencies with melody-like patterns
    final melody = sin(time * 3) * 0.4 + 0.6;
    final variation = cos(time * 0.7) * 0.2 + 0.8;
    return (melody * variation * _sensitivity).clamp(0.0, 1.0);
  }

  double _generateTrebleLevel(double time) {
    // Simulate treble with high-frequency content
    final treble = sin(time * 5) * 0.3 + 0.4;
    final sparkle = _random.nextDouble() * 0.2;
    return ((treble + sparkle) * _sensitivity).clamp(0.0, 1.0);
  }

  double _generateFrequencyResponse(double frequency, double center, double width) {
    final distance = (frequency - center).abs();
    return exp(-distance * distance / (2 * width * width));
  }

  double _getFrequencyForBand(int band) {
    // Logarithmic frequency distribution
    final minFreq = 20.0;
    final maxFreq = 20000.0;
    final ratio = pow(maxFreq / minFreq, 1.0 / (numBands - 1));
    return minFreq * pow(ratio, band);
  }

  void _detectBeat() {
    final currentLevel = _bassLevel;
    _beatHistory.add(currentLevel);
    
    if (_beatHistory.length > 10) {
      _beatHistory.removeAt(0);
    }
    
    if (_beatHistory.length >= 5) {
      final average = _beatHistory.reduce((a, b) => a + b) / _beatHistory.length;
      _beatThreshold = average * 1.3;
      _beatDetected = currentLevel > _beatThreshold && currentLevel > 0.3;
    }
  }

  // Mock FFT implementation (replace with real audio processing later)
  List<double> _performFFT(Float32List audioSamples) {
    // Simple mock FFT that generates realistic-looking frequency data
    final magnitudes = <double>[];
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    
    for (int i = 0; i < fftSize ~/ 2; i++) {
      final frequency = i * sampleRate / fftSize;
      
      // Generate mock frequency response with some realism
      double magnitude = 0.0;
      
      // Bass frequencies (20-250 Hz) - stronger response
      if (frequency < 250) {
        magnitude = sin(time * 2 + i * 0.1) * 0.8 + 0.2;
      }
      // Mid frequencies (250-4000 Hz) - moderate response  
      else if (frequency < 4000) {
        magnitude = sin(time * 1.5 + i * 0.05) * 0.6 + 0.15;
      }
      // High frequencies (4000+ Hz) - weaker response
      else {
        magnitude = sin(time * 3 + i * 0.02) * 0.4 + 0.1;
      }
      
      // Add some randomness
      magnitude += (_random.nextDouble() - 0.5) * 0.1;
      magnitude = magnitude.clamp(0.0, 1.0);
      
      magnitudes.add(magnitude);
    }
    
    return magnitudes;
  }

  List<double> _binToFrequencyBands(List<double> fftMagnitudes) {
    final bands = List.filled(numBands, 0.0);
    final binSize = sampleRate / fftSize;
    
    for (int band = 0; band < numBands; band++) {
      final frequency = _getFrequencyForBand(band);
      final binIndex = (frequency / binSize).round().clamp(0, fftMagnitudes.length - 1);
      
      // Average nearby bins for smoother response
      double sum = 0.0;
      int count = 0;
      final range = max(1, (fftMagnitudes.length / numBands / 4).round());
      
      for (int i = max(0, binIndex - range); 
           i < min(fftMagnitudes.length, binIndex + range); 
           i++) {
        sum += fftMagnitudes[i];
        count++;
      }
      
      bands[band] = count > 0 ? sum / count : 0.0;
    }
    
    return bands;
  }

  // Configuration methods
  void setSensitivity(double sensitivity) {
    _sensitivity = sensitivity.clamp(0.1, 3.0);
  }

  void setSmoothingFactor(double smoothing) {
    _smoothingFactor = smoothing.clamp(0.1, 0.95);
  }

  void dispose() {
    _analysisTimer?.cancel();
    if (_usingWebAudio && kIsWeb) {
      _webAudioService?.dispose();
    }
    _audioDataController.close();
  }
}