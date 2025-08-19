class AudioData {
  final List<double> frequencyBands;
  final double bassLevel;
  final double midLevel;
  final double trebleLevel;
  final double overallLevel;
  final bool beatDetected;
  final double beatStrength;
  final DateTime timestamp;

  AudioData({
    required this.frequencyBands,
    required this.bassLevel,
    required this.midLevel,
    required this.trebleLevel,
    required this.overallLevel,
    required this.beatDetected,
    required this.beatStrength,
    required this.timestamp,
  });

  // Convenience getters for different frequency ranges
  List<double> get bassFrequencies => frequencyBands.take(16).toList();
  List<double> get midFrequencies => frequencyBands.skip(16).take(32).toList();
  List<double> get trebleFrequencies => frequencyBands.skip(48).toList();

  // Get dominant frequency
  int get dominantFrequencyIndex {
    double maxLevel = 0.0;
    int maxIndex = 0;
    
    for (int i = 0; i < frequencyBands.length; i++) {
      if (frequencyBands[i] > maxLevel) {
        maxLevel = frequencyBands[i];
        maxIndex = i;
      }
    }
    
    return maxIndex;
  }

  // Get energy in different ranges
  double get bassEnergy => bassFrequencies.fold(0.0, (sum, level) => sum + level);
  double get midEnergy => midFrequencies.fold(0.0, (sum, level) => sum + level);
  double get trebleEnergy => trebleFrequencies.fold(0.0, (sum, level) => sum + level);
}

class CurrentlyPlaying {
  final Track? track;
  final bool isPlaying;
  final int progressMs;
  final int? durationMs;
  final String? context;

  CurrentlyPlaying({
    this.track,
    required this.isPlaying,
    required this.progressMs,
    this.durationMs,
    this.context,
  });

  factory CurrentlyPlaying.fromJson(Map<String, dynamic> json) {
    return CurrentlyPlaying(
      track: json['item'] != null ? Track.fromJson(json['item']) : null,
      isPlaying: json['is_playing'] ?? false,
      progressMs: json['progress_ms'] ?? 0,
      durationMs: json['item']?['duration_ms'],
      context: json['context']?['type'],
    );
  }

  double get progress {
    if (durationMs == null || durationMs == 0) return 0.0;
    return progressMs / durationMs!;
  }

  String get progressString {
    final current = Duration(milliseconds: progressMs);
    final total = Duration(milliseconds: durationMs ?? 0);
    return '${_formatDuration(current)} / ${_formatDuration(total)}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class Track {
  final String id;
  final String name;
  final List<Artist> artists;
  final Album album;
  final int durationMs;
  final int popularity;
  final bool explicit;
  final String? previewUrl;
  final AudioFeatures? audioFeatures;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.durationMs,
    required this.popularity,
    required this.explicit,
    this.previewUrl,
    this.audioFeatures,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artists: (json['artists'] as List?)
          ?.map((artist) => Artist.fromJson(artist))
          .toList() ?? [],
      album: Album.fromJson(json['album'] ?? {}),
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'] ?? 0,
      explicit: json['explicit'] ?? false,
      previewUrl: json['preview_url'],
    );
  }

  String get artistNames => artists.map((artist) => artist.name).join(', ');
  
  String get durationString {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

class Artist {
  final String id;
  final String name;
  final List<String> genres;
  final int popularity;
  final List<SpotifyImage> images;

  Artist({
    required this.id,
    required this.name,
    required this.genres,
    required this.popularity,
    required this.images,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genres: (json['genres'] as List?)?.cast<String>() ?? [],
      popularity: json['popularity'] ?? 0,
      images: (json['images'] as List?)
          ?.map((image) => SpotifyImage.fromJson(image))
          .toList() ?? [],
    );
  }
}

class Album {
  final String id;
  final String name;
  final List<Artist> artists;
  final List<SpotifyImage> images;
  final String releaseDate;
  final String albumType;
  final int totalTracks;

  Album({
    required this.id,
    required this.name,
    required this.artists,
    required this.images,
    required this.releaseDate,
    required this.albumType,
    required this.totalTracks,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artists: (json['artists'] as List?)
          ?.map((artist) => Artist.fromJson(artist))
          .toList() ?? [],
      images: (json['images'] as List?)
          ?.map((image) => SpotifyImage.fromJson(image))
          .toList() ?? [],
      releaseDate: json['release_date'] ?? '',
      albumType: json['album_type'] ?? '',
      totalTracks: json['total_tracks'] ?? 0,
    );
  }

  SpotifyImage? get largestImage {
    if (images.isEmpty) return null;
    return images.reduce((a, b) => 
        (a.width ?? 0) > (b.width ?? 0) ? a : b);
  }

  SpotifyImage? get smallestImage {
    if (images.isEmpty) return null;
    return images.reduce((a, b) => 
        (a.width ?? 999999) < (b.width ?? 999999) ? a : b);
  }
}

class SpotifyImage {
  final String url;
  final int? width;
  final int? height;

  SpotifyImage({
    required this.url,
    this.width,
    this.height,
  });

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url'] ?? '',
      width: json['width'],
      height: json['height'],
    );
  }
}

