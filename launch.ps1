# Adobe MCP Server Launcher for PowerShell
Write-Host "Adobe MCP Server Launcher" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

# Check Python
try {
    python --version | Out-Null
} catch {
    Write-Host "ERROR: Python is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Detect Adobe installations
Write-Host "Detecting Adobe installations..." -ForegroundColor Yellow
python -m adobe_mcp.shared.adobe_detector 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Could not auto-detect Adobe applications" -ForegroundColor Yellow
    Write-Host "Please check config.windows.json manually" -ForegroundColor Yellow
}

# Check and activate virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "Virtual environment not found. Running install.ps1..." -ForegroundColor Yellow
    & .\install.ps1
    exit
}

# Activate virtual environment
$activateScript = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    & $activateScript
} else {
    Write-Host "ERROR: Virtual environment not found. Please run install.ps1 first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Verify activation
$pythonPath = (Get-Command python).Source
Write-Host "Using Python: $pythonPath" -ForegroundColor Gray

# Check Node.js
try {
    node --version | Out-Null
} catch {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Install proxy dependencies if needed
if (-not (Test-Path "proxy-server\node_modules")) {
    Write-Host "Installing proxy server dependencies..." -ForegroundColor Yellow
    Push-Location proxy-server
    npm install
    Pop-Location
}

# Menu function
function Show-Menu {
    Write-Host ""
    Write-Host "Select Adobe application:" -ForegroundColor Cyan
    Write-Host "1. Photoshop" -ForegroundColor White
    Write-Host "2. Premiere Pro" -ForegroundColor White
    Write-Host "3. Illustrator" -ForegroundColor White
    Write-Host "4. InDesign" -ForegroundColor White
    Write-Host "5. Proxy Server (run this first)" -ForegroundColor Yellow
    Write-Host "6. Run Tests" -ForegroundColor White
    Write-Host "0. Exit" -ForegroundColor White
    Write-Host ""
}

# Main loop
while ($true) {
    Show-Menu
    $choice = Read-Host "Enter your choice"
    
    switch ($choice) {
        "1" {
            Write-Host "Starting Photoshop MCP Server..." -ForegroundColor Green
            python -m adobe_mcp.photoshop
        }
        "2" {
            Write-Host "Starting Premiere Pro MCP Server..." -ForegroundColor Green
            python -m adobe_mcp.premiere
        }
        "3" {
            Write-Host "Starting Illustrator MCP Server..." -ForegroundColor Green
            python -m adobe_mcp.illustrator
        }
        "4" {
            Write-Host "Starting InDesign MCP Server..." -ForegroundColor Green
            python -m adobe_mcp.indesign
        }
        "5" {
            Write-Host "Starting Proxy Server..." -ForegroundColor Green
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd proxy-server; node proxy.js"
            Write-Host "Proxy server started in new window on port 3001" -ForegroundColor Green
        }
        "6" {
            Write-Host "Running tests..." -ForegroundColor Green
            python -m pytest tests/
        }
        "0" {
            Write-Host "Exiting..." -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
        }
    }
}