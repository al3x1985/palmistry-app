# CV Pipeline Implementation Plan (Plan 1 of 3)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Python FastAPI server that accepts a palm photo + MediaPipe landmarks, detects palm lines via OpenCV, classifies them, fits bezier curves, and returns structured JSON with line data and palm characteristics. Deployable to Cloud Run.

**Architecture:** FastAPI receives POST with base64 image + landmarks JSON. Pipeline: preprocess (grayscale, CLAHE, blur) → Canny edge detection → contour extraction → rule-based line classification using landmark positions → cubic bezier fitting → line characteristic computation. Returns JSON with lines (bezier points, type, length, depth, curvature) + palm shape + finger proportions.

**Tech Stack:** Python 3.12, FastAPI, OpenCV (opencv-python-headless), NumPy, SciPy (bezier fitting), uvicorn, Docker, pytest

---

## File Structure

```
server/
├── requirements.txt
├── Dockerfile
├── docker-compose.yml           — local dev
├── main.py                      — FastAPI app entry point
├── cv_pipeline/
│   ├── __init__.py
│   ├── models.py                — Pydantic request/response models
│   ├── preprocess.py            — grayscale, CLAHE, blur, ROI crop
│   ├── edge_detect.py           — Canny + adaptive threshold
│   ├── contour_extract.py       — findContours, filter, candidates
│   ├── line_classify.py         — rule-based classification by landmark position
│   ├── bezier_fit.py            — cubic bezier approximation
│   ├── characteristics.py       — length, depth, curvature, start/end point
│   ├── palm_shape.py            — palm shape + finger proportions from landmarks
│   └── pipeline.py              — orchestrates all steps
├── tests/
│   ├── conftest.py              — fixtures (sample image, landmarks)
│   ├── test_models.py
│   ├── test_preprocess.py
│   ├── test_edge_detect.py
│   ├── test_contour_extract.py
│   ├── test_line_classify.py
│   ├── test_bezier_fit.py
│   ├── test_characteristics.py
│   ├── test_palm_shape.py
│   ├── test_pipeline.py
│   └── test_api.py              — FastAPI endpoint tests
└── fixtures/
    └── sample_palm.jpg          — test fixture image
```

---

## Task 1: Project Scaffolding

**Files:**
- Create: `server/requirements.txt`
- Create: `server/main.py`
- Create: `server/cv_pipeline/__init__.py`
- Create: `server/Dockerfile`
- Create: `server/docker-compose.yml`

- [ ] **Step 1: Create requirements.txt**

Create `server/requirements.txt`:

```
fastapi==0.115.0
uvicorn[standard]==0.30.0
opencv-python-headless==4.10.0.84
numpy>=1.26.0
scipy>=1.13.0
python-multipart==0.0.9
pydantic>=2.0.0
pytest==8.3.0
httpx==0.27.0
```

- [ ] **Step 2: Create minimal FastAPI app**

Create `server/main.py`:

```python
from fastapi import FastAPI

app = FastAPI(title="Palmistry CV Pipeline", version="1.0.0")


@app.get("/health")
async def health():
    return {"status": "ok"}
```

Create `server/cv_pipeline/__init__.py`:

```python
```

- [ ] **Step 3: Create Dockerfile**

Create `server/Dockerfile`:

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

Create `server/docker-compose.yml`:

```yaml
version: "3.8"
services:
  cv-pipeline:
    build: .
    ports:
      - "8080:8080"
    volumes:
      - .:/app
    command: uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```

- [ ] **Step 4: Create virtual env and install deps**

```bash
cd /Users/macbook/Development/palmistry-app/server
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

- [ ] **Step 5: Verify server starts**

```bash
uvicorn main:app --port 8080 &
curl http://localhost:8080/health
kill %1
```

Expected: `{"status":"ok"}`

- [ ] **Step 6: Commit**

```bash
cd /Users/macbook/Development/palmistry-app
git add server/
git commit -m "feat: scaffold CV pipeline server with FastAPI"
```

---

## Task 2: Pydantic Models (Request/Response)

**Files:**
- Create: `server/cv_pipeline/models.py`
- Test: `server/tests/test_models.py`

- [ ] **Step 1: Write the test**

Create `server/tests/__init__.py` (empty) and `server/tests/test_models.py`:

```python
import pytest
from cv_pipeline.models import (
    Landmark,
    AnalyzeRequest,
    BezierPoint,
    DetectedLine,
    PalmAnalysisResponse,
)


def test_landmark_creation():
    lm = Landmark(x=0.5, y=0.3)
    assert lm.x == 0.5
    assert lm.y == 0.3


def test_analyze_request_with_landmarks():
    req = AnalyzeRequest(
        image_base64="abc123",
        landmarks=[Landmark(x=0.1, y=0.2)] * 21,
        hand="left",
    )
    assert len(req.landmarks) == 21
    assert req.hand == "left"


def test_analyze_request_rejects_wrong_landmark_count():
    with pytest.raises(ValueError):
        AnalyzeRequest(
            image_base64="abc",
            landmarks=[Landmark(x=0.0, y=0.0)] * 10,
            hand="right",
        )


def test_detected_line_creation():
    line = DetectedLine(
        line_type="heart",
        control_points=[BezierPoint(x=0.1, y=0.2), BezierPoint(x=0.5, y=0.3)],
        length=0.75,
        depth="deep",
        curvature="curved",
        start_point="jupiter",
        end_point="between_fingers",
    )
    assert line.line_type == "heart"
    assert len(line.control_points) == 2


def test_palm_analysis_response():
    resp = PalmAnalysisResponse(
        palm_shape="square",
        palm_width_ratio=0.85,
        finger_proportions={"index": 0.9, "middle": 1.0, "ring": 0.95, "pinky": 0.75},
        lines=[],
    )
    assert resp.palm_shape == "square"
    assert resp.lines == []
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd /Users/macbook/Development/palmistry-app/server
python -m pytest tests/test_models.py -v
```

Expected: FAIL — ModuleNotFoundError.

- [ ] **Step 3: Implement models**

Create `server/cv_pipeline/models.py`:

```python
from pydantic import BaseModel, field_validator
from typing import Literal


