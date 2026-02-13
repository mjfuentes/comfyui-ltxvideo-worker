FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes via git clone (not in comfy registry)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-LTXVideo && pip install -r requirements.txt 2>/dev/null || true && \
    cd ../ComfyUI-VideoHelperSuite && pip install -r requirements.txt 2>/dev/null || true

# Rename base image's start.sh, replace with ours that downloads models first
RUN mv /start.sh /start_original.sh
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
