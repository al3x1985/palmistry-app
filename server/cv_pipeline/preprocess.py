"""Image preprocessing utilities for the palm CV pipeline."""

import base64
from typing import TypedDict

import cv2
import numpy as np

from cv_pipeline.models import Landmark

# Padding added around the palm bounding box when cropping the ROI (pixels)
_ROI_PADDING = 20


class PreprocessResult(TypedDict):
    gray: np.ndarray       # 2D grayscale ROI
    edges: np.ndarray      # 2D uint8 edge map (Canny + morphological cleanup)
    roi_offset: tuple[int, int]   # (x, y) pixel offset of the ROI in the original image
    roi_size: tuple[int, int]     # (width, height) of the ROI
    original_size: tuple[int, int]  # (width, height) of the original image


def decode_image(base64_str: str) -> np.ndarray:
    """Decode a base64-encoded image string to a BGR numpy array.

    Parameters
    ----------
    base64_str:
        Base64-encoded image bytes (JPEG or PNG).

    Returns
    -------
    np.ndarray
        BGR image with shape (H, W, 3).

    Raises
    ------
    ValueError
        If the string cannot be decoded or the result is not a valid image.
    """
    try:
        img_bytes = base64.b64decode(base64_str, validate=True)
    except Exception as exc:
        raise ValueError(f"Invalid base64 string: {exc}") from exc

    arr = np.frombuffer(img_bytes, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Could not decode image from base64 data (unsupported format or corrupt bytes).")

    return img


def preprocess_palm(image: np.ndarray, landmarks: list[Landmark]) -> PreprocessResult:
    """Preprocess a palm image for line detection.

    Steps
    -----
    1. Compute a bounding-box ROI from the landmark positions.
    2. Crop the ROI with padding.
    3. Convert to grayscale.
    4. Apply CLAHE for contrast enhancement.
    5. Apply bilateral filter to smooth skin texture while preserving edges.
    6. Compute strong edges via Canny (higher thresholds than before).
    7. Morphological close to connect nearby segments, then open to remove noise.

    Parameters
    ----------
    image:
        BGR image as returned by :func:`decode_image`.
    landmarks:
        Exactly 21 :class:`~cv_pipeline.models.Landmark` objects with
        normalised (0-1) coordinates.

    Returns
    -------
    PreprocessResult
        Dictionary with keys ``gray``, ``edges``, ``roi_offset``,
        ``roi_size``, and ``original_size``.
    """
    h, w = image.shape[:2]

    # --- 1. ROI from landmarks ---
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

    # --- 2. Crop ---
    roi_bgr = image[y_min:y_max, x_min:x_max]

    # --- 3. Grayscale ---
    gray = cv2.cvtColor(roi_bgr, cv2.COLOR_BGR2GRAY)

    # --- 4. CLAHE ---
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)

    # --- 5. Bilateral filter — smooths skin texture while preserving real edges ---
    blurred = cv2.bilateralFilter(enhanced, d=9, sigmaColor=75, sigmaSpace=75)

    # --- 6. Canny edge detection (higher thresholds → only strong edges) ---
    canny_edges = cv2.Canny(blurred, threshold1=50, threshold2=150)

    # --- 7. Morphological cleanup ---
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    # Close: connect nearby line segments
    edges = cv2.morphologyEx(canny_edges, cv2.MORPH_CLOSE, kernel, iterations=2)
    # Open: remove small isolated noise dots
    edges = cv2.morphologyEx(edges, cv2.MORPH_OPEN, kernel, iterations=1)

    return PreprocessResult(
        gray=gray,
        edges=edges,
        roi_offset=roi_offset,
        roi_size=roi_size,
        original_size=(w, h),
    )
