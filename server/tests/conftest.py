import base64
import cv2
import numpy as np
import pytest

from cv_pipeline.models import Landmark


@pytest.fixture
def sample_image() -> np.ndarray:
    """640x480 synthetic BGR image with drawn lines resembling a palm."""
    img = np.ones((480, 640, 3), dtype=np.uint8) * 200  # light gray background

    # Draw some lines to simulate palm lines
    # Heart line (curved, upper palm)
    pts_heart = np.array(
        [[100, 150], [200, 130], [320, 140], [440, 120], [540, 130]], dtype=np.int32
    )
    cv2.polylines(img, [pts_heart], isClosed=False, color=(80, 60, 50), thickness=3)

    # Head line (middle palm)
    pts_head = np.array(
        [[110, 220], [220, 210], [340, 215], [460, 200]], dtype=np.int32
    )
    cv2.polylines(img, [pts_head], isClosed=False, color=(70, 55, 45), thickness=2)

    # Life line (curved, lower palm)
    pts_life = np.array(
        [[200, 180], [190, 250], [185, 320], [190, 390], [205, 440]], dtype=np.int32
    )
    cv2.polylines(img, [pts_life], isClosed=False, color=(75, 58, 48), thickness=3)

    # Add some texture noise
    noise = np.random.randint(0, 20, img.shape, dtype=np.uint8)
    img = cv2.subtract(img, noise)

    return img


@pytest.fixture
def sample_image_base64(sample_image: np.ndarray) -> str:
    """Base64-encoded JPEG of the sample image."""
    success, encoded = cv2.imencode(".jpg", sample_image, [cv2.IMWRITE_JPEG_QUALITY, 90])
    assert success, "Failed to encode sample image to JPEG"
    return base64.b64encode(encoded.tobytes()).decode("utf-8")


@pytest.fixture
def sample_landmarks() -> list[Landmark]:
    """21 Landmark objects positioned like a real palm on a 640x480 image.

    Follows MediaPipe hand landmark order:
    0: wrist
    1-4: thumb (CMC -> tip)
    5-8: index finger (MCP -> tip)
    9-12: middle finger (MCP -> tip)
    13-16: ring finger (MCP -> tip)
    17-20: pinky (MCP -> tip)
    """
    # Normalized coordinates (x: 0-1, y: 0-1) for a right hand
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
    assert len(raw) == 21
    return [Landmark(x=x, y=y) for x, y in raw]
