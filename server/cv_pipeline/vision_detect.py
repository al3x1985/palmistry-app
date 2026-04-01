"""Claude Vision API-based palm line detection."""

import anthropic
import json
import os


def detect_lines_with_vision(image_base64: str, landmarks: list) -> list[dict]:
    """Send palm photo to Claude Vision to detect palm lines with precise coordinates."""
    client = anthropic.Anthropic(api_key=os.environ.get("CLAUDE_API_KEY", ""))

    # Build landmark reference so Claude can anchor coordinates
    landmark_ref = ""
    if landmarks:
        lm_names = [
            "wrist", "thumb_cmc", "thumb_mcp", "thumb_ip", "thumb_tip",
            "index_mcp", "index_pip", "index_dip", "index_tip",
            "middle_mcp", "middle_pip", "middle_dip", "middle_tip",
            "ring_mcp", "ring_pip", "ring_dip", "ring_tip",
            "pinky_mcp", "pinky_pip", "pinky_dip", "pinky_tip",
        ]
        landmark_ref = "\nDetected hand landmarks (normalized 0-1 coords, x=left-right, y=top-bottom):\n"
        for i, lm in enumerate(landmarks):
            if i < len(lm_names):
                landmark_ref += f"  {lm_names[i]}: x={lm.x:.3f}, y={lm.y:.3f}\n"

        # Add explicit reference points
        landmark_ref += "\nKey reference positions:\n"
        landmark_ref += f"  Finger bases (MCP row): index={landmarks[5].y:.3f}, middle={landmarks[9].y:.3f}, ring={landmarks[13].y:.3f}, pinky={landmarks[17].y:.3f}\n"
        landmark_ref += f"  Wrist: y={landmarks[0].y:.3f}\n"
        landmark_ref += f"  Palm center: approximately x={0.5*(landmarks[5].x + landmarks[17].x):.3f}, y={0.5*(landmarks[9].y + landmarks[0].y):.3f}\n"

    prompt = f"""You are analyzing a photo of a human palm to detect palm lines. Return precise coordinates that trace EXACTLY along the visible skin creases/folds.

CRITICAL INSTRUCTIONS:
- The coordinates are normalized 0-1 relative to the FULL IMAGE (not just the palm).
- x=0 is the LEFT edge of the image, x=1 is the RIGHT edge.
- y=0 is the TOP of the image, y=1 is the BOTTOM.
- Each control point MUST lie exactly ON a visible crease/fold line in the palm skin. Do NOT approximate or guess — trace the actual visible line.
- Palm lines are the deep visible creases/folds in the palm skin, NOT the finger joints.

{landmark_ref}

LINES TO DETECT (trace the actual visible crease):

1. HEART LINE: The uppermost major horizontal crease across the palm.
   - It runs BELOW the finger base joints (below the MCP row), NOT through the fingers.
   - Typically starts near the pinky side and curves across toward the index finger.
   - It should be in the zone between the MCP row and the middle of the palm.

2. HEAD LINE: The second major horizontal crease, below the heart line.
   - Starts near the thumb/index web and runs across the palm.
   - Often starts at or near the beginning of the life line.

3. LIFE LINE: The curved line that arcs around the thumb base.
   - Starts between the thumb and index finger (near the web).
   - Curves downward and around the fleshy thumb mount (thenar eminence).
   - Does NOT go straight down — it arcs to the LEFT.

4. FATE LINE (if visible): A vertical or near-vertical crease running up the center of the palm.
   - Runs from the lower palm up toward the middle finger.
   - May not be present on all hands — only include if clearly visible.

For each line provide 5-7 control points tracing the crease precisely.

Also determine for each line:
- length: "short" / "medium" / "long"
- depth: "deep" (dark, clearly visible) / "medium" / "faint"
- curvature: "straight" / "curved" / "steep"
- start_point: nearest mount ("jupiter"=under index, "saturn"=under middle, "apollo"=under ring, "mercury"=under pinky, "wrist", "edge")
- end_point: same options

Return ONLY a valid JSON array, no markdown fences, no explanations:
[
  {{
    "line_type": "heart",
    "control_points": [{{"x": 0.3, "y": 0.42}}, ...],
    "length": "long",
    "depth": "deep",
    "curvature": "curved",
    "start_point": "mercury",
    "end_point": "jupiter"
  }}
]"""

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
