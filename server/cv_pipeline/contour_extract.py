"""Contour extraction from edge images for palm line detection."""

import cv2
import numpy as np

from cv_pipeline.models import Landmark


def _palm_convex_hull(
    landmarks: list[Landmark],
    original_size: tuple[int, int],
    roi_offset: tuple[int, int],
) -> np.ndarray | None:
    """Compute convex hull of key palm boundary landmarks in ROI pixel coords."""
    img_w, img_h = original_size
    off_x, off_y = roi_offset
    boundary_idx = [0, 1, 5, 9, 13, 17]
    pts = []
    for i in boundary_idx:
        lm = landmarks[i]
        x = int(lm.x * img_w) - off_x
        y = int(lm.y * img_h) - off_y
        pts.append([x, y])
    arr = np.array(pts, dtype=np.int32)
    hull = cv2.convexHull(arr)
    return hull


def _contour_inside_hull(pts: np.ndarray, hull: np.ndarray) -> bool:
    """Return True if at least 30% of contour points are inside the hull."""
    inside = 0
    # Sample every 3rd point for speed
    step = max(1, len(pts) // 30)
    sampled = pts[::step]
    for pt in sampled:
        dist = cv2.pointPolygonTest(hull, (float(pt[0]), float(pt[1])), False)
        if dist >= 0:
            inside += 1
    return inside / len(sampled) > 0.3


def extract_line_candidates(
    edges: np.ndarray,
    min_length: float = 40,
    max_candidates: int = 20,
    roi_size: tuple[int, int] | None = None,
    landmarks: list[Landmark] | None = None,
    original_size: tuple[int, int] | None = None,
    roi_offset: tuple[int, int] | None = None,
) -> list[np.ndarray]:
    """Extract line candidates from an edge image."""

    # Adaptive min_length: 8% of ROI width (was 20% — too aggressive)
    if roi_size is not None:
        roi_w, roi_h = roi_size
        min_length = max(30, 0.08 * roi_w)
    else:
        roi_w = roi_h = None

    # Palm hull for boundary filtering
    hull: np.ndarray | None = None
    if (
        landmarks is not None
        and original_size is not None
        and roi_offset is not None
        and len(landmarks) == 21
    ):
        hull = _palm_convex_hull(landmarks, original_size, roi_offset)

    # Dilate to connect nearby edge fragments
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    dilated = cv2.dilate(edges, kernel, iterations=1)

    # Use RETR_LIST to get all contours (not just external)
    contours, _ = cv2.findContours(dilated, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

    candidates: list[tuple[float, np.ndarray]] = []
    for cnt in contours:
        length = cv2.arcLength(cnt, False)
        if length < min_length:
            continue

        pts = cnt.reshape(-1, 2)

        # Aspect ratio filter: only discard perfectly round blobs
        x_range = float(np.ptp(pts[:, 0]))
        y_range = float(np.ptp(pts[:, 1]))
        longer = max(x_range, y_range, 1)
        shorter = min(x_range, y_range)
        if shorter / longer > 0.85:
            continue

        candidates.append((length, pts))

    candidates.sort(key=lambda x: x[0], reverse=True)
    return [pts for _, pts in candidates[:max_candidates]]