class Landmark(BaseModel):
    """A single MediaPipe hand landmark (normalized 0-1 coordinates)."""
    x: float
    y: float


class AnalyzeRequest(BaseModel):
    """Request body for the /analyze endpoint."""
    image_base64: str
    landmarks: list[Landmark]
    hand: Literal["left", "right"]

    @field_validator("landmarks")
    @classmethod
    def check_landmark_count(cls, v: list[Landmark]) -> list[Landmark]:
        if len(v) != 21:
            raise ValueError(f"Expected 21 landmarks, got {len(v)}")
        return v


class BezierPoint(BaseModel):
    """A point in normalized coordinates (0-1 relative to image)."""
    x: float
    y: float


class DetectedLine(BaseModel):
    """A detected palm line with bezier control points and characteristics."""
    line_type: Literal["heart", "head", "life", "fate"]
    control_points: list[BezierPoint]
    length: float  # normalized to palm width
    depth: Literal["deep", "medium", "faint"]
    curvature: Literal["straight", "curved", "steep"]
    start_point: str  # e.g. "jupiter", "saturn", "edge"
    end_point: str


class PalmAnalysisResponse(BaseModel):
    """Response from the /analyze endpoint."""
    palm_shape: Literal["square", "rectangle", "spatulate", "conic"]
    palm_width_ratio: float
    finger_proportions: dict[str, float]
    lines: list[DetectedLine]
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_models.py -v
```

Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add Pydantic request/response models with validation"
```

---

## Task 3: Image Preprocessing

**Files:**
- Create: `server/cv_pipeline/preprocess.py`
- Test: `server/tests/test_preprocess.py`
- Create: `server/tests/conftest.py`

- [ ] **Step 1: Create test fixtures**

Create `server/tests/conftest.py`:

```python
import base64
import numpy as np
import cv2
import pytest
from cv_pipeline.models import Landmark


@pytest.fixture
def sample_image() -> np.ndarray:
    """A 640x480 synthetic image with some lines drawn on it."""
    img = np.zeros((480, 640, 3), dtype=np.uint8)
    img[:] = (200, 180, 160)  # skin-like color

    # Draw some "palm lines"
    cv2.line(img, (100, 200), (500, 180), (120, 100, 80), 2)  # heart-like
    cv2.line(img, (80, 260), (450, 250), (130, 110, 90), 2)   # head-like
    cv2.ellipse(img, (200, 200), (150, 200), 0, 60, 180, (110, 90, 70), 2)  # life-like
    cv2.line(img, (300, 400), (310, 150), (125, 105, 85), 2)  # fate-like

    return img


@pytest.fixture
def sample_image_base64(sample_image) -> str:
    _, buf = cv2.imencode(".jpg", sample_image)
    return base64.b64encode(buf).decode("utf-8")


@pytest.fixture
def sample_landmarks() -> list[Landmark]:
    """21 fake landmarks roughly positioned on a palm."""
    # MediaPipe hand landmarks layout (simplified):
    # 0=wrist, 1-4=thumb, 5-8=index, 9-12=middle, 13-16=ring, 17-20=pinky
    base = [
        (0.50, 0.95),  # 0: wrist
        (0.30, 0.80),  # 1: thumb_cmc
        (0.22, 0.65),  # 2: thumb_mcp
        (0.18, 0.50),  # 3: thumb_ip
        (0.15, 0.38),  # 4: thumb_tip
        (0.32, 0.42),  # 5: index_mcp
        (0.30, 0.28),  # 6: index_pip
        (0.29, 0.18),  # 7: index_dip
        (0.28, 0.10),  # 8: index_tip
        (0.45, 0.38),  # 9: middle_mcp
        (0.44, 0.22),  # 10: middle_pip
        (0.43, 0.13),  # 11: middle_dip
        (0.43, 0.05),  # 12: middle_tip
        (0.57, 0.40),  # 13: ring_mcp
        (0.57, 0.25),  # 14: ring_pip
        (0.57, 0.16),  # 15: ring_dip
        (0.57, 0.08),  # 16: ring_tip
        (0.68, 0.45),  # 17: pinky_mcp
        (0.69, 0.33),  # 18: pinky_pip
        (0.70, 0.25),  # 19: pinky_dip
        (0.70, 0.18),  # 20: pinky_tip
    ]
    return [Landmark(x=x, y=y) for x, y in base]
```

- [ ] **Step 2: Write the test**

Create `server/tests/test_preprocess.py`:

```python
import base64
import numpy as np
import cv2
import pytest
from cv_pipeline.preprocess import decode_image, preprocess_palm
from cv_pipeline.models import Landmark


def test_decode_image(sample_image_base64):
    img = decode_image(sample_image_base64)
    assert isinstance(img, np.ndarray)
    assert img.ndim == 3
    assert img.shape[2] == 3


def test_decode_image_invalid():
    with pytest.raises(ValueError, match="decode"):
        decode_image("not_valid_base64!!!")


def test_preprocess_palm(sample_image, sample_landmarks):
    result = preprocess_palm(sample_image, sample_landmarks)

    assert "gray" in result
    assert "edges" in result
    assert "roi_offset" in result

    assert result["gray"].ndim == 2  # grayscale
    assert result["edges"].ndim == 2  # binary
    assert result["edges"].dtype == np.uint8
```

- [ ] **Step 3: Run test to verify it fails**

```bash
python -m pytest tests/test_preprocess.py -v
```

- [ ] **Step 4: Implement preprocess.py**

Create `server/cv_pipeline/preprocess.py`:

