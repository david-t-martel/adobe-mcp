# Environment Check Script for Adobe MCP
Write-Host "Adobe MCP Environment Check" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan
Write-Host ""

# Check Python
Write-Host "Python Check:" -ForegroundColor Yellow
try {
    $pythonPath = (Get-Command python -ErrorAction Stop).Source
    $pythonVersion = python --version 2>&1
    Write-Host "  ✓ Python found: $pythonVersion" -ForegroundColor Green
    Write-Host "  Path: $pythonPath" -ForegroundColor Gray
    
    # Check if it's MSYS/MinGW Python
    if ($pythonPath -like "*msys*" -or $pythonPath -like "*mingw*") {
        Write-Host "  ⚠ Warning: Using MSYS/MinGW Python. Native Windows Python recommended." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Python not found in PATH" -ForegroundColor Red
}

# Check Node.js
Write-Host ""
Write-Host "Node.js Check:" -ForegroundColor Yellow
try {
    $nodePath = (Get-Command node -ErrorAction Stop).Source
    $nodeVersion = node --version 2>&1
    Write-Host "  ✓ Node.js found: $nodeVersion" -ForegroundColor Green
    Write-Host "  Path: $nodePath" -ForegroundColor Gray
} catch {
    Write-Host "  ✗ Node.js not found in PATH" -ForegroundColor Red
}

# Check virtual environment
Write-Host ""
Write-Host "Virtual Environment Check:" -ForegroundColor Yellow
if (Test-Path ".venv") {
    Write-Host "  ✓ Virtual environment exists" -ForegroundColor Green
    
    # Check if we can activate it
    if (Test-Path ".\.venv\Scripts\Activate.ps1") {
        Write-Host "  ✓ Activation script found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Activation script not found" -ForegroundColor Red
    }
    
    # Check if activated
    if ($env:VIRTUAL_ENV) {
        Write-Host "  ✓ Virtual environment is active" -ForegroundColor Green
        Write-Host "  Path: $env:VIRTUAL_ENV" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠ Virtual environment not currently active" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✗ Virtual environment not found (.venv directory missing)" -ForegroundColor Red
    Write-Host "  Run .\install.ps1 to create it" -ForegroundColor Yellow
}

# Check config file
Write-Host ""
Write-Host "Configuration Check:" -ForegroundColor Yellow
if (Test-Path "config.windows.json") {
    Write-Host "  ✓ config.windows.json exists" -ForegroundColor Green
    
    # Try to read and parse it
    try {
        $config = Get-Content "config.windows.json" | ConvertFrom-Json
        if ($config.adobePaths) {
            foreach ($app in $config.adobePaths.PSObject.Properties) {
                if ($app.Value) {
                    Write-Host "  ✓ $($app.Name): $($app.Value)" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠ $($app.Name): Not found" -ForegroundColor Yellow
                }
            }
        }
    } catch {
        Write-Host "  ✗ Error reading config file" -ForegroundColor Red
    }
} else {
    Write-Host "  ✗ config.windows.json not found" -ForegroundColor Red
}

# Check test directory
Write-Host ""
Write-Host "Test Directory Check:" -ForegroundColor Yellow
$testDir = Join-Path $env:USERPROFILE "Documents\Adobe_MCP_Tests"
if (Test-Path $testDir) {
    Write-Host "  ✓ Test directory exists: $testDir" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Test directory will be created at: $testDir" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Recommendations:" -ForegroundColor Cyan
if (-not (Test-Path ".venv")) {
    Write-Host "1. Run .\install.ps1 to set up the environment" -ForegroundColor White
}
if (-not $env:VIRTUAL_ENV) {
    Write-Host "2. Activate the virtual environment with: .\.venv\Scripts\Activate.ps1" -ForegroundColor White
}
Write-Host ""
Read-Host "Press Enter to continue"