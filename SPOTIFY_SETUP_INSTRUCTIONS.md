# Spotify Developer Dashboard Setup Instructions

## 🎵 Setting Up Your Spotify Developer Account

To use SpotiVisualizer, you need to configure your Spotify Developer Dashboard correctly. Follow these steps:

### 1. Access Spotify Developer Dashboard

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Log in with your Spotify account
3. Click "Create App" if you haven't already created one

### 2. Configure Your App

1. Fill in the required information:
   - **App Name**: SpotiVisualizer (or any name you prefer)
   - **App Description**: Music visualization app for Spotify
   - **Website**: You can use `http://localhost:8888` for development
   - **Redirect URI**: This is critical! Set it to exactly:
     ```
     http://localhost:8888/
     ```
     (Note the trailing slash - it's important!)

2. Accept the terms and click "Create"

### 3. Get Your Client ID and Secret

1. Once your app is created, you'll see your **Client ID** on the dashboard
2. Click "Show Client Secret" to reveal your **Client Secret**
3. Keep these values safe - they're used in the app configuration

### 4. Update App Configuration (if needed)

The app already has default credentials, but if you want to use your own:

1. Open `lib/config/app_config.dart`
2. Update the following values with your own:
   ```dart
   static const String spotifyClientId = 'your-client-id';
   static const String spotifyClientSecret = 'your-client-secret';
   ```

## 🔍 Troubleshooting Authentication Issues

If you encounter "Invalid Client" errors:

### 1. Check Redirect URI

Make sure your Spotify Developer Dashboard has **EXACTLY** this redirect URI:
```
http://localhost:8888/
```

Common mistakes:
- Missing the trailing slash
- Using `https://` instead of `http://`
- Adding extra paths like `/callback`

### 2. Try Incognito Mode

If you still have issues:
1. When the browser opens for authentication, copy the URL
2. Open a new incognito/private browsing window
3. Paste the URL and continue the authentication process

### 3. Clear Browser Cache

If problems persist:
1. Clear your browser cookies and cache, especially for Spotify domains
2. Try using a different browser
3. Make sure you're not logged into multiple Google accounts

## 🚀 Running the App

1. Make sure your Spotify Developer Dashboard is correctly configured
2. Run the app using:
   ```
   flutter run -d windows
   ```
3. Click "Connect to Spotify" in the app
4. Log in with your Spotify account
5. Enjoy visualizing your music!

## 📝 Note About HTTP vs HTTPS

For local development, we're using HTTP instead of HTTPS for simplicity. This is perfectly fine for development purposes, but in a production environment, you would want to use HTTPS for security reasons.

If you want to switch to HTTPS:
1. Update the redirect URI in `lib/config/app_config.dart` to use `https://`
2. Update your Spotify Developer Dashboard redirect URI to match
3. Implement proper certificate handling for local HTTPS

## 🎮 Need More Help?

If you continue to experience issues:
1. Check the console output for specific error messages
2. Make sure Spotify is running and playing music
3. Try logging out of Spotify completely and logging back in
4. Restart the application