@echo off
setlocal enabledelayedexpansion

:: ============================================
:: helperAI Setup Script (Windows)
:: - Downloads llama.cpp Vulkan binaries
:: - Downloads default model
:: ============================================

set "ROOT=%~dp0"
set "BIN=%ROOT%bin"
set "MODELS=%ROOT%models"

:: llama.cpp release version (Vulkan build for portability)
set "LLAMA_VERSION=b6995"
set "LLAMA_ASSET=llama-%LLAMA_VERSION%-bin-win-vulkan-x64.zip"
set "LLAMA_URL=https://github.com/ggml-org/llama.cpp/releases/download/%LLAMA_VERSION%/%LLAMA_ASSET%"

:: Default model
set "MODEL_NAME=Qwen_Qwen3-8B-Q5_K_M.gguf"
set "MODEL_URL=https://huggingface.co/bartowski/Qwen_Qwen3-8B-GGUF/resolve/main/%MODEL_NAME%"

echo ============================================
echo   helperAI Setup (Windows)
echo ============================================
echo.

:: Step 1: Download llama.cpp binaries
if exist "%BIN%\llama-server.exe" (
    echo [1/2] llama-server already exists, skipping download.
) else (
    echo [1/2] Downloading llama.cpp %LLAMA_VERSION% (Vulkan)...
    if not exist "%ROOT%temp" mkdir "%ROOT%temp"
    powershell -Command "Invoke-WebRequest -Uri '%LLAMA_URL%' -OutFile '%ROOT%temp\llama.zip'"
    if errorlevel 1 (
        echo ERROR: Download failed. Check your internet connection.
        pause
        exit /b 1
    )
    echo Extracting...
    powershell -Command "Expand-Archive -Path '%ROOT%temp\llama.zip' -DestinationPath '%ROOT%temp\extracted' -Force"
    if not exist "%BIN%" mkdir "%BIN%"
    xcopy /Y /E "%ROOT%temp\extracted\*" "%BIN%\" >nul
    rmdir /S /Q "%ROOT%temp"
    echo Done.
)
echo.

:: Step 2: Download default model
if not exist "%MODELS%" mkdir "%MODELS%"
if exist "%MODELS%\%MODEL_NAME%" (
    echo [2/2] Model already exists, skipping download.
) else (
    echo [2/2] Downloading model: %MODEL_NAME% (~6 GB)...
    echo This may take a while depending on your connection.
    powershell -Command "Invoke-WebRequest -Uri '%MODEL_URL%' -OutFile '%MODELS%\%MODEL_NAME%'"
    if errorlevel 1 (
        echo ERROR: Model download failed.
        pause
        exit /b 1
    )
)
echo.

echo ============================================
echo   Setup complete!
echo ============================================
echo   Run start.bat to launch the server.
echo.
pause
