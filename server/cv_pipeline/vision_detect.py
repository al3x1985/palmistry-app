"""Claude Vision API-based palm line detection."""

import anthropic
import json
import os


def detect_lines_with_vision(image_base64: str, landmarks: list) -> list[dict]:
    """
    Send palm photo to Claude Vision API to detect palm lines.

    Returns list of dicts matching the existing format:
    [
        {
            "line_type": "heart",
            "control_points": [{"x": 0.3, "y": 0.4}, {"x": 0.5, "y": 0.38}, ...],
            "length": 0.65,
            "depth": "deep",
            "curvature": "curved",
            "start_point": "mercury",
            "end_point": "jupiter"
        },
        ...
    ]

    Control points are normalized 0-1 relative to the full image.
    """
    client = anthropic.Anthropic(api_key=os.environ.get("CLAUDE_API_KEY", ""))

    # Build landmark context for Claude
    landmark_desc = ""
    if landmarks:
        lm_names = [
            "wrist", "thumb_cmc", "thumb_mcp", "thumb_ip", "thumb_tip",
            "index_mcp", "index_pip", "index_dip", "index_tip",
            "middle_mcp", "middle_pip", "middle_dip", "middle_tip",
            "ring_mcp", "ring_pip", "ring_dip", "ring_tip",
            "pinky_mcp", "pinky_pip", "pinky_dip", "pinky_tip",
        ]
        landmark_desc = "Hand landmarks detected:\n"
        for i, lm in enumerate(landmarks):
            name = lm_names[i] if i < len(lm_names) else f"point_{i}"
            landmark_desc += f"  {name}: ({lm.x:.3f}, {lm.y:.3f})\n"

    prompt = f"""Analyze this palm photo. Detect the main palm lines and return their positions as normalized coordinates (0-1 relative to image width and height).

{landmark_desc}

For each detected line, provide 4-6 control points that trace the line from start to end. The points should follow the actual visible line on the palm.

Lines to detect:
- heart line: runs horizontally across the upper palm, below the fingers
- head line: runs horizontally across the middle of the palm
- life line: curves from between thumb and index finger down around the thumb base
- fate line: runs vertically from near the wrist up toward the middle finger (may not be present)

For each line also determine:
- length: "short", "medium", or "long" relative to palm width
- depth: "deep" (clearly visible), "medium", or "faint" (barely visible)
- curvature: "straight", "curved", or "steep"
- start_point: nearest palm mount ("jupiter"=under index, "saturn"=under middle, "apollo"=under ring, "mercury"=under pinky, "wrist", "edge")
- end_point: same options

Return ONLY valid JSON array, no markdown:
[
  {{
    "line_type": "heart",
    "control_points": [{{"x": 0.3, "y": 0.4}}, {{"x": 0.45, "y": 0.38}}, {{"x": 0.6, "y": 0.37}}, {{"x": 0.75, "y": 0.39}}],
    "length": "long",
    "depth": "deep",
    "curvature": "curved",
    "start_point": "mercury",
    "end_point": "jupiter"
  }}
]

Only include lines that are actually visible. If a line is not visible, don't include it."""

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
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
