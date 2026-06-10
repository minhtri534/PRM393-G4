from __future__ import annotations

import os
import time
from typing import Any

# PyTorch 2.6+ changed torch.load default weights_only=True, which breaks
# loading older YOLO checkpoints unless explicitly disabled.
os.environ.setdefault("TORCH_FORCE_NO_WEIGHTS_ONLY_LOAD", "1")

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

# pip install fastapi uvicorn ultralytics
from ultralytics import YOLO

APP_MODEL = os.getenv("YOLO_MODEL", "yolov8n.pt")
APP_PROVIDER = os.getenv("AI_PROVIDER", "UltralyticsYOLO")

app = FastAPI(title="DLSS YOLO Inference", version="0.1")
model = YOLO(APP_MODEL)


@app.get("/health")
def health() -> dict[str, Any]:
    return {"status": "ok", "provider": APP_PROVIDER, "model": APP_MODEL}


@app.post("/detect")
async def detect(file: UploadFile = File(...), conf: float = 0.25):
    started = time.time()

    content = await file.read()

    # Ultralytics can run directly on bytes via numpy/PIL; simplest is to write to temp? 
    # To keep it simple and stateless, we pass bytes as a memory file via PIL.
    from PIL import Image
    import io

    img = Image.open(io.BytesIO(content)).convert("RGB")

    results = model.predict(img, conf=conf, verbose=False)

    detections = []
    for r in results:
        if r.boxes is None:
            continue
        for b in r.boxes:
            # b.cls, b.conf, b.xyxy
            class_id = int(b.cls.item())
            confidence = float(b.conf.item())
            x1, y1, x2, y2 = [float(v) for v in b.xyxy[0].tolist()]
            detections.append(
                {
                    "classId": class_id,
                    "confidence": confidence,
                    "bbox": {"x1": x1, "y1": y1, "x2": x2, "y2": y2},
                }
            )

    elapsed_ms = int((time.time() - started) * 1000)

    return JSONResponse(
        {
            "provider": APP_PROVIDER,
            "model": APP_MODEL,
            "confidenceThreshold": conf,
            "elapsedMs": elapsed_ms,
            "detections": detections,
        }
    )
