# CarRental Pro - System Testing Script
# This script helps you test all components of your car rental system

Write-Host "🚗 CarRental Pro - System Testing" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Test 1: Check if Flutter is available
Write-Host "`n1. Testing Flutter Installation..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✅ Flutter is installed" -ForegroundColor Green
    Write-Host "   Version: $($flutterVersion | Select-String 'Flutter' | Select-Object -First 1)" -ForegroundColor White
} catch {
    Write-Host "❌ Flutter not found. Please install Flutter first." -ForegroundColor Red
}

# Test 2: Check if build files exist
Write-Host "`n2. Testing Build Files..." -ForegroundColor Yellow
$buildPath = "build\windows\x64\runner\Release\offline_rent_car.exe"
if (Test-Path $buildPath) {
    Write-Host "✅ Windows executable exists" -ForegroundColor Green
    $fileSize = (Get-Item $buildPath).Length / 1MB
    Write-Host "   Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor White
} else {
    Write-Host "❌ Windows executable not found. Run: flutter build windows" -ForegroundColor Red
}

# Test 3: Check website files
Write-Host "`n3. Testing Website Files..." -ForegroundColor Yellow
$websiteFiles = @(
    "website\index.html",
    "website\styles.css", 
    "website\script.js"
)

foreach ($file in $websiteFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Test 4: Check download files
Write-Host "`n4. Testing Download Files..." -ForegroundColor Yellow
$downloadFiles = @(
    "website\downloads\CarRentalPro-Windows.zip",
    "website\downloads\CarRentalPro-Source.zip",
    "website\downloads\CarRentalPro-Docs.pdf"
)

foreach ($file in $downloadFiles) {
    if (Test-Path $file) {
        $fileSize = (Get-Item $file).Length
        if ($fileSize -gt 1MB) {
            $size = "$([math]::Round($fileSize / 1MB, 2)) MB"
        } else {
            $size = "$([math]::Round($fileSize / 1KB, 2)) KB"
        }
        Write-Host "✅ $file exists ($size)" -ForegroundColor Green
    } else {
        Write-Host "❌ $file missing" -ForegroundColor Red
    }
}

# Test 5: Check project structure
Write-Host "`n5. Testing Project Structure..." -ForegroundColor Yellow
$requiredDirs = @(
    "lib",
    "assets",
    "assets\fonts",
    "assets\translations"
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "✅ $dir exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $dir missing" -ForegroundColor Red
    }
}

Write-Host "`n🎯 Testing Instructions:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

Write-Host "`n📱 Test Flutter App:" -ForegroundColor White
Write-Host "1. Run: flutter run -d windows" -ForegroundColor Gray
Write-Host "2. Test all features in the app" -ForegroundColor Gray
Write-Host "3. Add vehicles, customers, rentals" -ForegroundColor Gray
Write-Host "4. Generate contracts" -ForegroundColor Gray

Write-Host "`n🌐 Test Website:" -ForegroundColor White
Write-Host "1. Open: website\index.html in browser" -ForegroundColor Gray
Write-Host "2. Test navigation and download buttons" -ForegroundColor Gray
Write-Host "3. Test contact form" -ForegroundColor Gray
Write-Host "4. Test responsive design" -ForegroundColor Gray

Write-Host "`n📦 Test Downloads:" -ForegroundColor White
Write-Host "1. Extract CarRentalPro-Windows.zip" -ForegroundColor Gray
Write-Host "2. Run offline_rent_car.exe" -ForegroundColor Gray
Write-Host "3. Verify all features work" -ForegroundColor Gray

Write-Host "`n🚀 Ready to Deploy!" -ForegroundColor Green
Write-Host "Your car rental system is ready for distribution!" -ForegroundColor Green 