```python
import base64
import cv2
import numpy as np
from cv_pipeline.models import Landmark


def decode_image(image_base64: str) -> np.ndarray:
    """Decode a base64-encoded image to a BGR numpy array."""
    try:
        img_bytes = base64.b64decode(image_base64)
        arr = np.frombuffer(img_bytes, dtype=np.uint8)
        img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    except Exception:
        img = None

    if img is None:
        raise ValueError("Failed to decode image from base64")
    return img


def _compute_roi(
    landmarks: list[Landmark], img_h: int, img_w: int, padding: float = 0.1
) -> tuple[int, int, int, int]:
    """Compute a bounding ROI around the palm from landmarks, with padding."""
    xs = [lm.x * img_w for lm in landmarks]
    ys = [lm.y * img_h for lm in landmarks]
    x_min, x_max = int(min(xs)), int(max(xs))
    y_min, y_max = int(min(ys)), int(max(ys))

    pad_x = int((x_max - x_min) * padding)
    pad_y = int((y_max - y_min) * padding)

    x_min = max(0, x_min - pad_x)
    y_min = max(0, y_min - pad_y)
    x_max = min(img_w, x_max + pad_x)
    y_max = min(img_h, y_max + pad_y)

    return x_min, y_min, x_max, y_max


def preprocess_palm(
    image: np.ndarray, landmarks: list[Landmark]
) -> dict:
    """
    Preprocess a palm image for line detection.

    Returns dict with:
      - gray: grayscale ROI after CLAHE + blur
      - edges: Canny edge map
      - roi_offset: (x_min, y_min) offset of ROI in original image
      - roi_size: (width, height) of ROI
      - original_size: (width, height) of original image
    """
    h, w = image.shape[:2]
    x_min, y_min, x_max, y_max = _compute_roi(landmarks, h, w)

    roi = image[y_min:y_max, x_min:x_max]

    # Grayscale
    gray = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)

    # CLAHE for contrast enhancement
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    gray = clahe.apply(gray)

    # Gaussian blur to reduce noise
    gray = cv2.GaussianBlur(gray, (5, 5), 0)

    # Canny edge detection
    edges = cv2.Canny(gray, 30, 100)

    # Adaptive threshold as supplement
    thresh = cv2.adaptiveThreshold(
        gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2
    )

    # Combine Canny and adaptive threshold
    combined = cv2.bitwise_or(edges, thresh)

    return {
        "gray": gray,
        "edges": combined,
        "roi_offset": (x_min, y_min),
        "roi_size": (x_max - x_min, y_max - y_min),
        "original_size": (w, h),
    }
```

- [ ] **Step 5: Run test**

```bash
python -m pytest tests/test_preprocess.py -v
```

Expected: All 3 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add server/
git commit -m "feat: add image preprocessing (decode, ROI, CLAHE, Canny)"
```

---

## Task 4: Contour Extraction

**Files:**
- Create: `server/cv_pipeline/contour_extract.py`
- Test: `server/tests/test_contour_extract.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_contour_extract.py`:

```python
import numpy as np
import cv2
from cv_pipeline.contour_extract import extract_line_candidates


def test_extract_finds_lines_on_synthetic_image():
    # Create a 200x200 black image with 3 white lines
    edges = np.zeros((200, 200), dtype=np.uint8)
    cv2.line(edges, (20, 50), (180, 45), 255, 2)   # horizontal-ish
    cv2.line(edges, (20, 100), (180, 95), 255, 2)   # horizontal-ish
    cv2.line(edges, (100, 150), (105, 30), 255, 2)  # vertical-ish

    candidates = extract_line_candidates(edges, min_length=30)

    assert len(candidates) >= 2  # should find at least the longer lines
    for c in candidates:
        assert isinstance(c, np.ndarray)
        assert c.ndim == 2  # Nx2 array of points


def test_extract_filters_short_contours():
    edges = np.zeros((200, 200), dtype=np.uint8)
    cv2.line(edges, (10, 10), (15, 15), 255, 1)  # very short

    candidates = extract_line_candidates(edges, min_length=50)
    assert len(candidates) == 0


def test_extract_returns_sorted_by_length():
    edges = np.zeros((200, 200), dtype=np.uint8)
    cv2.line(edges, (10, 50), (190, 50), 255, 2)   # long
    cv2.line(edges, (10, 100), (100, 100), 255, 2)  # medium

    candidates = extract_line_candidates(edges, min_length=30)

    if len(candidates) >= 2:
        lengths = [cv2.arcLength(c.reshape(-1, 1, 2).astype(np.float32), False) for c in candidates]
        assert lengths[0] >= lengths[1]
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_contour_extract.py -v
```

- [ ] **Step 3: Implement contour_extract.py**

Create `server/cv_pipeline/contour_extract.py`:

```python
import cv2
import numpy as np


def extract_line_candidates(
    edges: np.ndarray,
    min_length: float = 40,
    max_candidates: int = 20,
) -> list[np.ndarray]:
    """
    Extract line candidate contours from an edge image.

    Args:
        edges: Binary edge image (uint8, 0/255).
        min_length: Minimum arc length of a contour to keep.
        max_candidates: Maximum number of candidates to return.

    Returns:
        List of Nx2 numpy arrays (point sequences), sorted by length descending.
    """
    # Dilate to connect nearby edges
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    dilated = cv2.dilate(edges, kernel, iterations=1)

    contours, _ = cv2.findContours(dilated, cv2.RETR_LIST, cv2.CHAIN_APPROX_NONE)

    candidates = []
    for cnt in contours:
        length = cv2.arcLength(cnt, closed=False)
        if length < min_length:
            continue

        # Flatten from (N,1,2) to (N,2)
        points = cnt.reshape(-1, 2)
        candidates.append(points)

    # Sort by arc length descending
    candidates.sort(
        key=lambda pts: cv2.arcLength(pts.reshape(-1, 1, 2), False),
        reverse=True,
    )

    return candidates[:max_candidates]
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_contour_extract.py -v
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add contour extraction with length filtering"
```

---

## Task 5: Rule-Based Line Classification

**Files:**
- Create: `server/cv_pipeline/line_classify.py`
- Test: `server/tests/test_line_classify.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_line_classify.py`:

```python
import numpy as np
import pytest
from cv_pipeline.line_classify import classify_lines
from cv_pipeline.models import Landmark


