from pydantic import BaseModel, field_validator
from typing import Literal


class Landmark(BaseModel):
    x: float  # normalized 0-1
    y: float


class AnalyzeRequest(BaseModel):
    image_base64: str
    # Optional — when omitted or None the server detects landmarks automatically.
    # When provided, must be exactly 21 points.
    landmarks: list[Landmark] | None = None
    hand: Literal["left", "right"]

    @field_validator("landmarks")
    @classmethod
    def check_landmark_count(cls, v):
        if v is not None and len(v) != 21:
            raise ValueError(f"Expected 21 landmarks, got {len(v)}")
        return v


class BezierPoint(BaseModel):
    x: float
    y: float


class DetectedLine(BaseModel):
    line_type: Literal["heart", "head", "life", "fate"]
    control_points: list[BezierPoint]
    length: float
    depth: Literal["deep", "medium", "faint"]
    curvature: Literal["straight", "curved", "steep"]
    start_point: str
    end_point: str


class PalmAnalysisResponse(BaseModel):
    palm_shape: Literal["square", "rectangle", "spatulate", "conic"]
    palm_width_ratio: float
    finger_proportions: dict[str, float]
    lines: list[DetectedLine]
