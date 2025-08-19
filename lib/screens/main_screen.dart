import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart';
import '../models/spotify_models.dart';
import '../services/spotify_service.dart';
import '../services/audio_analysis_service.dart';
import '../widgets/player_controls.dart';
import '../widgets/settings_panel.dart';
import '../widgets/visualizer_factory.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final SpotifyService _spotifyService = SpotifyService();
  final AudioAnalysisService _audioService = AudioAnalysisService();
  
  CurrentlyPlaying? _currentTrack;
  PlaybackState? _playbackState;
  bool _isAuthenticated = false;
  bool _isSettingsVisible = false;
  bool _isAuthenticating = false;
  
  VisualizationStyle _currentVisualizationStyle = VisualizationStyle.bars;
  Map<String, dynamic> _visualizationSettings = {
    'sensitivity': 1.0,
    'smoothing': 0.8,
    'showPeaks': true,
    'reactToBeats': true,
    'bassBoost': 1.0,
    'trebleBoost': 1.0,
    'primaryColor': Colors.blue,
    'secondaryColor': Colors.purple,
    'glowEffect': true,
    'particleCount': 200.0,
    'animationSpeed': 1.0,
  };

  late AnimationController _backgroundController;
  late AnimationController _settingsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeServices();
    _setupWindowManager();
  }

  void _initializeControllers() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializeServices() async {
    // Initialize Spotify service
    await _spotifyService.initialize();
    
    // Listen to authentication state
    _spotifyService.authStateStream.listen((isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    // Listen to current track
    _spotifyService.currentTrackStream.listen((track) {
      setState(() {
        _currentTrack = track;
      });
      
      // Auto-adjust visualization based on track features
      if (track?.track?.audioFeatures != null) {
        _autoAdjustVisualization(track!.track!.audioFeatures!);
      }
    });

    // Listen to playback state
    _spotifyService.playbackStateStream.listen((state) {
      setState(() {
        _playbackState = state;
      });
    });

    // Start audio analysis
    _audioService.startAnalysis();
  }

  void _setupWindowManager() async {
    // Skip window manager setup for web
    if (kIsWeb) return;
    
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  void _autoAdjustVisualization(AudioFeatures features) {
    setState(() {
      _currentVisualizationStyle = features.recommendedVisualizationStyle;
      
      // Adjust settings based on audio features
      _visualizationSettings['sensitivity'] = 0.5 + (features.energy * 1.5);
      _visualizationSettings['bassBoost'] = 0.8 + (features.danceability * 1.2);
      _visualizationSettings['reactToBeats'] = features.danceability > 0.5;
      
      // Adjust colors based on mood
      if (features.valence > 0.7) {
        // Happy - bright colors
        _visualizationSettings['primaryColor'] = Colors.yellow;
        _visualizationSettings['secondaryColor'] = Colors.orange;
      } else if (features.valence < 0.3) {
        // Sad - cool colors
        _visualizationSettings['primaryColor'] = Colors.blue;
        _visualizationSettings['secondaryColor'] = Colors.purple;
      } else if (features.energy > 0.7) {
        // Energetic - vibrant colors
        _visualizationSettings['primaryColor'] = Colors.red;
        _visualizationSettings['secondaryColor'] = Colors.pink;
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _settingsController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 1000 || screenSize.height < 700;
    final settingsPanelWidth = isSmallScreen ? 300.0 : 350.0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Animated background
                _buildAnimatedBackground(),
                
                // Main content
                _buildMainContent(),
                
                // Top bar
                _buildTopBar(),
                
                // Player controls - responsive positioning
                Positioned(
                  left: 20,
                  right: _isSettingsVisible ? settingsPanelWidth + 20 : 20,
                  bottom: 20,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.2, // Max 20% of screen height
                      minHeight: 80,
                    ),
                    child: PlayerControls(
                      currentTrack: _currentTrack,
                      playbackState: _playbackState,
                    ),
                  ),
                ),
                
                // Settings panel - responsive
                if (_isSettingsVisible)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: settingsPanelWidth,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth * 0.4, // Max 40% of screen width
                        minWidth: 280,
                      ),
                      child: SettingsPanel(
                        currentStyle: _currentVisualizationStyle,
                        settings: _visualizationSettings,
                        onStyleChanged: (style) {
                          setState(() {
                            _currentVisualizationStyle = style;
                          });
                        },
                        onSettingsChanged: (settings) {
                          setState(() {
                            _visualizationSettings = settings;
                          });
                        },
                        onClose: () {
                          setState(() {
                            _isSettingsVisible = false;
                          });
                        },
                        onClearSettings: () {
                          setState(() {
                            _visualizationSettings = {
                              'sensitivity': 1.0,
                              'smoothing': 0.8,
                              'showPeaks': true,
                              'reactToBeats': true,
                              'bassBoost': 1.0,
                              'trebleBoost': 1.0,
                              'primaryColor': Colors.blue,
                              'secondaryColor': Colors.purple,
                              'glowEffect': true,
                              'particleCount': 200.0,
                              'animationSpeed': 1.0,
                            };
                          });
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [
                _visualizationSettings['primaryColor'].withOpacity(0.1),
                _visualizationSettings['secondaryColor'].withOpacity(0.05),
                Colors.black,
              ],
              stops: [
                0.0,
                0.5 + (_backgroundController.value * 0.3),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (!_isAuthenticated) {
      return _buildAuthenticationScreen();
    }

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsets.only(
          top: 60,
          bottom: 160,
          left: 20,
          right: _isSettingsVisible ? 370 : 20,
        ),
        child: _buildVisualizer(),
      ),
    );
  }

  Widget _buildAuthenticationScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 80,
                color: Colors.white.withOpacity(0.8),
              ).animate().scale(duration: 1000.ms).then().shimmer(),
              
              const SizedBox(height: 24),
              
              const Text(
                'SpotiVisualizer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms),
              
              const SizedBox(height: 12),
              
              const Text(
                'Connect to Spotify to start visualizing your music',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 700.ms),
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: _isAuthenticating ? null : () async {
                  setState(() {
                    _isAuthenticating = true;
                  });
                  
                  try {
                    final success = await _spotifyService.authenticate();
                    if (!success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to authenticate with Spotify. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isAuthenticating = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954), // Spotify green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isAuthenticating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Connect to Spotify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
          ).animate().fadeIn(delay: 900.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Window controls
            const SizedBox(width: 20),
            
            // App title - draggable area on desktop
            Expanded(
              child: GestureDetector(
                onPanStart: (details) {
                  if (!kIsWeb) {
                    windowManager.startDragging();
                  }
                },
                child: const Text(
                  'SpotiVisualizer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            // Visualization style indicator
            if (_isAuthenticated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: Text(
                  _currentVisualizationStyle.displayName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            
            const SizedBox(width: 12),
            
            // Logout button
            if (_isAuthenticated)
              IconButton(
                onPressed: () async {
                  // Show confirmation dialog with account switching tips
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        'Disconnect from Spotify?',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This will log you out of your current Spotify account.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tips for switching accounts:',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Use incognito/private browsing\n'
                            '• Clear browser cookies\n'
                            '• Try a different browser\n'
                            '• Log out of Google first',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldLogout == true) {
                    await _spotifyService.logout();
                    setState(() {
                      _isAuthenticated = false;
                      _isSettingsVisible = false;
                      _currentTrack = null;
                      _playbackState = null;
                    });
                  }
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white70,
                ),
                tooltip: 'Disconnect from Spotify',
              ),
            
            // Settings button
            if (_isAuthenticated)
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSettingsVisible = !_isSettingsVisible;
                  });
                  
                  if (_isSettingsVisible) {
                    _settingsController.forward();
                  } else {
                    _settingsController.reverse();
                  }
                },
                icon: Icon(
                  _isSettingsVisible ? Icons.close : Icons.settings,
                  color: Colors.white70,
                ),
                tooltip: _isSettingsVisible ? 'Close Settings' : 'Open Settings',
              ),
            
            // Window controls - only show on desktop
            if (!kIsWeb)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => windowManager.minimize(),
                    icon: const Icon(Icons.minimize, color: Colors.white70, size: 16),
                    tooltip: 'Minimize',
                    padding: const EdgeInsets.all(4),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        windowManager.unmaximize();
                      } else {
                        windowManager.maximize();
                      }
                    },
                    icon: const Icon(Icons.crop_square, color: Colors.white70, size: 16),
                    tooltip: 'Maximize/Restore',
                    padding: const EdgeInsets.all(4),
                  ),
                  IconButton(
                    onPressed: () => windowManager.close(),
                    icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                    tooltip: 'Close',
                    padding: const EdgeInsets.all(4),
                  ),
                ],
              ),
            
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return VisualizerFactory.createVisualizer(
      _currentVisualizationStyle,
      _visualizationSettings,
    );
  }
}