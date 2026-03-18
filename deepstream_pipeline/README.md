# Complete DeepStream 7.1 Pipeline for RF-DETR Nano

This repository contains an end-to-end production-ready pipeline for object detection using the RF-DETR Nano model, optimized for GPU inference via ONNX and TensorRT, deployed on NVIDIA DeepStream 7.1.

## Folder Structure

```
deepstream_pipeline/
├── configs/
│   ├── config_infer_primary.txt     # DeepStream primary GIE config
│   ├── deepstream_app_config.txt    # DeepStream app main pipeline config
│   └── labels.txt                   # COCO labels for 80 classes
├── models/
│   ├── rf_detr_nano.onnx            # Place exported ONNX model here
│   └── (TensorRT engines will be generated here)
└── parsers/
    └── (Custom parser code goes here if needed for output tensors)
```

---

## Step 1: Model Preparation (RF-DETR Nano -> ONNX)

**Architecture Context:**
RF-DETR (Receptive Field DETR) Nano is a lightweight transformer-based object detection model. It typically removes complex NMS logic at the end by outputting fixed bounding boxes and class scores directly via bipartite matching, making it efficient for real-time edge inference.

1. **Load Pretrained PyTorch Model and Export to ONNX**
Ensure you have the correct opset (usually opset=16 or 17 for DETR-based architectures in TensorRT 8.6+).

```python
import torch
# Assuming rf_detr is available in your environment
from models.rf_detr import build_model

# 1. Load PyTorch model
model = build_model(variant='nano')
model.load_state_dict(torch.load('rf_detr_nano.pth', map_location='cpu'))
model.eval()
model.cuda()

# 2. Define dummy input (Static batch size 1, 3 channels, 640x640 resolution)
dummy_input = torch.randn(1, 3, 640, 640).cuda()

# 3. Export to ONNX
# For DETR models, the output is typically (bboxes, scores)
torch.onnx.export(
    model,
    dummy_input,
    "deepstream_pipeline/models/rf_detr_nano.onnx",
    export_params=True,
    opset_version=17,
    do_constant_folding=True,
    input_names=['input'],
    output_names=['boxes', 'scores'],
    dynamic_axes={
        'input': {0: 'batch_size'},
        'boxes': {0: 'batch_size'},
        'scores': {0: 'batch_size'}
    }
)
print("ONNX Export Complete.")
```

2. **Validate ONNX Model**
```bash
pip install onnx onnxsim
onnxsim deepstream_pipeline/models/rf_detr_nano.onnx deepstream_pipeline/models/rf_detr_nano_sim.onnx
```

---

## Step 2: ONNX Optimization & TensorRT Engine Generation

Convert the ONNX model to a TensorRT engine using `trtexec`. For production, FP16 is recommended as it provides a good balance between precision and inference speed. INT8 requires a calibration dataset to measure activation ranges.

**FP16 Optimization Command:**
```bash
# Run this on the target deployment machine (dGPU or Jetson)
trtexec --onnx=deepstream_pipeline/models/rf_detr_nano_sim.onnx \
        --saveEngine=deepstream_pipeline/models/rf_detr_nano.onnx_b1_gpu0_fp16.engine \
        --fp16 \
        --workspace=1024
```

*Note: If using dynamic axes in ONNX, you must specify `--minShapes`, `--optShapes`, and `--maxShapes` in `trtexec`.*

---

## Step 3: DeepStream Integration

DeepStream 7.1 requires configuration files to construct the GStreamer pipeline.

1. `config_infer_primary.txt`: Configures the Primary GIE (NvDsInfer). It defines the network mode (2 for FP16), model paths, batch size, and input scaling.
2. `labels.txt`: COCO class labels.
3. `deepstream_app_config.txt`: The main application config that ties the pipeline together.

**Custom Parser Requirement:**
DETR architectures often output raw `[batch, num_queries, 4]` boxes and `[batch, num_queries, num_classes]` scores. DeepStream's default `NvDsInferParseCustom*` parsers (like YOLO) expect specific formats. You will likely need a custom C++ parser (`libnvds_infercustomparser.so`) placed in `deepstream_pipeline/parsers/` to map RF-DETR's `boxes` and `scores` outputs to DeepStream's `NvDsInferParseObjectInfo` array.
Uncomment `parse-bbox-func-name` and `custom-lib-path` in `config_infer_primary.txt` once the parser is compiled.

