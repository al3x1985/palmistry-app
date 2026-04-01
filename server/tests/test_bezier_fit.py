"""Tests for Bezier/B-spline curve fitting."""

import numpy as np
import pytest

from cv_pipeline.bezier_fit import fit_cubic_bezier, bezier_points_to_normalized


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def arc_points(n: int = 60) -> np.ndarray:
    """Generate n points along a smooth arc."""
    t = np.linspace(0, np.pi, n)
    xs = (50 + 150 * np.cos(t)).astype(np.float64)
    ys = (100 + 80 * np.sin(t)).astype(np.float64)
    return np.stack([xs, ys], axis=1)


def line_points(n: int = 40) -> np.ndarray:
    """Generate n points along a diagonal line."""
    xs = np.linspace(10, 300, n)
    ys = np.linspace(20, 250, n)
    return np.stack([xs, ys], axis=1)


# ---------------------------------------------------------------------------
# fit_cubic_bezier tests
# ---------------------------------------------------------------------------

class TestFitCubicBezier:
    def test_returns_correct_default_num_control_points(self):
        """Default call returns exactly 4 control points."""
        pts = arc_points()
        result = fit_cubic_bezier(pts)
        assert len(result) == 4

    def test_returns_correct_custom_num_control_points(self):
        """Requesting 6 control points returns exactly 6."""
        pts = arc_points(80)
        result = fit_cubic_bezier(pts, num_control_points=6)
        assert len(result) == 6

    def test_control_points_are_tuples_of_floats(self):
        """Each control point must be a tuple of two floats."""
        pts = arc_points()
        result = fit_cubic_bezier(pts)
        for cp in result:
            assert isinstance(cp, tuple)
            assert len(cp) == 2
            assert isinstance(cp[0], float)
            assert isinstance(cp[1], float)

    def test_preserves_start_endpoint_within_tolerance(self):
        """First and last control points should be close to the input endpoints."""
        pts = line_points()
        result = fit_cubic_bezier(pts, num_control_points=4)
        start_cp = np.array(result[0])
        end_cp = np.array(result[-1])
        start_ref = pts[0]
        end_ref = pts[-1]
        tolerance = 30.0  # pixels — spline may not pass exactly through ends
        assert np.linalg.norm(start_cp - start_ref) < tolerance, (
            f"Start control point {start_cp} too far from input start {start_ref}"
        )
        assert np.linalg.norm(end_cp - end_ref) < tolerance, (
            f"End control point {end_cp} too far from input end {end_ref}"
        )

    def test_works_with_many_control_points(self):
        """Requesting 8 control points from a dense arc works without error."""
        pts = arc_points(100)
        result = fit_cubic_bezier(pts, num_control_points=8)
        assert len(result) == 8

    def test_fallback_with_two_points(self):
        """Degenerate 2-point input falls back gracefully."""
        pts = np.array([[0.0, 0.0], [100.0, 100.0]])
        result = fit_cubic_bezier(pts, num_control_points=4)
        assert len(result) == 4

    def test_values_are_finite(self):
        """All control point coordinates must be finite numbers."""
        pts = arc_points()
        result = fit_cubic_bezier(pts)
        for x, y in result:
            assert np.isfinite(x), f"Non-finite x: {x}"
            assert np.isfinite(y), f"Non-finite y: {y}"


# ---------------------------------------------------------------------------
# bezier_points_to_normalized tests
# ---------------------------------------------------------------------------

class TestBezierPointsToNormalized:
    def test_produces_values_in_zero_one_range(self):
        """Normalized output coords must lie in [0, 1]."""
        roi_offset = (50, 30)
        roi_size = (300, 400)
        img_size = (640, 480)
        # Control points fully within the ROI
        control_points = [
            (60.0, 50.0),
            (120.0, 150.0),
            (200.0, 250.0),
            (260.0, 350.0),
        ]
        normalized = bezier_points_to_normalized(
            control_points, roi_offset, roi_size, img_size
        )
        for x, y in normalized:
            assert 0.0 <= x <= 1.0, f"x={x} out of [0,1]"
            assert 0.0 <= y <= 1.0, f"y={y} out of [0,1]"

    def test_correct_normalization_math(self):
        """A point at the ROI origin should map to the ROI offset in image space."""
        roi_offset = (100, 80)
        roi_size = (200, 300)
        img_size = (640, 480)
        # A point at (0, 0) in ROI coords maps to pixel (100, 80) in image → (100/640, 80/480)
        control_points = [(0.0, 0.0)]
        normalized = bezier_points_to_normalized(
            control_points, roi_offset, roi_size, img_size
        )
        assert len(normalized) == 1
        expected_x = 100.0 / 640.0
        expected_y = 80.0 / 480.0
        assert abs(normalized[0][0] - expected_x) < 1e-6
        assert abs(normalized[0][1] - expected_y) < 1e-6

    def test_returns_same_count_as_input(self):
        """Output list has same length as input control points."""
        roi_offset = (0, 0)
        roi_size = (640, 480)
        img_size = (640, 480)
        control_points = [(10.0, 20.0), (200.0, 100.0), (400.0, 300.0)]
        normalized = bezier_points_to_normalized(
            control_points, roi_offset, roi_size, img_size
        )
        assert len(normalized) == 3

    def test_output_is_list_of_tuples(self):
        """Return type must be a list of (float, float) tuples."""
        roi_offset = (0, 0)
        roi_size = (640, 480)
        img_size = (640, 480)
        control_points = [(100.0, 200.0)]
        normalized = bezier_points_to_normalized(
            control_points, roi_offset, roi_size, img_size
        )
        assert isinstance(normalized, list)
        assert isinstance(normalized[0], tuple)
        assert len(normalized[0]) == 2
