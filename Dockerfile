FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (baked in)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite
