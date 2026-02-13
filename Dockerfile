FROM runpod/worker-comfyui:5.7.1-base

# No custom nodes needed - LTX-Video v0.9.x nodes are built into ComfyUI
# Only need model downloads at startup

RUN mv /start.sh /start_original.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
