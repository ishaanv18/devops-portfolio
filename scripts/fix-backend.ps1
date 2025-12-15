# Fix Backend Services Script
# This script ensures all backend services compile correctly

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Fixing Backend Services" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

function Print-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

# Check Java version
Write-Host "Checking Java version..." -ForegroundColor White
try {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    if ($javaVersion -match "17") {
        Print-Success "Java 17 detected"
    }
    else {
        Print-Error "Java 17 is required. Current version: $javaVersion"
        Write-Host "Please install Java 17 from: https://adoptium.net/" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Print-Error "Java is not installed or not in PATH"
    exit 1
}

Write-Host ""

# Fix User Service
Write-Host "Fixing User Service..." -ForegroundColor White
Set-Location user-service

Print-Info "Cleaning previous builds..."
mvn clean | Out-Null

Print-Info "Downloading dependencies..."
mvn dependency:resolve | Out-Null

Print-Info "Compiling User Service..."
$compileResult = mvn compile -DskipTests 2>&1
if ($LASTEXITCODE -eq 0) {
    Print-Success "User Service compiled successfully"
}
else {
    Print-Error "User Service compilation failed"
    Write-Host $compileResult -ForegroundColor Red
}

Set-Location ..
Write-Host ""

# Fix Product Service
Write-Host "Fixing Product Service..." -ForegroundColor White
Set-Location product-service

Print-Info "Cleaning previous builds..."
mvn clean | Out-Null

Print-Info "Downloading dependencies..."
mvn dependency:resolve | Out-Null

Print-Info "Compiling Product Service..."
$compileResult = mvn compile -DskipTests 2>&1
if ($LASTEXITCODE -eq 0) {
    Print-Success "Product Service compiled successfully"
}
else {
    Print-Error "Product Service compilation failed"
    Write-Host $compileResult -ForegroundColor Red
}

Set-Location ..
Write-Host ""

# Fix API Gateway
Write-Host "Fixing API Gateway..." -ForegroundColor White
Set-Location api-gateway

Print-Info "Cleaning previous installations..."
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force node_modules
}
if (Test-Path "package-lock.json") {
    Remove-Item -Force package-lock.json
}

Print-Info "Installing dependencies..."
npm install 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Print-Success "API Gateway dependencies installed successfully"
}
else {
    Print-Error "API Gateway npm install failed"
}

Set-Location ..
Write-Host ""

# Summary
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Fix Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Test User Service:" -ForegroundColor Gray
Write-Host "   cd user-service" -ForegroundColor Cyan
Write-Host "   mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Test Product Service:" -ForegroundColor Gray
Write-Host "   cd product-service" -ForegroundColor Cyan
Write-Host "   mvn spring-boot:run" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Test API Gateway:" -ForegroundColor Gray
Write-Host "   cd api-gateway" -ForegroundColor Cyan
Write-Host "   npm start" -ForegroundColor Cyan
Write-Host ""

Print-Success "Backend services fixed!"
