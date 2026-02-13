FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Download models with wget (comfy model download requires git)
RUN wget -q --show-progress -O /comfyui/models/checkpoints/ltx-video-2b-v0.9.1.safetensors \
  https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.1.safetensors

RUN wget -q --show-progress -O /comfyui/models/clip/t5xxl_fp16.safetensors \
  https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors

RUN wget -q --show-progress -O /comfyui/models/vae/ltxv_vae.safetensors \
  https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv_vae.safetensors
