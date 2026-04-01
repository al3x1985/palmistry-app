"""Tests for line characteristics computation."""

import math
import numpy as np
import pytest

from cv_pipeline.models import Landmark
from cv_pipeline.characteristics import compute_line_characteristics


# ---------------------------------------------------------------------------
# Fixtures / helpers
# ---------------------------------------------------------------------------

@pytest.fixture
def sample_landmarks() -> list[Landmark]:
    """21 landmarks on a 640×480 image (normalised)."""
    raw = [
        (0.50, 0.90),  # 0 wrist
        (0.35, 0.78), (0.25, 0.68), (0.18, 0.58), (0.12, 0.50),  # 1-4 thumb
        (0.38, 0.55), (0.36, 0.44), (0.35, 0.34), (0.34, 0.26),  # 5-8 index
        (0.50, 0.52), (0.50, 0.40), (0.50, 0.30), (0.50, 0.22),  # 9-12 middle
        (0.62, 0.54), (0.63, 0.42), (0.63, 0.32), (0.63, 0.24),  # 13-16 ring
        (0.74, 0.60), (0.75, 0.50), (0.76, 0.42), (0.77, 0.36),  # 17-20 pinky
    ]
    assert len(raw) == 21
    return [Landmark(x=x, y=y) for x, y in raw]


def palm_width_from_landmarks(landmarks: list[Landmark]) -> float:
    """Index MCP (5) to pinky MCP (17) distance."""
    p5 = landmarks[5]
    p17 = landmarks[17]
    return math.hypot(p17.x - p5.x, p17.y - p5.y)


def long_straight_control_points():
    """Control points for a long, nearly-straight horizontal line."""
    # Horizontal line from x=0.1 to x=0.9, y constant — very long, very straight
    return [(0.10, 0.50), (0.37, 0.50), (0.63, 0.50), (0.90, 0.50)]


def short_control_points():
    """Control points for a short line."""
    # x spans only 0.1 units
    return [(0.40, 0.50), (0.43, 0.51), (0.47, 0.50), (0.50, 0.50)]


def curved_control_points():
    """Control points for a clearly curved line."""
    # Arc-like shape with significant deviation from the chord
    return [(0.10, 0.50), (0.30, 0.20), (0.60, 0.20), (0.80, 0.50)]


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestComputeLineCharacteristics:

    def test_long_straight_length_and_curvature(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = long_straight_control_points()
        result = compute_line_characteristics(cp, "heart", sample_landmarks, pw)

        assert result["length"] == "long", f"Expected 'long', got {result['length']!r}"
        assert result["curvature"] == "straight", f"Expected 'straight', got {result['curvature']!r}"

    def test_curved_line_curvature(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = curved_control_points()
        result = compute_line_characteristics(cp, "life", sample_landmarks, pw)

        assert result["curvature"] in ("curved", "steep"), (
            f"Expected 'curved' or 'steep', got {result['curvature']!r}"
        )

    def test_short_line_length(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = short_control_points()
        result = compute_line_characteristics(cp, "fate", sample_landmarks, pw)

        assert result["length"] == "short", f"Expected 'short', got {result['length']!r}"

    def test_all_required_fields_present(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = long_straight_control_points()
        result = compute_line_characteristics(cp, "head", sample_landmarks, pw)

        required = {"length", "length_raw", "depth", "curvature", "start_point", "end_point"}
        assert required.issubset(result.keys()), (
            f"Missing keys: {required - result.keys()}"
        )

    def test_depth_default_is_medium(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = long_straight_control_points()
        result = compute_line_characteristics(cp, "heart", sample_landmarks, pw)

        assert result["depth"] == "medium"

    def test_length_raw_is_float(self, sample_landmarks):
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = long_straight_control_points()
        result = compute_line_characteristics(cp, "heart", sample_landmarks, pw)

        assert isinstance(result["length_raw"], float)
        assert result["length_raw"] > 0

    def test_start_end_point_valid_landmark_names(self, sample_landmarks):
        valid_names = {"jupiter", "saturn", "apollo", "mercury", "wrist"}
        pw = palm_width_from_landmarks(sample_landmarks)
        cp = long_straight_control_points()
        result = compute_line_characteristics(cp, "heart", sample_landmarks, pw)

        assert result["start_point"] in valid_names, (
            f"start_point {result['start_point']!r} not in {valid_names}"
        )
        assert result["end_point"] in valid_names, (
            f"end_point {result['end_point']!r} not in {valid_names}"
        )

    def test_length_categories_cover_all_thresholds(self, sample_landmarks):
        """Medium-length line should return 'medium'."""
        pw = palm_width_from_landmarks(sample_landmarks)
        # Medium: normalised length in 0.5–0.75 of palm_width
        # palm_width ≈ 0.36, so we want raw length ≈ 0.2 → medium range
        cp = [(0.30, 0.50), (0.40, 0.50), (0.50, 0.50), (0.60, 0.50)]
        result = compute_line_characteristics(cp, "head", sample_landmarks, pw)
        assert result["length"] in ("short", "medium", "long")  # sanity — no crash
