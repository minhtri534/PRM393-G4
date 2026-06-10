from __future__ import annotations

import os
import time
from typing import Any

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

APP_MODEL = os.getenv("YOLO_MODEL", "mock-yolo")
APP_PROVIDER = os.getenv("AI_PROVIDER", "MockYolo")

app = FastAPI(title="DLSS Mock YOLO Inference", version="0.1")


@app.get("/health")
def health() -> dict[str, Any]:
    return {"status": "ok", "provider": APP_PROVIDER, "model": APP_MODEL}


@app.post("/detect")
async def detect(file: UploadFile = File(...), conf: float = 0.25):
    started = time.time()
    _ = await file.read()

    # Always return a deterministic bbox for classId=0 (person in COCO)
    detections = [
        {
            "classId": 0,
            "confidence": max(conf, 0.9),
            "bbox": {"x1": 100.0, "y1": 120.0, "x2": 520.0, "y2": 860.0},
        }
    ]

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
