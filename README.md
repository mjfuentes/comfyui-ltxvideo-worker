# AI Video Transitions — RunPod Serverless ComfyUI

Generate image-to-video transitions using LTX-Video on RunPod's serverless GPU infrastructure.

## Architecture

- **RunPod Serverless Endpoint** (`plpbyovrzzg5t2`)
- **Docker Image:** `runpod/worker-comfyui:5.7.1-base`
- **GPU:** AMPERE_24 (RTX 4090 / RTX 3090 — 24GB VRAM)
- **Scaling:** 0 min → 1 max workers, 5s idle timeout (scale-to-zero)
- **ComfyUI workflow** sends two frames + prompt, outputs video

## ⚠️ IMPORTANT: Cold Start & Model Setup

The base Docker image has **NO models installed**. The first cold start will be **very slow** (potentially 10-20+ minutes) because:

1. The ComfyUI-LTXVideo custom node needs to install
2. LTX-Video model weights (~3.5GB) need to download
3. T5-XXL text encoder (~9GB) needs to download
4. LTX VAE needs to download

### Recommended: Custom Docker Image (for production)

Create a `Dockerfile` to bake in models:

```dockerfile
FROM runpod/worker-comfyui:5.7.1-base

# Install LTX-Video custom nodes
RUN comfy-node-install comfyui-ltxvideo comfyui-videohelpersuite

# Download LTX-Video model
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
```

Build & push: `docker build --platform linux/amd64 -t yourdockerhub/ltxvideo-worker:1.0 .`  
Then update the template on RunPod to use your custom image.

### Alternative: Network Volume

1. Create a Network Volume in RunPod (~20GB)
2. Spin up a temporary pod, download models to `/runpod-volume/models/`
3. Attach the volume to the serverless endpoint

## Usage

```bash
# Set API key
export RUNPOD_API_KEY="your_runpod_api_key"

# Generate transition
./run_transition.sh frame_start.png frame_end.png "smooth zoom transition" ./output/
```

### Script Arguments

| Arg | Required | Description |
|-----|----------|-------------|
| `frame_start` | ✅ | Path to starting frame image |
| `frame_end` | ✅ | Path to ending frame image |
| `prompt` | ❌ | Transition description (default: cinematic transition) |
| `output_dir` | ❌ | Output directory (default: current dir) |

## API Direct Usage

```bash
curl -X POST "https://api.runpod.ai/v2/plpbyovrzzg5t2/runsync" \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "workflow": <contents of workflow.json>,
      "images": [
        {"name": "frame_start.png", "image": "data:image/png;base64,..."},
        {"name": "frame_end.png", "image": "data:image/png;base64,..."}
      ]
    }
  }'
```

## Costs

- **GPU:** ~$0.00031/sec (~$1.12/hr) for AMPERE_24
- **Idle:** $0 (scales to zero after 5s idle)
- **Per transition:** ~$0.02-0.10 depending on video length and generation time
- **Cold start penalty:** First request after idle pays for startup time (~30-120s with baked models, 10-20min with base image)

## Files

| File | Description |
|------|-------------|
| `workflow.json` | ComfyUI API workflow for LTX-Video img2vid transition |
| `run_transition.sh` | Automation script: encode frames → submit → poll → download |
| `endpoint_config.json` | RunPod endpoint/template IDs and settings |
| `README.md` | This file |

## Workflow Details

The workflow:
1. Loads two input images (start frame, end frame)
2. Scales them to 768×1344 (vertical, close to 9:16 ratio)
3. Encodes start frame through LTX VAE
4. Runs KSampler with LTX-Video model to generate video latents
5. Decodes latents through VAE
6. Combines frames into H.264 MP4 video at 24fps

**Note:** The current workflow uses the start frame as the initial latent and generates forward. True two-frame interpolation (start→end) would require a more complex workflow with frame conditioning at both ends, which LTX-Video supports via its image conditioning features. The workflow can be refined once the endpoint is tested.

## Troubleshooting

- **"Worker not found"**: Endpoint is scaling up from zero. Wait and retry.
- **Timeout**: Cold start can be slow. Use `/run` (async) instead of `/runsync`.
- **Missing models**: Check that custom nodes and models are properly installed.
- **OOM errors**: Reduce resolution or video length in workflow.json.
