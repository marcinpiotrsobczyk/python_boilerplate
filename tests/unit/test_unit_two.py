import logging

from PIL import Image
import pytest

from python_boilerplate.__private.one import get_hello_string


@pytest.mark.parametrize("mine_param", ["a", "b", "c"])
def test_case_one(some_string, mine_param) -> None:
    logging.error(f"from unit_two suite")
    logging.warning(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")
    logging.debug(f"example debug log")


@pytest.mark.parametrize("mine_param", ["x", "y", "z"])
def test_case_two(some_string, mine_param) -> None:
    logging.info(f"from unit_two suite")
    logging.info(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")


def test_case_three(some_string) -> None:
    logging.info(f"from unit_two suite")
    img  = Image.new(
        mode = "RGB",
        size = (400, 300),
        color = (255, 0, 0))
    img.save("red-color-image.jpg")


def test_case_four(some_string) -> None:
    logging.info(f"from unit_two suite")
    str = get_hello_string()
    logging.warning(str)
