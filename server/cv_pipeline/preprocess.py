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
    edges: np.ndarray      # 2D uint8 combined edge map (Canny + adaptive threshold)
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
    5. Apply Gaussian blur to reduce noise.
    6. Compute edges via Canny + adaptive threshold and combine them.

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

    # --- 5. Gaussian blur ---
    blurred = cv2.GaussianBlur(enhanced, (5, 5), sigmaX=0)

    # --- 6. Canny edge detection ---
    canny_edges = cv2.Canny(blurred, threshold1=30, threshold2=80)

    # --- Adaptive threshold for soft/faint lines ---
    adaptive = cv2.adaptiveThreshold(
        blurred,
        maxValue=255,
        adaptiveMethod=cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        thresholdType=cv2.THRESH_BINARY_INV,
        blockSize=11,
        C=2,
    )

    # --- Combine: union of both edge maps ---
    edges = cv2.bitwise_or(canny_edges, adaptive)

    return PreprocessResult(
        gray=gray,
        edges=edges,
        roi_offset=roi_offset,
        roi_size=roi_size,
        original_size=(w, h),
    )
