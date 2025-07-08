@echo off
echo Adobe MCP Installation Script
echo =============================
echo.

:: Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.10 or later from python.org
    pause
    exit /b 1
)

:: Check Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    echo Please install Node.js 18 or later from nodejs.org
    pause
    exit /b 1
)

echo Dependencies OK!
echo.

:: Create virtual environment
if not exist ".venv" (
    echo Creating Python virtual environment...
    python -m venv .venv
    if errorlevel 1 (
        echo ERROR: Failed to create virtual environment
        echo Trying with --without-pip option...
        python -m venv --without-pip .venv
    )
)

:: Activate it
echo Activating virtual environment...
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
) else (
    echo ERROR: Virtual environment activation script not found
    pause
    exit /b 1
)

:: Ensure pip is installed
echo Checking pip installation...
python -m ensurepip --default-pip 2>nul
if errorlevel 1 (
    echo Installing pip manually...
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    del get-pip.py
)

:: Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

:: Install from requirements.txt instead of pyproject.toml
echo Installing Python dependencies...
python -m pip install -r requirements.txt

:: Install Node.js dependencies
echo.
echo Installing Node.js dependencies for proxy server...
cd proxy-server
call npm install
cd ..

:: Detect Adobe installations
echo.
echo Detecting Adobe installations...
python -m adobe_mcp.shared.adobe_detector 2>nul
if exist "config.windows.json" (
    echo Configuration saved to config.windows.json
) else (
    echo WARNING: Could not auto-detect Adobe applications
    echo You may need to create config.windows.json manually
)

:: Create test output directory
set TEST_DIR=%USERPROFILE%\Documents\Adobe_MCP_Tests
if not exist "%TEST_DIR%" mkdir "%TEST_DIR%"

echo.
echo ================================
echo Installation complete!
echo.
echo Next steps:
echo 1. Run launch-windows.bat to start servers
echo 2. Install UXP plugins via Adobe UXP Developer Tools
echo 3. Run run-tests.bat to test the integration
echo.
echo Test outputs will be saved to: %TEST_DIR%
echo ================================
pause