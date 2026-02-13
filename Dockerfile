FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (baked in)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Download models at startup via custom entrypoint
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
