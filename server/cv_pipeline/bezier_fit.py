"""Bezier/B-spline curve fitting for palm line control points."""

import numpy as np

try:
    from scipy.interpolate import splprep, splev
    _SCIPY_AVAILABLE = True
except ImportError:  # pragma: no cover
    _SCIPY_AVAILABLE = False


def fit_cubic_bezier(
    points: np.ndarray,
    num_control_points: int = 4,
) -> list[tuple[float, float]]:
    """Fit a B-spline to *points* and return evenly-sampled control points.

    Parameters
    ----------
    points:
        Nx2 float/int array of (x, y) coordinates.
    num_control_points:
        Number of control points to return (default 4 → cubic Bezier corners).

    Returns
    -------
    list[tuple[float, float]]
        *num_control_points* (x, y) tuples sampled evenly along the fitted
        spline.  Falls back to evenly sampling from the original point array
        if the spline fit fails (e.g. too few unique points).
    """
    pts = np.array(points, dtype=float)
    if pts.ndim != 2 or pts.shape[1] != 2:
        raise ValueError(f"points must be Nx2, got shape {pts.shape}")

    n = len(pts)
    t_sample = np.linspace(0, 1, num_control_points)

    # --- Try B-spline via scipy ---
    if _SCIPY_AVAILABLE and n >= 4:
        try:
            # Remove duplicate consecutive points to avoid splprep errors
            diffs = np.diff(pts, axis=0)
            keep = np.concatenate([[True], np.any(diffs != 0, axis=1)])
            pts_unique = pts[keep]

            if len(pts_unique) >= 4:
                # degree k: use cubic (3) but cap at n-1
                k = min(3, len(pts_unique) - 1)
                tck, _ = splprep([pts_unique[:, 0], pts_unique[:, 1]], s=0, k=k)
                x_new, y_new = splev(t_sample, tck)
                return [(float(x), float(y)) for x, y in zip(x_new, y_new)]
        except Exception:
            pass  # fall through to fallback

    # --- Fallback: evenly sample from original points ---
    indices = np.round(np.linspace(0, n - 1, num_control_points)).astype(int)
    return [(float(pts[i, 0]), float(pts[i, 1])) for i in indices]


def bezier_points_to_normalized(
    control_points: list[tuple[float, float]],
    roi_offset: tuple[int, int],
    roi_size: tuple[int, int],
    img_size: tuple[int, int],
) -> list[tuple[float, float]]:
    """Convert ROI-relative pixel coordinates to normalised image coordinates.

    Parameters
    ----------
    control_points:
        List of (x, y) tuples in ROI pixel space.
    roi_offset:
        (x, y) pixel offset of the ROI top-left corner in the original image.
    roi_size:
        (width, height) of the ROI in pixels.  Currently unused in the
        computation but retained for API consistency.
    img_size:
        (width, height) of the full original image in pixels.

    Returns
    -------
    list[tuple[float, float]]
        Each coordinate normalised to [0, 1] relative to the full image.
    """
    off_x, off_y = roi_offset
    img_w, img_h = img_size

    normalized: list[tuple[float, float]] = []
    for x, y in control_points:
        norm_x = (x + off_x) / img_w
        norm_y = (y + off_y) / img_h
        normalized.append((float(norm_x), float(norm_y)))

    return normalized
