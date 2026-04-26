#!/bin/bash
# ============================================
# helperAI v0.0.1 - Server Launcher (Linux/macOS)
# ============================================

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="$ROOT/bin"
MODELS="$ROOT/models"
PORT=8080

# Verify setup
if [ ! -f "$BIN/llama-server" ]; then
    echo "ERROR: llama-server not found in $BIN"
    echo "Run ./setup.sh first."
    exit 1
fi

if [ -z "$(ls -A "$MODELS"/*.gguf 2>/dev/null)" ]; then
    echo "ERROR: No .gguf model in $MODELS"
    echo "Run ./setup.sh first or place a .gguf file in models/"
    exit 1
fi

echo "============================================"
echo "  helperAI v0.0.1"
echo "============================================"
echo "  Bin    : $BIN"
echo "  Models : $MODELS"
echo "  URL    : http://127.0.0.1:$PORT"
echo

# Open browser after 5 seconds (background)
(sleep 5 && (
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "http://127.0.0.1:$PORT"
    elif command -v open >/dev/null 2>&1; then
        open "http://127.0.0.1:$PORT"
    fi
) >/dev/null 2>&1) &

# Start server
cd "$BIN"
./llama-server \
    --models-dir "$MODELS" \
    -c 32768 \
    -ngl 99 \
    --host 0.0.0.0 \
    --port $PORT \
    -fa on
