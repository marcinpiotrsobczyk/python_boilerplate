from __future__ import annotations

import logging

import pytest


@pytest.mark.parametrize("mine_param", ["d", "e", "f"])
def test_case_one(some_string: str, mine_param: str) -> None:
    logging.info("from functional_one suite")
    logging.info(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")


@pytest.mark.parametrize("mine_param", ["u", "v", "w"])
def test_case_two(some_string: str, mine_param: str) -> None:
    logging.info("from functional_one suite")
    logging.info(f"fixture first: {some_string}")
    logging.info(f"fixture second: {mine_param}")
