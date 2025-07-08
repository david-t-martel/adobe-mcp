# Adobe MCP Test Runner for PowerShell
Write-Host "Adobe MCP Test Runner" -ForegroundColor Cyan
Write-Host "====================" -ForegroundColor Cyan
Write-Host ""

# Check virtual environment
if (-not (Test-Path ".venv")) {
    Write-Host "Virtual environment not found. Running install.ps1..." -ForegroundColor Yellow
    & .\install.ps1
}

# Activate virtual environment
$activateScript = ".\.venv\Scripts\Activate.ps1"
if (Test-Path $activateScript) {
    & $activateScript
} else {
    Write-Host "ERROR: Virtual environment not found." -ForegroundColor Red
    exit 1
}

# Install test dependencies
Write-Host "Installing test dependencies..." -ForegroundColor Yellow
python -m pip install -r requirements-test.txt

# Create test output directory
$testDir = Join-Path $env:USERPROFILE "Documents\Adobe_MCP_Tests"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir -Force | Out-Null
}
Write-Host "Test outputs will be saved to: $testDir" -ForegroundColor Yellow

# Run tests
Write-Host ""
if ($args -contains "manual") {
    Write-Host "Running manual Illustrator test..." -ForegroundColor Green
    python tests/test_illustrator.py
} else {
    Write-Host "Running Illustrator integration tests..." -ForegroundColor Green
    python -m pytest tests/test_illustrator.py -v
}

Write-Host ""
Write-Host "Test run complete." -ForegroundColor Green
Read-Host "Press Enter to continue"