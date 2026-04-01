"""Image preprocessing utilities for the palm CV pipeline."""

import base64
from typing import TypedDict

import cv2
import numpy as np

from cv_pipeline.models import Landmark

_ROI_PADDING = 20


class PreprocessResult(TypedDict):
    gray: np.ndarray
    edges: np.ndarray
    roi_offset: tuple[int, int]
    roi_size: tuple[int, int]
    original_size: tuple[int, int]


def decode_image(base64_str: str) -> np.ndarray:
    """Decode a base64-encoded image string to a BGR numpy array."""
    try:
        img_bytes = base64.b64decode(base64_str, validate=True)
    except Exception as exc:
        raise ValueError(f"Invalid base64 string: {exc}") from exc

    arr = np.frombuffer(img_bytes, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Could not decode image from base64 data.")

    return img


def _build_hand_mask(landmarks: list[Landmark], roi_w: int, roi_h: int,
                     roi_offset: tuple[int, int], img_w: int, img_h: int) -> np.ndarray:
    """Build a binary mask of the hand interior from landmarks.

    Uses convex hull of key palm landmarks to create a mask that
    excludes background, fingers (mostly), and non-palm areas.
    """
    ox, oy = roi_offset

    # Use palm + finger base landmarks for convex hull
    palm_indices = [0, 1, 2, 5, 9, 13, 17]

    pts = []
    for idx in palm_indices:
        if idx < len(landmarks):
            lm = landmarks[idx]
            # Convert from normalized (0-1 of full image) to ROI pixel coords
            full_px = int(lm.x * img_w)
            full_py = int(lm.y * img_h)
            roi_px = full_px - ox
            roi_py = full_py - oy
            roi_px = max(0, min(roi_w - 1, roi_px))
            roi_py = max(0, min(roi_h - 1, roi_py))
            pts.append([roi_px, roi_py])

    if len(pts) < 3:
        return np.ones((roi_h, roi_w), dtype=np.uint8) * 255

    hull = cv2.convexHull(np.array(pts, dtype=np.int32))
    mask = np.zeros((roi_h, roi_w), dtype=np.uint8)
    cv2.fillConvexPoly(mask, hull, 255)

    # Dilate to include edges at palm boundary
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (20, 20))
    mask = cv2.dilate(mask, kernel, iterations=1)

    return mask


def preprocess_palm(image: np.ndarray, landmarks: list[Landmark]) -> PreprocessResult:
    """Preprocess a palm image for line detection.

    Pipeline:
    1. ROI crop from landmarks
    2. Build hand mask (convex hull of palm landmarks)
    3. Grayscale → CLAHE → bilateral filter
    4. Apply hand mask (zero out background)
    5. Canny edge detection with moderate thresholds
    6. Mask edges (only keep edges inside hand)
    7. Morphological cleanup
    """
    h, w = image.shape[:2]

    # 1. ROI from landmarks
    xs = [int(lm.x * w) for lm in landmarks]
    ys = [int(lm.y * h) for lm in landmarks]

    x_min = max(0, min(xs) - _ROI_PADDING)
    y_min = max(0, min(ys) - _ROI_PADDING)
    x_max = min(w, max(xs) + _ROI_PADDING)
    y_max = min(h, max(ys) + _ROI_PADDING)

    roi_offset: tuple[int, int] = (x_min, y_min)
    roi_w = x_max - x_min
    roi_h = y_max - y_min
    roi_size: tuple[int, int] = (roi_w, roi_h)

    # 2. Crop
    roi_bgr = image[y_min:y_max, x_min:x_max]

    # 3. Grayscale
    gray = cv2.cvtColor(roi_bgr, cv2.COLOR_BGR2GRAY)

    # 4. CLAHE for contrast
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)

    # 5. Bilateral filter — smooths skin texture, preserves line edges
    blurred = cv2.bilateralFilter(enhanced, d=9, sigmaColor=50, sigmaSpace=50)

    # 6. Build hand mask from landmarks
    hand_mask = _build_hand_mask(landmarks, roi_w, roi_h, roi_offset, w, h)

    # 7. Canny — low thresholds are OK because hand mask removes background noise
    canny_edges = cv2.Canny(blurred, threshold1=30, threshold2=90)

    # 8. Apply hand mask — remove all edges outside the palm
    edges = cv2.bitwise_and(canny_edges, hand_mask)

    # 9. Morphological cleanup
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    edges = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel, iterations=2)
    edges = cv2.morphologyEx(edges, cv2.MORPH_OPEN, kernel, iterations=1)

    return PreprocessResult(
        gray=gray,
        edges=edges,
        roi_offset=roi_offset,
        roi_size=roi_size,
        original_size=(w, h),
    )
