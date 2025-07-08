@echo off
echo Adobe MCP Server Launcher for Windows
echo =====================================

:: Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    exit /b 1
)

:: Detect Adobe installations
echo Detecting Adobe installations...
python -m adobe_mcp.shared.adobe_detector 2>nul
if errorlevel 1 (
    echo WARNING: Could not auto-detect Adobe applications
    echo Please check config.windows.json manually
)

:: Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

:: Activate virtual environment
if exist ".venv\Scripts\activate.bat" (
    call .venv\Scripts\activate.bat
) else (
    echo ERROR: Virtual environment not found. Please run install.bat first.
    pause
    exit /b 1
)

:: Verify we're in venv by checking python location
where python | findstr /i "\.venv" >nul
if errorlevel 1 (
    echo ERROR: Virtual environment not activated properly
    echo Please ensure .venv exists and try again
    pause
    exit /b 1
)

:: Install dependencies if needed
python -m pip show fastmcp >nul 2>&1
if errorlevel 1 (
    echo Installing dependencies...
    python -m pip install -r requirements.txt
)

:: Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not in PATH
    exit /b 1
)

:: Install proxy server dependencies
cd proxy-server
if not exist "node_modules" (
    echo Installing proxy server dependencies...
    npm install
)
cd ..

:: Menu
:menu
echo.
echo Select Adobe application:
echo 1. Photoshop
echo 2. Premiere Pro
echo 3. Illustrator
echo 4. InDesign
echo 5. Proxy Server (run this first)
echo 6. Run Tests
echo 0. Exit
echo.
set /p choice="Enter your choice: "

if "%choice%"=="1" goto photoshop
if "%choice%"=="2" goto premiere
if "%choice%"=="3" goto illustrator
if "%choice%"=="4" goto indesign
if "%choice%"=="5" goto proxy
if "%choice%"=="6" goto tests
if "%choice%"=="0" goto end

echo Invalid choice. Please try again.
goto menu

:photoshop
echo Starting Photoshop MCP Server...
python -m adobe_mcp.photoshop
goto menu

:premiere
echo Starting Premiere Pro MCP Server...
python -m adobe_mcp.premiere
goto menu

:illustrator
echo Starting Illustrator MCP Server...
python -m adobe_mcp.illustrator
goto menu

:indesign
echo Starting InDesign MCP Server...
python -m adobe_mcp.indesign
goto menu

:proxy
echo Starting Proxy Server...
start cmd /k "cd proxy-server && node proxy.js"
echo Proxy server started in new window on port 3001
goto menu

:tests
echo Running tests...
python -m pytest tests/
goto menu

:end
echo Exiting...
deactivate