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

        # Heart line: 10-18% below MCP row (tight zone)
        heart_y_min = mcp_y + 0.10 * palm_height
        heart_y_max = mcp_y + 0.18 * palm_height

        # Head line: 22-35% below MCP row
        head_y_min = mcp_y + 0.22 * palm_height
        head_y_max = mcp_y + 0.35 * palm_height

        # Life line: starts at index_mcp area, curves left and down
        life_start_x = index_x
        life_start_y = (head_y_min + head_y_max) / 2

        anchor_info = f"""
PRECISE COORDINATE CONSTRAINTS (derived from hand landmarks):

Heart line (y ≈ {(heart_y_min+heart_y_max)/2:.3f}):
  - Start point: x ≈ {pinky_x:.3f}, y ≈ {(heart_y_min+heart_y_max)/2:.3f}
  - End point: x ≈ {index_x:.3f}, y ≈ {(heart_y_min+heart_y_max)/2:.3f}
  - ALL points y between {heart_y_min:.3f} and {heart_y_max:.3f}
  - Nearly horizontal, slight curve upward in the middle

Head line (y ≈ {(head_y_min+head_y_max)/2:.3f}):
  - Start point: x ≈ {index_x:.3f}, y ≈ {head_y_min:.3f} (same area as life line start)
  - End point: x ≈ {center_x + 0.05:.3f}, y ≈ {head_y_max:.3f} (does NOT extend to pinky — shorter than heart line)
  - Slopes slightly downward from left to right
  - x range: {index_x:.3f} to {center_x + 0.05:.3f}

Life line (starts at x ≈ {index_x:.3f}, y ≈ {head_y_min:.3f}):
  - CRITICAL: starts from the SAME point as head line (thumb-index web)
  - Curves DOWN and strongly to the LEFT around the thumb mount
  - Midpoint should be at x ≈ {thumb_x:.3f}, y ≈ {mcp_y + 0.45 * palm_height:.3f}
  - End point: x ≈ {thumb_x + 0.03:.3f}, y ≈ {wrist_y - 0.15 * palm_height:.3f}
  - This is a DEEP ARC, not a straight line

Fate line (if visible):
  - Vertical, x ≈ {center_x:.3f} (±0.03)
  - From y ≈ {mcp_y + 0.55 * palm_height:.3f} up to y ≈ {head_y_min:.3f}

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

    # Try to extract JSON array from response
    try:
        lines = json.loads(text)
    except json.JSONDecodeError:
        # Try to find JSON array in the text
        start = text.find("[")
        end = text.rfind("]")
        if start != -1 and end != -1 and end > start:
            try:
                lines = json.loads(text[start:end + 1])
            except json.JSONDecodeError:
                # Last resort: return empty
                lines = []
        else:
            lines = []

    return lines
