import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../models/spotify_models.dart';

class SpotifyService {
  static final SpotifyService _instance = SpotifyService._internal();
  factory SpotifyService() => _instance;
  SpotifyService._internal();

  final Dio _dio = Dio();
  Timer? _tokenRefreshTimer;
  Timer? _currentTrackTimer;
  
  final StreamController<CurrentlyPlaying?> _currentTrackController = 
      StreamController<CurrentlyPlaying?>.broadcast();
  final StreamController<PlaybackState> _playbackStateController = 
      StreamController<PlaybackState>.broadcast();
  final StreamController<bool> _authStateController = 
      StreamController<bool>.broadcast();

  Stream<CurrentlyPlaying?> get currentTrackStream => _currentTrackController.stream;
  Stream<PlaybackState> get playbackStateStream => _playbackStateController.stream;
  Stream<bool> get authStateStream => _authStateController.stream;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  HttpServer? _authServer;
  Completer<bool>? _authCompleter;

  Future<void> initialize() async {
    final token = await AppConfig.getAccessToken();
    if (token != null) {
      _isAuthenticated = true;
      _authStateController.add(true);
      _setupTokenRefresh();
      _startCurrentTrackPolling();
    }
  }

  Future<bool> authenticate() async {
    try {
      await _cleanupAuth();
      
      final state = _generateRandomString(16);
      
      // Add cache busting and force approval parameters
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final authUrl = Uri.parse(AppConfig.spotifyAuthUrl).replace(
        queryParameters: {
          'client_id': AppConfig.spotifyClientId,
          'response_type': 'code',
          'redirect_uri': AppConfig.redirectUri,
          'scope': AppConfig.spotifyScopes.join(' '),
          'state': state,
          'show_dialog': 'true',        // ALWAYS show dialog
          'approval_prompt': 'force',   // Force approval screen
          '_t': timestamp,              // Cache buster - unique every time
        },
      );
      
      // Check if we're running on web
      if (kIsWeb) {
        // For web, we'll just launch the URL and handle the callback in a separate route
        await launchUrl(authUrl, webOnlyWindowName: '_self');
        // The result will be handled by the callback route
        return true;
      }

      // Start HTTPS server with self-signed certificate
      _authServer = await _createHttpsServer();
      _authCompleter = Completer<bool>();
      
      // Handle callback
      _authServer!.listen((request) async {
        final uri = request.uri;
        
        if (uri.path == '/') {
          final code = uri.queryParameters['code'];
          final error = uri.queryParameters['error'];
          final returnedState = uri.queryParameters['state'];
          
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType.html;
            
          if (error != null) {
            request.response.write('''
              <!DOCTYPE html>
              <html>
                <head><title>Authentication Failed</title></head>
                <body style="font-family: Arial; text-align: center; padding: 50px;">
                  <h1 style="color: red;">Authentication Failed</h1>
                  <p>Error: $error</p>
                  <p><strong>BEST FIX:</strong> Use incognito/private browsing mode</p>
                  <p><strong>Why this happens:</strong> Your browser has cached authentication data that conflicts with the new login attempt.</p>
                  <p>Other solutions:</p>
                  <ul style="text-align: left; display: inline-block;">
                    <li>Try a different browser (Edge, Firefox)</li>
                    <li>Clear your browser cookies for Spotify</li>
                    <li>Make sure you're logged out of all Google accounts</li>
                  </ul>
                  <p>Close this window and try again.</p>
                  <script>setTimeout(() => window.close(), 10000);</script>
                </body>
              </html>
            ''');
            await request.response.close();
            if (!_authCompleter!.isCompleted) {
              _authCompleter!.complete(false);
            }
          } else if (code != null && returnedState == state) {
            request.response.write('''
              <!DOCTYPE html>
              <html>
                <head><title>Success</title></head>
                <body style="font-family: Arial; text-align: center; padding: 50px;">
                  <h1 style="color: green;">Success!</h1>
                  <p>Authentication successful. You can close this window.</p>
                  <p>Return to the SpotiVisualizer app to start visualizing your music!</p>
                  <script>setTimeout(() => window.close(), 2000);</script>
                </body>
              </html>
            ''');
            await request.response.close();
            
            final success = await _exchangeCodeForToken(code);
            if (!_authCompleter!.isCompleted) {
              _authCompleter!.complete(success);
            }
          } else {
            request.response.write('''
              <!DOCTYPE html>
              <html>
                <head><title>Error</title></head>
                <body style="font-family: Arial; text-align: center; padding: 50px;">
                  <h1 style="color: red;">Invalid Request</h1>
                  <p>Authentication request was invalid or incomplete.</p>
                  <p><strong>Try these solutions:</strong></p>
                  <ul style="text-align: left; display: inline-block;">
                    <li>Use incognito/private browsing mode</li>
                    <li>Try a different browser</li>
                    <li>Clear your browser cookies</li>
                    <li>Restart the application</li>
                  </ul>
                  <p>Close this window and try again.</p>
                  <script>setTimeout(() => window.close(), 5000);</script>
                </body>
              </html>
            ''');
            await request.response.close();
            if (!_authCompleter!.isCompleted) {
              _authCompleter!.complete(false);
            }
          }
        }
      });

      // Launch browser
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);

      // Wait for result
      final result = await _authCompleter!.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () => false,
      );

