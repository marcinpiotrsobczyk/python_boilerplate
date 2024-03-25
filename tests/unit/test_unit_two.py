from __future__ import annotations

import logging

import pytest
from PIL import Image

from python_boilerplate.__private.one import get_hello_string


@pytest.mark.parametrize("mine_param", ["a", "b", "c"])
def test_case_one(some_string: str, mine_param: str) -> None:
    logging.error("from unit_two suite")
    logging.warning(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")
    logging.debug("example debug log")


@pytest.mark.parametrize("mine_param", ["x", "y", "z"])
def test_case_two(some_string: str, mine_param: str) -> None:
    logging.info("from unit_two suite")
    logging.info(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")


@pytest.mark.mymark()
def test_case_three() -> None:
    logging.info("from unit_two suite")
    img = Image.new(mode="RGB", size=(400, 300), color=(255, 0, 0))
    img.save("red-color-image.jpg")


def test_case_four() -> None:
    logging.info("from unit_two suite")
    s = get_hello_string()
    logging.warning(s)
