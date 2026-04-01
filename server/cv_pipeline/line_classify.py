"""Rule-based palm line classification by position relative to landmarks."""

import numpy as np

from cv_pipeline.models import Landmark


def _lm_to_roi(lm: Landmark, original_size: tuple[int, int], roi_offset: tuple[int, int]) -> tuple[float, float]:
    img_w, img_h = original_size
    off_x, off_y = roi_offset
    return lm.x * img_w - off_x, lm.y * img_h - off_y


def classify_lines(
    candidates: list[np.ndarray],
    landmarks: list[Landmark],
    roi_size: tuple,
    roi_offset: tuple,
    original_size: tuple | None = None,
) -> list[dict]:
    """Classify top line candidates by their position.

    Simple approach: take up to 4 best candidates and assign types based
    on relative position within the palm.

    - Sort horizontal-ish lines by Y position → topmost = heart, next = head
    - Left-side line with significant vertical span → life
    - Central vertical line → fate
    """
    if not candidates:
        return []

    if original_size is None:
        roi_w, roi_h = roi_size
        off_x, off_y = roi_offset
        original_size = (roi_w + off_x, roi_h + off_y)

    roi_w, roi_h = roi_size

    # Compute palm center and thumb position for reference
    _, wrist_y = _lm_to_roi(landmarks[0], original_size, roi_offset)
    mcp_positions = []
    for idx in [5, 9, 13, 17]:
        x, y = _lm_to_roi(landmarks[idx], original_size, roi_offset)
        mcp_positions.append((x, y))
    mcp_y_mean = np.mean([p[1] for p in mcp_positions])
    palm_centre_x = np.mean([p[0] for p in mcp_positions])

    # Categorize each candidate
    scored: list[dict] = []
    for pts in candidates:
        if len(pts) < 2:
            continue
        avg_x = float(np.mean(pts[:, 0]))
        avg_y = float(np.mean(pts[:, 1]))
        h_span = float(np.ptp(pts[:, 0]))
        v_span = float(np.ptp(pts[:, 1]))
        is_more_horizontal = h_span >= v_span * 0.7
        is_more_vertical = v_span >= h_span * 1.2
        length = float(np.sqrt(h_span**2 + v_span**2))

        scored.append({
            "points": pts,
            "avg_x": avg_x,
            "avg_y": avg_y,
            "h_span": h_span,
            "v_span": v_span,
            "horizontal": is_more_horizontal,
            "vertical": is_more_vertical,
            "length": length,
        })

    assigned: set[str] = set()
    results: list[dict] = []

    # 1. Find horizontal lines sorted by Y (top to bottom)
    horizontals = sorted(
        [s for s in scored if s["horizontal"]],
        key=lambda s: s["avg_y"]
    )

    # Top horizontal → heart
    if horizontals and "heart" not in assigned:
        results.append({"line_type": "heart", "points": horizontals[0]["points"]})
        assigned.add("heart")
        scored = [s for s in scored if s is not horizontals[0]]
        horizontals = horizontals[1:]

    # Next horizontal → head
    if horizontals and "head" not in assigned:
        results.append({"line_type": "head", "points": horizontals[0]["points"]})
        assigned.add("head")
        scored = [s for s in scored if s is not horizontals[0]]
        horizontals = horizontals[1:]

    # 2. Left-side line with vertical span → life
    left_candidates = sorted(
        [s for s in scored if s["avg_x"] < palm_centre_x and s["v_span"] > roi_h * 0.05],
        key=lambda s: s["v_span"],
        reverse=True,
    )
    if left_candidates and "life" not in assigned:
        results.append({"line_type": "life", "points": left_candidates[0]["points"]})
        assigned.add("life")
        scored = [s for s in scored if s is not left_candidates[0]]

    # 3. Central vertical → fate
    verticals = sorted(
        [s for s in scored if s["vertical"] and abs(s["avg_x"] - palm_centre_x) < roi_w * 0.3],
        key=lambda s: s["length"],
        reverse=True,
    )
    if verticals and "fate" not in assigned:
        results.append({"line_type": "fate", "points": verticals[0]["points"]})
        assigned.add("fate")

    return results
