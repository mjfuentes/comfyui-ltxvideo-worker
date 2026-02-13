FROM runpod/worker-comfyui:5.7.1-base

# Install custom nodes
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Download LTX-Video checkpoint
RUN comfy model download \
  --url https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltx-video-2b-v0.9.1.safetensors \
  --relative-path models/checkpoints \
  --filename ltx-video-2b-v0.9.1.safetensors

# Download T5-XXL text encoder
RUN comfy model download \
  --url https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors \
  --relative-path models/clip \
  --filename t5xxl_fp16.safetensors

# Download LTX VAE
RUN comfy model download \
  --url https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv_vae.safetensors \
  --relative-path models/vae \
  --filename ltxv_vae.safetensors