def _make_landmarks() -> list[Landmark]:
    """Standard palm landmarks for a 200x200 image."""
    base = [
        (0.50, 0.95),  # 0: wrist
        (0.30, 0.80), (0.22, 0.65), (0.18, 0.50), (0.15, 0.38),  # 1-4: thumb
        (0.32, 0.42), (0.30, 0.28), (0.29, 0.18), (0.28, 0.10),  # 5-8: index
        (0.45, 0.38), (0.44, 0.22), (0.43, 0.13), (0.43, 0.05),  # 9-12: middle
        (0.57, 0.40), (0.57, 0.25), (0.57, 0.16), (0.57, 0.08),  # 13-16: ring
        (0.68, 0.45), (0.69, 0.33), (0.70, 0.25), (0.70, 0.18),  # 17-20: pinky
    ]
    return [Landmark(x=x, y=y) for x, y in base]


def test_classify_heart_line():
    """A horizontal line in the upper-middle zone should be classified as heart."""
    landmarks = _make_landmarks()
    # Heart line region: y ~ 0.40-0.50, spanning horizontally
    heart_pts = np.array([[60, 90], [80, 88], [100, 87], [120, 86], [140, 88]])

    result = classify_lines(
        candidates=[heart_pts],
        landmarks=landmarks,
        roi_size=(200, 200),
        roi_offset=(0, 0),
    )

    assert len(result) >= 1
    heart = [r for r in result if r["line_type"] == "heart"]
    assert len(heart) == 1


def test_classify_head_line():
    """A horizontal line below heart line zone should be head."""
    landmarks = _make_landmarks()
    # Head line: y ~ 0.50-0.65
    head_pts = np.array([[50, 110], [80, 112], [110, 114], [140, 112]])

    result = classify_lines(
        candidates=[head_pts],
        landmarks=landmarks,
        roi_size=(200, 200),
        roi_offset=(0, 0),
    )

    head = [r for r in result if r["line_type"] == "head"]
    assert len(head) == 1


def test_classify_life_line():
    """A curved line on the left side should be life."""
    landmarks = _make_landmarks()
    # Life line: curves from index base to wrist, left side
    life_pts = np.array([[65, 80], [55, 100], [48, 130], [45, 160], [50, 185]])

    result = classify_lines(
        candidates=[life_pts],
        landmarks=landmarks,
        roi_size=(200, 200),
        roi_offset=(0, 0),
    )

    life = [r for r in result if r["line_type"] == "life"]
    assert len(life) == 1


def test_classify_fate_line():
    """A vertical line in the center should be fate."""
    landmarks = _make_landmarks()
    # Fate line: vertical in center
    fate_pts = np.array([[100, 180], [99, 150], [98, 120], [99, 90]])

    result = classify_lines(
        candidates=[fate_pts],
        landmarks=landmarks,
        roi_size=(200, 200),
        roi_offset=(0, 0),
    )

    fate = [r for r in result if r["line_type"] == "fate"]
    assert len(fate) == 1


def test_classify_skips_unknown():
    """A short random contour should not be classified."""
    landmarks = _make_landmarks()
    random_pts = np.array([[5, 5], [8, 8], [10, 10]])

    result = classify_lines(
        candidates=[random_pts],
        landmarks=landmarks,
        roi_size=(200, 200),
        roi_offset=(0, 0),
    )

    known = [r for r in result if r["line_type"] in ("heart", "head", "life", "fate")]
    assert len(known) == 0
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_line_classify.py -v
```

- [ ] **Step 3: Implement line_classify.py**

Create `server/cv_pipeline/line_classify.py`:

```python
import numpy as np
from cv_pipeline.models import Landmark


def classify_lines(
    candidates: list[np.ndarray],
    landmarks: list[Landmark],
    roi_size: tuple[int, int],
    roi_offset: tuple[int, int],
) -> list[dict]:
    """
    Classify line candidates by their position relative to landmarks.

    Uses zones defined by landmark positions to determine line type:
    - Heart line: horizontal, in upper palm zone (between finger bases and head)
    - Head line: horizontal, in middle palm zone
    - Life line: curved, on thumb side, spanning vertically
    - Fate line: mostly vertical, in center of palm

    Args:
        candidates: List of Nx2 point arrays (in ROI pixel coords).
        landmarks: 21 MediaPipe hand landmarks (normalized 0-1).
        roi_size: (width, height) of the ROI.
        roi_offset: (x_offset, y_offset) of ROI in original image.

    Returns:
        List of dicts with 'line_type' and 'points' for classified lines.
    """
    roi_w, roi_h = roi_size
    if roi_w == 0 or roi_h == 0:
        return []

    # Key landmark positions in ROI pixel coords
    # We need to convert from normalized (0-1 of full image) to ROI pixels
    # But landmarks are normalized to full image, and ROI is a crop.
    # For simplicity, we work with normalized coords within the ROI.
    ox, oy = roi_offset

    def _norm_y(pts: np.ndarray) -> float:
        """Average normalized Y of a point set within ROI."""
        return float(np.mean(pts[:, 1]) / roi_h)

    def _norm_x(pts: np.ndarray) -> float:
        """Average normalized X of a point set within ROI."""
        return float(np.mean(pts[:, 0]) / roi_w)

    def _is_horizontal(pts: np.ndarray) -> bool:
        """Check if line spans more horizontally than vertically."""
        dx = pts[:, 0].max() - pts[:, 0].min()
        dy = pts[:, 1].max() - pts[:, 1].min()
        return dx > dy * 1.2

    def _is_vertical(pts: np.ndarray) -> bool:
        """Check if line spans more vertically than horizontally."""
        dx = pts[:, 0].max() - pts[:, 0].min()
        dy = pts[:, 1].max() - pts[:, 1].min()
        return dy > dx * 1.5

    def _is_curved_left(pts: np.ndarray) -> bool:
        """Check if line curves on the left (thumb) side."""
        avg_x = _norm_x(pts)
        dy = pts[:, 1].max() - pts[:, 1].min()
        return avg_x < 0.45 and dy > roi_h * 0.3

    # Finger base Y: average of MCP joints (indices 5, 9, 13, 17)
    finger_base_y = np.mean([landmarks[i].y for i in [5, 9, 13, 17]])
    wrist_y = landmarks[0].y

    # Define zones (normalized to full image, approximate)
    palm_mid_y = (finger_base_y + wrist_y) / 2

    classified = []
    used_types: set[str] = set()

    for pts in candidates:
        if len(pts) < 5:
            continue

        avg_y = _norm_y(pts)
        avg_x = _norm_x(pts)

        line_type = None

        if _is_horizontal(pts) and 0.35 < avg_y < 0.55 and "heart" not in used_types:
            line_type = "heart"
        elif _is_horizontal(pts) and 0.45 < avg_y < 0.70 and "head" not in used_types:
            line_type = "head"
        elif _is_curved_left(pts) and "life" not in used_types:
            line_type = "life"
        elif _is_vertical(pts) and 0.35 < avg_x < 0.65 and "fate" not in used_types:
            line_type = "fate"

        if line_type:
            classified.append({"line_type": line_type, "points": pts})
            used_types.add(line_type)

    return classified
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_line_classify.py -v
```

Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add rule-based line classification by landmark position"
```

