"""Refine Claude Vision line coordinates by snapping to actual skin creases.

Takes approximate line positions from Vision API and adjusts each control
point to the nearest strong edge (real crease) in the palm image.
"""

import cv2
import numpy as np


def _preprocess_for_creases(image: np.ndarray) -> np.ndarray:
    """Create an edge map optimized for detecting skin creases."""
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # CLAHE for contrast
    clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(gray)

    # Bilateral filter — smooth skin texture, keep crease edges
    smoothed = cv2.bilateralFilter(enhanced, d=9, sigmaColor=50, sigmaSpace=50)

    # Canny with moderate thresholds
    edges = cv2.Canny(smoothed, 30, 90)

    # Dilate slightly to make creases wider for easier snapping
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    edges = cv2.dilate(edges, kernel, iterations=1)

    return edges


def _snap_point_to_edge(
    edges: np.ndarray,
    px: int,
    py: int,
    search_radius: int = 30,
) -> tuple[int, int]:
    """Find the nearest edge pixel to (px, py) within search_radius.

    If no edge found within radius, return original point.
    """
    h, w = edges.shape[:2]

    # Search in a square around the point
    y_min = max(0, py - search_radius)
    y_max = min(h, py + search_radius)
    x_min = max(0, px - search_radius)
    x_max = min(w, px + search_radius)

    roi = edges[y_min:y_max, x_min:x_max]

    # Find all edge pixels in the ROI
    edge_ys, edge_xs = np.nonzero(roi)

    if len(edge_xs) == 0:
        return px, py

    # Convert to absolute coords
    abs_xs = edge_xs + x_min
    abs_ys = edge_ys + y_min

    # Find closest edge pixel
    dists = (abs_xs - px) ** 2 + (abs_ys - py) ** 2
    closest_idx = np.argmin(dists)

    return int(abs_xs[closest_idx]), int(abs_ys[closest_idx])


def _snap_line_to_edges(
    edges: np.ndarray,
    points: list[dict],
    img_w: int,
    img_h: int,
    search_radius: int = 25,
) -> list[dict]:
    """Snap all control points of a line to nearest creases.

    Also adds intermediate points along the line and snaps those too,
    for better tracing of curved creases.
    """
    # Convert normalized to pixel
    pixel_pts = [(int(p["x"] * img_w), int(p["y"] * img_h)) for p in points]

    # Densify: add midpoints between each pair for better tracing
    dense_pts = []
    for i in range(len(pixel_pts)):
        dense_pts.append(pixel_pts[i])
        if i < len(pixel_pts) - 1:
            mx = (pixel_pts[i][0] + pixel_pts[i + 1][0]) // 2
            my = (pixel_pts[i][1] + pixel_pts[i + 1][1]) // 2
            dense_pts.append((mx, my))

    # Snap each point
    snapped = []
    for px, py in dense_pts:
        sx, sy = _snap_point_to_edge(edges, px, py, search_radius)
        snapped.append((sx, sy))

    # Smooth: moving average to avoid jagged lines
    if len(snapped) >= 3:
        smoothed = [snapped[0]]
        for i in range(1, len(snapped) - 1):
            sx = (snapped[i - 1][0] + snapped[i][0] + snapped[i + 1][0]) // 3
            sy = (snapped[i - 1][1] + snapped[i][1] + snapped[i + 1][1]) // 3
            smoothed.append((sx, sy))
        smoothed.append(snapped[-1])
        snapped = smoothed

    # Subsample back to ~original density (pick every other)
    if len(snapped) > len(points) + 2:
        indices = np.linspace(0, len(snapped) - 1, len(points), dtype=int)
        snapped = [snapped[i] for i in indices]

    # Convert back to normalized
    return [{"x": round(px / img_w, 4), "y": round(py / img_h, 4)} for px, py in snapped]


def refine_lines(
    image: np.ndarray,
    lines: list[dict],
) -> list[dict]:
    """Refine all detected lines by snapping to actual creases in the image.

    Parameters
    ----------
    image : np.ndarray
        Original BGR palm image.
    lines : list[dict]
        Lines from Claude Vision, each with 'control_points' as normalized coords.

    Returns
    -------
    list[dict]
        Same lines with refined control_points.
    """
    h, w = image.shape[:2]
    edges = _preprocess_for_creases(image)

    # Adaptive search radius based on image size
    search_radius = max(15, min(40, w // 30))

    refined = []
    for line in lines:
        new_line = dict(line)
        new_line["control_points"] = _snap_line_to_edges(
            edges, line["control_points"], w, h, search_radius
        )
        refined.append(new_line)

    return refined
