"""Full palm analysis pipeline orchestrator."""

from cv_pipeline.models import (
    AnalyzeRequest,
    PalmAnalysisResponse,
    DetectedLine,
    BezierPoint,
)
from cv_pipeline.preprocess import decode_image
from cv_pipeline.palm_shape import analyze_palm_shape
from cv_pipeline.vision_detect import detect_lines_with_vision


def analyze_palm(request: AnalyzeRequest) -> PalmAnalysisResponse:
    """
    Full palm analysis pipeline.

    Steps
    -----
    1. decode_image
    2. Resolve landmarks (client-supplied or MediaPipe)
    3. analyze_palm_shape from landmarks
    4. detect_lines_with_vision (Claude Vision API)
    5. Convert raw line dicts to DetectedLine objects
    6. Return PalmAnalysisResponse

    Parameters
    ----------
    request:
        :class:`~cv_pipeline.models.AnalyzeRequest` containing the
        base64-encoded image, 21 landmarks, and hand side.

    Returns
    -------
    PalmAnalysisResponse
    """
    # 1. Decode
    image = decode_image(request.image_base64)

    # 2. Resolve landmarks: use client-supplied ones, or detect server-side
    if request.landmarks:
        landmarks = request.landmarks
    else:
        from cv_pipeline.landmark_detect import detect_hand_landmarks
        landmarks = detect_hand_landmarks(image)
        if landmarks is None:
            raise ValueError("No hand detected in image — cannot extract palm landmarks")

    # 3. Palm shape from landmarks
    shape_info = analyze_palm_shape(landmarks)

    # 4. Detect lines with Claude Vision
    raw_lines = detect_lines_with_vision(request.image_base64, landmarks)

    # 5. Convert to DetectedLine objects
    detected_lines: list[DetectedLine] = []
    for line_data in raw_lines:
        control_points = [BezierPoint(x=p["x"], y=p["y"]) for p in line_data["control_points"]]

        # Compute normalized length from control points
        total_len = 0.0
        for i in range(len(control_points) - 1):
            dx = control_points[i + 1].x - control_points[i].x
            dy = control_points[i + 1].y - control_points[i].y
            total_len += (dx ** 2 + dy ** 2) ** 0.5

        detected_lines.append(
            DetectedLine(
                line_type=line_data["line_type"],
                control_points=control_points,
                length=round(total_len, 3),
                depth=line_data.get("depth", "medium"),
                curvature=line_data.get("curvature", "curved"),
                start_point=line_data.get("start_point", "edge"),
                end_point=line_data.get("end_point", "edge"),
            )
        )

    # 6. Build response
    return PalmAnalysisResponse(
        palm_shape=shape_info["palm_shape"],
        palm_width_ratio=shape_info["palm_width_ratio"],
        finger_proportions=shape_info["finger_proportions"],
        lines=detected_lines,
    )
