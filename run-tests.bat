@echo off
echo Adobe MCP Test Runner
echo ====================

:: Ensure we're in the virtual environment
if not exist ".venv" (
    echo ERROR: Virtual environment not found. Run launch-windows.bat first.
    exit /b 1
)

call .venv\Scripts\activate

:: Install test dependencies
pip install -r requirements-test.txt >nul 2>&1

:: Create temp directory for test outputs
if not exist "C:\Temp" mkdir C:\Temp

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