"""Full palm analysis pipeline orchestrator."""

from cv_pipeline.models import (
    AnalyzeRequest,
    PalmAnalysisResponse,
    DetectedLine,
    BezierPoint,
)
from cv_pipeline.preprocess import decode_image, preprocess_palm
from cv_pipeline.contour_extract import extract_line_candidates
from cv_pipeline.line_classify import classify_lines
from cv_pipeline.bezier_fit import fit_cubic_bezier, bezier_points_to_normalized
from cv_pipeline.characteristics import compute_line_characteristics
from cv_pipeline.palm_shape import analyze_palm_shape
import math


def _palm_width_from_landmarks(landmarks) -> float:
    """Distance index MCP (5) → pinky MCP (17) in normalised space."""
    p5  = landmarks[5]
    p17 = landmarks[17]
    return math.hypot(p17.x - p5.x, p17.y - p5.y)


def analyze_palm(request: AnalyzeRequest) -> PalmAnalysisResponse:
    """
    Full palm analysis pipeline.

    Steps
    -----
    1. decode_image
    2. preprocess_palm
    3. extract_line_candidates
    4. classify_lines
    5. fit_cubic_bezier for each classified line
    6. bezier_points_to_normalized
    7. compute_line_characteristics for each
    8. analyze_palm_shape
    9. Return PalmAnalysisResponse

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

    # Resolve landmarks: use client-supplied ones, or detect server-side
    if request.landmarks:
        landmarks = request.landmarks
    else:
        from cv_pipeline.landmark_detect import detect_hand_landmarks
        landmarks = detect_hand_landmarks(image)
        if landmarks is None:
            raise ValueError("No hand detected in image — cannot extract palm landmarks")

    # 2. Preprocess
    prep = preprocess_palm(image, landmarks)
    edges      = prep["edges"]
    roi_offset = prep["roi_offset"]
    roi_size   = prep["roi_size"]
    orig_size  = prep["original_size"]

    # 3. Extract line candidates (pass geometry for stricter filtering)
    candidates = extract_line_candidates(
        edges,
        roi_size=roi_size,
        landmarks=landmarks,
        original_size=orig_size,
        roi_offset=roi_offset,
    )

    # 4. Classify (pass original_size so landmarks can be projected to ROI coords)
    classified = classify_lines(candidates, landmarks, roi_size, roi_offset, original_size=orig_size)

    # 5-7. Bezier fit + normalize + characteristics
    palm_width = _palm_width_from_landmarks(landmarks)
    detected_lines: list[DetectedLine] = []

    for item in classified:
        line_type = item["line_type"]
        points    = item["points"]

        # 5. Fit cubic bezier (4 control points)
        cp_roi = fit_cubic_bezier(points, num_control_points=4)

        # 6. Normalise to image space
        cp_norm = bezier_points_to_normalized(cp_roi, roi_offset, roi_size, orig_size)

        # 7. Compute characteristics
        chars = compute_line_characteristics(cp_norm, line_type, landmarks, palm_width)

        bezier_points = [BezierPoint(x=float(x), y=float(y)) for x, y in cp_norm]

        detected_lines.append(
            DetectedLine(
                line_type=line_type,
                control_points=bezier_points,
                length=chars["length_raw"],
                depth=chars["depth"],
                curvature=chars["curvature"],
                start_point=chars["start_point"],
                end_point=chars["end_point"],
            )
        )

    # 8. Palm shape
    shape_info = analyze_palm_shape(landmarks)

    # 9. Build response
    return PalmAnalysisResponse(
        palm_shape=shape_info["palm_shape"],
        palm_width_ratio=shape_info["palm_width_ratio"],
        finger_proportions=shape_info["finger_proportions"],
        lines=detected_lines,
    )
