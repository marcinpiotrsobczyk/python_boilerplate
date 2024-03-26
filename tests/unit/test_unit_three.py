from __future__ import annotations

import logging
import warnings
from pathlib import Path

import pytest
from bs4 import BeautifulSoup, XMLParsedAsHTMLWarning


@pytest.mark.skip(reason="gives warning")
def test_case_beautifulsoup() -> None:
    warnings.filterwarnings("ignore", category=XMLParsedAsHTMLWarning)

    logging.error("from unit_one suite")
    example_file_path = Path(__file__).parent / "example.xml"
    with Path.open(example_file_path) as file:
        soup = BeautifulSoup(file)

    logging.debug(soup.prettify())


def test_case_beautifulsoup_htmlparser() -> None:
    warnings.filterwarnings("ignore", category=XMLParsedAsHTMLWarning)
    logging.error("from unit_one suite")
    example_file_path = Path(__file__).parent / "example.xml"
    with Path.open(example_file_path) as file:
        soup = BeautifulSoup(file, features="lxml")

    logging.debug(soup.prettify())