---

## Task 6: Bezier Fitting

**Files:**
- Create: `server/cv_pipeline/bezier_fit.py`
- Test: `server/tests/test_bezier_fit.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_bezier_fit.py`:

```python
import numpy as np
from cv_pipeline.bezier_fit import fit_cubic_bezier, bezier_points_to_normalized


def test_fit_cubic_bezier_returns_control_points():
    # Straight-ish line
    pts = np.array([[10, 50], [30, 48], [50, 47], [70, 45], [90, 44], [110, 43]])

    control_points = fit_cubic_bezier(pts, num_control_points=4)

    assert len(control_points) == 4
    for cp in control_points:
        assert len(cp) == 2  # (x, y)


def test_fit_preserves_endpoints():
    pts = np.array([[10, 50], [30, 55], [50, 60], [70, 55], [90, 50]])

    control_points = fit_cubic_bezier(pts, num_control_points=4)

    # First control point should be near first data point
    assert abs(control_points[0][0] - 10) < 5
    assert abs(control_points[0][1] - 50) < 5

    # Last control point should be near last data point
    assert abs(control_points[-1][0] - 90) < 5
    assert abs(control_points[-1][1] - 50) < 5


def test_fit_with_many_points():
    # 6 control points for a complex curve
    t = np.linspace(0, np.pi, 50)
    pts = np.column_stack([t * 30 + 10, np.sin(t) * 40 + 100]).astype(int)

    control_points = fit_cubic_bezier(pts, num_control_points=6)

    assert len(control_points) == 6


def test_bezier_points_to_normalized():
    control_points = [(100, 200), (150, 180), (200, 190)]
    roi_w, roi_h = 400, 500
    roi_offset = (50, 30)
    img_w, img_h = 640, 480

    normalized = bezier_points_to_normalized(
        control_points, roi_offset, (roi_w, roi_h), (img_w, img_h)
    )

    assert len(normalized) == 3
    for p in normalized:
        assert 0 <= p[0] <= 1
        assert 0 <= p[1] <= 1
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_bezier_fit.py -v
```

- [ ] **Step 3: Implement bezier_fit.py**

Create `server/cv_pipeline/bezier_fit.py`:

```python
import numpy as np
from scipy.interpolate import splprep, splev


def fit_cubic_bezier(
    points: np.ndarray,
    num_control_points: int = 4,
) -> list[tuple[float, float]]:
    """
    Fit a cubic B-spline to point data and sample control points.

    Args:
        points: Nx2 array of (x, y) pixel coordinates.
        num_control_points: Number of control points to output.

    Returns:
        List of (x, y) tuples representing bezier control points.
    """
    if len(points) < 3:
        return [(float(p[0]), float(p[1])) for p in points]

    # Remove duplicate consecutive points
    diffs = np.diff(points, axis=0)
    mask = np.any(diffs != 0, axis=1)
    mask = np.concatenate([[True], mask])
    points = points[mask]

    if len(points) < 3:
        return [(float(p[0]), float(p[1])) for p in points]

    x = points[:, 0].astype(float)
    y = points[:, 1].astype(float)

    try:
        # Fit B-spline
        k = min(3, len(points) - 1)
        tck, _ = splprep([x, y], k=k, s=len(points) * 2)

        # Sample control points evenly along the spline
        u_new = np.linspace(0, 1, num_control_points)
        xs, ys = splev(u_new, tck)

        return [(float(xi), float(yi)) for xi, yi in zip(xs, ys)]
    except Exception:
        # Fallback: evenly sample from original points
        indices = np.linspace(0, len(points) - 1, num_control_points, dtype=int)
        return [(float(points[i][0]), float(points[i][1])) for i in indices]


def bezier_points_to_normalized(
    control_points: list[tuple[float, float]],
    roi_offset: tuple[int, int],
    roi_size: tuple[int, int],
    img_size: tuple[int, int],
) -> list[tuple[float, float]]:
    """
    Convert bezier control points from ROI pixel coords to normalized (0-1)
    coords relative to the full image.
    """
    ox, oy = roi_offset
    img_w, img_h = img_size

    result = []
    for px, py in control_points:
        nx = (px + ox) / img_w
        ny = (py + oy) / img_h
        result.append((round(nx, 4), round(ny, 4)))
    return result
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_bezier_fit.py -v
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add bezier curve fitting with B-spline approximation"
```

---

## Task 7: Line Characteristics Computation

**Files:**
- Create: `server/cv_pipeline/characteristics.py`
- Test: `server/tests/test_characteristics.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_characteristics.py`:

