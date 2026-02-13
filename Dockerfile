FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (baked in)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Ensure curl is available and copy startup script
RUN apt-get update && apt-get install -y --no-install-recommends curl wget && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
