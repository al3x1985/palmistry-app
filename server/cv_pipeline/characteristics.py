"""Line characteristics computation for palm analysis."""

import math
from cv_pipeline.models import Landmark

# Named landmark indices (MediaPipe order)
_NAMED_LANDMARKS: list[tuple[int, str]] = [
    (5,  "jupiter"),   # index MCP
    (9,  "saturn"),    # middle MCP
    (13, "apollo"),    # ring MCP
    (17, "mercury"),   # pinky MCP
    (0,  "wrist"),     # wrist
]


def _polyline_length(control_points: list[tuple[float, float]]) -> float:
    """Approximate arc length of the bezier by summing chord segments."""
    total = 0.0
    for i in range(1, len(control_points)):
        dx = control_points[i][0] - control_points[i - 1][0]
        dy = control_points[i][1] - control_points[i - 1][1]
        total += math.hypot(dx, dy)
    return total


def _max_curvature_deviation(control_points: list[tuple[float, float]]) -> float:
    """
    Maximum perpendicular deviation of intermediate control points from the
    chord (straight line between first and last control point), expressed as
    a fraction of the chord length.

    Returns 0.0 for degenerate inputs (single point or zero-length chord).
    """
    if len(control_points) < 2:
        return 0.0

    start = control_points[0]
    end = control_points[-1]
    chord_len = math.hypot(end[0] - start[0], end[1] - start[1])

    if chord_len < 1e-9:
        return 0.0

    # Direction unit vector along the chord
    dx = (end[0] - start[0]) / chord_len
    dy = (end[1] - start[1]) / chord_len

    max_dev = 0.0
    for pt in control_points[1:-1]:
        # Vector from start to pt
        vx = pt[0] - start[0]
        vy = pt[1] - start[1]
        # Perpendicular component
        perp = abs(vx * (-dy) + vy * dx)
        max_dev = max(max_dev, perp)

    return max_dev / chord_len


def _nearest_named_landmark(
    point: tuple[float, float],
    landmarks: list[Landmark],
) -> str:
    """Return the name of the nearest named landmark to *point*."""
    min_dist = float("inf")
    nearest = "wrist"
    px, py = point
    for idx, name in _NAMED_LANDMARKS:
        lm = landmarks[idx]
        dist = math.hypot(lm.x - px, lm.y - py)
        if dist < min_dist:
            min_dist = dist
            nearest = name
    return nearest


def compute_line_characteristics(
    control_points: list[tuple[float, float]],
    line_type: str,
    landmarks: list[Landmark],
    palm_width: float,
) -> dict:
    """
    Compute characteristics of a palm line from normalized bezier control points.

    Parameters
    ----------
    control_points:
        List of (x, y) normalised [0-1] tuples (e.g. from bezier_points_to_normalized).
    line_type:
        One of "heart", "head", "life", "fate".
    landmarks:
        Exactly 21 :class:`~cv_pipeline.models.Landmark` objects.
    palm_width:
        Normalised palm width (distance index MCP to pinky MCP) used to
        categorise line length.

    Returns
    -------
    dict with keys:
        - length       : "short" / "medium" / "long"
        - length_raw   : float (normalised arc length)
        - depth        : "deep" / "medium" / "faint"  (MVP: always "medium")
        - curvature    : "straight" / "curved" / "steep"
        - start_point  : nearest named landmark to first control point
        - end_point    : nearest named landmark to last control point
    """
    # --- Arc length ---
    length_raw = _polyline_length(control_points)

    # Categorise relative to palm width
    if palm_width > 1e-9:
        ratio = length_raw / palm_width
    else:
        ratio = 0.0

    if ratio < 0.5:
        length_cat = "short"
    elif ratio <= 0.75:
        length_cat = "medium"
    else:
        length_cat = "long"

    # --- Curvature ---
    dev_frac = _max_curvature_deviation(control_points)
    if dev_frac < 0.05:
        curvature = "straight"
    elif dev_frac <= 0.15:
        curvature = "curved"
    else:
        curvature = "steep"

    # --- Depth (MVP: no pixel intensity available) ---
    depth = "medium"

    # --- Endpoints ---
    start_point = _nearest_named_landmark(control_points[0], landmarks)
    end_point   = _nearest_named_landmark(control_points[-1], landmarks)

    return {
        "length":      length_cat,
        "length_raw":  float(length_raw),
        "depth":       depth,
        "curvature":   curvature,
        "start_point": start_point,
        "end_point":   end_point,
    }
