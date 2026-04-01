import base64

import numpy as np
import pytest

from cv_pipeline.preprocess import decode_image, preprocess_palm


class TestDecodeImage:
    def test_decode_image_valid(self, sample_image_base64: str):
        """Valid base64 JPEG decodes to a 3-channel BGR ndarray."""
        img = decode_image(sample_image_base64)
        assert isinstance(img, np.ndarray)
        assert img.ndim == 3
        assert img.shape[2] == 3

    def test_decode_image_preserves_dimensions(self, sample_image: np.ndarray, sample_image_base64: str):
        """Decoded image has same height and width as the original."""
        img = decode_image(sample_image_base64)
        assert img.shape[0] == sample_image.shape[0]  # height
        assert img.shape[1] == sample_image.shape[1]  # width

    def test_decode_image_invalid_base64_raises(self):
        """Non-base64 string raises ValueError."""
        with pytest.raises(ValueError, match="Invalid base64"):
            decode_image("not-valid-base64!!!")

    def test_decode_image_valid_base64_but_not_image_raises(self):
        """Valid base64 that doesn't encode an image raises ValueError."""
        garbage = base64.b64encode(b"this is not image data at all").decode()
        with pytest.raises(ValueError):
            decode_image(garbage)


class TestPreprocessPalm:
    def test_returns_expected_keys(self, sample_image: np.ndarray, sample_landmarks):
        result = preprocess_palm(sample_image, sample_landmarks)
        assert "gray" in result
        assert "edges" in result
        assert "roi_offset" in result
        assert "roi_size" in result
        assert "original_size" in result

    def test_gray_is_2d(self, sample_image: np.ndarray, sample_landmarks):
        """Gray output must be a 2D array (single channel)."""
        result = preprocess_palm(sample_image, sample_landmarks)
        assert result["gray"].ndim == 2

    def test_edges_is_2d_uint8(self, sample_image: np.ndarray, sample_landmarks):
        """Edge map must be 2D and uint8."""
        result = preprocess_palm(sample_image, sample_landmarks)
        edges = result["edges"]
        assert edges.ndim == 2
        assert edges.dtype == np.uint8

    def test_roi_offset_is_tuple_of_two_ints(self, sample_image: np.ndarray, sample_landmarks):
        """roi_offset should be a (x, y) tuple of non-negative ints."""
        result = preprocess_palm(sample_image, sample_landmarks)
        offset = result["roi_offset"]
        assert isinstance(offset, tuple)
        assert len(offset) == 2
        assert offset[0] >= 0
        assert offset[1] >= 0

    def test_roi_size_matches_gray_shape(self, sample_image: np.ndarray, sample_landmarks):
        """roi_size (w, h) must match the gray array's shape (h, w)."""
        result = preprocess_palm(sample_image, sample_landmarks)
        roi_w, roi_h = result["roi_size"]
        gray_h, gray_w = result["gray"].shape
        assert roi_w == gray_w
        assert roi_h == gray_h

    def test_original_size_matches_input(self, sample_image: np.ndarray, sample_landmarks):
        """original_size should equal (width, height) of input image."""
        result = preprocess_palm(sample_image, sample_landmarks)
        h, w = sample_image.shape[:2]
        assert result["original_size"] == (w, h)

    def test_gray_and_edges_same_shape(self, sample_image: np.ndarray, sample_landmarks):
        """Gray and edges arrays must have the same shape."""
        result = preprocess_palm(sample_image, sample_landmarks)
        assert result["gray"].shape == result["edges"].shape

    def test_edges_contains_nonzero_pixels(self, sample_image: np.ndarray, sample_landmarks):
        """Edges array should have some detected edge pixels (not all black)."""
        result = preprocess_palm(sample_image, sample_landmarks)
        assert np.any(result["edges"] > 0), "Expected some edge pixels in the palm ROI"