      await _cleanupAuth();
      return result;
    } catch (e) {
      debugPrint('Authentication error: $e');
      await _cleanupAuth();
      return false;
    }
  }

  // Make this public so it can be called from the callback screen
  Future<bool> exchangeCodeForToken(String code) async {
    try {
      final response = await _dio.post(
        AppConfig.spotifyTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': AppConfig.redirectUri,
          'client_id': AppConfig.spotifyClientId,
          'client_secret': AppConfig.spotifyClientSecret,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        await AppConfig.storeAccessToken(accessToken);
        if (refreshToken != null) {
          await AppConfig.storeRefreshToken(refreshToken);
        }

        _isAuthenticated = true;
        _authStateController.add(true);
        _setupTokenRefresh();
        _startCurrentTrackPolling();

        return true;
      }
    } catch (e) {
      debugPrint('Token exchange error: $e');
    }
    return false;
  }
  
  // Keep this for backward compatibility
  Future<bool> _exchangeCodeForToken(String code) async {
    return exchangeCodeForToken(code);
  }

  void _setupTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _refreshAccessToken();
    });
  }

  Future<void> _refreshAccessToken() async {
    try {
      final refreshToken = await AppConfig.getRefreshToken();
      if (refreshToken == null) return;

      final response = await _dio.post(
        AppConfig.spotifyTokenUrl,
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': AppConfig.spotifyClientId,
          'client_secret': AppConfig.spotifyClientSecret,
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accessToken = data['access_token'];
        await AppConfig.storeAccessToken(accessToken);
      }
    } catch (e) {
      debugPrint('Token refresh error: $e');
    }
  }

  void _startCurrentTrackPolling() {
    _currentTrackTimer?.cancel();
    _currentTrackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchCurrentTrack();
    });
  }

  Future<void> _fetchCurrentTrack() async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      final response = await _dio.get(
        '${AppConfig.spotifyApiBaseUrl}/me/player/currently-playing',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final currentTrack = CurrentlyPlaying.fromJson(response.data);
        _currentTrackController.add(currentTrack);
        
        _playbackStateController.add(PlaybackState(
          isPlaying: currentTrack.isPlaying,
          progressMs: currentTrack.progressMs ?? 0,
          volume: 50.0,
        ));
      } else {
        _currentTrackController.add(null);
        _playbackStateController.add(PlaybackState(
          isPlaying: false,
          progressMs: 0,
          volume: 50.0,
        ));
      }
    } catch (e) {
      // Ignore errors for now
    }
  }

  Future<void> play() async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.put(
        '${AppConfig.spotifyApiBaseUrl}/me/player/play',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> pause() async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.put(
        '${AppConfig.spotifyApiBaseUrl}/me/player/pause',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Pause error: $e');
    }
  }

  Future<void> nextTrack() async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.post(
        '${AppConfig.spotifyApiBaseUrl}/me/player/next',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Next track error: $e');
    }
  }

  Future<void> previousTrack() async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.post(
        '${AppConfig.spotifyApiBaseUrl}/me/player/previous',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Previous track error: $e');
    }
  }

  Future<void> seek(int positionMs) async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.put(
        '${AppConfig.spotifyApiBaseUrl}/me/player/seek',
        queryParameters: {'position_ms': positionMs},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Seek error: $e');
    }
  }

  Future<void> setVolume(int volume) async {
    try {
      final token = await AppConfig.getAccessToken();
      if (token == null) return;

      await _dio.put(
        '${AppConfig.spotifyApiBaseUrl}/me/player/volume',
        queryParameters: {'volume_percent': volume},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      debugPrint('Volume error: $e');
    }
  }

  Future<void> _cleanupAuth() async {
    try {
      if (_authServer != null) {
        await _authServer!.close(force: true);
        _authServer = null;
      }
      if (_authCompleter != null && !_authCompleter!.isCompleted) {
        _authCompleter!.complete(false);
      }
      _authCompleter = null;
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _cleanupAuth();
      await AppConfig.clearTokens();
      _dio.options.headers.remove('Authorization');
      
      _tokenRefreshTimer?.cancel();
      _currentTrackTimer?.cancel();
      
      _isAuthenticated = false;
      _authStateController.add(false);
      _currentTrackController.add(null);
      _playbackStateController.add(PlaybackState(
        isPlaying: false,
        progressMs: 0,
        volume: 50.0,
      ));
      
      debugPrint('Successfully logged out - ready for new account');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<HttpServer> _createHttpsServer() async {
    try {
      // Use HTTP server directly for local development
      debugPrint('Starting HTTP server on localhost:8888');
      return await HttpServer.bind('localhost', 8888);
    } catch (e) {
      debugPrint('HTTP server creation failed: $e');
      throw e; // Re-throw to handle the error properly
    }
  }

  Future<void> _createCertificateFiles() async {
    final certPath = 'c:\\Users\\krish\\App Development\\SpotiVisualizer\\certs\\cert.pem';
    final keyPath = 'c:\\Users\\krish\\App Development\\SpotiVisualizer\\certs\\key.pem';
    
    // Create directory if it doesn't exist
    final certsDir = Directory('c:\\Users\\krish\\App Development\\SpotiVisualizer\\certs');
    if (!await certsDir.exists()) {
      await certsDir.create(recursive: true);
    }
    
    // Always create new certificates to avoid issues
    await _createDummyCertificates(certPath, keyPath);
  }

  Future<void> _createDummyCertificates(String certPath, String keyPath) async {
    // Create valid certificates for localhost
    const dummyCert = '''-----BEGIN CERTIFICATE-----
MIIDazCCAlOgAwIBAgIUJFdebh7kUxk0OsZvQ5KDrMFHtOcwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMzA1MTUwMDAwMDBaFw0yNDA1
MTUwMDAwMDBaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDCpQhDj8M8UHyZ9tQTUmXKIFQkAcjzDLx+BA3gkQM3
JRj9GXCsJk2JucuM6rNdW5PhZ3fZ7Z92SFFHgJGEOYbvI5XxnJKj9QP+wF5XSPVT
AwdTGNO+aMYcSuRQZW5qqNDvML8RbJIFQS4Yz9Q4KsW2kYeYYxw4IyxYOd0jJXy7
ItVUPRUxI3zM6Yi5ooLmFGYdlts+8+qvS6WMjCp3xFG6R/WcHjD+g4XR/j+QQhfj
yZBKXJAIjKKzQYPBtb+9E0QHXlzxLiYwJlIBZUCMahRT6KPzlxSH8kQQGJbO8agt
+GbCzN7QmYUZuY5iFmxpNhNQRArqxVZ+JdAM3sTLAgMBAAGjUzBRMB0GA1UdDgQW
BBQVkPQii8FwlnJ7GvKyqKQwwF1FpDAfBgNVHSMEGDAWgBQVkPQii8FwlnJ7GvKy
qKQwwF1FpDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBpPeIK
ZrCUjUPfSgvJtpIrSgUCQFRKrxYWBhB6KbJ7X+AbbGDQc0wbOTkVCjlZrlr9MbOk
rFjnU0xvWv48UM1+xPBtpvhCLxNS0L+WFyAjXj4GQJ/vbIgJjLZRZZ78oAOXO8+Y
WQwjrZEDCblmMiTl8yDgCo4fUUUgTgdDvg1je1iKqFfxEm8bWxPxCQlXO7F4Iedt
/JYIgm3JKJOe7YVmYOQZVdQxGx/Jui5G7c9BnCFsQAD1UYQ3XCbLym3FUQY1QeiI
igCH1lcLQkQJCsvYjP5l+7GgpCWRH3PDGOYgm/muT6sZNsb2vHLTyKMGDXzOL+7E
6mbcPVVQIjKmLvEd
-----END CERTIFICATE-----''';

    const dummyKey = '''-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDCpQhDj8M8UHyZ
9tQTUmXKIFQkAcjzDLx+BA3gkQM3JRj9GXCsJk2JucuM6rNdW5PhZ3fZ7Z92SFHH
gJGEOYbvI5XxnJKj9QP+wF5XSPVTAwdTGNO+aMYcSuRQZW5qqNDvML8RbJIFQS4Y
z9Q4KsW2kYeYYxw4IyxYOd0jJXy7ItVUPRUxI3zM6Yi5ooLmFGYdlts+8+qvS6WM
jCp3xFG6R/WcHjD+g4XR/j+QQhfjyZBKXJAIjKKzQYPBtb+9E0QHXlzxLiYwJlIB
ZUCMahRT6KPzlxSH8kQQGJbO8agt+GbCzN7QmYUZuY5iFmxpNhNQRArqxVZ+JdAM
3sTLAgMBAAECggEAHEDWAyD+hnQ9TLrGWjhzCc5iKaZZZhbLJDjD+AiAMCw8fKaI
t0zMkxfcH17ZMmP8XhX9eYXNzX3GQKUb6UXP97lbPRFWVMwQxgNH3pWfxFEjnASS
Pu8sMPrZWcBjGYcSgSXwQYKqsjRMwXIVe6/9y/jEAyAj/nLJMmkw3aqGkJ/hEV1u
wvHLJ6WtTRZbHSzubu7MNw8JNnL2vKGVboTZnTBjNvNKcpZBVFpOJHlmZQZ9iGfk
3GBdUQXXG+EYl9i8lNrLQBZkS0qxMfkzwDTZbz9LUQCxQO3YeAQNlIEYJTZP5c6P
ORKjLZ0QCpjnR1PW5AhQCFJJgwPPzLkZ0Z8ZAQKBgQDlPYQhEuVcOC0/uRYCjA9P
JzD5dYAIqHJEIlbqLKCtiLBDOxSGgU9OmVNlYfwHGYzoYVKXTHJOvKSHfUgJEr+V
TYDqcQVSKXYEAImh3yLvVQnVJJfCQXN3M9q9/xzEY7XzKjvwP0AOlSQoAIWTCaGV
Ij/WJbplPYWCJFZnTVZAQQKBgQDZPQCYDUVWzxMpEnXh5EwJo+n5NRUl+4jOYoMm
JQNkJM/hJpoQSmGy5ykFP4mJMcC6fNO5ZYvXAMqVuRuvZFM27NKjOToPd3Ky6mKJ
XBVpbQQTJiDAP9ZBZ4JiQBjK5ueGLQdZ/o2PxYBjgGFxqILMW3GzKOcXCn3ngHLc
oCnCywKBgQCVmobhoLkWiEwpCYKqlsgInxGzKTwxpTlmYZC2Eg5m1/S6OQPgKDbr
ZyTYWIawi5Cbk68hwz1VYGQGjFiJXrJnKAMJ7Z/G5D4TLuDOh45hIVpZH5ykiw7+
A1yS3UEH6Qwq9J+gp2XhCdlI2NLQyiWTDcmjKuIDwHJOOKrjAELQAQKBgQCbCJ7e
Q2yTFXNKvdwPw7hbKQtFiQEPzZMmvKW896KeYkAJbFHe4yQmR5qW4qldyRnKzIB+
MpA8WaYcjKLMqz7jxQQvPfRMCQP3W6q+1wDS9CG+5MJadE8y9JGK5V0zuRoPYs0I
9Zg0NyYgXh8UUuGIgRrNMuGPGqc8F0MBqTx2ywKBgHZYmXzuBWZJb1xYs2Qe4Fvx
JQm0ZZt6qA3XdSNwcjpUeRlJ0rZQHyHRm+7G0eB78N+RvYWK+B3GqHDDVFSS8V+w
PrtiQEpWAELyB8BGm6/tQc8oMiJw8GFapKh+B1aAYS0AZI6RxWzerm0WCpJ7gww1
+QhHsj9gQJFUHNv6QgZe
-----END PRIVATE KEY-----''';

    await File(certPath).writeAsString(dummyCert);
    await File(keyPath).writeAsString(dummyKey);
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void dispose() {
    _tokenRefreshTimer?.cancel();
    _currentTrackTimer?.cancel();
    _currentTrackController.close();
    _playbackStateController.close();
    _authStateController.close();
    _cleanupAuth();
  }
}