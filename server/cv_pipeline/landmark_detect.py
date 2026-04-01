"""Server-side hand landmark detection using MediaPipe Hands (Solutions API)."""

from __future__ import annotations

import cv2
import numpy as np

from cv_pipeline.models import Landmark


def detect_hand_landmarks(image: np.ndarray) -> list[Landmark] | None:
    """Detect 21 hand landmarks using the MediaPipe Hands Solutions API.

    Uses the legacy mp.solutions.hands API which works on CPU without
    OpenGL/GPU dependencies (unlike the newer Tasks API).

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
    import mediapipe as mp

    mp_hands = mp.solutions.hands

    with mp_hands.Hands(
        static_image_mode=True,
        max_num_hands=1,
        min_detection_confidence=0.5,
    ) as hands:
        rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(rgb)

        if results.multi_hand_landmarks:
            hand = results.multi_hand_landmarks[0]
            return [Landmark(x=lm.x, y=lm.y) for lm in hand.landmark]

    return None
