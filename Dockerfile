FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (small, ~100MB total)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Startup script downloads models on first boot
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
