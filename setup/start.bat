@echo off
setlocal
:: ============================================
:: helperAI v0.0.1 - Server Launcher (Windows)
:: ============================================

set "ROOT=%~dp0"
set "BIN=%ROOT%bin"
set "MODELS=%ROOT%models"
set "PORT=8080"

:: Verify setup
if not exist "%BIN%\llama-server.exe" (
    echo ERROR: llama-server.exe not found in %BIN%
    echo Run setup.bat first.
    pause
    exit /b 1
)

dir /b "%MODELS%\*.gguf" >nul 2>&1
if errorlevel 1 (
    echo ERROR: No .gguf model in %MODELS%
    echo Run setup.bat first or place a .gguf file in models\
    pause
    exit /b 1
)

echo ============================================
echo   helperAI v0.0.1
echo ============================================
echo   Bin    : %BIN%
echo   Models : %MODELS%
echo   URL    : http://127.0.0.1:%PORT%
echo.

cd /d "%BIN%"

:: Open browser after 5 seconds
start "" /min cmd /c "timeout /t 5 /nobreak >nul && start http://127.0.0.1:%PORT%"

llama-server.exe --models-dir "%MODELS%" -c 32768 -ngl 99 --host 0.0.0.0 --port %PORT% -fa on

pause