---

## Step 4: Pipeline Setup

The pipeline is defined in `deepstream_app_config.txt`.

**Flow:**
1. **Source:** `uridecodebin` (Reads MP4 file or RTSP stream).
2. **Streammux:** `nvstreammux` (Batches frames).
3. **Primary GIE:** `nvinfer` (Runs TensorRT engine for object detection).
4. **Tracker:** `nvtracker` (Uses NvDCF or IOU to track detected objects across frames).
5. **OSD:** `nvdsosd` (Draws bounding boxes and text).
6. **Sink:** `nveglglessink` (Displays output).

**Run the pipeline:**
```bash
cd deepstream_pipeline/configs
deepstream-app -c deepstream_app_config.txt
```

---

## Step 5: Performance Optimization

- **GPU Memory Optimization:** Set `workspace-size` in `config_infer_primary.txt` appropriately (1024MB is usually sufficient for Nano models). Ensure `nvbuf-memory-type` is set correctly for your platform (0 for default, 3 for Jetson NVMM).
- **Batch Size Tuning:** If processing multiple streams, match the `streammux` batch size to the `primary-gie` batch size. Rebuild the TensorRT engine with the corresponding max batch size.
- **Precision:** Use INT8 for maximum throughput. FP16 offers a good baseline for Nano models without accuracy loss.

---

## Step 6: Deployment

**Docker Deployment for DeepStream 7.1 (dGPU):**

```bash
# 1. Pull the official DeepStream 7.1 container
docker pull nvcr.io/nvidia/deepstream:7.1-triton-multiarch

# 2. Run the container with GPU access and X11 forwarding (for display)
xhost +
docker run --gpus all -it --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  -w /opt/nvidia/deepstream/deepstream/sources/deepstream_pipeline \
  -v $(pwd)/deepstream_pipeline:/opt/nvidia/deepstream/deepstream/sources/deepstream_pipeline \
  nvcr.io/nvidia/deepstream:7.1-triton-multiarch bash

# Inside the container, run:
cd configs
deepstream-app -c deepstream_app_config.txt
```

**Edge Deployment (Jetson):**
For Jetson devices, ensure you are using the `l4t` tagged DeepStream containers and set `cudadec-memtype=4` and `nvbuf-memory-type=4` in the configs.

---

## Step 7: AI Agent Design

To automate this workflow, we can design a Multi-Agent system using **LangGraph** or **CrewAI**.

1. **Model Conversion Agent:**
   - *Role:* ML Engineer.
   - *Task:* Ingests the PyTorch model, verifies dependencies, and executes the ONNX export script. Handles dynamic shape configuration.
2. **Optimization Agent:**
   - *Role:* TensorRT Specialist.
   - *Task:* Takes the ONNX model, runs `onnxsim`, and executes `trtexec` with optimal parameters (FP16/INT8). If INT8 is requested, it requests a calibration dataset.
3. **Deployment Agent:**
   - *Role:* DeepStream DevOps.
   - *Task:* Generates the `config_infer_primary.txt` and `deepstream_app_config.txt` based on the target hardware (Jetson vs dGPU). Deploys the Docker container and runs the test pipeline.

**Coordination (LangGraph):**
The state object contains `{model_path, onnx_path, engine_path, hardware_target}`.
`Conversion Agent` -> `Optimization Agent` -> `Deployment Agent`. The workflow halts if validation fails at any node.

---

## Common Errors + Fixes

- **Error:** `trtexec` fails with unsupported operations.
  **Fix:** Ensure ONNX opset is 16 or 17. Simplify the model with `onnxsim`.
- **Error:** DeepStream crashes with memory allocation errors.
  **Fix:** Reduce batch size or lower `workspace-size` in `config_infer_primary.txt`.
- **Error:** No bounding boxes displayed.
  **Fix:** Check if the custom parser is correctly mapping the RF-DETR outputs to `NvDsInferParseObjectInfo`. Ensure `parse-bbox-func-name` is correctly spelled.
