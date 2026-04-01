"""Palm shape analysis from hand landmarks."""

import math
from cv_pipeline.models import Landmark

# MediaPipe landmark indices
_WRIST = 0
_INDEX_MCP = 5
_MIDDLE_MCP = 9
_RING_MCP = 13
_PINKY_MCP = 17

# Finger tip indices
_INDEX_TIP = 8
_MIDDLE_TIP = 12
_RING_TIP = 16
_PINKY_TIP = 20


def _dist(a: Landmark, b: Landmark) -> float:
    return math.hypot(b.x - a.x, b.y - a.y)


def analyze_palm_shape(landmarks: list[Landmark]) -> dict:
    """
    Determine palm shape and finger proportions from landmarks.

    Palm width : distance index MCP (5) → pinky MCP (17).
    Palm height: distance middle MCP (9) → wrist (0).

    Shape by width/height ratio:
    - square    : 0.85 – 1.15
    - rectangle : < 0.85  (tall/narrow palm)
    - spatulate : > 1.15  (wide palm)
    - conic     : finger_width / wrist_width > 1.2  (checked after the above)

    Finger proportions are lengths from MCP to tip, normalised to the
    middle finger (longest reference = 1.0).

    Returns
    -------
    dict with keys:
        palm_shape         : str
        palm_width_ratio   : float  (width / height)
        palm_width         : float  (normalised)
        finger_proportions : dict[str, float]
    """
    wrist      = landmarks[_WRIST]
    index_mcp  = landmarks[_INDEX_MCP]
    middle_mcp = landmarks[_MIDDLE_MCP]
    pinky_mcp  = landmarks[_PINKY_MCP]

    palm_width  = _dist(index_mcp, pinky_mcp)
    palm_height = _dist(middle_mcp, wrist)

    if palm_height < 1e-9:
        ratio = 1.0
    else:
        ratio = palm_width / palm_height

    # --- Finger lengths (MCP → tip) ---
    finger_lengths: dict[str, float] = {
        "index":  _dist(index_mcp,          landmarks[_INDEX_TIP]),
        "middle": _dist(middle_mcp,         landmarks[_MIDDLE_TIP]),
        "ring":   _dist(landmarks[_RING_MCP],  landmarks[_RING_TIP]),
        "pinky":  _dist(pinky_mcp,          landmarks[_PINKY_TIP]),
    }

    middle_len = finger_lengths["middle"]
    if middle_len < 1e-9:
        finger_proportions = {k: 0.0 for k in finger_lengths}
    else:
        finger_proportions = {k: v / middle_len for k, v in finger_lengths.items()}

    # --- Conic: MCP spread significantly wider than wrist-level spread ---
    # Wrist-level spread: thumb CMC (landmark 1) x to pinky MCP (17) x
    # This approximates the hand width at the wrist / lower palm.
    thumb_cmc   = landmarks[1]
    wrist_spread = abs(pinky_mcp.x - thumb_cmc.x)
    mcp_spread   = abs(pinky_mcp.x - index_mcp.x)

    # Only classify conic when the ratio makes sense (avoid division by near-zero)
    if wrist_spread > 1e-9:
        is_conic = (mcp_spread / wrist_spread) > 1.2
    else:
        is_conic = False

    # --- Shape classification ---
    if is_conic:
        shape = "conic"
    elif ratio < 0.85:
        shape = "rectangle"
    elif ratio <= 1.15:
        shape = "square"
    else:
        shape = "spatulate"

    return {
        "palm_shape":        shape,
        "palm_width_ratio":  float(ratio),
        "palm_width":        float(palm_width),
        "finger_proportions": finger_proportions,
    }
