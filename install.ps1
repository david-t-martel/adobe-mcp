# Adobe MCP Installation Script for PowerShell
Write-Host "Adobe MCP Installation Script" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

# Check Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "Found Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Python 3.10 or later from python.org" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Node.js
try {
    $nodeVersion = node --version 2>&1
    Write-Host "Found Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js 18 or later from nodejs.org" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Dependencies OK!" -ForegroundColor Green
Write-Host ""

# Create virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "Creating Python virtual environment..." -ForegroundColor Yellow
    python -m venv .venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Trying alternative venv creation..." -ForegroundColor Yellow
        python -m venv --system-site-packages .venv
    }
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Yellow
$activateScript = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    & $activateScript
} else {
    Write-Host "ERROR: Virtual environment activation script not found" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify activation
$pythonPath = (Get-Command python).Source
if ($pythonPath -notlike "*\.venv\*") {
    Write-Host "WARNING: Virtual environment may not be activated properly" -ForegroundColor Yellow
    Write-Host "Python path: $pythonPath" -ForegroundColor Yellow
}

# Ensure pip
Write-Host "Ensuring pip is installed..." -ForegroundColor Yellow
python -m ensurepip --default-pip 2>$null
python -m pip install --upgrade pip

# Install Python dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
python -m pip install -r requirements.txt

# Install Node.js dependencies
Write-Host ""
Write-Host "Installing Node.js dependencies for proxy server..." -ForegroundColor Yellow
Push-Location proxy-server
npm install
Pop-Location

# Detect Adobe installations
Write-Host ""
Write-Host "Detecting Adobe installations..." -ForegroundColor Yellow
python -m adobe_mcp.shared.adobe_detector 2>$null

if (Test-Path "config.windows.json") {
    Write-Host "Configuration saved to config.windows.json" -ForegroundColor Green
} else {
    Write-Host "WARNING: Could not auto-detect Adobe applications" -ForegroundColor Yellow
    Write-Host "You may need to create config.windows.json manually" -ForegroundColor Yellow
}

# Create test output directory
$testDir = Join-Path $env:USERPROFILE "Documents\Adobe_MCP_Tests"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run .\launch.ps1 to start servers" -ForegroundColor White
Write-Host "2. Install UXP plugins via Adobe UXP Developer Tools" -ForegroundColor White
Write-Host "3. Run .\run-tests.ps1 to test the integration" -ForegroundColor White
Write-Host ""
Write-Host "Test outputs will be saved to: $testDir" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Green
Read-Host "Press Enter to continue"