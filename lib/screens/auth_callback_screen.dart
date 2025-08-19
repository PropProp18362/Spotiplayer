import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/spotify_service.dart';

class AuthCallbackScreen extends StatefulWidget {
  final String? code;
  final String? error;
  final String? state;

  const AuthCallbackScreen({
    Key? key,
    this.code,
    this.error,
    this.state,
  }) : super(key: key);

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  final SpotifyService _spotifyService = SpotifyService();
  bool _isProcessing = true;
  bool _isSuccess = false;
  String _message = 'Processing authentication...';

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  Future<void> _processCallback() async {
    try {
      if (widget.error != null) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = 'Authentication failed: ${widget.error}';
        });
        return;
      }

      if (widget.code != null) {
        final success = await _spotifyService.exchangeCodeForToken(widget.code!);
        
        setState(() {
          _isProcessing = false;
          _isSuccess = success;
          _message = success 
              ? 'Authentication successful! You can close this window and return to the app.'
              : 'Failed to exchange code for token. Please try again.';
        });
      } else {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = 'No authentication code received. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _message = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error,
                  color: _isSuccess ? Colors.green : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 24),
              Text(
                _isSuccess ? 'Success!' : 'Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: _isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (!_isProcessing)
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                  child: const Text('Close'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}