# SpotiVisualizer Web Version

A beautiful Spotify Visualizer with multiple visualization styles and full Spotify integration, now available as a web application!

## 🚀 Features

- **Multiple Visualization Styles**: Choose from various stunning visualization styles
- **Spotify Integration**: Connect to your Spotify account to visualize your music
- **Responsive Design**: Works on desktop and mobile browsers
- **Real-time Audio Analysis**: Visualize the audio in real-time
- **Customizable Settings**: Adjust visualization parameters to your liking

## 🔧 Getting Started

### Prerequisites

- A Spotify account
- A modern web browser (Chrome, Firefox, Edge recommended)

### Running Locally

1. Clone the repository
2. Install Flutter and configure it for web development:
   ```
   flutter config --enable-web
   ```
3. Get dependencies:
   ```
   flutter pub get
   ```
4. Run the web version:
   ```
   flutter run -d chrome
   ```

### Building for Production

Use the included build script:

```
./build_web.ps1
```

Or manually build:

```
flutter build web --release
```

The built files will be in the `build/web` directory.

## 🔌 Spotify Configuration

### Setting Up Spotify Developer Account

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new application
3. Set the redirect URI to:
   - For local development: `http://localhost:4200/auth/callback`
   - For production: `https://your-domain.com/auth/callback`

### Updating the App Configuration

Update the redirect URI in `lib/config/app_config.dart`:

```dart
// For local development
static const String redirectUri = 'http://localhost:4200/auth/callback';

// For production (uncomment when deploying)
// static const String redirectUri = 'https://your-domain.com/auth/callback';
```

## 🌐 Deployment

### Deploying to Vercel

1. Install Vercel CLI:
   ```
   npm install -g vercel
   ```

2. Deploy:
   ```
   vercel
   ```

3. Follow the prompts to complete the deployment

### After Deployment

1. Update the redirect URI in your Spotify Developer Dashboard to match your deployed domain
2. Update the redirect URI in `lib/config/app_config.dart` to match your deployed domain
3. Rebuild and redeploy

## 🔄 Using Spotify's Official Website as Redirect URI

To use Spotify's official website as the redirect URI:

1. Update the redirect URI in `lib/config/app_config.dart`:
   ```dart
   static const String redirectUri = 'https://open.spotify.com/callback';
   ```

2. Update your Spotify Developer Dashboard with the same URI

3. Note: This requires coordination with Spotify and may not be possible without special permission

## 🛠️ Troubleshooting

### Authentication Issues

If you encounter authentication issues:

1. Make sure the redirect URI in your Spotify Developer Dashboard exactly matches the one in your app
2. Try using incognito/private browsing mode
3. Clear your browser cookies and cache
4. Check the browser console for error messages

### Audio Visualization Issues

If visualizations aren't working:

1. Make sure you have an active Spotify Premium subscription
2. Check that a track is currently playing
3. Try refreshing the page
4. Allow microphone access if prompted (for local audio analysis)

## 📱 Progressive Web App

SpotiVisualizer is configured as a Progressive Web App (PWA), which means you can install it on your device for a more app-like experience:

1. Visit the deployed website in Chrome or Edge
2. Look for the install icon in the address bar
3. Click "Install" to add it to your device

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgements

- [Spotify Web API](https://developer.spotify.com/documentation/web-api/)
- [Flutter](https://flutter.dev/)
- [Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)