```python
import numpy as np
from cv_pipeline.characteristics import compute_line_characteristics
from cv_pipeline.models import Landmark


def _make_landmarks():
    base = [
        (0.50, 0.95), (0.30, 0.80), (0.22, 0.65), (0.18, 0.50), (0.15, 0.38),
        (0.32, 0.42), (0.30, 0.28), (0.29, 0.18), (0.28, 0.10),
        (0.45, 0.38), (0.44, 0.22), (0.43, 0.13), (0.43, 0.05),
        (0.57, 0.40), (0.57, 0.25), (0.57, 0.16), (0.57, 0.08),
        (0.68, 0.45), (0.69, 0.33), (0.70, 0.25), (0.70, 0.18),
    ]
    return [Landmark(x=x, y=y) for x, y in base]


def test_compute_long_straight_line():
    # Long straight horizontal line
    control_points = [(0.15, 0.45), (0.35, 0.44), (0.55, 0.43), (0.75, 0.42)]
    palm_width = 0.4  # normalized

    chars = compute_line_characteristics(
        control_points=control_points,
        line_type="heart",
        landmarks=_make_landmarks(),
        palm_width=palm_width,
    )

    assert chars["length"] == "long"
    assert chars["curvature"] == "straight"
    assert isinstance(chars["start_point"], str)
    assert isinstance(chars["end_point"], str)


def test_compute_curved_line():
    # Curved line (life line shape)
    control_points = [(0.32, 0.42), (0.25, 0.55), (0.22, 0.70), (0.28, 0.85)]

    chars = compute_line_characteristics(
        control_points=control_points,
        line_type="life",
        landmarks=_make_landmarks(),
        palm_width=0.4,
    )

    assert chars["curvature"] in ("curved", "steep")


def test_compute_short_line():
    control_points = [(0.45, 0.50), (0.50, 0.49)]

    chars = compute_line_characteristics(
        control_points=control_points,
        line_type="head",
        landmarks=_make_landmarks(),
        palm_width=0.4,
    )

    assert chars["length"] == "short"


def test_compute_returns_all_fields():
    control_points = [(0.2, 0.5), (0.4, 0.48), (0.6, 0.47)]

    chars = compute_line_characteristics(
        control_points=control_points,
        line_type="heart",
        landmarks=_make_landmarks(),
        palm_width=0.4,
    )

    for key in ("length", "length_raw", "depth", "curvature", "start_point", "end_point"):
        assert key in chars
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_characteristics.py -v
```

- [ ] **Step 3: Implement characteristics.py**

Create `server/cv_pipeline/characteristics.py`:

```python
import math
import numpy as np
from cv_pipeline.models import Landmark


# Landmark indices for named positions
_MOUNT_NAMES = {
    5: "jupiter",    # index MCP
    9: "saturn",     # middle MCP
    13: "apollo",    # ring MCP (sun)
    17: "mercury",   # pinky MCP
    0: "wrist",
}


def _line_length(points: list[tuple[float, float]]) -> float:
    """Compute total Euclidean length of polyline."""
    total = 0.0
    for i in range(len(points) - 1):
        dx = points[i + 1][0] - points[i][0]
        dy = points[i + 1][1] - points[i][1]
        total += math.sqrt(dx * dx + dy * dy)
    return total


def _max_deviation(points: list[tuple[float, float]]) -> float:
    """Max perpendicular distance from straight line between endpoints."""
    if len(points) < 3:
        return 0.0

    p0 = np.array(points[0])
    p1 = np.array(points[-1])
    line_vec = p1 - p0
    line_len = np.linalg.norm(line_vec)

    if line_len < 1e-6:
        return 0.0

    max_dist = 0.0
    for px, py in points[1:-1]:
        pt = np.array([px, py])
        dist = abs(np.cross(line_vec, p0 - pt)) / line_len
        max_dist = max(max_dist, dist)

    return max_dist


def _nearest_landmark_name(
    point: tuple[float, float], landmarks: list[Landmark]
) -> str:
    """Find the nearest named landmark to a point."""
    min_dist = float("inf")
    name = "edge"

    for idx, lm_name in _MOUNT_NAMES.items():
        lm = landmarks[idx]
        dist = math.sqrt((point[0] - lm.x) ** 2 + (point[1] - lm.y) ** 2)
        if dist < min_dist:
            min_dist = dist
            name = lm_name

    return name


def compute_line_characteristics(
    control_points: list[tuple[float, float]],
    line_type: str,
    landmarks: list[Landmark],
    palm_width: float,
) -> dict:
    """
    Compute characteristics of a palm line.

    Args:
        control_points: Normalized (0-1) bezier control points.
        line_type: heart/head/life/fate.
        landmarks: 21 MediaPipe landmarks.
        palm_width: Normalized width of palm (for length normalization).

    Returns:
        Dict with length, length_raw, depth, curvature, start_point, end_point.
    """
    raw_length = _line_length(control_points)
    norm_length = raw_length / palm_width if palm_width > 0 else 0

    # Length category
    if norm_length < 0.5:
        length_cat = "short"
    elif norm_length < 0.75:
        length_cat = "medium"
    else:
        length_cat = "long"

    # Curvature
    straight_dist = math.sqrt(
        (control_points[-1][0] - control_points[0][0]) ** 2
        + (control_points[-1][1] - control_points[0][1]) ** 2
    )
    deviation = _max_deviation(control_points)
    curvature_ratio = deviation / straight_dist if straight_dist > 0 else 0

    if curvature_ratio < 0.05:
        curvature_cat = "straight"
    elif curvature_ratio < 0.15:
        curvature_cat = "curved"
    else:
        curvature_cat = "steep"

    # Start/end nearest landmarks
    start_point = _nearest_landmark_name(control_points[0], landmarks)
    end_point = _nearest_landmark_name(control_points[-1], landmarks)

    # Depth: we don't have pixel intensity in normalized coords,
    # so for MVP we default to "medium" (server can enhance later with raw image)
    depth = "medium"

    return {
        "length": length_cat,
        "length_raw": round(norm_length, 3),
        "depth": depth,
        "curvature": curvature_cat,
        "start_point": start_point,
        "end_point": end_point,
    }
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_characteristics.py -v
```

Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add line characteristics computation (length, curvature, endpoints)"
```

---

## Task 8: Palm Shape & Finger Proportions

**Files:**
- Create: `server/cv_pipeline/palm_shape.py`
- Test: `server/tests/test_palm_shape.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_palm_shape.py`:

```python
from cv_pipeline.palm_shape import analyze_palm_shape
from cv_pipeline.models import Landmark


