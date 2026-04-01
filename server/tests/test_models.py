import pytest
from pydantic import ValidationError
from cv_pipeline.models import (
    Landmark,
    AnalyzeRequest,
    BezierPoint,
    DetectedLine,
    PalmAnalysisResponse,
)


def make_landmarks(count: int) -> list[dict]:
    return [{"x": i * 0.05, "y": i * 0.05} for i in range(count)]


class TestLandmark:
    def test_landmark_creation(self):
        lm = Landmark(x=0.5, y=0.75)
        assert lm.x == 0.5
        assert lm.y == 0.75

    def test_landmark_float_coercion(self):
        lm = Landmark(x=1, y=0)
        assert isinstance(lm.x, float)
        assert isinstance(lm.y, float)


class TestAnalyzeRequest:
    def test_analyze_request_with_21_landmarks(self):
        data = {
            "image_base64": "abc123",
            "landmarks": make_landmarks(21),
            "hand": "left",
        }
        req = AnalyzeRequest(**data)
        assert len(req.landmarks) == 21
        assert req.hand == "left"

    def test_analyze_request_wrong_landmark_count_raises(self):
        data = {
            "image_base64": "abc123",
            "landmarks": make_landmarks(5),
            "hand": "right",
        }
        with pytest.raises(ValidationError) as exc_info:
            AnalyzeRequest(**data)
        assert "Expected 21 landmarks" in str(exc_info.value)

    def test_analyze_request_zero_landmarks_raises(self):
        data = {
            "image_base64": "abc123",
            "landmarks": [],
            "hand": "right",
        }
        with pytest.raises(ValidationError):
            AnalyzeRequest(**data)

    def test_analyze_request_invalid_hand_raises(self):
        data = {
            "image_base64": "abc123",
            "landmarks": make_landmarks(21),
            "hand": "both",
        }
        with pytest.raises(ValidationError):
            AnalyzeRequest(**data)


class TestDetectedLine:
    def test_detected_line_creation(self):
        line = DetectedLine(
            line_type="heart",
            control_points=[BezierPoint(x=0.1, y=0.2), BezierPoint(x=0.5, y=0.3)],
            length=120.5,
            depth="deep",
            curvature="curved",
            start_point="index_finger_base",
            end_point="pinky_side",
        )
        assert line.line_type == "heart"
        assert len(line.control_points) == 2
        assert line.length == 120.5
        assert line.depth == "deep"
        assert line.curvature == "curved"

    def test_detected_line_invalid_type_raises(self):
        with pytest.raises(ValidationError):
            DetectedLine(
                line_type="mystery",
                control_points=[],
                length=50.0,
                depth="medium",
                curvature="straight",
                start_point="a",
                end_point="b",
            )


class TestPalmAnalysisResponse:
    def test_palm_analysis_response_creation(self):
        heart_line = DetectedLine(
            line_type="heart",
            control_points=[BezierPoint(x=0.2, y=0.3)],
            length=95.0,
            depth="medium",
            curvature="curved",
            start_point="index_base",
            end_point="pinky_edge",
        )
        response = PalmAnalysisResponse(
            palm_shape="square",
            palm_width_ratio=0.85,
            finger_proportions={"index": 0.9, "middle": 1.0, "ring": 0.95, "pinky": 0.7},
            lines=[heart_line],
        )
        assert response.palm_shape == "square"
        assert response.palm_width_ratio == 0.85
        assert "index" in response.finger_proportions
        assert len(response.lines) == 1

    def test_palm_analysis_response_invalid_shape_raises(self):
        with pytest.raises(ValidationError):
            PalmAnalysisResponse(
                palm_shape="triangular",
                palm_width_ratio=0.8,
                finger_proportions={},
                lines=[],
            )
