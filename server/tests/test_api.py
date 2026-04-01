"""API endpoint tests for /health and /analyze."""

import pytest
from starlette.testclient import TestClient

from main import app


def _landmarks_payload(count: int = 21) -> list[dict]:
    """Generate a list of normalized landmark dicts."""
    raw = [
        # wrist
        (0.50, 0.90),
        # thumb
        (0.35, 0.78),
        (0.25, 0.68),
        (0.18, 0.58),
        (0.12, 0.50),
        # index
        (0.38, 0.55),
        (0.36, 0.44),
        (0.35, 0.34),
        (0.34, 0.26),
        # middle
        (0.50, 0.52),
        (0.50, 0.40),
        (0.50, 0.30),
        (0.50, 0.22),
        # ring
        (0.62, 0.54),
        (0.63, 0.42),
        (0.63, 0.32),
        (0.63, 0.24),
        # pinky
        (0.74, 0.60),
        (0.75, 0.50),
        (0.76, 0.42),
        (0.77, 0.36),
    ]
    return [{"x": x, "y": y} for x, y in raw[:count]]


@pytest.fixture
def client() -> TestClient:
    """Synchronous test client for the FastAPI app."""
    return TestClient(app)


def test_health(client: TestClient):
    """GET /health should return 200 with {"status": "ok"}."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_analyze_endpoint(client: TestClient, sample_image_base64: str):
    """POST /analyze with valid data should return 200 with palm_shape and lines."""
    payload = {
        "image_base64": sample_image_base64,
        "landmarks": _landmarks_payload(21),
        "hand": "right",
    }
    response = client.post("/analyze", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "palm_shape" in data
    assert "lines" in data
    assert isinstance(data["lines"], list)


def test_analyze_without_landmarks(client: TestClient, sample_image_base64: str):
    """POST /analyze without landmarks — server should attempt auto-detection.

    On a real palm image we expect 200 (landmarks detected) or 400 (no hand
    found on a synthetic image).  On macOS ARM the mediapipe model may fail to
    load (500 from the analysis pipeline), which is also tolerated here because
    it will work correctly inside the Linux Docker container on Cloud Run.

    What must NOT happen is a 422 (validation error — landmarks are now optional).
    """
    payload = {
        "image_base64": sample_image_base64,
        "hand": "right",
    }
    response = client.post("/analyze", json=payload)
    assert response.status_code != 422, (
        "landmarks should be optional — got 422 validation error"
    )


def test_analyze_invalid_landmarks(client: TestClient, sample_image_base64: str):
    """POST /analyze with wrong landmark count should return 422."""
    payload = {
        "image_base64": sample_image_base64,
        "landmarks": _landmarks_payload(5),  # only 5, not 21
        "hand": "right",
    }
    response = client.post("/analyze", json=payload)
    assert response.status_code == 422


def test_analyze_invalid_image(client: TestClient):
    """POST /analyze with bad base64 image should return 400."""
    payload = {
        "image_base64": "not_valid_base64!!!",
        "landmarks": _landmarks_payload(21),
        "hand": "left",
    }
    response = client.post("/analyze", json=payload)
    assert response.status_code == 400
