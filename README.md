# 🎵 SpotiVisualizer

A beautiful, high-quality Spotify music visualizer that creates stunning visual effects that react to your music in real-time. Experience your favorite songs in a whole new way with multiple visualization styles, customizable settings, and seamless Spotify integration.

## ✨ Features

### 🎵 Spotify Integration
- **Seamless Authentication**: Connect to your Spotify account with secure OAuth
- **Real-time Playback**: Visualizations sync perfectly with your music
- **Track Information**: View song details, album art, and audio features
- **Audio Analysis**: Visualizations react to tempo, energy, and beat patterns

### 🎨 Visualization Styles
- **Spectrum**: Classic frequency bars with glow effects and bass response
- **Orbital**: Particles orbiting in 3D space that react to music intensity
- **Nebula**: Cosmic cloud of particles with connections that pulse to the beat
- **Terrain**: Dynamic landscape that morphs with the music
- **Fire**: Realistic flame simulation that reacts to lyrics and bass drops
- **Liquid**: Fluid simulation that ripples and flows with the music
- **Starfield**: 3D star field that warps and pulses with the beat

### ⚙️ Customization
- **Sensitivity**: Adjust how responsive visualizations are to audio
- **Bass Boost**: Enhance low-frequency response
- **Motion Speed**: Control animation speed
- **Color Themes**: Choose from multiple color schemes
- **Quality Settings**: Optimize for performance or visual fidelity
- **Fullscreen Mode**: Immersive visualization experience

## 🚀 Getting Started

### Web Version
1. Visit [SpotiVisualizer Web](https://your-deployed-url.com)
2. Click "Connect with Spotify"
3. Authorize the application
4. Start playing music on Spotify
5. Enjoy the visualizations!

### Local Development
1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/SpotiVisualizer.git
   ```
2. Set up Spotify Developer credentials
   - Create an app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Add `http://localhost:8000` as a redirect URI
3. Update the client ID in the code
4. Serve the application locally
   ```bash
   # Using Python's built-in server
   python -m http.server
   ```
5. Open `http://localhost:8000` in your browser

## 🔧 Spotify Developer Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new application
3. Add the following redirect URIs:
   - For local testing: `http://localhost:8000`
   - For production: `https://your-domain.com`
4. Copy your Client ID and update it in the application
5. Set the proper redirect URI in the code

## 🎮 Usage

1. **Connect**: Authenticate with your Spotify account
2. **Play Music**: Start playing music on any Spotify-connected device
3. **Choose Visualization**: Select from different visualization styles
4. **Customize**: Adjust settings to your preference
5. **Fullscreen**: Enter fullscreen mode for an immersive experience
6. **Enjoy**: Watch as the visualizations react to your music!

## 🔍 Troubleshooting

### Common Issues

1. **Authentication Fails**
   - Make sure you have a Spotify Premium account
   - Check that your redirect URI matches what's in your Spotify Developer Dashboard
   - Clear browser cookies and try again

2. **No Visualization**
   - Ensure music is actively playing on Spotify
   - Check your internet connection
   - Try refreshing the page

3. **Performance Issues**
   - Lower the quality settings
   - Close other resource-intensive applications
   - Try a different browser (Chrome recommended)

4. **Track Changes Not Detected**
   - Wait a few seconds for the API to update
   - Try skipping to the next track
   - Refresh the page if issues persist

## 🔒 Privacy & Security

- SpotiVisualizer only requests the minimum required permissions from Spotify
- No personal data is stored on our servers
- Authentication is handled securely through Spotify's OAuth flow
- Your listening data is only used for visualization purposes

## 🛠️ Technical Details

- **Frontend**: HTML5, CSS3, JavaScript
- **Visualization**: Canvas API with WebGL acceleration
- **Audio Analysis**: Spotify Web API for audio features and analysis
- **Authentication**: Spotify OAuth 2.0
- **Storage**: Local browser storage for settings and tokens

## 📝 License

This project is for personal use and educational purposes. Spotify integration requires compliance with Spotify's Developer Terms of Service.

---

**Enjoy your music with beautiful visualizations! 🎵✨**