class AudioFeatures {
  final String id;
  final double acousticness;
  final double danceability;
  final double energy;
  final double instrumentalness;
  final int key;
  final double liveness;
  final double loudness;
  final int mode;
  final double speechiness;
  final double tempo;
  final int timeSignature;
  final double valence;

  AudioFeatures({
    required this.id,
    required this.acousticness,
    required this.danceability,
    required this.energy,
    required this.instrumentalness,
    required this.key,
    required this.liveness,
    required this.loudness,
    required this.mode,
    required this.speechiness,
    required this.tempo,
    required this.timeSignature,
    required this.valence,
  });

  factory AudioFeatures.fromJson(Map<String, dynamic> json) {
    return AudioFeatures(
      id: json['id'] ?? '',
      acousticness: (json['acousticness'] ?? 0.0).toDouble(),
      danceability: (json['danceability'] ?? 0.0).toDouble(),
      energy: (json['energy'] ?? 0.0).toDouble(),
      instrumentalness: (json['instrumentalness'] ?? 0.0).toDouble(),
      key: json['key'] ?? 0,
      liveness: (json['liveness'] ?? 0.0).toDouble(),
      loudness: (json['loudness'] ?? 0.0).toDouble(),
      mode: json['mode'] ?? 0,
      speechiness: (json['speechiness'] ?? 0.0).toDouble(),
      tempo: (json['tempo'] ?? 0.0).toDouble(),
      timeSignature: json['time_signature'] ?? 4,
      valence: (json['valence'] ?? 0.0).toDouble(),
    );
  }

  // Get mood based on audio features
  String get mood {
    if (valence > 0.7 && energy > 0.7) return 'Energetic & Happy';
    if (valence > 0.7 && energy < 0.3) return 'Happy & Calm';
    if (valence < 0.3 && energy > 0.7) return 'Intense & Dark';
    if (valence < 0.3 && energy < 0.3) return 'Sad & Mellow';
    if (danceability > 0.7) return 'Danceable';
    if (acousticness > 0.7) return 'Acoustic';
    return 'Balanced';
  }

  // Get visualization style based on audio features
  VisualizationStyle get recommendedVisualizationStyle {
    if (energy > 0.8 && danceability > 0.7) return VisualizationStyle.particles;
    if (acousticness > 0.6) return VisualizationStyle.waveform;
    if (instrumentalness > 0.5) return VisualizationStyle.spectrum;
    if (valence > 0.7) return VisualizationStyle.circular;
    return VisualizationStyle.bars;
  }
}

class PlaybackState {
  final bool isPlaying;
  final int progressMs;
  final double volume;

  PlaybackState({
    required this.isPlaying,
    required this.progressMs,
    required this.volume,
  });
}

enum VisualizationStyle {
  bars,
  waveform,
  circular,
  spectrum,
  particles,
  galaxy,
  matrix,
  fire,
}

extension VisualizationStyleExtension on VisualizationStyle {
  String get displayName {
    switch (this) {
      case VisualizationStyle.bars:
        return 'Classic Bars';
      case VisualizationStyle.waveform:
        return 'Waveform';
      case VisualizationStyle.circular:
        return 'Circular';
      case VisualizationStyle.spectrum:
        return 'Spectrum';
      case VisualizationStyle.particles:
        return 'Particles';
      case VisualizationStyle.galaxy:
        return 'Galaxy';
      case VisualizationStyle.matrix:
        return 'Matrix';
      case VisualizationStyle.fire:
        return 'Fire';
    }
  }

  String get description {
    switch (this) {
      case VisualizationStyle.bars:
        return 'Traditional frequency bars with bass response';
      case VisualizationStyle.waveform:
        return 'Smooth waveform visualization';
      case VisualizationStyle.circular:
        return 'Circular frequency display';
      case VisualizationStyle.spectrum:
        return 'Full spectrum analyzer';
      case VisualizationStyle.particles:
        return 'Dynamic particle system';
      case VisualizationStyle.galaxy:
        return 'Cosmic galaxy effect';
      case VisualizationStyle.matrix:
        return 'Digital matrix rain';
      case VisualizationStyle.fire:
        return 'Flame-like visualization';
    }
  }
}