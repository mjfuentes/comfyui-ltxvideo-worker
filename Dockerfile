FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes (small, fine to bake in)
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Download models at startup instead of baking them in
# This keeps the image small enough for RunPod's GitHub builder
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
