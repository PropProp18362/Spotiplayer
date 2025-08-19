import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  
  // Spotify credentials
  static const String spotifyClientId = 'd37b7146ee274b33bf6539611a0c307e';
  static const String spotifyClientSecret = 'e63d3d9982c84339bbe9c0c0fe012f50';
  
  // Spotify API endpoints
  static const String spotifyAuthUrl = 'https://accounts.spotify.com/authorize';
  static const String spotifyTokenUrl = 'https://accounts.spotify.com/api/token';
  static const String spotifyApiBaseUrl = 'https://api.spotify.com/v1';
  
  // OAuth scopes needed for the app
  static const List<String> spotifyScopes = [
    'user-read-currently-playing',
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-private',
    'user-read-email',
    'streaming',
    'app-remote-control',
  ];
  
  // App configuration - MUST MATCH Spotify Developer Dashboard EXACTLY
  // For local development (commented out for production)
  // static const String redirectUri = 'http://localhost:4200/auth/callback';
  // For production
  static const String redirectUri = 'https://spotiplayer.vercel.app/auth/callback';
  static const String appName = 'SpotiVisualizer';
  

  
  // Store access token securely
  static Future<void> storeAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spotify_access_token', token);
  }
  
  // Get stored access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('spotify_access_token');
  }
  
  // Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('spotify_refresh_token', token);
  }
  
  // Get stored refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('spotify_refresh_token');
  }
  
  // Clear all stored tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
  }
  
  // Store user preferences
  static Future<void> storeUserPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_$key', value);
  }
  
  // Get user preference
  static Future<String?> getUserPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pref_$key');
  }
}