"""Rule-based palm line classification by position relative to landmarks."""

import numpy as np

from cv_pipeline.models import Landmark


# ---------------------------------------------------------------------------
# Geometry helpers
# ---------------------------------------------------------------------------

def _avg_y_px(points: np.ndarray) -> float:
    """Return mean y position of points in pixels."""
    return float(np.mean(points[:, 1]))


def _avg_x_px(points: np.ndarray) -> float:
    """Return mean x position of points in pixels."""
    return float(np.mean(points[:, 0]))


def _vertical_span(points: np.ndarray) -> float:
    """Return y range of points in pixels."""
    return float(np.ptp(points[:, 1]))


def _horizontal_span(points: np.ndarray) -> float:
    """Return x range of points in pixels."""
    return float(np.ptp(points[:, 0]))


def _is_horizontal(points: np.ndarray) -> bool:
    """True when the contour is wider than it is tall (ratio >= 2:1)."""
    v_span = _vertical_span(points)
    h_span = _horizontal_span(points)
    return h_span > 0 and (v_span / h_span) < 0.5


def _is_vertical(points: np.ndarray) -> bool:
    """True when the contour is taller than it is wide (ratio >= 2:1)."""
    v_span = _vertical_span(points)
    h_span = _horizontal_span(points)
    return v_span > 0 and (h_span / v_span) < 0.5


# ---------------------------------------------------------------------------
# Landmark projection helpers
# ---------------------------------------------------------------------------

def _lm_to_roi(
    lm: Landmark,
    original_size: tuple[int, int],
    roi_offset: tuple[int, int],
) -> tuple[float, float]:
    """Project a normalised landmark into ROI pixel coordinates."""
    img_w, img_h = original_size
    off_x, off_y = roi_offset
    return lm.x * img_w - off_x, lm.y * img_h - off_y


def _compute_zones(
    landmarks: list[Landmark],
    roi_size: tuple[int, int],
    roi_offset: tuple[int, int],
    original_size: tuple[int, int],
) -> dict:
    """Derive classification zones from MediaPipe landmark positions.

    Heart line zone
    ---------------
    Runs just below the finger MCP row (landmarks 5, 9, 13, 17).
    Y band: [mcp_y_mean, mcp_y_mean + 0.15 * palm_height]

    Head line zone
    --------------
    Runs horizontally in the middle of the palm, between heart line bottom
    and life-line start.
    Y band: [heart_bottom, heart_bottom + 0.25 * palm_height]

    Life line zone
    --------------
    Curves from the thumb/index web space (landmark 2-5 area) down toward the
    wrist.  X constraint: avg_x < life_x_threshold (left third of palm).
    Vertical span must cover > 20 % of palm height.

    Fate line zone
    --------------
    Vertical, running up the centre of the palm.  X band:
    [centre_x - 0.15 * palm_width, centre_x + 0.15 * palm_width].
    """
    roi_w, roi_h = roi_size

    # MCP row: landmarks 5 (index MCP), 9 (middle MCP), 13 (ring MCP), 17 (pinky MCP)
    mcp_ys = []
    for idx in (5, 9, 13, 17):
        _, y = _lm_to_roi(landmarks[idx], original_size, roi_offset)
        mcp_ys.append(y)
    mcp_y_mean = float(np.mean(mcp_ys))

    # Wrist (landmark 0) gives the bottom reference
    _, wrist_y = _lm_to_roi(landmarks[0], original_size, roi_offset)

    palm_height = max(wrist_y - mcp_y_mean, 1.0)

    # Palm width: landmark 5 (index MCP) to landmark 17 (pinky MCP)
    x5, _ = _lm_to_roi(landmarks[5], original_size, roi_offset)
    x17, _ = _lm_to_roi(landmarks[17], original_size, roi_offset)
    palm_width = max(abs(x17 - x5), 1.0)
    palm_centre_x = (x5 + x17) / 2.0

    heart_top    = mcp_y_mean
    heart_bottom = mcp_y_mean + 0.15 * palm_height
    head_top     = heart_bottom
    head_bottom  = heart_bottom + 0.25 * palm_height

    # Life line starts in thumb-index web: landmark 2 (thumb MCP)
    x2, _ = _lm_to_roi(landmarks[2], original_size, roi_offset)
    life_x_threshold = x2 + 0.10 * palm_width   # just right of thumb base
    life_min_vspan   = 0.20 * palm_height

    fate_x_lo = palm_centre_x - 0.15 * palm_width
    fate_x_hi = palm_centre_x + 0.15 * palm_width

    return {
        "heart_top":          heart_top,
        "heart_bottom":       heart_bottom,
        "head_top":           head_top,
        "head_bottom":        head_bottom,
        "life_x_threshold":   life_x_threshold,
        "life_min_vspan":     life_min_vspan,
        "fate_x_lo":          fate_x_lo,
        "fate_x_hi":          fate_x_hi,
    }


# ---------------------------------------------------------------------------
# Public classifier
# ---------------------------------------------------------------------------

def classify_lines(
    candidates: list[np.ndarray],
    landmarks: list[Landmark],
    roi_size: tuple,
    roi_offset: tuple,
    original_size: tuple | None = None,
) -> list[dict]:
    """Classify line candidates by position relative to landmarks.

    Rules (all derived from MediaPipe landmark geometry)
    ----
    - heart : horizontal, avg_y in [mcp_y, mcp_y + 15% palm_height]
    - head  : horizontal, avg_y in [heart_bottom, heart_bottom + 25% palm_height]
    - life  : avg_x < thumb-base x + 10% palm_width, vertical span > 20% palm_height
    - fate  : vertical, avg_x within ±15% palm_width of palm centre

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
        (x, y) pixel offset of the ROI in the original image.
    original_size:
        (width, height) of the original image.  When ``None``, a fallback
        based on the ROI size is used so the function remains usable in unit
        tests that don't supply it.

    Returns
    -------
    list[dict]
        Each element: ``{"line_type": str, "points": np.ndarray}``.
    """
    if original_size is None:
        # Fallback: assume the ROI covers the whole image (no offset).
        # This keeps unit tests working when original_size is not supplied.
        roi_w, roi_h = roi_size
        off_x, off_y = roi_offset
        original_size = (roi_w + off_x, roi_h + off_y)

    zones = _compute_zones(landmarks, roi_size, roi_offset, original_size)

    assigned: set[str] = set()
    results: list[dict] = []

    for pts in candidates:
        if len(pts) < 2:
            continue

        avg_y   = _avg_y_px(pts)
        avg_x   = _avg_x_px(pts)
        v_span  = _vertical_span(pts)
        horizontal = _is_horizontal(pts)
        vertical   = _is_vertical(pts)

        matched: str | None = None

        # Heart line: horizontal band just below MCPs
        if (
            "heart" not in assigned
            and horizontal
            and zones["heart_top"] <= avg_y <= zones["heart_bottom"]
        ):
            matched = "heart"

        # Head line: horizontal band below heart line
        elif (
            "head" not in assigned
            and horizontal
            and zones["head_top"] <= avg_y <= zones["head_bottom"]
        ):
            matched = "head"

        # Life line: left/thumb side, significant vertical span
        elif (
            "life" not in assigned
            and avg_x < zones["life_x_threshold"]
            and v_span > zones["life_min_vspan"]
        ):
            matched = "life"

        # Fate line: vertical, central x band
        elif (
            "fate" not in assigned
            and vertical
            and zones["fate_x_lo"] <= avg_x <= zones["fate_x_hi"]
        ):
            matched = "fate"

        if matched is not None:
            assigned.add(matched)
            results.append({"line_type": matched, "points": pts})

    return results