def _make_landmarks(width_factor: float = 1.0):
    """Generate landmarks with adjustable palm width."""
    base = [
        (0.50, 0.95),  # wrist
        (0.30, 0.80), (0.22, 0.65), (0.18, 0.50), (0.15, 0.38),  # thumb
        (0.32 * width_factor, 0.42), (0.30, 0.28), (0.29, 0.18), (0.28, 0.10),  # index
        (0.45, 0.38), (0.44, 0.22), (0.43, 0.13), (0.43, 0.05),  # middle
        (0.57, 0.40), (0.57, 0.25), (0.57, 0.16), (0.57, 0.08),  # ring
        (0.68 / width_factor, 0.45), (0.69, 0.33), (0.70, 0.25), (0.70, 0.18),  # pinky
    ]
    return [Landmark(x=x, y=y) for x, y in base]


def test_analyze_returns_shape():
    lm = _make_landmarks()
    result = analyze_palm_shape(lm)

    assert result["palm_shape"] in ("square", "rectangle", "spatulate", "conic")
    assert 0 < result["palm_width_ratio"] < 2
    assert "finger_proportions" in result
    assert "index" in result["finger_proportions"]
    assert "middle" in result["finger_proportions"]
    assert "ring" in result["finger_proportions"]
    assert "pinky" in result["finger_proportions"]


def test_analyze_palm_width():
    lm = _make_landmarks()
    result = analyze_palm_shape(lm)

    # palm_width should be the distance between index MCP (5) and pinky MCP (17)
    assert result["palm_width"] > 0


def test_finger_proportions_relative():
    lm = _make_landmarks()
    result = analyze_palm_shape(lm)

    # Middle finger is typically longest
    props = result["finger_proportions"]
    assert props["middle"] >= props["pinky"]
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_palm_shape.py -v
```

- [ ] **Step 3: Implement palm_shape.py**

Create `server/cv_pipeline/palm_shape.py`:

```python
import math
from cv_pipeline.models import Landmark


def _distance(a: Landmark, b: Landmark) -> float:
    return math.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2)


def _finger_length(landmarks: list[Landmark], mcp: int, tip: int) -> float:
    """Length of a finger from MCP joint to tip."""
    return _distance(landmarks[mcp], landmarks[tip])


def analyze_palm_shape(landmarks: list[Landmark]) -> dict:
    """
    Analyze palm shape and finger proportions from MediaPipe landmarks.

    Palm shape types (based on width/height ratio):
    - Square (Earth): width ≈ height (ratio 0.85-1.15)
    - Rectangle (Air): height > width (ratio < 0.85)
    - Spatulate (Fire): width > height (ratio > 1.15)
    - Conic (Water): narrower at wrist, wider at fingers

    Returns dict with palm_shape, palm_width_ratio, palm_width, finger_proportions.
    """
    # Palm dimensions
    # Width: index MCP (5) to pinky MCP (17)
    palm_width = _distance(landmarks[5], landmarks[17])

    # Height: middle MCP (9) to wrist (0)
    palm_height = _distance(landmarks[9], landmarks[0])

    width_ratio = palm_width / palm_height if palm_height > 0 else 1.0

    # Determine shape
    # Check for conic: compare width at finger base vs wrist area
    wrist_width = _distance(landmarks[1], landmarks[17])  # thumb CMC to pinky MCP
    finger_width = palm_width

    if wrist_width > 0 and finger_width / wrist_width > 1.2:
        palm_shape = "conic"
    elif width_ratio > 1.15:
        palm_shape = "spatulate"
    elif width_ratio < 0.85:
        palm_shape = "rectangle"
    else:
        palm_shape = "square"

    # Finger proportions (normalized to middle finger)
    finger_lengths = {
        "index": _finger_length(landmarks, 5, 8),
        "middle": _finger_length(landmarks, 9, 12),
        "ring": _finger_length(landmarks, 13, 16),
        "pinky": _finger_length(landmarks, 17, 20),
    }

    max_len = max(finger_lengths.values()) or 1.0
    finger_proportions = {
        k: round(v / max_len, 3) for k, v in finger_lengths.items()
    }

    return {
        "palm_shape": palm_shape,
        "palm_width_ratio": round(width_ratio, 3),
        "palm_width": round(palm_width, 4),
        "finger_proportions": finger_proportions,
    }
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_palm_shape.py -v
```

Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add palm shape analysis and finger proportions"
```

---

## Task 9: Pipeline Orchestrator

**Files:**
- Create: `server/cv_pipeline/pipeline.py`
- Test: `server/tests/test_pipeline.py`

- [ ] **Step 1: Write the test**

Create `server/tests/test_pipeline.py`:

```python
from cv_pipeline.pipeline import analyze_palm
from cv_pipeline.models import AnalyzeRequest, Landmark, PalmAnalysisResponse


def test_analyze_palm_full_pipeline(sample_image_base64, sample_landmarks):
    request = AnalyzeRequest(
        image_base64=sample_image_base64,
        landmarks=sample_landmarks,
        hand="left",
    )

    result = analyze_palm(request)

    assert isinstance(result, PalmAnalysisResponse)
    assert result.palm_shape in ("square", "rectangle", "spatulate", "conic")
    assert result.palm_width_ratio > 0
    assert "index" in result.finger_proportions
    # Lines may or may not be found on synthetic image, but no crash
    assert isinstance(result.lines, list)


def test_analyze_palm_returns_lines_with_correct_types(sample_image_base64, sample_landmarks):
    request = AnalyzeRequest(
        image_base64=sample_image_base64,
        landmarks=sample_landmarks,
        hand="right",
    )

    result = analyze_palm(request)

    for line in result.lines:
        assert line.line_type in ("heart", "head", "life", "fate")
        assert len(line.control_points) >= 2
        assert line.length > 0
        assert line.depth in ("deep", "medium", "faint")
        assert line.curvature in ("straight", "curved", "steep")
```

- [ ] **Step 2: Run test to verify it fails**

```bash
python -m pytest tests/test_pipeline.py -v
```

- [ ] **Step 3: Implement pipeline.py**

Create `server/cv_pipeline/pipeline.py`:

