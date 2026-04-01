"""Tests for contour extraction from edge images."""

import cv2
import numpy as np
import pytest

from cv_pipeline.contour_extract import extract_line_candidates


def make_edge_image(shape=(200, 200)):
    """Return a blank uint8 edge image."""
    return np.zeros(shape, dtype=np.uint8)


class TestExtractLineCandidates:
    def test_finds_at_least_two_lines_from_three(self):
        """Synthetic image with 3 drawn lines → finds at least 2 candidates."""
        img = make_edge_image((300, 400))
        # Draw three distinct white lines (edges)
        cv2.line(img, (10, 50), (350, 55), 255, 2)
        cv2.line(img, (10, 120), (350, 125), 255, 2)
        cv2.line(img, (10, 200), (350, 205), 255, 2)
        candidates = extract_line_candidates(img, min_length=40)
        assert len(candidates) >= 2, f"Expected at least 2 candidates, got {len(candidates)}"

    def test_short_contours_filtered_out(self):
        """Short contours (below min_length) should not appear in results."""
        img = make_edge_image((200, 200))
        # Draw one short segment (length ~10) and one long segment (length ~200)
        cv2.line(img, (10, 50), (18, 52), 255, 1)   # short ~8px
        cv2.line(img, (10, 100), (190, 100), 255, 2)  # long ~180px
        candidates = extract_line_candidates(img, min_length=40)
        # Only the long line should remain
        assert len(candidates) >= 1
        lengths = [cv2.arcLength(c.reshape(-1, 1, 2).astype(np.int32), False) for c in candidates]
        for length in lengths:
            assert length >= 40, f"Short contour with length {length} should have been filtered"

    def test_sorted_by_length_descending(self):
        """Returned candidates must be ordered longest first."""
        img = make_edge_image((300, 400))
        # Draw lines of clearly different lengths
        cv2.line(img, (10, 50), (380, 50), 255, 2)   # ~370px
        cv2.line(img, (10, 120), (200, 120), 255, 2)  # ~190px
        cv2.line(img, (10, 200), (100, 200), 255, 2)  # ~90px
        candidates = extract_line_candidates(img, min_length=40)
        assert len(candidates) >= 2
        lengths = [cv2.arcLength(c.reshape(-1, 1, 2).astype(np.int32), False) for c in candidates]
        for i in range(len(lengths) - 1):
            assert lengths[i] >= lengths[i + 1], (
                f"Candidates not sorted: index {i} length {lengths[i]} < index {i+1} length {lengths[i+1]}"
            )

    def test_max_candidates_respected(self):
        """Number of returned candidates should not exceed max_candidates."""
        img = make_edge_image((400, 600))
        # Draw many lines
        for y in range(20, 380, 20):
            cv2.line(img, (10, y), (580, y), 255, 1)
        candidates = extract_line_candidates(img, min_length=10, max_candidates=5)
        assert len(candidates) <= 5

    def test_returns_list_of_ndarrays(self):
        """Each candidate should be an Nx2 numpy array."""
        img = make_edge_image((200, 300))
        cv2.line(img, (10, 50), (280, 55), 255, 2)
        candidates = extract_line_candidates(img, min_length=20)
        assert isinstance(candidates, list)
        for c in candidates:
            assert isinstance(c, np.ndarray)
            assert c.ndim == 2
            assert c.shape[1] == 2

    def test_empty_image_returns_empty(self):
        """An all-black (no-edge) image should return no candidates."""
        img = make_edge_image((200, 200))
        candidates = extract_line_candidates(img, min_length=10)
        assert candidates == []
