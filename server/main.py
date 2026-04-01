import base64

import cv2
import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from cv_pipeline.models import AnalyzeRequest, PalmAnalysisResponse
from cv_pipeline.pipeline import analyze_palm
from cv_pipeline.preprocess import decode_image, preprocess_palm
from cv_pipeline.contour_extract import extract_line_candidates

app = FastAPI(title="Palmistry CV Pipeline", version="1.0.0")


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/analyze", response_model=PalmAnalysisResponse)
async def analyze(request: AnalyzeRequest):
    try:
        result = analyze_palm(request)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")


@app.post("/debug")
async def debug(request: AnalyzeRequest):
    """Debug endpoint: returns edge map stats and intermediate data."""
    try:
        image = decode_image(request.image_base64)
        img_h, img_w = image.shape[:2]

        # Detect landmarks if not provided
        landmarks = request.landmarks
        if not landmarks:
            from cv_pipeline.landmark_detect import detect_hand_landmarks
            landmarks = detect_hand_landmarks(image)

        if not landmarks:
            return JSONResponse({"error": "No hand detected", "image_size": [img_w, img_h]})

        prep = preprocess_palm(image, landmarks)

        edges = prep["edges"]
        edge_pixels = int(np.count_nonzero(edges))
        total_pixels = edges.shape[0] * edges.shape[1]

        candidates = extract_line_candidates(edges)

        # Encode edge map as base64 JPEG for visual inspection
        _, buf = cv2.imencode(".jpg", edges)
        edges_b64 = base64.b64encode(buf).decode()

        return JSONResponse({
            "image_size": [img_w, img_h],
            "roi_offset": list(prep["roi_offset"]),
            "roi_size": list(prep["roi_size"]),
            "landmarks_count": len(landmarks),
            "edge_pixels": edge_pixels,
            "total_pixels": total_pixels,
            "edge_ratio": round(edge_pixels / max(1, total_pixels), 4),
            "num_contour_candidates": len(candidates),
            "candidate_lengths": [int(cv2.arcLength(c.reshape(-1, 1, 2), False)) for c in candidates[:10]],
            "edges_image_base64": edges_b64,
        })
    except Exception as e:
        return JSONResponse({"error": str(e)}, status_code=500)
