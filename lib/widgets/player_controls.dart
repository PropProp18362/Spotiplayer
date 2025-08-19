import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/spotify_models.dart';
import '../services/spotify_service.dart';

class PlayerControls extends StatefulWidget {
  final CurrentlyPlaying? currentTrack;
  final PlaybackState? playbackState;

  const PlayerControls({
    super.key,
    this.currentTrack,
    this.playbackState,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls>
    with TickerProviderStateMixin {
  final SpotifyService _spotifyService = SpotifyService();
  double _volume = 50.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    if (widget.playbackState?.isPlaying == true) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlayerControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.playbackState?.isPlaying == true) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // ABSOLUTE CONSTRAINTS - CANNOT OVERFLOW
        final containerWidth = constraints.maxWidth.clamp(320.0, 1200.0);
        final containerHeight = 90.0; // FIXED HEIGHT
        
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: containerWidth,
            height: containerHeight,
            margin: const EdgeInsets.all(16),
            child: _buildPlayerContainer(containerWidth, containerHeight),
          ),
        );
      },
    );
  }

  Widget _buildPlayerContainer(double width, double height) {
    return GlassmorphicContainer(
      width: width,
      height: height,
      borderRadius: 12,
      blur: 10,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.06),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: _buildContent(width - 32, height - 24),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildContent(double availableWidth, double availableHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar - FIXED HEIGHT
        SizedBox(
          height: 20,
          width: availableWidth,
          child: _buildProgressBar(availableWidth),
        ),
        
        const SizedBox(height: 8),
        
        // Main content - FIXED HEIGHT
        SizedBox(
          height: availableHeight - 28, // 20 for progress + 8 for spacing
          width: availableWidth,
          child: _buildMainRow(availableWidth),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double width) {
    final progress = widget.currentTrack?.progress ?? 0.0;
    final currentTime = widget.currentTrack?.progressString.split(' / ')[0] ?? '0:00';
    final totalTime = widget.currentTrack?.track?.durationString ?? '0:00';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Slider - FIXED HEIGHT
        SizedBox(
          height: 12,
          width: width,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
              trackHeight: 2,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 8),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                if (widget.currentTrack?.durationMs != null) {
                  final positionMs = (value * widget.currentTrack!.durationMs!).round();
                  _spotifyService.seek(positionMs);
                }
              },
            ),
          ),
        ),
        
        // Time labels - FIXED HEIGHT
        SizedBox(
          height: 8,
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                totalTime,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainRow(double width) {
    final isCompact = width < 600;
    
    return Row(
      children: [
        // Track info - FLEXIBLE but CONSTRAINED
        Expanded(
          flex: isCompact ? 2 : 3,
          child: _buildTrackInfo(isCompact),
        ),
        
        const SizedBox(width: 16),
        
        // Controls - FIXED WIDTH
        SizedBox(
          width: isCompact ? 120 : 140,
          child: _buildPlaybackControls(isCompact),
        ),
        
        if (!isCompact) ...[
          const SizedBox(width: 16),
          // Volume - FIXED WIDTH
          SizedBox(
            width: 100,
            child: _buildVolumeControls(),
          ),
        ],
      ],
    );
  }

  Widget _buildTrackInfo(bool isCompact) {
    if (widget.currentTrack?.track == null) {
      return const Center(
        child: Text(
          'No track playing',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      );
    }

    final track = widget.currentTrack!.track!;
    final albumImage = track.album.largestImage;
    final imageSize = isCompact ? 32.0 : 40.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Album art - FIXED SIZE
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: albumImage != null
                ? Image.network(
                    albumImage.url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAlbumArt(imageSize),
                  )
                : _buildDefaultAlbumArt(imageSize),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Track details - FLEXIBLE but CONSTRAINED
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                track.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                track.artistNames,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isCompact ? 10 : 11,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAlbumArt(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  Widget _buildPlaybackControls(bool isCompact) {
    final isPlaying = widget.playbackState?.isPlaying ?? false;
    final buttonSize = isCompact ? 28.0 : 32.0;
    final playButtonSize = isCompact ? 36.0 : 40.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous - FIXED SIZE
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton(
            onPressed: () => _spotifyService.previousTrack(),
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            iconSize: buttonSize * 0.7,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: const CircleBorder(),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Play/Pause - FIXED SIZE
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: isPlaying ? 1.0 + (_pulseController.value * 0.03) : 1.0,
              child: SizedBox(
                width: playButtonSize,
                height: playButtonSize,
                child: IconButton(
                  onPressed: () {
                    if (isPlaying) {
                      _spotifyService.pause();
                    } else {
                      _spotifyService.play();
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: playButtonSize * 0.6,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(width: 8),
        
        // Next - FIXED SIZE
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: IconButton(
            onPressed: () => _spotifyService.nextTrack(),
            icon: const Icon(Icons.skip_next, color: Colors.white),
            iconSize: buttonSize * 0.7,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: const CircleBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Volume icon - FIXED SIZE
        SizedBox(
          width: 24,
          height: 24,
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              _volume > 50 ? Icons.volume_up : 
              _volume > 0 ? Icons.volume_down : Icons.volume_off,
              color: Colors.white70,
              size: 16,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Volume slider - FIXED WIDTH
        SizedBox(
          width: 60,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 3),
              trackHeight: 2,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 6),
            ),
            child: Slider(
              value: _volume,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _volume = value;
                });
                _spotifyService.setVolume(value.round());
              },
            ),
          ),
        ),
      ],
    );
  }
}