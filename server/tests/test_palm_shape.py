"""Tests for palm shape analysis."""

import math
import pytest

from cv_pipeline.models import Landmark
from cv_pipeline.palm_shape import analyze_palm_shape


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def sample_landmarks() -> list[Landmark]:
    """21 landmarks positioned like a right hand on 640×480."""
    raw = [
        (0.50, 0.90),  # 0 wrist
        (0.35, 0.78), (0.25, 0.68), (0.18, 0.58), (0.12, 0.50),  # 1-4 thumb
        (0.38, 0.55), (0.36, 0.44), (0.35, 0.34), (0.34, 0.26),  # 5-8 index
        (0.50, 0.52), (0.50, 0.40), (0.50, 0.30), (0.50, 0.22),  # 9-12 middle
        (0.62, 0.54), (0.63, 0.42), (0.63, 0.32), (0.63, 0.24),  # 13-16 ring
        (0.74, 0.60), (0.75, 0.50), (0.76, 0.42), (0.77, 0.36),  # 17-20 pinky
    ]
    return [Landmark(x=x, y=y) for x, y in raw]


def _make_landmarks(raw: list[tuple[float, float]]) -> list[Landmark]:
    return [Landmark(x=x, y=y) for x, y in raw]


def _square_landmarks() -> list[Landmark]:
    """Construct a landmark set whose width/height ratio is ~1.0 (square)."""
    # width (index5→pinky17) = 0.36, height (middle9→wrist0) = 0.36
    base = [
        (0.50, 0.90),  # 0 wrist
        (0.35, 0.78), (0.25, 0.68), (0.18, 0.58), (0.12, 0.50),
        (0.32, 0.54), (0.30, 0.43), (0.29, 0.33), (0.28, 0.25),  # index MCP at x=0.32
        (0.50, 0.52), (0.50, 0.40), (0.50, 0.30), (0.50, 0.22),  # middle MCP at (0.50, 0.52)
        (0.62, 0.54), (0.63, 0.42), (0.63, 0.32), (0.63, 0.24),
        (0.68, 0.54), (0.69, 0.44), (0.70, 0.36), (0.71, 0.30),  # pinky MCP at x=0.68
    ]
    return _make_landmarks(base)


def _spatulate_landmarks() -> list[Landmark]:
    """Width >> height → spatulate (ratio > 1.15).

    Designed so that:
      - palm_width  (index5→pinky17) is much larger than palm_height (middle9→wrist0)
      - mcp_spread / wrist_spread <= 1.2  (so conic does NOT fire)

    Layout:
      wrist at (0.50, 0.80), thumb CMC (1) at (0.20, 0.79)
      index MCP (5) at (0.30, 0.60), pinky MCP (17) at (0.70, 0.60)
      → mcp_spread = 0.40, wrist_spread = |0.70-0.20| = 0.50, ratio = 0.80 ≤ 1.2 ✓
      middle MCP (9) at (0.50, 0.58), wrist at (0.50, 0.80)
      → palm_height ≈ 0.22
      palm_width = dist(index5, pinky17) = 0.40
      width/height ratio = 0.40/0.22 ≈ 1.82 > 1.15 → spatulate ✓
    """
    base = [
        (0.50, 0.80),  # 0 wrist
        (0.20, 0.79), (0.18, 0.75), (0.16, 0.70), (0.14, 0.65),  # 1-4 thumb
        (0.30, 0.60), (0.30, 0.50), (0.30, 0.42), (0.30, 0.35),  # 5-8 index MCP
        (0.50, 0.58), (0.50, 0.48), (0.50, 0.40), (0.50, 0.33),  # 9-12 middle MCP
        (0.60, 0.60), (0.61, 0.50), (0.61, 0.42), (0.61, 0.35),  # 13-16 ring
        (0.70, 0.60), (0.71, 0.51), (0.72, 0.43), (0.73, 0.37),  # 17-20 pinky MCP
    ]
    return _make_landmarks(base)


def _rectangle_landmarks() -> list[Landmark]:
    """Height >> width → rectangle (ratio < 0.85)."""
    # narrow width, tall height
    # index MCP x=0.44, pinky MCP x=0.56 → width ≈ 0.12
    # middle MCP y=0.30, wrist y=0.90 → height = 0.60
    base = [
        (0.50, 0.90),  # 0 wrist
        (0.42, 0.78), (0.38, 0.68), (0.35, 0.58), (0.33, 0.50),
        (0.44, 0.55), (0.44, 0.44), (0.44, 0.34), (0.44, 0.26),  # 5 index MCP
        (0.50, 0.30), (0.50, 0.20), (0.50, 0.12), (0.50, 0.06),  # 9 middle MCP y=0.30
        (0.54, 0.55), (0.54, 0.44), (0.54, 0.34), (0.54, 0.26),
        (0.56, 0.58), (0.57, 0.48), (0.57, 0.40), (0.58, 0.34),  # 17 pinky MCP
    ]
    return _make_landmarks(base)


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestAnalyzePalmShape:

    def test_returns_valid_palm_shape(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        valid = {"square", "rectangle", "spatulate", "conic"}
        assert result["palm_shape"] in valid, (
            f"palm_shape {result['palm_shape']!r} not in {valid}"
        )

    def test_palm_width_positive(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        assert result["palm_width"] > 0, "palm_width must be positive"

    def test_palm_width_ratio_positive(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        assert result["palm_width_ratio"] > 0, "palm_width_ratio must be positive"

    def test_finger_proportions_middle_gte_pinky(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        fp = result["finger_proportions"]
        assert "middle" in fp and "pinky" in fp
        assert fp["middle"] >= fp["pinky"], (
            f"middle {fp['middle']} should be >= pinky {fp['pinky']}"
        )

    def test_finger_proportions_all_keys(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        fp = result["finger_proportions"]
        required = {"index", "middle", "ring", "pinky"}
        assert required.issubset(fp.keys()), f"Missing keys: {required - fp.keys()}"

    def test_finger_proportions_middle_is_one(self, sample_landmarks):
        """Middle finger is the reference: normalized value should be 1.0."""
        result = analyze_palm_shape(sample_landmarks)
        assert result["finger_proportions"]["middle"] == pytest.approx(1.0)

    def test_spatulate_shape(self):
        """Wide palm (width >> height) → spatulate."""
        lms = _spatulate_landmarks()
        result = analyze_palm_shape(lms)
        assert result["palm_shape"] == "spatulate", (
            f"Expected spatulate, got {result['palm_shape']} (ratio={result['palm_width_ratio']:.3f})"
        )

    def test_rectangle_shape(self):
        """Tall palm (height >> width) → rectangle."""
        lms = _rectangle_landmarks()
        result = analyze_palm_shape(lms)
        assert result["palm_shape"] == "rectangle", (
            f"Expected rectangle, got {result['palm_shape']} (ratio={result['palm_width_ratio']:.3f})"
        )

    def test_all_required_top_level_keys(self, sample_landmarks):
        result = analyze_palm_shape(sample_landmarks)
        required = {"palm_shape", "palm_width_ratio", "palm_width", "finger_proportions"}
        assert required.issubset(result.keys()), f"Missing: {required - result.keys()}"
