"""Claude Vision API-based palm line detection."""

import anthropic
import json
import os


def detect_lines_with_vision(image_base64: str, landmarks: list) -> list[dict]:
    """Send palm photo to Claude Vision to detect palm lines with precise coordinates."""
    client = anthropic.Anthropic(api_key=os.environ.get("CLAUDE_API_KEY", ""))

    # Compute anchor zones from landmarks to constrain Claude's output
    anchor_info = ""
    if landmarks and len(landmarks) >= 21:
        # Key Y positions
        mcp_y = (landmarks[5].y + landmarks[9].y + landmarks[13].y + landmarks[17].y) / 4
        wrist_y = landmarks[0].y
        palm_height = wrist_y - mcp_y

        # Key X positions
        thumb_x = landmarks[2].x
        index_x = landmarks[5].x
        pinky_x = landmarks[17].x
        center_x = (index_x + pinky_x) / 2

        # Heart line zone: 10-25% below MCP row
        heart_y_min = mcp_y + 0.10 * palm_height
        heart_y_max = mcp_y + 0.25 * palm_height

        # Head line zone: 25-45% below MCP row
        head_y_min = mcp_y + 0.25 * palm_height
        head_y_max = mcp_y + 0.45 * palm_height

        # Life line: starts near index_mcp, curves to left
        life_start_x = (thumb_x + index_x) / 2
        life_start_y = head_y_min

        anchor_info = f"""
PRECISE COORDINATE CONSTRAINTS (derived from hand landmarks):

Heart line Y range: {heart_y_min:.3f} to {heart_y_max:.3f}
  - Must start near pinky side: x ≈ {pinky_x:.3f}
  - Must end near index/middle area: x ≈ {index_x:.3f} to {landmarks[9].x:.3f}
  - ALL control points must have y between {heart_y_min:.3f} and {heart_y_max:.3f}

Head line Y range: {head_y_min:.3f} to {head_y_max:.3f}
  - Must start near thumb-index web: x ≈ {life_start_x:.3f}, y ≈ {head_y_min:.3f}
  - Runs across to the right, may slope slightly downward
  - ALL control points must have y between {head_y_min:.3f} and {head_y_max:.3f}

Life line:
  - Must start near thumb-index web: x ≈ {life_start_x:.3f}, y ≈ {life_start_y:.3f}
  - Curves DOWN and LEFT around the thumb mount
  - End point should be near: x ≈ {thumb_x:.3f} to {life_start_x:.3f}, y ≈ {wrist_y - 0.1 * palm_height:.3f}
  - x values should DECREASE then slightly increase (arc shape)

Fate line (if visible):
  - Runs vertically near palm center: x ≈ {center_x:.3f} (±0.05)
  - From lower palm (y ≈ {mcp_y + 0.6 * palm_height:.3f}) up to mid-palm (y ≈ {head_y_min:.3f})

Palm boundaries: left edge x ≈ {min(thumb_x, index_x) - 0.02:.3f}, right edge x ≈ {pinky_x + 0.02:.3f}
Wrist: y ≈ {wrist_y:.3f}
Finger bases: y ≈ {mcp_y:.3f}
"""

    prompt = f"""Analyze this palm photo. Trace the visible skin creases (palm lines) with precise normalized coordinates (0-1 of full image, x=left-right, y=top-bottom).

RULES:
- Each point must lie ON a visible crease in the skin
- Follow the coordinate constraints below — they are computed from detected hand position
- Provide 5-7 points per line, evenly spaced along the crease
- Only include lines that are clearly visible
{anchor_info}
LINES:
1. HEART LINE — uppermost horizontal crease, below finger bases
2. HEAD LINE — second horizontal crease, below heart line
3. LIFE LINE — curved arc around thumb mount (thenar eminence)
4. FATE LINE — vertical crease up the center (only if visible)

For each line:
- line_type: "heart" / "head" / "life" / "fate"
- control_points: [{{"x": float, "y": float}}, ...] — 5-7 points ON the crease
- length: "short" / "medium" / "long"
- depth: "deep" / "medium" / "faint"
- curvature: "straight" / "curved" / "steep"
- start_point: "jupiter" / "saturn" / "apollo" / "mercury" / "wrist" / "edge"
- end_point: same

Return ONLY valid JSON array:
[{{"line_type":"heart","control_points":[{{"x":0.7,"y":0.45}},...], "length":"long","depth":"deep","curvature":"curved","start_point":"mercury","end_point":"jupiter"}}]"""

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=2048,
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": image_base64,
                        },
                    },
                    {
                        "type": "text",
                        "text": prompt,
                    },
                ],
            }
        ],
    )

    text = response.content[0].text.strip()

    # Strip markdown fences if present
    if text.startswith("```"):
        text = text.split("\n", 1)[1]
        text = text.rsplit("```", 1)[0]
        text = text.strip()

    lines = json.loads(text)
    return lines
