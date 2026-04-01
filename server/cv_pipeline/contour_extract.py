"""Contour extraction from edge images for palm line detection."""

import cv2
import numpy as np


def extract_line_candidates(
    edges: np.ndarray,
    min_length: float = 40,
    max_candidates: int = 20,
) -> list[np.ndarray]:
    """Extract line candidates from an edge image.

    Parameters
    ----------
    edges:
        2D uint8 edge map (e.g. output of Canny / adaptive threshold).
    min_length:
        Minimum arc length (in pixels) a contour must have to be included.
    max_candidates:
        Maximum number of candidates to return.

    Returns
    -------
    list[np.ndarray]
        Each element is an Nx2 int32 array of (x, y) points, sorted by arc
        length descending.
    """
    # Dilate to connect nearby edge fragments
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
    dilated = cv2.dilate(edges, kernel, iterations=1)

    contours, _ = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Filter by arc length and reshape to Nx2
    candidates: list[tuple[float, np.ndarray]] = []
    for cnt in contours:
        length = cv2.arcLength(cnt, False)
        if length >= min_length:
            # cnt has shape (N, 1, 2); squeeze to (N, 2)
            pts = cnt.reshape(-1, 2)
            candidates.append((length, pts))

    # Sort descending by arc length
    candidates.sort(key=lambda x: x[0], reverse=True)

    # Return at most max_candidates, dropping the length scalar
    return [pts for _, pts in candidates[:max_candidates]]
