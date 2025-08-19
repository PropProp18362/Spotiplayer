# SpotiVisualizer - Troubleshooting Guide

## 🔧 Common Issues and Solutions

### Build Issues

#### Issue: "Flutter not found" or "flutter command not recognized"
**Solution:**
1. Install Flutter from https://flutter.dev/docs/get-started/install/windows
2. Add Flutter to your system PATH
3. Restart your terminal/PowerShell
4. Run `flutter doctor` to verify installation

#### Issue: "Visual Studio not found" or C++ build errors
**Solution:**
1. Install Visual Studio 2022 Community (free)
2. During installation, select "Desktop development with C++"
3. Make sure Windows 10/11 SDK is installed
4. Run `flutter doctor` to verify setup

#### Issue: "Windows platform not available"
**Solution:**
1. Run `flutter config --enable-windows-desktop`
2. Restart your terminal
3. Run `flutter devices` to verify Windows is listed

### Runtime Issues

#### Issue: App crashes on startup
**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Try running the simple version first: `flutter run -d windows -t lib/main_simple.dart`
4. Check console output for specific error messages

#### Issue: "Failed to authenticate with Spotify"
**Solution:**
1. Ensure you have a Spotify Premium account
2. Check your internet connection
3. Make sure Spotify is not blocking the app
4. Try logging out and back into Spotify
5. Clear app data and try again

#### Issue: No visualization or blank screen
**Solution:**
1. Make sure music is playing on Spotify
2. Check that the app has proper permissions
3. Try switching visualization styles in settings
4. Restart the app

#### Issue: Poor performance or lag
**Solution:**
1. Reduce particle count in settings
2. Disable glow effects
3. Lower animation speed
4. Close other resource-intensive applications
5. Update your graphics drivers

### Spotify Integration Issues

#### Issue: "Invalid client credentials"
**Solution:**
1. The credentials are embedded in the app
2. If you need to change them, modify the base64 encoded values in `lib/config/app_config.dart`
3. Make sure your Spotify Developer App has the correct redirect URI: `http://localhost:8888/callback`

#### Issue: "Authorization failed" during OAuth
**Solution:**
1. Make sure port 8888 is not blocked by firewall
2. Check that no other application is using port 8888
3. Try running as administrator
4. Ensure your Spotify Developer App is properly configured

#### Issue: "Token expired" errors
**Solution:**
1. The app should automatically refresh tokens
2. If it doesn't work, clear app data and re-authenticate
3. Check your internet connection
4. Make sure system clock is correct

### Performance Optimization

#### For Better Performance:
1. **Reduce Particle Count:** Lower to 100-150 particles
2. **Disable Glow Effects:** Turn off in visual settings
3. **Lower Sensitivity:** Reduce to 0.5-0.8
4. **Increase Smoothing:** Set to 0.9 for smoother animations
5. **Close Background Apps:** Free up system resources

#### For Better Visual Quality:
1. **Increase Particle Count:** Set to 300-500 particles
2. **Enable Glow Effects:** Turn on in visual settings
3. **Higher Sensitivity:** Set to 1.5-2.0
4. **Lower Smoothing:** Set to 0.6-0.7 for more responsive visuals

## 🛠️ Development Issues

### If you're modifying the code:

#### Issue: Hot reload not working
**Solution:**
1. Use `flutter run` instead of `flutter build`
2. Make sure you're not modifying native code
3. Try `r` for hot reload or `R` for hot restart

#### Issue: New dependencies not working
**Solution:**
1. Run `flutter clean`
2. Run `flutter pub get`
3. Restart the app completely

#### Issue: Build errors after changes
**Solution:**
1. Check for syntax errors
2. Ensure all imports are correct
3. Run `flutter analyze` to check for issues
4. Revert recent changes if needed

## 📞 Getting Help

### Debug Information to Collect:
1. Flutter version: `flutter --version`
2. Flutter doctor output: `flutter doctor -v`
3. Error messages from console
4. Steps to reproduce the issue
5. System specifications (Windows version, RAM, etc.)

### Useful Commands:
```bash
# Check Flutter installation
flutter doctor -v

# Clean and rebuild
flutter clean
flutter pub get
flutter run -d windows

# Run simple version for testing
flutter run -d windows -t lib/main_simple.dart

# Check available devices
flutter devices

# Analyze code for issues
flutter analyze

# Enable Windows desktop (if needed)
flutter config --enable-windows-desktop
```

### Log Files:
- Flutter logs are shown in the terminal when running
- Windows Event Viewer may contain additional error information
- Check Task Manager for resource usage

## 🔍 Advanced Troubleshooting

### Registry Issues (Windows):
If you encounter persistent issues, you might need to:
1. Clear Flutter cache: Delete `%USERPROFILE%\.flutter`
2. Reinstall Flutter completely
3. Check Windows Defender exclusions

### Network Issues:
1. Check firewall settings for Flutter and the app
2. Ensure Spotify API endpoints are accessible
3. Try using a VPN if there are regional restrictions

### Hardware Issues:
1. Update graphics drivers
2. Check if hardware acceleration is enabled
3. Ensure sufficient RAM (minimum 4GB recommended)
4. Close other graphics-intensive applications

---

**Still having issues?** 
Check the PROJECT_STATUS.md file for the latest known issues and solutions, or create a detailed issue report with the debug information listed above.