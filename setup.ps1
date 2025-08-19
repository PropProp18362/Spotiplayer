Write-Host "SpotiVisualizer Setup Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Flutter is installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Check Flutter doctor
Write-Host ""
Write-Host "Running Flutter doctor..." -ForegroundColor Yellow
flutter doctor

# Clean and get dependencies
Write-Host ""
Write-Host "Cleaning project..." -ForegroundColor Yellow
flutter clean

Write-Host ""
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Check if Windows is available as a target
Write-Host ""
Write-Host "Checking available devices..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To run the app:" -ForegroundColor Yellow
Write-Host "1. Simple version: flutter run -d windows -t lib/main_simple.dart" -ForegroundColor White
Write-Host "2. Full version: flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "Note: You'll need a Spotify Premium account to use the full features." -ForegroundColor Cyan
Write-Host ""

$runNow = Read-Host "Would you like to run the simple version now? (y/n)"
if ($runNow -eq 'y' -or $runNow -eq 'Y') {
    Write-Host ""
    Write-Host "Starting SpotiVisualizer (Simple Version)..." -ForegroundColor Green
    flutter run -d windows -t lib/main_simple.dart
}