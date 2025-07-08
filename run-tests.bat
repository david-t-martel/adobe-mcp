@echo off
echo Adobe MCP Test Runner
echo ====================

:: Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

:: Activate virtual environment with full path
call "%CD%\.venv\Scripts\activate.bat"

:: Install test dependencies
echo Installing test dependencies...
python -m pip install --upgrade pip >nul 2>&1
python -m pip install -r requirements-test.txt

:: Create test output directory in Documents
set TEST_DIR=%USERPROFILE%\Documents\Adobe_MCP_Tests
if not exist "%TEST_DIR%" mkdir "%TEST_DIR%"
echo Test outputs will be saved to: %TEST_DIR%

:: Run the tests
echo.
echo Running Illustrator integration tests...
python -m pytest tests/test_illustrator.py -v

:: Run manual test if requested
if "%1"=="manual" (
    echo.
    echo Running manual Illustrator test...
    python tests/test_illustrator.py
)

echo.
echo Test run complete.
pause