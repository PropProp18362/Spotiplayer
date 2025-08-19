# Build script for SpotiVisualizer web version

Write-Host "🚀 Building SpotiVisualizer for web..." -ForegroundColor Cyan

# Ensure Flutter is configured for web
flutter config --enable-web

# Clean previous builds
Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build web version
Write-Host "🔨 Building web version..." -ForegroundColor Yellow
flutter build web --release

# Check if build was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host "📁 Output directory: $(Resolve-Path "build\web")" -ForegroundColor Green
    
    # Instructions for deployment
    Write-Host "`n📝 Deployment Instructions:" -ForegroundColor Cyan
    Write-Host "1. To deploy to Vercel, run: vercel" -ForegroundColor White
    Write-Host "2. To test locally, run: flutter run -d chrome" -ForegroundColor White
    Write-Host "3. Remember to update the redirect URI in Spotify Developer Dashboard to:" -ForegroundColor White
    Write-Host "   https://your-vercel-domain.vercel.app/auth/callback" -ForegroundColor Yellow
} else {
    Write-Host "❌ Build failed!" -ForegroundColor Red
}