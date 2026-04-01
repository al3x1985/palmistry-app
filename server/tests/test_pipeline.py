"""Tests for the full palm analysis pipeline orchestrator."""

import pytest

from cv_pipeline.models import AnalyzeRequest, PalmAnalysisResponse, Landmark
from cv_pipeline.pipeline import analyze_palm


# ---------------------------------------------------------------------------
# Tests
# ---------------------------------------------------------------------------

class TestAnalyzePalm:

    def test_returns_palm_analysis_response(self, sample_image_base64, sample_landmarks):
        """Pipeline returns a PalmAnalysisResponse without raising."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        assert isinstance(result, PalmAnalysisResponse)

    def test_valid_palm_shape(self, sample_image_base64, sample_landmarks):
        """palm_shape must be one of the four valid values."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        valid = {"square", "rectangle", "spatulate", "conic"}
        assert result.palm_shape in valid, f"Unexpected palm_shape: {result.palm_shape!r}"

    def test_lines_have_correct_types(self, sample_image_base64, sample_landmarks):
        """Every detected line must have a valid line_type."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        valid_types = {"heart", "head", "life", "fate"}
        for line in result.lines:
            assert line.line_type in valid_types, (
                f"Invalid line_type: {line.line_type!r}"
            )

    def test_lines_have_required_fields(self, sample_image_base64, sample_landmarks):
        """Each DetectedLine must have all required fields populated."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        for line in result.lines:
            assert len(line.control_points) > 0, "control_points must not be empty"
            assert line.depth in ("deep", "medium", "faint")
            assert line.curvature in ("straight", "curved", "steep")
            assert isinstance(line.start_point, str) and line.start_point
            assert isinstance(line.end_point, str) and line.end_point
            assert isinstance(line.length, float)

    def test_no_crash_on_synthetic_image(self, sample_image_base64, sample_landmarks):
        """Pipeline completes without exception on a synthetic image."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="left",
        )
        # Should not raise
        result = analyze_palm(request)
        assert result is not None

    def test_palm_width_ratio_positive(self, sample_image_base64, sample_landmarks):
        """palm_width_ratio must be positive."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        assert result.palm_width_ratio > 0

    def test_finger_proportions_keys(self, sample_image_base64, sample_landmarks):
        """finger_proportions must include index, middle, ring, pinky."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        required = {"index", "middle", "ring", "pinky"}
        assert required.issubset(result.finger_proportions.keys()), (
            f"Missing keys: {required - result.finger_proportions.keys()}"
        )

    def test_control_points_are_bezier_points(self, sample_image_base64, sample_landmarks):
        """control_points on each line must be BezierPoint objects with x, y."""
        request = AnalyzeRequest(
            image_base64=sample_image_base64,
            landmarks=sample_landmarks,
            hand="right",
        )
        result = analyze_palm(request)
        for line in result.lines:
            for cp in line.control_points:
                assert hasattr(cp, "x") and hasattr(cp, "y")
                assert isinstance(cp.x, float) and isinstance(cp.y, float)
