# 🎵 SpotiVisualizer

A beautiful, high-quality Spotify music visualizer built with Flutter. Features multiple visualization styles that react to your music with bass response, beat detection, and customizable settings. Now available as both a desktop application and a web application!

## Features

### 🎵 Spotify Integration
- Secure OAuth authentication with Spotify
- Real-time track information display
- Playback controls (play, pause, skip, volume)
- Progress tracking and seeking
- Automatic visualization adjustment based on song characteristics

### 🎨 Multiple Visualization Styles
- **Classic Bars**: Traditional frequency bars with bass response
- **Circular**: Circular frequency display with rotating elements
- **Particles**: Dynamic particle system that reacts to music
- **Waveform**: Smooth waveform visualization with frequency layers
- **Spectrum**: 3D spectrum analyzer with frequency grid
- **Galaxy**: Cosmic galaxy effect with rotating stars
- **Fire**: Flame-like visualization with heat effects
- **Matrix**: Digital matrix rain (coming soon)

### ⚙️ Advanced Settings
- **Audio Settings**: Bass boost, treble boost, sensitivity, smoothing
- **Visual Settings**: Colors, effects, animation speed, particle count
- **Beat Detection**: Automatic beat detection with visual reactions
- **Auto-Adjustment**: Visualization automatically adapts to song mood and energy

### 🎛️ Professional UI
- Glassmorphic design with beautiful animations
- Responsive controls with haptic feedback
- Settings panel with tabbed interface
- Real-time audio visualization
- Window management for desktop experience

## Installation

### Prerequisites
- Flutter SDK (latest stable version)
- Spotify Premium account
- Valid Spotify Developer App credentials

### Desktop Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the desktop application:
   ```bash
   flutter run -d windows
   ```

### Web Setup
1. Enable Flutter web support:
   ```bash
   flutter config --enable-web
   ```
2. Run the web application:
   ```bash
   flutter run -d chrome
   ```
3. For deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md)

## Configuration

The app uses secure credential storage for Spotify API keys. The credentials are encrypted and stored locally using Flutter Secure Storage.

### Spotify Developer Setup
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Add the appropriate redirect URI:
   - For desktop: `http://localhost:8888/`
   - For web (local): `http://localhost:4200/auth/callback`
   - For web (production): `https://your-domain.com/auth/callback`
4. The app will handle authentication automatically

For detailed web deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md) and [README_WEB.md](README_WEB.md)

## Usage

1. **Launch the app** - The application will open in a desktop window
2. **Connect to Spotify** - Click "Connect to Spotify" and authorize the app
3. **Start playing music** - Play any song on Spotify
4. **Enjoy visualizations** - The app will automatically start visualizing your music
5. **Customize settings** - Click the settings icon to adjust visualization parameters
6. **Control playback** - Use the built-in controls to manage your music

## Visualization Styles

### Classic Bars
- Traditional frequency spectrum bars
- Bass-responsive with peak indicators
- Color-coded frequency ranges
- Beat pulse effects

### Circular
- 360-degree frequency display
- Rotating visualization elements
- Center pulsing based on audio level
- Beat ring effects

### Particles
- Dynamic particle system (200+ particles)
- Particle connections based on proximity
- Frequency-responsive movement
- Beat explosion effects

### Waveform
- Smooth waveform with frequency layers
- Bass, mid, and treble separation
- Historical waveform tracking
- Beat indicator lines

### Spectrum
- 3D spectrum analyzer
- Logarithmic frequency scaling
- Peak hold indicators
- Heat distortion effects

### Galaxy
- Cosmic spiral galaxy visualization
- Rotating star field (300+ stars)
- Central black hole with accretion disk
- Energy wave effects on beats

### Fire
- Realistic flame simulation
- Heat distortion effects
- Spark generation
- Beat explosion bursts

## Settings

### Audio Settings
- **Sensitivity**: Overall responsiveness to audio (0.1 - 3.0)
- **Smoothing**: Smoothness of transitions (0.1 - 0.95)
- **Bass Boost**: Amplification of low frequencies (0.5 - 3.0)
- **Treble Boost**: Amplification of high frequencies (0.5 - 3.0)
- **Beat Sensitivity**: Responsiveness to beat detection (0.1 - 2.0)

### Visual Settings
- **Primary/Secondary Colors**: Customizable color scheme
- **Glow Effects**: Enable/disable glow effects
- **Particle Count**: Number of particles (50 - 500)
- **Animation Speed**: Speed of animations (0.5 - 3.0)
- **Show Peaks**: Display peak indicators
- **React to Beats**: Enable beat-reactive effects

## Technical Details

### Architecture
- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Secure Storage**: Encrypted credential storage
- **Window Manager**: Desktop window controls
- **Custom Painters**: High-performance visualizations

### Audio Processing
- Real-time FFT analysis
- 64-band frequency spectrum
- Beat detection algorithm
- Bass/mid/treble separation
- Smoothing and peak detection

### Performance
- 60 FPS visualization rendering
- Efficient memory management
- Optimized audio processing
- Smooth animations and transitions

## Security

- Spotify credentials are encrypted using base64 encoding
- Tokens stored in secure storage
- No credentials visible in source code
- Automatic token refresh handling

## Contributing

This is a personal project, but suggestions and feedback are welcome!

## Repository Privacy

This repository should be kept private due to the sensitive nature of the Spotify API credentials.

### Making the Repository Private

1. Go to [GitHub Repository Settings](https://github.com/PropProp18362/Spotiplayer/settings)
2. Scroll down to the "Danger Zone"
3. Click "Change repository visibility"
4. Select "Make private" and follow the prompts

Alternatively, you can use the provided script:
```bash
node make-repo-private.js
```
(Note: You'll need to edit the script and add your personal access token first)

## License

This project is for personal use. Spotify integration requires compliance with Spotify's Terms of Service.

## Troubleshooting

### Common Issues
1. **Authentication fails**: Check internet connection and Spotify credentials
2. **No visualization**: Ensure music is playing on Spotify
3. **Performance issues**: Reduce particle count or disable glow effects
4. **Window issues**: Restart the application

### Support
For issues or questions, please check the troubleshooting section or create an issue in the repository.

## Web Version

SpotiVisualizer is now available as a web application! This allows you to enjoy the visualizations directly in your browser without installing anything.

### Web Features
- **Browser-based**: Run directly in Chrome, Firefox, Edge, or other modern browsers
- **Responsive Design**: Adapts to different screen sizes
- **Web Audio API**: Uses the Web Audio API for audio analysis
- **Deployment Ready**: Can be deployed to Vercel or other hosting platforms

### Web Deployment
For detailed instructions on deploying the web version, see [DEPLOYMENT.md](DEPLOYMENT.md).

### Web-specific Configuration
The web version uses a different authentication flow than the desktop version. Make sure to update your Spotify Developer Dashboard with the correct redirect URI for web.

---

**Enjoy your music with beautiful visualizations! 🎵✨**