#!/bin/bash
# ============================================
# helperAI Setup Script (Linux / macOS)
# - Downloads llama.cpp binaries for current OS
# - Downloads default model
# ============================================

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="$ROOT/bin"
MODELS="$ROOT/models"

LLAMA_VERSION="b6995"

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)
        if [ "$ARCH" = "x86_64" ]; then
            LLAMA_ASSET="llama-${LLAMA_VERSION}-bin-ubuntu-vulkan-x64.zip"
        else
            echo "Unsupported Linux architecture: $ARCH"
            exit 1
        fi
        ;;
    Darwin)
        if [ "$ARCH" = "arm64" ]; then
            LLAMA_ASSET="llama-${LLAMA_VERSION}-bin-macos-arm64.zip"
        else
            LLAMA_ASSET="llama-${LLAMA_VERSION}-bin-macos-x64.zip"
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

LLAMA_URL="https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_VERSION}/${LLAMA_ASSET}"

# Default model
MODEL_NAME="Qwen_Qwen3-8B-Q5_K_M.gguf"
MODEL_URL="https://huggingface.co/bartowski/Qwen_Qwen3-8B-GGUF/resolve/main/${MODEL_NAME}"

echo "============================================"
echo "  helperAI Setup ($OS $ARCH)"
echo "============================================"
echo

# Step 1: Download llama.cpp binaries
if [ -f "$BIN/llama-server" ]; then
    echo "[1/2] llama-server already exists, skipping download."
else
    echo "[1/2] Downloading llama.cpp ${LLAMA_VERSION}..."
    mkdir -p "$ROOT/temp"
    curl -L -o "$ROOT/temp/llama.zip" "$LLAMA_URL"
    echo "Extracting..."
    mkdir -p "$BIN"
    unzip -o "$ROOT/temp/llama.zip" -d "$ROOT/temp/extracted"

    # llama.cpp release zip layout: bin/* directly or under build/bin/*
    if [ -d "$ROOT/temp/extracted/build/bin" ]; then
        cp -r "$ROOT/temp/extracted/build/bin/"* "$BIN/"
    elif [ -d "$ROOT/temp/extracted/bin" ]; then
        cp -r "$ROOT/temp/extracted/bin/"* "$BIN/"
    else
        cp -r "$ROOT/temp/extracted/"* "$BIN/"
    fi

    chmod +x "$BIN/llama-server" 2>/dev/null || true
    chmod +x "$BIN/llama-cli" 2>/dev/null || true

    rm -rf "$ROOT/temp"
    echo "Done."
fi
echo

# Step 2: Download default model
mkdir -p "$MODELS"
if [ -f "$MODELS/$MODEL_NAME" ]; then
    echo "[2/2] Model already exists, skipping download."
else
    echo "[2/2] Downloading model: $MODEL_NAME (~6 GB)..."
    echo "This may take a while depending on your connection."
    curl -L -o "$MODELS/$MODEL_NAME" "$MODEL_URL"
fi
echo

echo "============================================"
echo "  Setup complete!"
echo "============================================"
echo "  Run ./start.sh to launch the server."
echo
