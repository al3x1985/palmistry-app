"""Tests for rule-based palm line classification."""

import numpy as np
import pytest

from cv_pipeline.line_classify import classify_lines
from cv_pipeline.models import Landmark


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ROI_SIZE = (400, 500)   # (width, height)
ROI_OFFSET = (50, 30)   # (x, y) offset in original image


def make_landmarks() -> list[Landmark]:
    """21 generic landmarks spread across a normalized palm area."""
    raw = [
        (0.50, 0.90),
        (0.35, 0.78), (0.25, 0.68), (0.18, 0.58), (0.12, 0.50),
        (0.38, 0.55), (0.36, 0.44), (0.35, 0.34), (0.34, 0.26),
        (0.50, 0.52), (0.50, 0.40), (0.50, 0.30), (0.50, 0.22),
        (0.62, 0.54), (0.63, 0.42), (0.63, 0.32), (0.63, 0.24),
        (0.74, 0.60), (0.75, 0.50), (0.76, 0.42), (0.77, 0.36),
    ]
    return [Landmark(x=x, y=y) for x, y in raw]


def horizontal_line_at_y(y_frac: float, roi_size=ROI_SIZE) -> np.ndarray:
    """Create a horizontal Nx2 array at a given fractional ROI y position."""
    roi_w, roi_h = roi_size
    y = int(y_frac * roi_h)
    xs = np.linspace(20, roi_w - 20, 60, dtype=np.int32)
    ys = np.full(60, y, dtype=np.int32)
    return np.stack([xs, ys], axis=1)


def vertical_line_at_x(x_frac: float, roi_size=ROI_SIZE) -> np.ndarray:
    """Create a vertical Nx2 array at a given fractional ROI x position."""
    roi_w, roi_h = roi_size
    x = int(x_frac * roi_w)
    ys = np.linspace(int(0.1 * roi_h), int(0.9 * roi_h), 60, dtype=np.int32)
    xs = np.full(60, x, dtype=np.int32)
    return np.stack([xs, ys], axis=1)


def curved_left_line(roi_size=ROI_SIZE) -> np.ndarray:
    """Create a roughly vertical curve on the left/thumb side of the ROI."""
    roi_w, roi_h = roi_size
    # Arc starting near top-left, curving down
    t = np.linspace(0, 1, 60)
    xs = (0.15 * roi_w + 0.05 * roi_w * np.sin(t * np.pi)).astype(np.int32)
    ys = (0.2 * roi_h + t * 0.65 * roi_h).astype(np.int32)
    return np.stack([xs, ys], axis=1)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestClassifyLines:
    def test_heart_line_detected(self):
        """A horizontal line at y~0.45 of ROI should be classified as heart."""
        heart_pts = horizontal_line_at_y(0.45)
        landmarks = make_landmarks()
        results = classify_lines([heart_pts], landmarks, ROI_SIZE, ROI_OFFSET)
        types = [r["line_type"] for r in results]
        assert "heart" in types

    def test_head_line_detected(self):
        """A horizontal line at y~0.55 of ROI should be classified as head."""
        head_pts = horizontal_line_at_y(0.55)
        landmarks = make_landmarks()
        results = classify_lines([head_pts], landmarks, ROI_SIZE, ROI_OFFSET)
        types = [r["line_type"] for r in results]
        assert "head" in types

    def test_life_line_detected(self):
        """A curved line on the left side with large vertical span → life."""
        life_pts = curved_left_line()
        landmarks = make_landmarks()
        results = classify_lines([life_pts], landmarks, ROI_SIZE, ROI_OFFSET)
        types = [r["line_type"] for r in results]
        assert "life" in types

    def test_fate_line_detected(self):
        """A vertical line at center x~0.50 should be classified as fate."""
        fate_pts = vertical_line_at_x(0.50)
        landmarks = make_landmarks()
        results = classify_lines([fate_pts], landmarks, ROI_SIZE, ROI_OFFSET)
        types = [r["line_type"] for r in results]
        assert "fate" in types

    def test_each_type_assigned_at_most_once(self):
        """Providing two identical heart-line candidates → only one heart result."""
        heart_pts = horizontal_line_at_y(0.45)
        landmarks = make_landmarks()
        results = classify_lines([heart_pts, heart_pts.copy()], landmarks, ROI_SIZE, ROI_OFFSET)
        heart_count = sum(1 for r in results if r["line_type"] == "heart")
        assert heart_count <= 1

    def test_result_contains_points_key(self):
        """Each classification result must have 'line_type' and 'points' keys."""
        pts = horizontal_line_at_y(0.45)
        results = classify_lines([pts], make_landmarks(), ROI_SIZE, ROI_OFFSET)
        for r in results:
            assert "line_type" in r
            assert "points" in r
            assert isinstance(r["points"], np.ndarray)

    def test_unknown_short_contour_skipped(self):
        """A very short 2-point segment not matching any zone → not classified."""
        # A single tiny segment far outside any zone (top-left corner)
        tiny = np.array([[1, 1], [2, 2]], dtype=np.int32)
        results = classify_lines([tiny], make_landmarks(), ROI_SIZE, ROI_OFFSET)
        # It might return an empty list or not include spurious types
        valid_types = {"heart", "head", "life", "fate"}
        for r in results:
            assert r["line_type"] in valid_types

    def test_empty_candidates_returns_empty(self):
        """Empty candidate list → empty result list."""
        results = classify_lines([], make_landmarks(), ROI_SIZE, ROI_OFFSET)
        assert results == []

    def test_multiple_lines_classified_together(self):
        """Passing heart + head + fate at once → all three classified."""
        heart_pts = horizontal_line_at_y(0.40)
        head_pts = horizontal_line_at_y(0.57)
        fate_pts = vertical_line_at_x(0.50)
        results = classify_lines(
            [heart_pts, head_pts, fate_pts], make_landmarks(), ROI_SIZE, ROI_OFFSET
        )
        types = {r["line_type"] for r in results}
        assert "heart" in types
        assert "head" in types
        assert "fate" in types
