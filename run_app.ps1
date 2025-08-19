Write-Host "Starting SpotiVisualizer..." -ForegroundColor Green
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "- Flutter installed and in PATH" -ForegroundColor White
Write-Host "- Spotify Premium account" -ForegroundColor White
Write-Host "- Internet connection" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Press Enter to continue or 'q' to quit"
if ($continue -eq 'q') {
    exit
}

Write-Host "Launching application..." -ForegroundColor Green
flutter run -d windows

Write-Host ""
Write-Host "Application closed. Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")