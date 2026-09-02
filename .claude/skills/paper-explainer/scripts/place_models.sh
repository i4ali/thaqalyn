#!/bin/zsh
# Move downloaded Wan 2.2 files into ComfyUI's model folders (run once after download completes).
set -e
cd "${COMFYUI_DIR:-$HOME/Documents/development/ComfyUI}"
D=models/_wan_dl/split_files
for f in diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors \
         text_encoders/umt5_xxl_fp16.safetensors vae/wan_2.1_vae.safetensors \
         loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors; do
  [ -f "$D/$f" ] || { echo "MISSING $f"; exit 1; }
  mkdir -p "models/$(dirname $f)"; mv -n "$D/$f" "models/$f"
done
rm -rf models/_wan_dl
ls -la models/diffusion_models models/text_encoders models/vae models/loras