```python
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


def analyze_palm(request: AnalyzeRequest) -> PalmAnalysisResponse:
    """
    Full palm analysis pipeline.

    1. Decode image
    2. Preprocess (grayscale, CLAHE, edge detection)
    3. Extract contour candidates
    4. Classify lines by position
    5. Fit bezier curves
    6. Compute characteristics
    7. Analyze palm shape from landmarks
    """
    # Step 1: Decode
    image = decode_image(request.image_base64)
    img_h, img_w = image.shape[:2]

    # Step 2: Preprocess
    prep = preprocess_palm(image, request.landmarks)

    # Step 3: Extract contours
    candidates = extract_line_candidates(
        prep["edges"],
        min_length=prep["roi_size"][0] * 0.15,  # minimum 15% of ROI width
    )

    # Step 4: Classify
    classified = classify_lines(
        candidates=candidates,
        landmarks=request.landmarks,
        roi_size=prep["roi_size"],
        roi_offset=prep["roi_offset"],
    )

    # Step 5-6: Bezier fit + characteristics
    shape_info = analyze_palm_shape(request.landmarks)
    palm_width = shape_info["palm_width"]

    detected_lines: list[DetectedLine] = []
    for cl in classified:
        pts = cl["points"]
        line_type = cl["line_type"]

        # Bezier fitting (in ROI pixel coords)
        num_cp = 6 if len(pts) > 20 else 4
        raw_cp = fit_cubic_bezier(pts, num_control_points=num_cp)

        # Normalize to full image coords
        norm_cp = bezier_points_to_normalized(
            raw_cp,
            roi_offset=prep["roi_offset"],
            roi_size=prep["roi_size"],
            img_size=(img_w, img_h),
        )

        # Characteristics
        chars = compute_line_characteristics(
            control_points=norm_cp,
            line_type=line_type,
            landmarks=request.landmarks,
            palm_width=palm_width,
        )

        detected_lines.append(
            DetectedLine(
                line_type=line_type,
                control_points=[BezierPoint(x=p[0], y=p[1]) for p in norm_cp],
                length=chars["length_raw"],
                depth=chars["depth"],
                curvature=chars["curvature"],
                start_point=chars["start_point"],
                end_point=chars["end_point"],
            )
        )

    return PalmAnalysisResponse(
        palm_shape=shape_info["palm_shape"],
        palm_width_ratio=shape_info["palm_width_ratio"],
        finger_proportions=shape_info["finger_proportions"],
        lines=detected_lines,
    )
```

- [ ] **Step 4: Run test**

```bash
python -m pytest tests/test_pipeline.py -v
```

Expected: All 2 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add server/
git commit -m "feat: add pipeline orchestrator connecting all CV steps"
```

---

## Task 10: FastAPI Endpoint & Docker

**Files:**
- Modify: `server/main.py`
- Test: `server/tests/test_api.py`

- [ ] **Step 1: Write the API test**

Create `server/tests/test_api.py`:

```python
import pytest
from httpx import AsyncClient, ASGITransport
from main import app


@pytest.mark.asyncio
async def test_health():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "ok"


@pytest.mark.asyncio
async def test_analyze_endpoint(sample_image_base64, sample_landmarks):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/analyze",
            json={
                "image_base64": sample_image_base64,
                "landmarks": [{"x": lm.x, "y": lm.y} for lm in sample_landmarks],
                "hand": "left",
            },
        )
    assert resp.status_code == 200
    data = resp.json()
    assert "palm_shape" in data
    assert "lines" in data
    assert "finger_proportions" in data


@pytest.mark.asyncio
async def test_analyze_invalid_landmarks(sample_image_base64):
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/analyze",
            json={
                "image_base64": sample_image_base64,
                "landmarks": [{"x": 0.0, "y": 0.0}] * 5,  # wrong count
                "hand": "left",
            },
        )
    assert resp.status_code == 422  # validation error


@pytest.mark.asyncio
async def test_analyze_invalid_image():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.post(
            "/analyze",
            json={
                "image_base64": "not_an_image",
                "landmarks": [{"x": 0.5, "y": 0.5}] * 21,
                "hand": "right",
            },
        )
    assert resp.status_code == 400
```

- [ ] **Step 2: Add pytest-asyncio to requirements**

Add to `server/requirements.txt`:

```
pytest-asyncio==0.23.0
```

Then: `pip install pytest-asyncio`

- [ ] **Step 3: Run test to verify it fails**

```bash
python -m pytest tests/test_api.py -v
```

- [ ] **Step 4: Implement the /analyze endpoint**

Replace `server/main.py`:

```python
from fastapi import FastAPI, HTTPException
from cv_pipeline.models import AnalyzeRequest, PalmAnalysisResponse
from cv_pipeline.pipeline import analyze_palm

app = FastAPI(title="Palmistry CV Pipeline", version="1.0.0")


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/analyze", response_model=PalmAnalysisResponse)
async def analyze(request: AnalyzeRequest):
    try:
        result = analyze_palm(request)
        return result
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis failed: {e}")
```

- [ ] **Step 5: Run all tests**

```bash
cd /Users/macbook/Development/palmistry-app/server
python -m pytest tests/ -v
```

Expected: All tests PASS (~20+ tests).

- [ ] **Step 6: Test Docker build**

```bash
docker build -t palmistry-cv .
docker run -d -p 8080:8080 --name palmistry-test palmistry-cv
curl http://localhost:8080/health
docker stop palmistry-test && docker rm palmistry-test
```

Expected: `{"status":"ok"}`

- [ ] **Step 7: Commit**

```bash
git add server/
git commit -m "feat: add /analyze endpoint and Docker setup"
```

---

## Task 11: CI & Final Verification

**Files:**
- Create: `.github/workflows/cv-pipeline.yml`

- [ ] **Step 1: Create CI workflow**

Create `.github/workflows/cv-pipeline.yml`:

```yaml
name: CV Pipeline CI

on:
  push:
    branches: [master]
    paths: ['server/**']
  pull_request:
    branches: [master]
    paths: ['server/**']

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: server
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt
      - run: python -m pytest tests/ -v --tb=short
```

- [ ] **Step 2: Run full test suite locally**

```bash
cd /Users/macbook/Development/palmistry-app/server
python -m pytest tests/ -v --tb=short
```

Expected: All tests PASS.

- [ ] **Step 3: Commit and push**

```bash
cd /Users/macbook/Development/palmistry-app
git add .github/
git commit -m "ci: add GitHub Actions for CV pipeline tests"
git push
```
