"""Rule-based palm line classification by position relative to landmarks."""

import numpy as np

from cv_pipeline.models import Landmark


def _avg_y_frac(points: np.ndarray, roi_h: int) -> float:
    """Return mean y position of points as a fraction of ROI height."""
    return float(np.mean(points[:, 1])) / roi_h


def _avg_x_frac(points: np.ndarray, roi_w: int) -> float:
    """Return mean x position of points as a fraction of ROI width."""
    return float(np.mean(points[:, 0])) / roi_w


def _vertical_span_frac(points: np.ndarray, roi_h: int) -> float:
    """Return y range of points as a fraction of ROI height."""
    return float(np.ptp(points[:, 1])) / roi_h


def _horizontal_span_frac(points: np.ndarray, roi_w: int) -> float:
    """Return x range of points as a fraction of ROI width."""
    return float(np.ptp(points[:, 0])) / roi_w


def _is_horizontal(points: np.ndarray, roi_w: int, roi_h: int) -> bool:
    """True when the contour is wider than it is tall (ratio >= 2:1)."""
    v_span = _vertical_span_frac(points, roi_h)
    h_span = _horizontal_span_frac(points, roi_w)
    return h_span > 0 and (v_span / h_span) < 0.5


def _is_vertical(points: np.ndarray, roi_w: int, roi_h: int) -> bool:
    """True when the contour is taller than it is wide (ratio >= 2:1)."""
    v_span = _vertical_span_frac(points, roi_h)
    h_span = _horizontal_span_frac(points, roi_w)
    return v_span > 0 and (h_span / v_span) < 0.5


def classify_lines(
    candidates: list[np.ndarray],
    landmarks: list[Landmark],
    roi_size: tuple,
    roi_offset: tuple,
) -> list[dict]:
    """Classify line candidates by position relative to landmarks.

    Rules
    -----
    - heart : horizontal, avg_y in 0.35–0.55 of ROI height
    - head  : horizontal, avg_y in 0.45–0.70 of ROI height
    - life  : curved on left/thumb side (avg_x < 0.35), vertical span > 30 % ROI height
    - fate  : vertical, avg_x in 0.35–0.65 of ROI width

    Each type is assigned at most once (first matching candidate wins).

    Parameters
    ----------
    candidates:
        List of Nx2 int arrays (ROI pixel coordinates).
    landmarks:
        21 Landmark objects with normalised (0-1) coordinates.
    roi_size:
        (width, height) of the ROI in pixels.
    roi_offset:
        (x, y) pixel offset of the ROI in the original image (not used for
        classification rules, kept for future normalisation callers).

    Returns
    -------
    list[dict]
        Each element: ``{"line_type": str, "points": np.ndarray}``.
    """
    roi_w, roi_h = roi_size
    assigned: set[str] = set()
    results: list[dict] = []

    for pts in candidates:
        if len(pts) < 2:
            continue

        avg_y = _avg_y_frac(pts, roi_h)
        avg_x = _avg_x_frac(pts, roi_w)
        v_span = _vertical_span_frac(pts, roi_h)
        horizontal = _is_horizontal(pts, roi_w, roi_h)
        vertical = _is_vertical(pts, roi_w, roi_h)

        matched: str | None = None

        # Heart line: horizontal, upper-middle palm (y in 0.35–0.55 but above midpoint)
        # Head line: horizontal, middle palm (y in 0.45–0.70 but at/below midpoint)
        # When zones overlap we resolve by position: y < 0.50 → heart, y >= 0.50 → head.
        if horizontal and 0.35 <= avg_y <= 0.55 and avg_y < 0.50 and "heart" not in assigned:
            matched = "heart"

        elif horizontal and 0.45 <= avg_y <= 0.70 and avg_y >= 0.50 and "head" not in assigned:
            matched = "head"

        # Within overlap zone: assign whichever type is still unassigned
        elif horizontal and 0.45 <= avg_y < 0.50 and "head" not in assigned and "heart" in assigned:
            matched = "head"

        elif horizontal and 0.50 <= avg_y <= 0.55 and "heart" not in assigned and "head" in assigned:
            matched = "heart"

        # Life line: curved left side, significant vertical span
        elif (
            "life" not in assigned
            and avg_x < 0.35
            and v_span > 0.30
        ):
            matched = "life"

        # Fate line: vertical, central x
        elif "fate" not in assigned and vertical and 0.35 <= avg_x <= 0.65:
            matched = "fate"

        if matched is not None:
            assigned.add(matched)
            results.append({"line_type": matched, "points": pts})

    return results
