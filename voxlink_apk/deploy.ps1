# VoxLink Deployment Script
# Run this script to push the code to your GitHub repository.

Write-Host "🚀 Initializing VoxLink Deployment..." -ForegroundColor Cyan

# 1. Initialize Git if not already
if (!(Test-Path .git)) {
    git init
    Write-Host "✅ Git initialized." -ForegroundColor Green
}

# 2. Add Remote
$remoteUrl = "https://github.com/bhoitesumit61-stack/VC-APK.git"
git remote remove origin 2>$null
git remote add origin $remoteUrl
Write-Host "✅ Remote set to $remoteUrl" -ForegroundColor Green

# 3. Stage and Commit
git add .
git commit -m "Initial commit: VoxLink Premium APK with GitHub Actions"
Write-Host "✅ Files staged and committed." -ForegroundColor Green

# 4. Push to Main
Write-Host "📤 Pushing to GitHub (this may prompt for login)..." -ForegroundColor Yellow
git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "✨ SUCCESS! Your code is now on GitHub." -ForegroundColor Green
    Write-Host "Go to https://github.com/bhoitesumit61-stack/VC-APK/actions to see the build." -ForegroundColor Cyan
} else {
    Write-Host "❌ Push failed. Please ensure you are logged into Git and have permissions." -ForegroundColor Red
}
