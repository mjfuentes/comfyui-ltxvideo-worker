#!/bin/bash
set -e

download_if_missing() {
    local path="$1"
    local url="$2"
    if [ ! -f "$path" ]; then
        echo "[start.sh] Downloading $(basename $path)..."
        wget -q -O "$path" "$url"
        echo "[start.sh] Done: $(basename $path)"
    else
        echo "[start.sh] Already exists: $(basename $path)"
    fi
}

# Model v0.9.5 (checkpoint includes VAE)
download_if_missing /comfyui/models/checkpoints/ltx-video-2b-v0.9.5.safetensors \
    "https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.5.safetensors"

# T5 text encoder - goes in text_encoders/ not clip/
mkdir -p /comfyui/models/text_encoders
download_if_missing /comfyui/models/text_encoders/t5xxl_fp16.safetensors \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"

echo "[start.sh] All models ready. Starting worker..."
exec /start_original.sh "$@"
