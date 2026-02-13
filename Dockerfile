FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (baked in)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Rename base image's start.sh, replace with ours that downloads models first
RUN mv /start.sh /start_original.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
