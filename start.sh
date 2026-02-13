#!/bin/bash
set -e

# Download models if not already present (supports network volume caching)
download_if_missing() {
    local path="$1"
    local url="$2"
    if [ ! -f "$path" ]; then
        echo "Downloading $(basename $path)..."
        wget -q --show-progress -O "$path" "$url"
        echo "Done: $(basename $path)"
    else
        echo "Already exists: $(basename $path)"
    fi
}

download_if_missing /comfyui/models/checkpoints/ltx-video-2b-v0.9.1.safetensors \
    https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.1.safetensors

download_if_missing /comfyui/models/clip/t5xxl_fp16.safetensors \
    https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors

download_if_missing /comfyui/models/vae/ltxv_vae.safetensors \
    https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv_vae.safetensors

echo "All models ready. Starting worker..."

# Start the default ComfyUI worker entrypoint
exec /entrypoint.sh
