"""Server-side hand landmark detection using MediaPipe Hands (Tasks API)."""

from __future__ import annotations

import os
import urllib.request
from pathlib import Path

import cv2
import numpy as np

from cv_pipeline.models import Landmark

# Official Google-hosted model — downloaded once and cached alongside this file.
_MODEL_URL = (
    "https://storage.googleapis.com/mediapipe-models/"
    "hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task"
)
_MODEL_PATH = Path(__file__).parent / "hand_landmarker.task"


def _ensure_model() -> str:
    """Return the local path to the model file, downloading it if needed."""
    if not _MODEL_PATH.exists():
        tmp = Path(str(_MODEL_PATH) + ".tmp")
        urllib.request.urlretrieve(_MODEL_URL, tmp)
        tmp.rename(_MODEL_PATH)
    return str(_MODEL_PATH)


def detect_hand_landmarks(image: np.ndarray) -> list[Landmark] | None:
    """Detect 21 hand landmarks using the MediaPipe HandLandmarker Tasks API.

    Parameters
    ----------
    image:
        BGR image as returned by :func:`~cv_pipeline.preprocess.decode_image`.

    Returns
    -------
    list[Landmark] | None
        A list of exactly 21 :class:`~cv_pipeline.models.Landmark` objects
        with normalized (0-1) coordinates, or ``None`` if no hand was found.
    """
    import mediapipe as mp  # lazy import — optional dependency

    BaseOptions = mp.tasks.BaseOptions
    HandLandmarker = mp.tasks.vision.HandLandmarker
    HandLandmarkerOptions = mp.tasks.vision.HandLandmarkerOptions
    RunningMode = mp.tasks.vision.RunningMode

    model_path = _ensure_model()

    options = HandLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=model_path),
        running_mode=RunningMode.IMAGE,
        num_hands=1,
        min_hand_detection_confidence=0.5,
        min_hand_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)

    with HandLandmarker.create_from_options(options) as landmarker:
        result = landmarker.detect(mp_image)

    if result.hand_landmarks:
        hand = result.hand_landmarks[0]  # first detected hand
        return [Landmark(x=lm.x, y=lm.y) for lm in hand]
    return None
