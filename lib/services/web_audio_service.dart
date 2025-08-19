import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// A web-specific implementation of audio analysis service
/// This uses the Web Audio API for better performance in browsers
class WebAudioService {
  // JavaScript objects
  dynamic _audioContext;
  dynamic _analyser;
  dynamic _mediaStreamSource;
  dynamic _mediaStream;
  
  // Analysis data
  Uint8List? _frequencyData;
  Uint8List? _timeData;
  
  // Stream controllers
  final StreamController<Uint8List> _frequencyDataController = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _timeDataController = StreamController<Uint8List>.broadcast();
  
  // Analysis configuration
  final int _fftSize = 2048;
  bool _isAnalyzing = false;
  Timer? _analysisTimer;
  
  // Public streams
  Stream<Uint8List> get frequencyDataStream => _frequencyDataController.stream;
  Stream<Uint8List> get timeDataStream => _timeDataController.stream;
  
  // Constructor
  WebAudioService() {
    if (kIsWeb) {
      _initializeWebAudio();
    }
  }
  
  /// Initialize the Web Audio API
  Future<void> _initializeWebAudio() async {
    try {
      // Create AudioContext
      _audioContext = js.context.hasProperty('AudioContext')
          ? js.context.callMethod('AudioContext', [])
          : js.context.callMethod('webkitAudioContext', []);
      
      // Create Analyser node
      _analyser = _audioContext.callMethod('createAnalyser');
      _analyser.setProperty('fftSize', _fftSize);
      _analyser.setProperty('smoothingTimeConstant', 0.8);
      
      // Create data arrays
      _frequencyData = Uint8List(_analyser.getProperty('frequencyBinCount'));
      _timeData = Uint8List(_fftSize);
      
      debugPrint('Web Audio API initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Web Audio API: $e');
    }
  }
  
  /// Start audio analysis from microphone
  Future<void> startMicrophoneAnalysis() async {
    if (!kIsWeb || _isAnalyzing) return;
    
    try {
      // Request microphone access
      _mediaStream = await promiseToFuture(
        html.window.navigator.mediaDevices?.getUserMedia({
          'audio': true,
          'video': false,
        })
      );
      
      // Create media stream source
      _mediaStreamSource = _audioContext.callMethod('createMediaStreamSource', [_mediaStream]);
      _mediaStreamSource.callMethod('connect', [_analyser]);
      
      // Start analysis loop
      _isAnalyzing = true;
      _startAnalysisLoop();
      
      debugPrint('Microphone analysis started');
    } catch (e) {
      debugPrint('Error starting microphone analysis: $e');
    }
  }
  
  /// Start audio analysis from Spotify playback
  Future<void> startSpotifyAnalysis() async {
    if (!kIsWeb) return;
    
    // For Spotify analysis, we'll use the Spotify Web Playback SDK
    // This requires additional setup with the Spotify API
    debugPrint('Spotify Web Playback analysis not yet implemented');
    
    // For now, we'll generate some dummy data for visualization
    _isAnalyzing = true;
    _startDummyAnalysisLoop();
  }
  
  /// Start the analysis loop
  void _startAnalysisLoop() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_isAnalyzing) return;
      
      // Get frequency data
      _analyser.callMethod('getByteFrequencyData', [_frequencyData]);
      _frequencyDataController.add(_frequencyData!);
      
      // Get time domain data
      _analyser.callMethod('getByteTimeDomainData', [_timeData]);
      _timeDataController.add(_timeData!);
    });
  }
  
  /// Generate dummy data for visualization when no audio source is available
  void _startDummyAnalysisLoop() {
    final random = DateTime.now().millisecondsSinceEpoch;
    _frequencyData = Uint8List(128);
    _timeData = Uint8List(128);
    
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isAnalyzing) return;
      
      // Generate dummy frequency data with some variation
      for (int i = 0; i < _frequencyData!.length; i++) {
        final baseValue = (i < _frequencyData!.length / 2) 
            ? 150 - i 
            : 150 - (_frequencyData!.length - i);
        
        final time = (timer.tick + random) / 50;
        final sinValue = (baseValue * 0.5) * (0.5 + 0.5 * math.sin(time + i / 10));
        final cosValue = (baseValue * 0.3) * (0.5 + 0.5 * math.cos(time * 0.7 + i / 8));
        
        _frequencyData![i] = (baseValue * 0.2 + sinValue + cosValue).toInt().clamp(0, 255);
      }
      
      // Generate dummy time domain data
      for (int i = 0; i < _timeData!.length; i++) {
        final time = (timer.tick + random) / 100;
        final value = 128 + 64 * math.sin(time + i / 20);
        _timeData![i] = value.toInt().clamp(0, 255);
      }
      
      _frequencyDataController.add(_frequencyData!);
      _timeDataController.add(_timeData!);
    });
  }
  
  /// Stop audio analysis
  void stopAnalysis() {
    _isAnalyzing = false;
    _analysisTimer?.cancel();
    
    if (kIsWeb) {
      // Stop microphone if active
      if (_mediaStream != null) {
        final tracks = _mediaStream.callMethod('getTracks');
        for (int i = 0; i < tracks.length; i++) {
          tracks[i].callMethod('stop');
        }
      }
      
      // Disconnect audio nodes
      if (_mediaStreamSource != null) {
        _mediaStreamSource.callMethod('disconnect');
      }
    }
  }
  
  /// Dispose resources
  void dispose() {
    stopAnalysis();
    _frequencyDataController.close();
    _timeDataController.close();
  }
}

// Import math for the dummy data generation
import 'dart:math' as math;