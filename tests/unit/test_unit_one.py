import logging

import pytest


@pytest.mark.parametrize("mine_param", ["a", "b", "c"])
def test_case_one(some_string, mine_param) -> None:
    logging.error(f"from unit_one suite")
    logging.warning(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")
    logging.debug(f"example debug log")


@pytest.mark.parametrize("mine_param", ["x", "y", "z"])
def test_case_two(some_string, mine_param) -> None:
    logging.info(f"from unit_one suite")
    logging.info(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")
